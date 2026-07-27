#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${X11APPJAIL_SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

for DESKTOPFILE in rustdesk.desktop rustdesk-link.desktop; do
    rm -f -- "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}.desktop"

    appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?

    appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?

    sed -i '' -Ee "s|^Exec=rustdesk (.+)|Exec=${X11APPJAIL_APPDIR}/START \1|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
    sed -i '' -Ee "s|^Name=(.+)|Name=\1 (AppJail:${X11APPJAIL_PROFILE})|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?
    sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/rustdesk.png|" "${HOME}/.local/share/applications/${X11APPJAIL_PROFILE}-${DESKTOPFILE}" || exit $?

done

appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/share/icons/hicolor/256x256/apps/rustdesk.png "${ICONDIR}/rustdesk.png" || exit $?

appjail cmd jaildir chown "${X11APPJAIL_UID}:${X11APPJAIL_GID}" "${ICONDIR}/rustdesk.png" || exit $?
