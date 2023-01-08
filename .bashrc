#!/usr/bin/env bash

set -o vi

export PS1='$ '
export EDITOR=vi
export BROWSER='/usr/local/bin/lynx' # /usr/bin/lynx -cookies -nopause -noreferer -prettysrc -vikeys -tna -useragent=Lynx -index='https://lite.duckduckgo.com/lite/' "$@"
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
alias news='sfeed_update; SFEED_PLUMBER_INTERACTIVE=1 SFEED_PLUMBER=/usr/local/bin/lynx SFEED_AUTOCMD=tgo SFEED_YANKER="xclip -r -sel c" SFEED_URL_FILE="$HOME/.sfeed/urls" sfeed_curses "$HOME/.sfeed/feeds/"*'
alias mail='ssh luiz@sdf.org mail'
alias token='openssl rand -hex 16'
alias aes='openssl enc -aes-256-ctr -pbkdf2 -a'

# sfeed_update(1)
feeds() {
    feed 'Ars Technica' 'https://feeds.arstechnica.com/arstechnica/features'
    feed 'Bruce Schneier' 'https://www.schneier.com/feed/atom'
    feed 'Coda Hale' 'https://codahale.com/atom.xml'
    feed 'Daniel J. Bernstein' 'https://blog.cr.yp.to/feed.application=xml'
    feed 'Filippo Valsorda' 'https://words.filippo.io/rss/'
    feed 'Hiltjo Posthuma' 'http://codemadness.org/rss.xml'
    feed 'Keccak Team' 'https://keccak.team/news.atom'
    feed 'Lobsters' 'https://lobste.rs/rss'
    feed 'Loup Vaillant' 'https://loup-vaillant.fr/updates'
    feed 'Matthew Green' 'https://blog.cryptographyengineering.com/feed/'
    feed 'Nate Lawson' 'https://rdist.root.org/feed/'
    feed 'Monero' 'https://www.getmonero.org/feed.xml'
    feed 'Mullvad' 'https://mullvad.net/en/blog/feed/atom/'
    feed 'Raspberry Pi' 'https://www.raspberrypi.com/news/feed/'
    feed 'Soatok' 'https://soatok.blog/feed/'
    feed 'Tor' 'https://blog.torproject.org/feed.xml'
    feed 'Wired' 'https://www.wired.com/feed/category/backchannel/latest/rss'
}

fetch() {
    /usr/bin/curl -fsLm 15 "$2" || exit 1
}
