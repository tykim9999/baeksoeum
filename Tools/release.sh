#!/usr/bin/env bash
#
# Build TestFlight archives for iOS (and tvOS if profile is available),
# export App-Store-signed .ipa(s) ready for upload.
#
#   ./Tools/release.sh           # build both, fall through tvOS if profile missing
#   ./Tools/release.sh ios       # iOS only
#   ./Tools/release.sh tvos      # tvOS only (requires Apple TV UDID registered in dev portal)
#
# Output:
#   build/release/BaekSoeum-iOS.xcarchive
#   build/release/iOS/BaekSoeum.ipa
#   (and tvOS equivalents if successful)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release"
TEAM_ID="L324XMPY22"
SCHEME="BaekSoeum"

mkdir -p "$OUT"

archive_export() {
  local platform="$1"            # iOS | tvOS
  local destination="$2"         # generic/platform=iOS
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

target="${1:-both}"

case "$target" in
  ios|both)
    archive_export iOS "generic/platform=iOS" || echo "[iOS] failed"
    ;;
esac

case "$target" in
  tvos|both)
    if ! archive_export tvOS "generic/platform=tvOS"; then
      cat <<HINT

[tvOS] Archive failed. Most common reason: no tvOS device registered in the
       developer account, so Apple cannot auto-create a tvOS Development
       provisioning profile.

  Fix: register your Apple TV's UDID at
       https://developer.apple.com/account/resources/devices/list
       Find UDID via: Settings -> General -> About -> tap-and-hold tvOS
       Version, OR connect Apple TV to Xcode via wired Apple TV (Devices
       and Simulators window).

  Workaround: ship iOS-only to family for now (the iOS .ipa is ready);
       add tvOS in a follow-up release.
HINT
    fi
    ;;
esac

echo
echo "Outputs in $OUT/"
ls -la "$OUT" 2>/dev/null
