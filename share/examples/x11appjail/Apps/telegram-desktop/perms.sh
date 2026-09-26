#!/bin/sh

ENABLE_3D_ALREADY=false
WEBCAM_ALREADY=false
USB_ALREADY=false
SOUND_ALREADY=false

if x11appjail sys-attr check users.${X11APPJAIL_UID}.perms; then
    PERMS=`x11appjail sys-attr cat users.${X11APPJAIL_UID}.perms`

    for PERM in ${PERMS}; do
        if [ "${PERM}" = "enable_3d" ]; then
            if ${ENABLE_3D_ALREADY}; then
                continue
            fi

            PERM_ATTR="${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.enable_3d"

            if ! x11appjail sys-attr check "${PERM_ATTR}" "${X11APPJAIL_UID}"; then
                continue
            fi

            ENABLE_3D_ALREADY=true
        elif [ "${PERM}" = "webcam" ]; then
            if ${WEBCAM_ALREADY}; then
                continue
            fi

            PERM_ATTR="${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.webcam"

            if ! x11appjail sys-attr check "${PERM_ATTR}" "${X11APPJAIL_UID}"; then
                continue
            fi

            WEBCAM_ALREADY=true
        elif [ "${PERM}" = "usb" ]; then
            if ${USB_ALREADY}; then
                continue
            fi

            PERM_ATTR="${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.usb"

            if ! x11appjail sys-attr check "${PERM_ATTR}" "${X11APPJAIL_UID}"; then
                continue
            fi

            USB_ALREADY=true
        elif [ "${PERM}" = "sound" ]; then
            if ${SOUND_ALREADY}; then
                continue
            fi

            PERM_ATTR="${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.sound"

            if ! x11appjail sys-attr check "${PERM_ATTR}" "${X11APPJAIL_UID}"; then
                continue
            fi

            SOUND_ALREADY=true
        fi
    done
fi
