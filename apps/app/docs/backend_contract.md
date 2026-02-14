# Backend Contract

This document is the frontend binding contract for `apps/app`.
Do not change backend schema/settings from this app project.

## Source of truth

- `supabase/schema.sql`
- `supabase/migrations/*.sql`
- `docs/frontend-contracts.md`
- `config/security/edge-auth-contract.json`

## Tables used in app

- `public.ride_requests`
- `public.rides`
- `public.driver_locations`
- `public.fare_quotes`
- `public.profiles`
- `public.ride_products`
- `public.customer_addresses`

## Rider RPCs used/scaffolded

- `get_my_app_context()`
- `set_my_active_role(p_role public.user_role)`
- `cancel_ride_request(p_request_id uuid)`
- `drivers_nearby_user_v1(...)`
- `dispatch_match_ride_user(...)`
- `transition_ride_user_v1(...)`
- `wallet_get_my_account()`

## Edge Functions used/scaffolded

- `fare-engine`
- `match-ride`
- `ride-transition`
- `maps-config-v2`
- `maps-usage`
- `geo`
- `ably-token`
- `device-token-upsert`
- `profile-avatar-url` (action: `download` for rider avatar display)

All names are centralized in:
`lib/data/supabase/schema_contract.dart`

## Realtime channels and sources

- Postgres Changes:
  - `public.ride_requests`
  - `public.rides`
  - `public.driver_locations`
- Broadcast patterns:
  - `nearby:gh6:<geohash6>`
  - `loc:driver:<userId>`

## Storage scaffolding

The app storage abstraction supports bucket/path upload, download, and signed URLs.
Current backend buckets visible from schema policy rules:

- `avatars`
- `chat-media`
- `driver-docs`
- `kyc-documents`

## How to adapt if backend differs

1. Update only constants in `lib/data/supabase/schema_contract.dart`.
2. Keep feature/domain code unchanged where possible.
3. Verify with:
   - `flutter analyze`
   - `flutter test`
4. Re-test OTP auth + ride request create/list/cancel + realtime.

## Auth expectations

- Phone OTP enabled in Supabase Auth.
- Frontend uses anon/publishable key only.
- Never use `service_role` or `sb_secret_*` in app defines.
- Signup role mapping:
  - UI `customer` -> backend `rider`
  - UI `driver` -> backend `driver`
  - UI `merchant` -> backend `merchant`

## Deep link expectations (frontend-side only)

Mobile placeholders:

- Android scheme: `com.rideiq.app.dev://auth-callback`
- iOS scheme: `com.rideiq.app://auth-callback`

Web callback placeholder route:

- `/auth/callback`

Update provider redirects in Supabase dashboard to match deployed domains.
