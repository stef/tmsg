#!/usr/bin/ksh

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
