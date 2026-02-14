# Rider Flow Parity QA

## Source Of Truth
- UI reference: `apps/page samples/home_mobile_first.html`
- Trip reference: `apps/page samples/trip_options.html`
- Finding driver reference: `apps/page samples/finding_driver.html`
- Target screen size: `390x844`
- Strict diff scope: all UI chrome, sheets, cards, pills, text rhythm, and transitions
- Excluded from strict diff: live map tile texture only

## Golden Matrix
- `rider_home_default_light.png`
- `rider_home_default_dark.png`
- `rider_home_account_sheet_open.png`
- `rider_home_pickup_sheet_search.png`
- `rider_home_schedule_panel_open.png`
- `rider_home_place_edit_open.png`
- `trip_options_default.png`
- `finding_driver_default.png`

## Auth Matrix (Manual + Widget)
- Splash
- Login (sign in mode)
- Login (sign up mode)
- OTP verification
- Role selection
- Profile setup
- Forgot password
- Reset password

## Commands
From `apps/app`:

```bash
flutter test test/features/rider_home/presentation/rider_home_golden_test.dart
```

Re-baseline (intentional visual change only):

```bash
flutter test test/features/rider_home/presentation/rider_home_golden_test.dart --update-goldens
```

Auth flow widget tests:

```bash
flutter test test/features/auth/presentation
```

## Manual Overlay QA
1. Capture reference screenshots from the sample HTML files for each state.
2. Run Flutter web/mobile at `390x844`.
3. Compare state-by-state:
   - header pill, marker placement, main sheet geometry
   - destination/schedule controls
   - account/pickup/place-edit overlays
   - recents/offers/bottom nav
   - trip options card metrics, payment row, CTA alignment
   - finding-driver timeline geometry and terminal states
   - auth pages using the same rounded sheet/pill language
4. Ignore map tile visual differences only.
5. If mismatch is outside map texture, update Flutter UI, then re-run goldens.

## Accessibility + Motion Checks
1. Validate `Esc` closes open popovers/sheets on web.
2. Validate focus stays in active interactive surface.
3. Validate reduced-motion environments still work without layout breakage.
