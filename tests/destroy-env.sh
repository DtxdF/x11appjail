#!/bin/sh

SSH_HOST="root@x11appjail-tests"

set -xe -o pipefail

overlord destroy -f vm.yml
waitforssh -U "${SSH_HOST}"
