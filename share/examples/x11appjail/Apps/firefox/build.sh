#!/bin/sh

set -e

SELF="$(dirname "$(readlink -f "$0")")"

cd -- "${SELF}"

exec doas x11appjail build -O -s dtxdf@disroot.org:"${HOME}/.x11appjail/secrets/x11appjail.sec" .
