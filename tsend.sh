#!/usr/bin/ksh
# (c) 2012 s@ctrlc.hu
#
#  This is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.

## example send to self:
# echo "snafu" | ./tsend.sh self
## example send to multiple peers:
# echo "immanentize the eschaton" | ./tsend.sh self hugo angela vlad kim

cfgdir=.

function sign {
    printf "$(date "+%Y-%m-%dT%T.%N%z")" | seccure-sign -a -c p521 -m 256 -F "$cfgdir"/sec
    echo
    cat | seccure-sign -a -c p521 -m 256 -F "$cfgdir"/sec
}

function send {
    host="$(fgrep "$1" "$cfgdir"/peers | cut -d' ' -f2)"
    torify socat - tcp4:"$host"
}

[[ "$#" -eq 1 ]] && {
    sign | send $1
    exit 0
}

tmp="$(mktemp)"
sign >"$tmp"
while [[ "$#" -gt 0 ]]; do
    send $1 <"$tmp"
    shift 1
done
rm "$tmp"
