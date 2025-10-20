#!/bin/bash
# Script to add SwiftSupport folder to an IPA file
# This fixes ITMS-90426: Invalid Swift Support error from App Store Connect
# Usage: ./add_swift_support.sh path/to/app.ipa path/to/app.xcarchive

set -e

IPA_PATH="$1"
ARCHIVE_PATH="$2"

if [ -z "$IPA_PATH" ] || [ ! -f "$IPA_PATH" ]; then
    echo "❌ Error: IPA file not found at: $IPA_PATH"
    echo "Usage: $0 <ipa_path> <archive_path>"
    exit 1
fi

if [ -z "$ARCHIVE_PATH" ] || [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Error: Archive not found at: $ARCHIVE_PATH"
    echo "Usage: $0 <ipa_path> <archive_path>"
    exit 1
fi

echo "🔧 Adding SwiftSupport to IPA..."
echo "  IPA: $IPA_PATH"
echo "  Archive: $ARCHIVE_PATH"

# Derived variables
IPA_DIR=$(dirname "$IPA_PATH")
IPA_NAME=$(basename "$IPA_PATH")
ZIP_NAME="${IPA_NAME/.ipa/.zip}"
UNZIP_DIR="${IPA_DIR}/ipa-unzipped-$$"
SWIFT_SUPPORT_SRC="${ARCHIVE_PATH}/SwiftSupport"

# Check if SwiftSupport exists in archive
if [ ! -d "$SWIFT_SUPPORT_SRC" ]; then
    echo "⚠️  Warning: SwiftSupport not found in archive at: $SWIFT_SUPPORT_SRC"
    echo "   This may happen if the app doesn't use Swift or ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO"
    exit 0
fi

# Step 1: Rename IPA to ZIP and unzip
echo "📦 Unzipping IPA..."
cp "$IPA_PATH" "${IPA_DIR}/${ZIP_NAME}"
unzip -q "${IPA_DIR}/${ZIP_NAME}" -d "$UNZIP_DIR"

# Step 2: Copy SwiftSupport from archive
echo "📋 Copying SwiftSupport from archive..."
cp -R "$SWIFT_SUPPORT_SRC" "$UNZIP_DIR/"

# Step 3: Verify SwiftSupport was copied
if [ -d "$UNZIP_DIR/SwiftSupport" ]; then
    DYLIB_COUNT=$(find "$UNZIP_DIR/SwiftSupport" -name "*.dylib" | wc -l)
    echo "✅ SwiftSupport copied successfully ($DYLIB_COUNT dylib files)"
else
    echo "❌ Error: Failed to copy SwiftSupport"
    rm -rf "$UNZIP_DIR"
    rm "${IPA_DIR}/${ZIP_NAME}"
    exit 1
fi

# Step 4: Re-zip and replace original IPA
echo "🗜️  Re-packaging IPA..."
cd "$UNZIP_DIR"
zip -qr "${IPA_DIR}/${ZIP_NAME}" ./*
cd - > /dev/null

# Replace original IPA
mv "${IPA_DIR}/${ZIP_NAME}" "$IPA_PATH"

# Step 5: Clean up
echo "🧹 Cleaning up..."
rm -rf "$UNZIP_DIR"

echo "✅ Done! SwiftSupport added to: $IPA_PATH"
echo ""
echo "You can now upload this IPA to App Store Connect."
