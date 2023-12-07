#!/usr/bin/env bash

FILENAME=$1
# if the file exists and can be read use that, otherwise just use "".
PEM=$(cat "$FILENAME" 2>/dev/null || echo "")
if [ -n "$PEM" ]; then
    # convert literal newlines into escaped newlines.
    # it's easier to work with an ugly escaped string than get yaml
    # identation right when templating.
    echo "$PEM" | awk '{printf "%s\\n", $0}' 2>/dev/null
fi
