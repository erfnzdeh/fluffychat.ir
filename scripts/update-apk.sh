#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DL_DIR="$PROJECT_DIR/src/assets/downloads"
DATA_FILE="$PROJECT_DIR/src/_data/downloads.json"
API_URL="https://api.github.com/repos/krille-chan/fluffychat/releases/latest"

mkdir -p "$DL_DIR"

echo "Fetching latest release info..."
RELEASE_JSON=$(curl -sL "$API_URL")

VERSION=$(echo "$RELEASE_JSON" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$VERSION" ]; then
    echo "ERROR: Could not determine release version."
    exit 1
fi

echo "Latest version: $VERSION"

rm -f "$DL_DIR"/*

ASSET_URLS=$(echo "$RELEASE_JSON" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4)

if [ -z "$ASSET_URLS" ]; then
    echo "ERROR: No files found in release."
    exit 1
fi

FILES_JSON="["
FIRST=true

for url in $ASSET_URLS; do
    FILENAME=$(basename "$url")
    echo "Downloading $FILENAME..."
    curl -sL -o "$DL_DIR/$FILENAME" "$url"

    SIZE_BYTES=$(stat -f%z "$DL_DIR/$FILENAME" 2>/dev/null || stat -c%s "$DL_DIR/$FILENAME" 2>/dev/null)
    SIZE_MB=$(echo "scale=1; $SIZE_BYTES / 1048576" | bc)

    LABEL=""
    PLATFORM=""
    RECOMMENDED=false

    case "$FILENAME" in
        *.apk)
            LABEL="اندروید (APK)"
            PLATFORM="android"
            ;;
        *linux-x64* | *linux-amd64*)
            LABEL="لینوکس (x86_64)"
            PLATFORM="linux"
            ;;
        *linux-arm64*)
            LABEL="لینوکس (ARM64)"
            PLATFORM="linux"
            ;;
        *web*)
            LABEL="نسخه وب"
            PLATFORM="web"
            ;;
        *windows* | *.exe | *.msix)
            LABEL="ویندوز"
            PLATFORM="windows"
            ;;
        *macos* | *.dmg)
            LABEL="مک"
            PLATFORM="macos"
            ;;
        *)
            LABEL="$FILENAME"
            PLATFORM="other"
            ;;
    esac

    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        FILES_JSON+=","
    fi

    FILES_JSON+=$(cat <<ENTRY
{
        "filename": "$FILENAME",
        "label": "$LABEL",
        "platform": "$PLATFORM",
        "size": "${SIZE_MB} MB",
        "recommended": $RECOMMENDED
    }
ENTRY
)
done

FILES_JSON+="]"

cat > "$DATA_FILE" <<DATAJSON
{
    "version": "$VERSION",
    "files": $FILES_JSON
}
DATAJSON

echo ""
echo "Done! Downloaded $(echo "$ASSET_URLS" | wc -l | tr -d ' ') file(s) for version $VERSION"
echo "Data written to $DATA_FILE"
