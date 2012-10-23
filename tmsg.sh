#!/usr/bin/ksh
## simple multiparty chat and file sharing via tor and ecc for auth.
## depends on socat, seccure, ksh
##
## start a hidden service like this in /etc/tor/torrc:
# HiddenServiceDir /var/lib/tor/tmsg/
# HiddenServicePort 80 127.0.0.1:14444
##
## after restarting tor or using torpy (https://github.com/stef/torpy):
# torpy start tmsg 127.0.0.1:14444 80
##
## get your onion address from
# sudo cat /var/lib/tor/tmsg/hostname
##
## This hostname together with the HiddenServicePort 80 from above and
## your public key from ./pub form your complete address that you can
## share with your friends so you can have a two-way conversation. If
## you only share your public key, then you will be able to send to
## people accepting your key. But you can only be contacted, if you
## shared your onion address with others.
##
## create a list of all your peers data in this format
# myself myaddress.onion <my public key>
# friend 3m3k8x....onion <friends public key>
# mom 8xj8nj38x....onion <moms public key>
# myself2 my2ndaddress.onion <my other public key>
## trailing space but no key, for read only address
# mydeaddrop mydeadrop.onion 
## twospaces before public key necessary, but no onion address
# poster  <pseudonym public key>
## etc.

cfgdir=.

[[ -d "$cfgdir" ]] || mkdir "$cfgdir"
[[ -f "$cfgdir/sec" ]] || {
    touch "$cfgdir"/sec
    chmod 600 "$cfgdir"/sec
    dd if=/dev/urandom of="$cfgdir"/sec bs=32 count=1 2>/dev/null
    seccure-key -q -c p521 -F "$cfgdir"/sec >"$cfgdir"/pub
    printf "your public key is: " >&2
    cat "$cfgdir"/pub >&2
}
[[ ! -f "$cfgdir"/peers ]] && {
    printf "don't forget to add your onion address to $cfgdir/peers" >&2
    printf "self <hiddenservicename:port> " >"$cfgdir"/peers
    cat "$cfgdir"/pub >>"$cfgdir"/peers
}

socat TCP4-listen:${localport:-14444},bind=127.0.0.1,reuseaddr,fork system:${0%/*}/tget.sh,fdout=4
