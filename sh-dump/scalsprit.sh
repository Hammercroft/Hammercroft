#!/bin/bash

# scalsprit.sh
# Scale Sprite Script
# Scales all images in a folder using nearest-neighbour scaling (GL_NEAREST style).
# Dependencies: ImageMagick (`magick` or `convert`)
# Usage: ./scale-sprites.sh <input_folder> <output_folder> <scale_factor>

# Made by Hammercroft (https://github.com/Hammercroft)

# This work is dedicated to the public domain under the CC0 1.0 Universal Public Domain Dedication.
# You are free to use, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.
# For more information, see: https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# ────────────────────────────────────────────────
# Dependency check
if command -v magick >/dev/null 2>&1; then
    MAGICK_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
    MAGICK_CMD="convert"
else
    echo "Error: ImageMagick is not installed (no 'magick' or 'convert' command found)." >&2
    exit 1
fi

# ────────────────────────────────────────────────
# Argument parsing
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <input_folder> <output_folder> <scale_factor>"
    echo "Example: $0 ./input ./output 2"
    exit 1
fi

INPUT_DIR="$1"
OUTPUT_DIR="$2"
SCALE_FACTOR="$3"

# ────────────────────────────────────────────────
# Input validation
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist."
    exit 1
fi

if ! [[ "$SCALE_FACTOR" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: Scale factor must be a positive integer (1, 2, 3...)."
    exit 1
fi
# Check read access to input folder
if [[ ! -r "$INPUT_DIR" ]]; then
    echo "Error: No read permission for input folder '$INPUT_DIR'."
    exit 1
fi

# Check write access to output folder (or its parent if it doesn't exist)
if [[ -d "$OUTPUT_DIR" && ! -w "$OUTPUT_DIR" ]] || \
   [[ ! -d "$OUTPUT_DIR" && ! -w "$(dirname "$OUTPUT_DIR")" ]]; then
    echo "Error: No write permission for output folder '$OUTPUT_DIR'."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# ────────────────────────────────────────────────
# Process images
SCALE_PERCENT=$((SCALE_FACTOR * 100))
echo "Scaling images in '$INPUT_DIR' by ${SCALE_FACTOR}x (${SCALE_PERCENT}%) to '$OUTPUT_DIR'..."

found_any=0

shopt -s nullglob
# Only match regular files (not subdirs)
for file in "$INPUT_DIR"/*.{png,jpg,jpeg,gif}; do
    [[ -f "$file" ]] || continue
    found_any=1
    filename=$(basename "$file")
    output_file="$OUTPUT_DIR/$filename"

    "$MAGICK_CMD" "$file" -filter point -resize "${SCALE_PERCENT}%" "$output_file"
    echo "$filename → ${SCALE_PERCENT}%"
done
shopt -u nullglob

if [[ $found_any -eq 0 ]]; then
    echo "No image files found in '$INPUT_DIR'."
fi

echo "Done!"
