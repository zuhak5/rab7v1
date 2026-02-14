#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${SUPABASE_URL:-}" ]]; then
  echo "Missing required env var: SUPABASE_URL"
  exit 1
fi

if [[ -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "Missing required env var: SUPABASE_ANON_KEY"
  exit 1
fi

FLUTTER_DIR="${PWD}/.flutter"

if [[ ! -d "${FLUTTER_DIR}" ]]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter pub get

flutter build web --release --pwa-strategy=none \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
  --dart-define=APP_ENV="${APP_ENV:-prod}" \
  --dart-define=LOG_LEVEL="${LOG_LEVEL:-info}" \
  --tree-shake-icons

# Keep a no-op self-unregistering worker at the same URL to clean up any
# previously registered Flutter service workers from older deployments.
cat > build/web/flutter_service_worker.js <<'INNER_EOF'
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
  event.waitUntil(
    self.registration.unregister().then(() => self.clients.matchAll()).then((clients) => {
      for (const client of clients) {
        client.navigate(client.url);
      }
    }),
  );
});
INNER_EOF
