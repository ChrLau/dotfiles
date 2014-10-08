#!/bin/sh

# Copy your public key on a machine and setup .ssh/authorized_keys
# TODO: Make it work that "root@host chrlauf": 1. Creates user chrlauf 2. copies the public key in user home

# Shamelessly stolen from:
# Author: Filip Krikava
# URL: https://github.com/fikovnik/bin-scripts/blob/master/export-ssh-key.sh


if [ "$#" != "1" ]; then
	echo "Usage: $0 <user@host>"
	exit 1
fi

UH=$1

ssh $UH "if [ ! -d .ssh ]; then mkdir .ssh; chmod 700 .ssh; fi"
scp ~/.ssh/id_rsa.pub $UH:.ssh
ssh $UH "cat .ssh/id_rsa.pub >> .ssh/authorized_keys; chmod 400 .ssh/authorized_keys"
