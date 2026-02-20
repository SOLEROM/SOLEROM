#!/usr/bin/env bash

USER="SOLEROM"
PER_PAGE=100
PAGE=1

while true; do
    DATA=$(curl -s "https://api.github.com/users/${USER}/repos?per_page=${PER_PAGE}&page=${PAGE}")

    COUNT=$(echo "$DATA" | jq 'length')

    [ "$COUNT" -eq 0 ] && break

    echo "$DATA" | jq -r '.[].name'

    PAGE=$((PAGE + 1))
done \
| tr '[:upper:]' '[:lower:]' \
| sort -u