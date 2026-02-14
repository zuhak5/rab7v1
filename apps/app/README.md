# RideIQ Flutter App (`apps/app`)

Production-oriented Flutter frontend for RideIQ rider workflows.

## Stack

- Flutter (target: 3.41.x via FVM)
- Dart null safety
- Riverpod (state management + DI)
- GoRouter (declarative routing)
- Supabase (`supabase_flutter`)
- Multi-provider maps:
  - Google (`google_maps_flutter`)
  - Mapbox / HERE / Thunderforest (`flutter_map` tile renderer)
  - ORS handled as backend geo provider (not direct renderer)

## Environment defines

Pass values with `--dart-define`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (anon/publishable only)
- `APP_ENV` (`dev|prod`)
- `LOG_LEVEL` (`debug|info|warning|error`)

Example shared flags:

```bash
--dart-define=SUPABASE_URL=https://<project>.supabase.co \
--dart-define=SUPABASE_ANON_KEY=<anon-key> \
--dart-define=APP_ENV=dev \
--dart-define=LOG_LEVEL=debug
```

## FVM setup (recommended)

```bash
cd apps/app
dart pub global activate fvm
fvm use 3.41.0
fvm flutter --version
```

> `.fvmrc` pins `3.41.0`.

## Run commands (from `apps/app`)

### Android

```bash
fvm flutter run --flavor dev -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=dev \
  --dart-define=LOG_LEVEL=debug
```

### iOS

```bash
fvm flutter run -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=dev \
  --dart-define=LOG_LEVEL=debug
```

### Web (clean URLs, no hash)

```bash
fvm flutter run -d chrome -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=dev \
  --dart-define=LOG_LEVEL=debug
```

## Build / release commands

### Analyze + tests

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

### Android APK / AAB

```bash
fvm flutter build apk --release --flavor prod -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=prod \
  --dart-define=LOG_LEVEL=info \
  --tree-shake-icons

fvm flutter build appbundle --release --flavor prod -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=prod \
  --dart-define=LOG_LEVEL=info \
  --tree-shake-icons
```

### iOS archive / IPA

```bash
fvm flutter build ios --release -t lib/main.dart \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=prod \
  --dart-define=LOG_LEVEL=info \
  --tree-shake-icons
```

### Web release (PWA service worker disabled)

```bash
fvm flutter build web --release --pwa-strategy=none \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=prod \
  --dart-define=LOG_LEVEL=info \
  --tree-shake-icons
```

### Web Wasm build

```bash
fvm flutter build web --wasm --release --pwa-strategy=none \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=APP_ENV=prod \
  --dart-define=LOG_LEVEL=info \
  --tree-shake-icons
```

Renderer guidance:

- `canvaskit`: better visual consistency and map-heavy rendering.
- `skwasm` (`--wasm`): smaller JS and faster startup in modern browsers.

## Auth flow

- Phone OTP (`signInWithOtp` + `verifyOTP`)
- Session bootstrap/restore on startup
- `onAuthStateChange` listener
- Fail-closed guarded routing:
  - signed out -> `/auth/login`
  - signed in + app context unresolved/error -> `/auth/bootstrap`
  - signed in + context ready -> `/rides` (or onboarding routes)

Deep-link scaffolding:

- Android callback intent filter configured with placeholder scheme.
- iOS callback URL scheme placeholder in `Info.plist`.
- Web callback placeholder route: `/auth/callback`.

### OTP troubleshooting

- If you get `phone_provider_disabled` / `Unsupported phone provider` from
  `POST /auth/v1/otp`, Phone auth is not enabled in Supabase Auth.
- If you get `hook_timeout` but OTP arrives anyway, Supabase timed out waiting
  for the SMS hook (5s max) even though provider delivery eventually succeeded.
  The login screen now lets users continue to OTP verification on this error.
- For backend tuning, the SMS provider chain in `supabase/functions/_shared/smsProviders.ts`
  supports:
  - `SMS_PROVIDER_TIMEOUT_MS` (per provider attempt)
  - `SMS_HOOK_TOTAL_TIMEOUT_MS` (total fallback budget)
- If OTP is received but UI does not advance, confirm:
  - request is redirected to `/auth/otp?phone=...`
  - app context bootstrap (`/auth/bootstrap`) is healthy and can load `get_my_app_context`.

## Rider vertical slice implemented

- Home screen sample-parity shell (`390x844`) with live map and provider failover
- Map runtime is backend-driven via (selection + fallback from backend):
  - `maps-config-v2` (provider selection + fallback order + telemetry token)
  - `maps-usage` (render success/failure metering)
  - `geo` wrapper methods are wired in `EdgeFunctionsClient` for route/geocode flows
- Backend-bound wallet + avatar + saved Home/Work places:
  - `rpc(wallet_get_my_account)`
  - `profiles.avatar_object_key` + edge `profile-avatar-url` (`download`)
  - `customer_addresses` (`home`, `work`)
- Trip options flow:
  - select offer + payment
  - invoke `fare-engine`
  - insert into `ride_requests` with `fare_quote_id`, `product_code`, `payment_method`
- Finding driver flow:
  - realtime status from `ride_requests` + `rides`
  - cancel via `cancel_ride_request`
- Activity screen bound to ride request history

## Maps CORS / origin allowlist

`maps-config-v2` and `geo` are Edge Functions and must allow the web origin.

Set these in Supabase Edge Function environment:

- `CORS_ALLOW_ORIGINS=https://rab7v1.vercel.app,http://localhost:3000,http://localhost:5173`
- `APP_ORIGIN=https://rab7v1.vercel.app`

Notes:

- `CORS_ALLOW_ORIGINS` should include every browser origin that will call the functions.
- After updating env vars, redeploy relevant functions and retest browser preflight.

## Backend contract updates

If backend table/column/function names differ, update only:

- `lib/data/supabase/schema_contract.dart`

Then re-run:

```bash
fvm flutter analyze
fvm flutter test
```

See full mapping in `docs/backend_contract.md`.

## Web SPA + Vercel deployment

### Required files

- `vercel.json` must be in `apps/app`
- web output directory: `build/web`

### Deploy steps

1. Build web:
   ```bash
   cd apps/app
   fvm flutter build web --release --pwa-strategy=none ...dart-defines...
   ```
2. In Vercel project settings:
   - Root Directory: `apps/app`
   - Build Command:
     ```bash
     bash scripts/vercel_build.sh
     ```
   - Output Directory: `build/web`
3. Ensure rewrite fallback is active (already in `vercel.json`).
4. Validate SPA routing:
   - open a deep URL directly, e.g. `/rides`
   - confirm page loads without 404 and app route renders.

Required Vercel environment variables:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `APP_ENV` (recommended: `prod`)
- `LOG_LEVEL` (recommended: `info`)

## PWA install + update strategy

This project intentionally disables Flutter service worker at build time:

- Use `--pwa-strategy=none`
- `index.html` served with `no-store`
- hashed assets served immutable

Result: users get fresh HTML on reload while static hashed assets remain cache-efficient.

## Mobile flavors and IDs

### Android

- `dev` flavor:
  - `applicationId = com.rideiq.app.dev`
  - app name: `RideIQ Dev`
- `prod` flavor:
  - `applicationId = com.rideiq.app`
  - app name: `RideIQ`

### iOS (placeholder config)

- Debug uses dev placeholders via `ios/Flutter/FlavorDev.xcconfig`
- Release uses prod placeholders via `ios/Flutter/FlavorProd.xcconfig`

Replace placeholders with final bundle IDs before store release.

## Icons and splash scaffolding

Tooling config is in `pubspec.yaml`:

- `flutter_launcher_icons`
- `flutter_native_splash`

Assets placeholders:

- `assets/branding/app_icon.png`
- `assets/branding/splash_logo.png`

Generate assets:

```bash
fvm flutter pub run flutter_launcher_icons
fvm dart run flutter_native_splash:create
```

## Permissions scaffolding

### Android

Configured in `android/app/src/main/AndroidManifest.xml`:

- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `POST_NOTIFICATIONS`

### iOS

Configured in `ios/Runner/Info.plist`:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- Background modes: `remote-notification`, `location`, `fetch`

## Push scaffolding (FCM)

Code structure:

- `lib/features/notifications/presentation/notification_bootstrap.dart`
- `lib/features/notifications/data/fcm_device_token_registrar.dart`

Setup required before production push:

1. Add Firebase project files:
   - Android `google-services.json`
   - iOS `GoogleService-Info.plist`
2. Configure Firebase initialization and platform entitlements.
3. Verify token registration against `device-token-upsert` function.

## CI example

A minimal workflow is provided at:

- `docs/ci_example.yml`

Move it to `.github/workflows/` if repository policy allows.

## Browser console triage

Non-blocking warnings you may see:

- Google Maps SDK warning about non-passive `mousewheel` listener.
- Browser extension logs (e.g., Amplitude/content script) not originating from this app.

Actionable app errors:

- `Null check operator used on a null value` from `main.dart.js` (must be fixed in app code).
- CORS errors for `maps-config-v2` / `geo` from `https://rab7v1.vercel.app` (fix function allowlist/env).
