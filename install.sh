#!/bin/bash

DST_PATH="/home/pi/Projects/companion-bridge"
cd $DST_PATH

git config pull.rebase false

git stash
git pull

sudo apt-get install -y tmux nodejs vim