#!/usr/bin/env bash
set -euo pipefail
echo "Flattening PNG files to remove alpha channel (will overwrite files in place; no .bak files will be created)"

# Ensure magick exists
if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick (magick) not found. On macOS you can install with: brew install imagemagick"
  exit 2
fi

# Collect PNG files from common locations
files=()
while IFS= read -r -d '' f; do files+=("$f"); done < <(find ios/Runner/Assets.xcassets -type f -name '*.png' -print0 2>/dev/null || true)

if [ ${#files[@]} -eq 0 ]; then
  echo "No PNG files found in ios/Runner/Assets.xcassets. Nothing to do."
  exit 0
fi

for f in "${files[@]}"; do
  # skip missing files
  if [ ! -f "$f" ]; then
    continue
  fi

  echo "Flattening $f (overwriting in place; no backup)"
  tmp="${f}.tmp.$$"

  # Convert into a temporary file first, then atomically replace the original.
  if magick convert "$f" -background white -alpha remove -alpha off -strip "$tmp"; then
    mv "$tmp" "$f"
  else
    rm -f "$tmp"
    echo "Failed to flatten $f"
    exit 3
  fi
done

echo "Done. Review changes and commit the updated PNGs if correct."

