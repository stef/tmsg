#!/usr/bin/ksh
# (c) 2012 s@ctrlc.hu
#
#  This is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.

# helper used by tmsg.sh - checks and displays valid incoming messages

# let's not allow any resource exhaustion because of overly big messages
# 4K should be enough for chatting
dd bs=1024 count=4 2>/dev/null | {
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
}
