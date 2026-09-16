#!/usr/bin/env bash
# 把 theme/ 下的 SVG 源转成 PNG 产物。fcitx5 用 cairo 渲染，PNG 的 alpha 最稳。
set -euo pipefail
cd "$(dirname "$0")/theme"
for f in panel highlight blur-mask; do
  [ -f "$f.svg" ] || continue
  rsvg-convert -o "$f.png" "$f.svg"
  printf '  %-14s -> %s\n' "$f.svg" "$f.png"
done
echo "done."
