#!/bin/sh

#
# Script designed to be run for development purposes only.
#

"${SUEXEC:-doas}" make X11APPJAIL_VERSION=`make -V X11APPJAIL_VERSION`+`git rev-parse HEAD`
