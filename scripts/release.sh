#!/usr/bin/env bash
#
# Generates archives with the cross compiled binary ready to be distributed.

set -e
[ -n "$DEBUG" ] && set -x

if [ -z "$(which gox)" ]; then
    echo "You need to install \`gox\` for cross compilation." >&2
    echo "    See how at https://github.com/mitchellh/gox" >&2
    exit 1
fi

PROGNAME="${PROGNAME:-$(basename $(pwd))}"
VERSION="$(cat VERSION)"

gox -output="pkg/{{.OS}}-{{.Arch}}/$(basename $PROGNAME)"

for file in $(find pkg -type f -depth 2); do
    dir="$(dirname "$file")"
    basename="$(basename "$file")"
    platform="$(basename "$dir")"

    cp "man/$(basename "$PROGNAME").html" "$dir"

    archive="pkg/${basename%.*}-${VERSION}+${platform}.tar.gz"
    tar -C "$dir" -czf "$archive" "$basename" "$(basename "$PROGNAME").html"
done

find pkg -type d -depth 1 | xargs rm -r
