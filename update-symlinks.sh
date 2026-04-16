#!/bin/sh

FILES="default.conf APPSCRIPT startup.sh create.sh start-server.sh Services"

for APPDIR in Apps/*; do
    APP="${APPDIR##*/}"

    for FILE in ${FILES}; do
        ln -fs "../../${FILE}" "${APPDIR}/${FILE}"
    done
done
