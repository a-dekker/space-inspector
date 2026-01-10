#!/bin/bash
#
# Copy up-to-date core files from File Browser into Space Inspector.
#
# SPDX-FileCopyrightText: 2026 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later

cFILE_BROWSER_DIR=../file-browser/src
cCORE_FILES_DIR=src/io

if [[ "$(basename "$PWD")" == "libs" ]]; then
    cd .. || exit 1
fi

if [[ ! -d src/io ]]; then
    echo "error: run this from Space Inspector's root directory"
    exit 1
fi

if [[ ! -d "$cFILE_BROWSER_DIR" ]]; then
    echo "error: make sure to clone File Browser's repository next to Space Inspector"
    echo "like this: cd .. && git clone https://github.com/ichthyosaurus/harbour-file-browser file-browser"
    exit 1
fi

if ! git diff --exit-code --quiet -- "$cCORE_FILES_DIR/"*; then
    echo "error: there are uncommitted changes to File Browser core files in ./$cCORE_FILES_DIR"
    exit 1
fi


printf -- "%s\n" "updating files in $cCORE_FILES_DIR from $cFILE_BROWSER_DIR..." >&2

for i in "$cCORE_FILES_DIR/"*.{cpp,h}; do
    file="$(basename "$i")"
    local="$i"
    remote="$cFILE_BROWSER_DIR/$file"

    if [[ -f "$remote" ]]; then
        if cp "$remote" "$local"; then
            printf -- "%s\n" "updated $file" >&2
        else
            printf -- "%s\n" "failed to update $file" >&2
        fi
    else
        printf -- "%s\n" "warning: file $file does not exist in File Browser" >&2
    fi
done

exit 0
