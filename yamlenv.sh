#!/bin/sh

# variables
MAGEDOWNLOAD_ID_S="{{ MAGEDOWNLOAD_ID }}"
MAGEDOWNLOAD_TOKEN_S="{{ MAGEDOWNLOAD_TOKEN }}"

# find and replace
sed -e "s/${MAGEDOWNLOAD_ID_S}/${MAGEDOWNLOAD_ID}/g" \
    -e "s/${MAGEDOWNLOAD_TOKEN_S}/${MAGEDOWNLOAD_TOKEN}/g" \
    < .magedownload-cli.yaml \
    > .magedownload-cli.yaml