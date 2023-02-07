#!/bin/bash

DST_PATH="/home/pi/Projects/companion-bridge/"
cd $DST_PATH

git stash
git pull

function sleeper {
    for (( sxslp = 0; sxslp < 1; sxslp++ )); do
        echo "."
        sleep 1
    done
}

RUN_USER="pi"
SESSION_ID="CMP_sess"

#zabijem processy
printf "\nPKILL: Clearing all KNX for '$RUN_USER'\n"
pkill -u $RUN_USER -9 nodejs

tmux list-sessions
printf "\nTMUX: Clearing session '$SESSION_ID'\n"
tmux kill-session -t "$SESSION_ID"
sleeper
tmux list-sessions
#
tmux new-session -s "$SESSION_ID" -n "knx-usb-ws" -d
printf "\nTMUX: Created new session '$SESSION_ID'\n"
tmux list-sessions
sleeper

tmux send-keys -t "$SESSION_ID:0" "node $DST_PATH/app.js" ENTER
echo "TMUX: Created new window 'companion-bridge'"
sleeper

echo "Autostart done";
echo "";
echo "Run tmux a";
echo -ne '\n\n' > /dev/null 2>&1 </dev/null