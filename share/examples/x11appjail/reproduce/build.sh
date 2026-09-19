#!/bin/sh

set -e

SELF="$(dirname "$(readlink -f "$0")")"

exec appjail-reproduce -fb -c "${SELF}/config.conf" "$1"
