#!/bin/bash

DST_PATH="/home/pi/Projects/companion-bridge"
cd $DST_PATH

git config pull.rebase false

git stash
git pull

sudo apt-get install -y tmux nodejs vim

sudo service cron status
sudo systemctl enable cron
sudo systemctl start cron

cmd="@reboot $DST_PATH/auto_tmuxer.sh >>/tmp/atem_cron.log 2>&1"
(crontab -u pi -l; echo "$cmd" ) | crontab -u pi -
cmd="0 1 * * * $DST_PATH/auto_tmuxer.sh >>/tmp/atem_cron.log 2>&1"
(crontab -u pi -l; echo "$cmd" ) | crontab -u pi -