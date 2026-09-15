#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-decoded}"

for img in \
  "$ROOT"/res/mipmap-*/ic_launcher.png \
  "$ROOT"/res/mipmap-*/ic_launcher_round.png \
  "$ROOT"/res/mipmap-*/ic_launcher_foreground.png
do
  [ -f "$img" ] || continue

  w=$(identify -format '%w' "$img")
  name=$(basename "$img")

  if [ "$name" = "ic_launcher_foreground.png" ]; then
    badge=$((w * 24 / 100))
    margin=$((w * 8 / 100))
  else
    badge=$((w * 28 / 100))
    margin=$((w * 3 / 100))
  fi

  point=$((badge * 46 / 100))
  stroke=$((w / 100))
  [ "$stroke" -lt 1 ] && stroke=1

  tmp=$(mktemp --suffix=.png)

  convert \
    -size "${badge}x${badge}" \
    canvas:none \
    -fill '#6B2E1F' \
    -stroke '#FFF1D6' \
    -strokewidth "$stroke" \
    -draw "circle $((badge / 2)),$((badge / 2)) $((badge / 2)),$stroke" \
    -fill '#FFF8EA' \
    -stroke none \
    -font DejaVu-Sans-Bold \
    -pointsize "$point" \
    -gravity center \
    -annotate +0+0 '11' \
    "$tmp"

  convert \
    "$img" \
    "$tmp" \
    -gravity northeast \
    -geometry "+${margin}+${margin}" \
    -composite \
    "$img"

  rm -f "$tmp"
  echo "Badged $img"
done
