#!/bin/zsh
set -e
cd "$(dirname "$0")"
APP="build/研究账本.app"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 图标
if [ ! -f build/AppIcon.icns ]; then
  swiftc -O makeicon.swift -o build/makeicon
  ./build/makeicon build/icon.png
  rm -rf build/AppIcon.iconset; mkdir build/AppIcon.iconset
  for s in 16 32 128 256 512; do
    sips -z $s $s build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
    sips -z $((s*2)) $((s*2)) build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
  done
  iconutil -c icns build/AppIcon.iconset -o build/AppIcon.icns
fi

swiftc -O -parse-as-library -swift-version 5 -target arm64-apple-macos14.0 \
  -framework SwiftUI -framework AppKit Sources/*.swift \
  -o "$APP/Contents/MacOS/Ledger"
cp Info.plist "$APP/Contents/"
cp build/AppIcon.icns "$APP/Contents/Resources/"
codesign --force --sign - "$APP" >/dev/null 2>&1
echo "built: $APP"
