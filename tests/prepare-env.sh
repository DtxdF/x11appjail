#!/bin/sh

SSH_HOST="root@x11appjail-tests"

set -xe -o pipefail

run_ssh()
{
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${SSH_HOST}" "$@"
}

check_step()
{
    run_ssh test -f /var/cache/x11appjail-tests/$1
}

mark_step()
{
    run_ssh touch /var/cache/x11appjail-tests/$1
}

waitforssh -- "${SSH_HOST}"

run_ssh mkdir -p /var/cache/x11appjail-tests

if ! check_step appjail-setup; then
    run_ssh set -xe o pipefail\; \
        fetch -o AppJail.setup https://github.com/DtxdF/AppJail.setup/blob/main/AppJail.setup?raw=true\; \
        chmod +x AppJail.setup\; \
        ./AppJail.setup --ignore-release --with-x11appjail --enable-debug --bleeding-edge\; \
        rm -f AppJail.setup
    mark_step appjail-setup
fi

if ! check_step user; then
    run_ssh set -xe -o pipefail\; \
        pw useradd -n noroot -d /noroot -G x11appjail\; \
        mkdir -p /noroot\; \
        chown noroot:noroot /noroot
    mark_step user
fi

if ! check_step doas; then
    run_ssh set -xe -o pipefail\; \
        echo permit nopass noroot cmd /usr/local/libexec/x11appjail/map-exec \| tee -a /usr/local/etc/doas.conf
    mark_step doas
fi

if ! check_step tests; then
    run_ssh mkdir -p /tests
    tar -T scp.txt -cf - | run_ssh tar -C /tests -xf -
    run_ssh chown -R noroot:noroot /tests
    mark_step tests
fi

if ! check_step keys; then
    run_ssh /tests/keys/genkey.sh
    run_ssh chown -R noroot:noroot /tests/keys
    mark_step keys
fi

if ! check_step image; then
    run_ssh mkdir -p /usr/local/appjail/cache/images
    scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        /usr/local/appjail/cache/images/atf-test "${SSH_HOST}:/usr/local/appjail/cache/images"
    mark_step image
fi
