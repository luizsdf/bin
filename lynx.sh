#!/bin/sh

/usr/bin/lynx -cookies -nopause -noreferer -prettysrc -vikeys -tna -useragent=Lynx -index='https://lite.duckduckgo.com/lite/' "$@"
