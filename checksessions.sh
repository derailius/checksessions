#!/bin/bash

sudo cat "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Preferences.xml" |  \
sed -e 's;^.* PlexOnlineToken=";;' | sed -e 's;".*$;;' | tail -1 > /tmp/plex.tmp

wget -q http://IP:32400/status/sessions?X-Plex-Token=`cat /tmp/plex.tmp` -O - > /tmp/sessions

value=$( grep -ic 'local="0"' /tmp/sessions )
sessions=$( grep 'local="0"' /tmp/sessions | grep -c "paused" )

    if [ "$value" = "$sessions" ]; then
        echo "All non-local are paused or zero non-local"
        /opt/Tautulli/tautulli-custom-scripts/throttleunlimit.sh
        echo "■■■ Unlimited ■■■■"
        rm -rf /tmp/sessions
        rm -rf /tmp/plex.tmp
        exit
    fi

    if (( value > 1 )); then
        echo "There are $value non-local sessions. Limit throttle."
        /opt/Tautulli/tautulli-custom-scripts/limitthrottle.sh
        echo "■■■ Limited ■■■■"
        rm -rf /tmp/sessions
        rm -rf /tmp/plex.tmp
        exit
    fi

    if (( sessions > 0 )); then
        echo "There are $sessions non-local and paused sessions."
        /opt/Tautulli/tautulli-custom-scripts/throttleunlimit.sh
        echo "■■■ Unlimited ■■■■"
        rm -rf /tmp/sessions
        rm -rf /tmp/plex.tmp
        exit
    fi

    if (( value == 0 )); then
        /opt/Tautulli/tautulli-custom-scripts/throttleunlimit.sh
        echo "■■■ Unlimited ■■■■"
        rm -rf /tmp/sessions
        rm -rf /tmp/plex.tmp
    else
        echo "There are $value non-local sessions currently in play state."
        /opt/Tautulli/tautulli-custom-scripts/limitthrottle.sh
        echo "■■■ Limited ■■■■"
        rm -rf /tmp/sessions
        rm -rf /tmp/plex.tmp
        exit
    fi

rm /tmp/plex.tmp
rm /tmp/sessions
exit
