#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_SLUG="vynody"
APP_DESCRIPTION="Cross-platform music player built with Flutter"
APP_LICENSE="GPL-3.0-or-later"
GITHUB_REPO="${GITHUB_REPOSITORY:-axel10/vynody}"

RAW_VERSION="${1:-$(sed -n 's/^version:[[:space:]]*//p' "$ROOT_DIR/pubspec.yaml" | head -n 1)}"
VERSION="${RAW_VERSION//+/-}"
SHA256="${2:-}"

OUTPUT_DIR="${3:-$ROOT_DIR/packaging/aur}"

if [[ -z "$SHA256" ]]; then
  DEB_FILE="${4:-$ROOT_DIR/build/linux/packages/${APP_SLUG}-linux-${VERSION}-amd64.deb}"
  if [[ -f "$DEB_FILE" ]]; then
    SHA256="$(sha256sum "$DEB_FILE" | awk '{print $1}')"
  fi
fi

if [[ -z "$SHA256" ]]; then
  echo "Usage: $0 [VERSION] [SHA256] [OUTPUT_DIR]" >&2
  echo "Error: SHA256 sum not provided and deb package not found." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

SED_EXPR=(
  -e "s|@APP_SLUG@|${APP_SLUG}|g"
  -e "s|@VERSION@|${VERSION}|g"
  -e "s|@APP_DESCRIPTION@|${APP_DESCRIPTION}|g"
  -e "s|@GITHUB_REPO@|${GITHUB_REPO}|g"
  -e "s|@APP_LICENSE@|${APP_LICENSE}|g"
  -e "s|@DEB_SHA256@|${SHA256}|g"
)

# 1. Render PKGBUILD from PKGBUILD.in
sed "${SED_EXPR[@]}" "$ROOT_DIR/packaging/aur/PKGBUILD.in" > "$OUTPUT_DIR/PKGBUILD"

# 2. Render .SRCINFO (using makepkg if available, otherwise from .SRCINFO.in template)
if command -v makepkg >/dev/null 2>&1; then
  (cd "$OUTPUT_DIR" && makepkg --printsrcinfo > .SRCINFO)
elif [[ -f "$ROOT_DIR/packaging/aur/.SRCINFO.in" ]]; then
  sed "${SED_EXPR[@]}" "$ROOT_DIR/packaging/aur/.SRCINFO.in" > "$OUTPUT_DIR/.SRCINFO"
fi

echo "Generated AUR package files in $OUTPUT_DIR:"
echo "  - $OUTPUT_DIR/PKGBUILD"
echo "  - $OUTPUT_DIR/.SRCINFO"
