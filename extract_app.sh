#!/bin/bash

VOLUME=$(hdiutil attach -nobrowse 'builds/osx/release.dmg' | awk 'END {$1=$2=""; print $0}'; exit ${PIPESTATUS[0]})
rsync -a ${VOLUME##*( )}/ProtonGraph.app builds/osx/; SYNCED=$?
(hdiutil detach -force -quiet $VOLUME || exit $?) && exit $SYNCED