#!/usr/bin/env bash

set -o vi

export PS1='$ '
export EDITOR=vi
export BROWSER=lynx
export HISTCONTROL=ignoreboth
unset HISTFILE

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias la='ls -lAh'
alias less='less -R'
alias curl='curl -fsSL'
alias mp3='yt-dlp --no-playlist --format=bestaudio --extract-audio --audio-format=mp3 --audio-quality=0 --output="%(title)s.%(ext)s"'
alias album='yt-dlp --quiet --format=bestaudio --extract-audio --audio-format=mp3 --audio-quality=0 --output="%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
#alias album='yt-dlp --format=bestaudio --extract-audio --audio-format=mp3 --audio-quality=0 --concat-playlist=always --output="pl_video:%(playlist)s.%(ext)s"'
alias mp4='yt-dlp --embed-metadata --embed-subs --no-playlist --format="bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a] / bestvideo[height<=1080]+bestaudio / best" --output="%(title)s.%(ext)s"'
alias playlist='yt-dlp --quiet --embed-metadata --embed-subs --format="bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a] / bestvideo[height<=1080]+bestaudio / best" --output="%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
alias news='sfeed_update; SFEED_PLUMBER_INTERACTIVE=1 SFEED_PLUMBER=lynx SFEED_AUTOCMD=tgo SFEED_YANKER="xclip -r -sel c" SFEED_URL_FILE="$HOME/.sfeed/urls" sfeed_curses "$HOME/.sfeed/feeds/"*'
alias mail='ssh luiz@sdf.org mail'
alias aes='openssl enc -aes-256-ctr -pbkdf2 -a'
