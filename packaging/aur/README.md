# Arch Linux (AUR) Packaging for Vynody

This directory contains the parameterized template (`PKGBUILD.in`) for generating the AUR package (`vynody-bin`).

## How it works

The package definition is fully dynamic and avoids hardcoded version numbers or checksums.

During Linux packaging (`scripts/package_linux.sh`), the script automatically populates `@VERSION@` and `@DEB_SHA256@` from `pubspec.yaml` and the generated `.deb` release artifact, outputting `PKGBUILD` and `.SRCINFO`.

## Generating AUR files manually

You can generate `PKGBUILD` and `.SRCINFO` manually using `scripts/generate_aur_package.sh`:

```shell
bash scripts/generate_aur_package.sh <VERSION> <SHA256> [OUTPUT_DIR]
```

Example:

```shell
bash scripts/generate_aur_package.sh 1.13.0 c74fd5bd9a0c668cf908e6af8791b24146b95a6ab915152eccd0e7e470f5adac packaging/aur
```

## Building locally

To test or build the package locally:

```shell
cd packaging/aur
makepkg -si
```
