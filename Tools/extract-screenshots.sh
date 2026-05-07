#!/usr/bin/env bash
#
# Extracts XCTAttachment screenshots from the most recent UI test xcresult
# bundle (or all recent bundles) into ./Tools/out/ux-journey/.
#
# Uses xcresulttool's modern `get test-results activities` API.
#
# Usage:
#   ./Tools/extract-screenshots.sh           # latest bundle only
#   ./Tools/extract-screenshots.sh --all     # walk all recent bundles
#

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Tools/out/ux-journey"
mkdir -p "$OUT"

DERIVED="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_DERIVED=$(ls -dt "$DERIVED"/BaekSoeum-* 2>/dev/null | head -1)
if [[ -z "$PROJECT_DERIVED" ]]; then
  echo "no DerivedData for BaekSoeum found; run a UI test first" >&2
  exit 1
fi

# Pick which xcresult bundles to walk.
if [[ "${1:-}" == "--all" ]]; then
  BUNDLES=$(ls -dt "$PROJECT_DERIVED"/Logs/Test/*.xcresult 2>/dev/null | head -5)
else
  BUNDLES=$(ls -dt "$PROJECT_DERIVED"/Logs/Test/*.xcresult 2>/dev/null | head -1)
fi

if [[ -z "$BUNDLES" ]]; then
  echo "no .xcresult bundle in $PROJECT_DERIVED/Logs/Test/" >&2
  exit 1
fi

extract() {
  local bundle="$1"
  echo "scanning: $bundle"

  # List all test ids in this bundle.
  local tests
  tests=$(xcrun xcresulttool get test-results tests --path "$bundle" 2>/dev/null \
    | python3 -c "
import json, sys
d = json.load(sys.stdin)
ids = []
def walk(n):
    if isinstance(n, dict):
        if 'nodeIdentifier' in n: ids.append(n['nodeIdentifier'])
        for v in n.values(): walk(v)
    elif isinstance(n, list):
        for i in n: walk(i)
walk(d)
for i in ids: print(i)
")

  for tid in $tests; do
    # Skip targets / suites; only run leaf test methods (have parens).
    [[ "$tid" == *"()" ]] || continue
    echo "  test: $tid"

    xcrun xcresulttool get test-results activities --path "$bundle" --test-id "$tid" 2>/dev/null \
      | python3 -c "
import json, sys, subprocess, os
d = json.load(sys.stdin)
out = os.environ['OUT']
bundle = os.environ['BUNDLE']
attachments = []
def walk(n):
    if isinstance(n, dict):
        if 'attachments' in n and isinstance(n['attachments'], list):
            for a in n['attachments']:
                if isinstance(a, dict):
                    name = a.get('name', '')
                    pl = a.get('payloadId', '')
                    if name and pl: attachments.append((name, pl))
        for v in n.values(): walk(v)
    elif isinstance(n, list):
        for i in n: walk(i)
walk(d)
for name, pl in attachments:
    # Names look like '01-ios-default_0_<UUID>.png' -- strip the suffix.
    base = name.split('.png')[0]
    base = '_'.join(base.split('_')[:-2]) if '_0_' in name else base
    out_path = os.path.join(out, base + '.png')
    with open(out_path, 'wb') as f:
        subprocess.run(
            ['xcrun','xcresulttool','get','--legacy','--path',bundle,'--id',pl],
            stdout=f, check=True
        )
    print(f'    saved {out_path}')
" 2>&1 || true

  done

  export -n BUNDLE
}

for bundle in $BUNDLES; do
  export BUNDLE="$bundle"
  export OUT
  extract "$bundle"
done

echo
echo "screenshots saved to: $OUT"
ls -1 "$OUT" | sort
