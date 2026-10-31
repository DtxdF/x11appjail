#!/bin/sh

SSH_HOST="root@x11appjail-tests"

set -xe -o pipefail

run_ssh()
{
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${SSH_HOST}" "$@"
}

run_ssh cd /tests\; /tests/kyua.sh test
