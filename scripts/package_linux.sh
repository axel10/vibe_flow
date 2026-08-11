#!/usr/bin/env bash

set -euo pipefail

APP_NAME="Vynody"
APP_ID="io.github.axel10.vynody"
APP_SLUG="vynody"
BINARY_NAME="vynody"
APP_DESCRIPTION="Cross-platform music player built with Flutter"
APP_VENDOR="Vynody"
APP_LICENSE="GPL-3.0-or-later"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="${BUNDLE_DIR:-$ROOT_DIR/build/linux/x64/release/bundle}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/build/linux/packages}"
STAGE_DIR="$OUTPUT_DIR/stage"
ICON_SOURCE="${ICON_SOURCE:-$ROOT_DIR/assets/images/icon-windows-and-linux.png}"
RAW_VERSION="${VERSION:-$(sed -n 's/^version:[[:space:]]*//p' "$ROOT_DIR/pubspec.yaml" | head -n 1)}"
VERSION="${RAW_VERSION//+/-}"

if [[ -z "$VERSION" ]]; then
  echo "Failed to determine version from pubspec.yaml" >&2
  exit 1
fi

if [[ ! -d "$BUNDLE_DIR" ]]; then
  echo "Bundle directory not found: $BUNDLE_DIR" >&2
  exit 1
fi

if [[ ! -f "$BUNDLE_DIR/$BINARY_NAME" ]]; then
  echo "Linux runner binary not found: $BUNDLE_DIR/$BINARY_NAME" >&2
  exit 1
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Icon not found: $ICON_SOURCE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -rf "$STAGE_DIR"

INSTALL_ROOT="$STAGE_DIR/opt/$APP_SLUG"
BIN_DIR="$STAGE_DIR/usr/bin"
APPLICATIONS_DIR="$STAGE_DIR/usr/share/applications"
ICON_DIR="$STAGE_DIR/usr/share/icons/hicolor/512x512/apps"

mkdir -p "$INSTALL_ROOT" "$BIN_DIR" "$APPLICATIONS_DIR" "$ICON_DIR"
cp -a "$BUNDLE_DIR/." "$INSTALL_ROOT/"
install -m 0644 "$ICON_SOURCE" "$ICON_DIR/$APP_SLUG.png"

cat > "$BIN_DIR/$APP_SLUG" <<EOF
#!/bin/sh
exec /opt/$APP_SLUG/$BINARY_NAME "\$@"
EOF
chmod 0755 "$BIN_DIR/$APP_SLUG"

cat > "$APPLICATIONS_DIR/$APP_ID.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=/usr/bin/$APP_SLUG
Icon=$APP_SLUG
Terminal=false
StartupNotify=true
Categories=AudioVideo;Audio;Player;
StartupWMClass=$APP_ID
EOF

DEB_ARCH="$(dpkg --print-architecture)"
RPM_ARCH="$(uname -m)"

DEB_DEPENDENCIES=(
  "libasound2"
  "libc6"
  "libgcc-s1"
  "libglib2.0-0"
  "libgtk-3-0"
  "libstdc++6"
)

RPM_DEPENDENCIES=(
  "alsa-lib"
  "glib2"
  "gtk3"
  "libstdc++"
)

FPM_ARGS=(
  --force
  --input-type dir
  --chdir "$STAGE_DIR"
  --name "$APP_SLUG"
  --version "$VERSION"
  --description "$APP_DESCRIPTION"
  --maintainer "$APP_VENDOR"
  --vendor "$APP_VENDOR"
  --license "$APP_LICENSE"
  --url "https://github.com/${GITHUB_REPOSITORY:-axel10/vynody}"
)

FPM_DEB_DEP_ARGS=()
for dep in "${DEB_DEPENDENCIES[@]}"; do
  FPM_DEB_DEP_ARGS+=(--depends "$dep")
done

FPM_RPM_DEP_ARGS=()
for dep in "${RPM_DEPENDENCIES[@]}"; do
  FPM_RPM_DEP_ARGS+=(--depends "$dep")
done

fpm \
  --output-type deb \
  "${FPM_ARGS[@]}" \
  "${FPM_DEB_DEP_ARGS[@]}" \
  --architecture "$DEB_ARCH" \
  --package "$OUTPUT_DIR/${APP_SLUG}-linux-${VERSION}-${DEB_ARCH}.deb" \
  .

fpm \
  --output-type rpm \
  "${FPM_ARGS[@]}" \
  "${FPM_RPM_DEP_ARGS[@]}" \
  --architecture "$RPM_ARCH" \
  --rpm-os linux \
  --package "$OUTPUT_DIR/${APP_SLUG}-linux-${VERSION}-${RPM_ARCH}.rpm" \
  .

if command -v appimagetool >/dev/null 2>&1; then
  echo "Building AppImage..."
  APPIMAGE_STAGE_DIR="$OUTPUT_DIR/vynody.AppDir"
  rm -rf "$APPIMAGE_STAGE_DIR"
  mkdir -p "$APPIMAGE_STAGE_DIR"
  
  # Copy Flutter bundle contents to the root of the AppDir stage
  cp -a "$BUNDLE_DIR/." "$APPIMAGE_STAGE_DIR/"
  
  # Copy icon to the root of the AppDir stage
  cp "$ICON_SOURCE" "$APPIMAGE_STAGE_DIR/$APP_SLUG.png"
  
  # Create AppRun script at the root
  cat > "$APPIMAGE_STAGE_DIR/AppRun" <<EOF
#!/bin/sh
cd "\$(dirname "\$0")"
exec ./$BINARY_NAME "\$@"
EOF
  chmod 0755 "$APPIMAGE_STAGE_DIR/AppRun"
  
  # Create desktop file at the root
  cat > "$APPIMAGE_STAGE_DIR/$APP_ID.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=$BINARY_NAME
Icon=$APP_SLUG
Terminal=false
StartupNotify=true
Categories=AudioVideo;Audio;Player;
StartupWMClass=$APP_ID
EOF
  chmod 0644 "$APPIMAGE_STAGE_DIR/$APP_ID.desktop"
  
  # Build AppImage using appimagetool
  export APPIMAGE_EXTRACT_AND_RUN=1
  ARCH="$RPM_ARCH" appimagetool "$APPIMAGE_STAGE_DIR" "$OUTPUT_DIR/${APP_SLUG}-linux-${VERSION}-${RPM_ARCH}.AppImage"
  
  # Clean up staging directory
  rm -rf "$APPIMAGE_STAGE_DIR"
else
  echo "appimagetool not found, skipping AppImage packaging."
fi

DEB_PACKAGE="$OUTPUT_DIR/${APP_SLUG}-linux-${VERSION}-${DEB_ARCH}.deb"
if [[ -f "$DEB_PACKAGE" && -f "$ROOT_DIR/packaging/aur/PKGBUILD.in" ]]; then
  echo "Generating AUR package files (PKGBUILD and .SRCINFO)..."
  AUR_DIR="$OUTPUT_DIR/aur"
  DEB_SHA256="$(sha256sum "$DEB_PACKAGE" | awk '{print $1}')"
  bash "$ROOT_DIR/scripts/generate_aur_package.sh" "$VERSION" "$DEB_SHA256" "$AUR_DIR"
fi

echo "Linux packages created:"
ls -1 "$OUTPUT_DIR"/*.deb "$OUTPUT_DIR"/*.rpm "$OUTPUT_DIR"/*.AppImage 2>/dev/null || ls -1 "$OUTPUT_DIR"/*.deb "$OUTPUT_DIR"/*.rpm

