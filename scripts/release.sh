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
    basename="$(basename "$file")"
    platform="$(basename $(dirname "$file"))"

    archive="pkg/${basename%.*}-${VERSION}+${platform}.tar.gz"
    tar -C "$(dirname "$file")" -czf "$archive" "$basename"
done

find pkg -type d -depth 1 | xargs rm -r
