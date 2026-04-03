#!/bin/sh

START=true
TRY=0
END=3

until pactl info > /dev/null 2>&1; do
    if ${START}; then
        pulseaudio --start --exit-idle-time=-1 || exit $?

        START=false
    fi

    sleep 1 || exit $?

    TRY=$((TRY+1))

    if [ ${TRY} -gt ${END} ]; then
        echo "WARNING: PULSEAUDIO ISN'T WORKING!"
        break
    fi
done

exec "/opt/brave.com/brave/brave-browser" --no-sandbox --test-type --v=0 --ignore-gpu-blocklist "$@"
