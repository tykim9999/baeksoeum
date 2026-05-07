#!/usr/bin/env bash
#
# One-command archive + upload for TestFlight.
#
#   ./Tools/release.sh ios            # archive + export iOS .ipa
#   ./Tools/release.sh tvos           # archive + export tvOS .ipa
#   ./Tools/release.sh both           # both
#   ./Tools/release.sh upload-ios     # upload last-built iOS .ipa to App Store Connect
#   ./Tools/release.sh upload-tvos    # upload last-built tvOS .ipa
#   ./Tools/release.sh ship-ios       # archive + export + upload iOS in one shot
#   ./Tools/release.sh ship-tvos      # same for tvOS
#   ./Tools/release.sh status         # list recent builds via App Store Connect API
#   ./Tools/release.sh testers        # list internal testers
#   ./Tools/release.sh apps           # list all apps in your team
#   ./Tools/release.sh invite <email> [<first> <last>]
#
# Upload requires APPLE_ID and APPLE_APP_PASSWORD env vars. APPLE_ID is the
# Apple Developer Program account (tykim890813@gmail.com per team L324XMPY22),
# NOT a public contact email. APPLE_APP_PASSWORD is an App-Specific Password
# generated at https://appleid.apple.com/account/manage. Add to ~/.zshrc:
#
#   export APPLE_ID="tykim890813@gmail.com"
#   export APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
#

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release"
TEAM_ID="L324XMPY22"
SCHEME="BaekSoeum"

mkdir -p "$OUT"

archive_export() {
  local platform="$1"
  local destination="$2"
  local method_dir="$OUT/$platform"
  local archive_path="$OUT/BaekSoeum-${platform}.xcarchive"
  local opts_path="$OUT/exportOptions-${platform}.plist"

  echo "==> [$platform] Archiving"
  xcodebuild archive \
    -project "$ROOT/BaekSoeum.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -destination "$destination" \
    -archivePath "$archive_path" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=$TEAM_ID \
    | grep -E "error:|warning:|ARCHIVE" | grep -v "ld: warning"

  if [[ ! -d "$archive_path" ]]; then
    echo "[$platform] ARCHIVE FAILED"
    return 1
  fi

  cat > "$opts_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

  echo "==> [$platform] Exporting App-Store-signed .ipa"
  xcodebuild -exportArchive \
    -archivePath "$archive_path" \
    -exportPath "$method_dir" \
    -exportOptionsPlist "$opts_path" \
    -allowProvisioningUpdates \
    | grep -E "error:|warning:|EXPORT" | grep -v "ld: warning"

  if [[ -f "$method_dir/BaekSoeum.ipa" ]]; then
    echo "[$platform] OK -> $method_dir/BaekSoeum.ipa ($(du -h "$method_dir/BaekSoeum.ipa" | cut -f1))"
  fi
}

upload() {
  local platform="$1"     # ios | tvos
  local ipa="$OUT/${platform}/BaekSoeum.ipa"
  # Note: xcrun altool's --type uses the lowercase short forms 'ios' and 'tvos'.
  local altool_type="$platform"

  if [[ ! -f "$ipa" ]]; then
    echo "missing $ipa -- run './Tools/release.sh $platform' first" >&2
    return 1
  fi

  if [[ -z "${APPLE_ID:-}" || -z "${APPLE_APP_PASSWORD:-}" ]]; then
    cat <<HELP >&2
Missing credentials. Set in your shell (or ~/.zshrc):

  export APPLE_ID="<your-apple-id-email>"
  export APPLE_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"

Generate the App-Specific Password at:
  https://appleid.apple.com/account/manage
  -> Sign-In and Security -> App-Specific Passwords -> Generate
HELP
    return 1
  fi

  # Use @env: form so the password is read from the environment, not argv.
  # Argv-form passwords leak via `ps`, shell history, and process snapshots.
  echo "==> Validating $platform .ipa"
  if ! xcrun altool --validate-app -f "$ipa" --type "$altool_type" \
       -u "$APPLE_ID" -p "@env:APPLE_APP_PASSWORD" 2>&1 | tail -10; then
    echo "[$platform] VALIDATION FAILED" >&2
    return 1
  fi

  echo "==> Uploading $platform .ipa to App Store Connect"
  xcrun altool --upload-app -f "$ipa" --type "$altool_type" \
    -u "$APPLE_ID" -p "@env:APPLE_APP_PASSWORD" 2>&1 | tail -5

  echo
  echo "Build is now processing in App Store Connect (~5-15 min)."
  echo "  https://appstoreconnect.apple.com -> My Apps -> TestFlight tab"
}

case "${1:-help}" in
  ios)              archive_export iOS  "generic/platform=iOS"  ;;
  tvos)             archive_export tvOS "generic/platform=tvOS" ;;
  both)
    archive_export iOS  "generic/platform=iOS"  || true
    archive_export tvOS "generic/platform=tvOS" || true
    ;;
  upload-ios)       upload ios  ;;
  upload-tvos)      upload tvos ;;
  ship-ios)
    archive_export iOS  "generic/platform=iOS" && upload ios
    ;;
  ship-tvos)
    archive_export tvOS "generic/platform=tvOS" && upload tvos
    ;;
  status)           "$ROOT/Tools/asc.py" builds com.tykim.baeksoeum.BaekSoeum ;;
  testers)          "$ROOT/Tools/asc.py" testers ;;
  apps)             "$ROOT/Tools/asc.py" apps ;;
  invite)
    shift
    "$ROOT/Tools/asc.py" invite com.tykim.baeksoeum.BaekSoeum "$@"
    ;;
  help|*)
    sed -n '3,30p' "$0"
    ;;
esac

echo
echo "Outputs in $OUT/"
ls -la "$OUT" 2>/dev/null
