#!/usr/bin/env bash
#
# Copies rendered PNGs from out/ into the app's Asset Catalog and writes
# the surrounding Contents.json files.
#
# Usage:
#   cd Tools/RenderIcon
#   swift run RenderIcon
#   ./install.sh
#

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/Tools/RenderIcon/out"
ASSETS="$ROOT/App/Resources/Assets.xcassets"
BRAND="$ASSETS/AppIcon.brandassets"

if [[ ! -f "$OUT/ios/Icon-1024.png" ]]; then
  echo "missing rendered PNGs in $OUT — run 'swift run RenderIcon' first" >&2
  exit 1
fi

# ---- iOS ------------------------------------------------------------------

mkdir -p "$ASSETS/AppIcon.appiconset"
cp "$OUT/ios/Icon-1024.png" "$ASSETS/AppIcon.appiconset/Icon-1024.png"

cat > "$ASSETS/AppIcon.appiconset/Contents.json" <<'JSON'
{
  "images" : [
    {
      "filename" : "Icon-1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

# ---- tvOS Brand Assets ----------------------------------------------------

rm -rf "$BRAND"
mkdir -p "$BRAND"

cat > "$BRAND/Contents.json" <<'JSON'
{
  "assets" : [
    { "filename" : "App Icon - Small.imagestack", "idiom" : "tv", "role" : "primary-app-icon", "size" : "400x240" },
    { "filename" : "App Icon - Large.imagestack", "idiom" : "tv", "role" : "primary-app-icon", "size" : "1280x768" },
    { "filename" : "Top Shelf Image.imageset",    "idiom" : "tv", "role" : "top-shelf-image" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

build_imagestack() {
  local stack_name="$1"     # "App Icon - Small.imagestack"
  local size_label="$2"     # "small" or "large"
  local stack_dir="$BRAND/$stack_name"

  mkdir -p "$stack_dir"

  cat > "$stack_dir/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "layers" : [
    { "filename" : "Front.imagestacklayer" },
    { "filename" : "Middle.imagestacklayer" },
    { "filename" : "Back.imagestacklayer" }
  ]
}
JSON

  for layer in Back Middle Front; do
    local layer_lower
    layer_lower=$(echo "$layer" | tr '[:upper:]' '[:lower:]')
    local layer_dir="$stack_dir/$layer.imagestacklayer"
    local content_dir="$layer_dir/Content.imageset"
    mkdir -p "$content_dir"

    cat > "$layer_dir/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

    cp "$OUT/tvos/${size_label}_${layer_lower}.png" "$content_dir/${layer_lower}.png"

    cat > "$content_dir/Contents.json" <<JSON
{
  "images" : [
    { "filename" : "${layer_lower}.png", "idiom" : "tv", "scale" : "1x" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
  done
}

build_imagestack "App Icon - Small.imagestack" "small"
build_imagestack "App Icon - Large.imagestack" "large"

# Top Shelf
TS_DIR="$BRAND/Top Shelf Image.imageset"
mkdir -p "$TS_DIR"
cp "$OUT/tvos/top_shelf.png" "$TS_DIR/top_shelf.png"
cat > "$TS_DIR/Contents.json" <<'JSON'
{
  "images" : [
    { "filename" : "top_shelf.png", "idiom" : "tv", "scale" : "1x" }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON

echo "installed:"
echo "  iOS:  $ASSETS/AppIcon.appiconset/"
echo "  tvOS: $BRAND/"
