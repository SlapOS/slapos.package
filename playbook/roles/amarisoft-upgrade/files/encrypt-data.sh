#!/bin/sh
usage() {
    echo 1>&2 "Usage: $0 KEYFILE IVFILE (encrypt | decrypt | genkey) [IN] [OUT]"
    exit 
}
chacha20() {
    test "$#" -ne 6 && usage
    KEY="$(od -An -v -tx1 $1 |tr -d ' \n')"
    IV="$(openssl base64 -A -in $2 -d |od -An -v -tx1 |tr -d ' \n')"
    openssl enc $6 -chacha20 -K $KEY -iv $IV -nosalt -in $4 -out $5
}
case "$3" in
    encrypt )
        chacha20 $@ -e;;
    decrypt )
        chacha20 $@ -d;;
    genkey )
        test "$#" -ne 3 && usage
        head -c32 /dev/urandom > $1
        head -c16 /dev/urandom > $2.bin
        openssl base64 -A -in $2.bin -out $2;;
    * )
        usage;;
esac
