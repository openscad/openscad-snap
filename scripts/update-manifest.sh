#!/bin/bash

set -euo pipefail

# Configuration
TEMPLATE="snap/snapcraft.yaml.template"
OUTPUT="snap/snapcraft.yaml"

if [ -z ${1+x} ]
then
	echo "usage: $0 URL-TO-RELEASE-TAR"
	exit 1
fi

SRCTAR="$1"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template file $TEMPLATE not found."
    exit 1
fi

TMPTAR=$(mktemp src_XXXXXXXXXX.tar.gz)
trap "rm -fv '$TMPTAR'" exit

wget -O "$TMPTAR" "$SRCTAR"

DATE=$(tar --wildcards --to-stdout -t -v -f "$TMPTAR" "**/VERSION.txt" 2>&1 | awk '{ print $4 }')
VERSION=$(tar --wildcards --to-stdout -x -f "$TMPTAR" "**/VERSION.txt")

SHORT_HASH=$(tar --wildcards --to-stdout -x -f "$TMPTAR" "**/COMMIT.txt")
FILE_HASH=$(sha256sum "$TMPTAR" | awk '{ print $1 }')

# Perform replacements and write to output file
sed -e "s/@@OPENSCAD_DATE@@/${DATE}/g" \
    -e "s/@@OPENSCAD_VERSION@@/${VERSION}/g" \
    -e "s/@@OPENSCAD_COMMIT@@/${SHORT_HASH}/g" \
    -e "s/@@OPENSCAD_FILE_HASH@@/${FILE_HASH}/g" \
    -e "s,@@OPENSCAD_ARCHIVE@@,${SRCTAR},g" \
    "$TEMPLATE" > "$OUTPUT"

echo -e "\n---"
echo -e "\nGenerated $OUTPUT with version $VERSION and commit $SHORT_HASH\n"
