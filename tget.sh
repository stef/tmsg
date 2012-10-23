#!/usr/bin/ksh

# helper used by tmsg.sh - checks and displays valid incoming messages

cfgdir=.
read header
match=false
cat "$cfgdir"/peers | while read name host key; do
    ts=$(echo -n "$header" | seccure-verify -q -a -c p521 -m 256 -f "$key" 2>${logfile:-/dev/null}) && {
        printf "$ts <$name> "
        match=true
        break
    }
done
$match && seccure-verify -q -a -c p521 -m 256 "$key" -f
