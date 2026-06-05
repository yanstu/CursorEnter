#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HELPER_DIR="$ROOT_DIR/helper"
OUT_DIR="$ROOT_DIR/bin"

mkdir -p "$OUT_DIR"

cd "$HELPER_DIR"
swift build -c release --product cursor-enter-helper
cp ".build/release/cursor-enter-helper" "$OUT_DIR/cursor-enter-helper"
chmod +x "$OUT_DIR/cursor-enter-helper"
