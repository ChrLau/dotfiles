# Prompt settings
# Yeah.. Debian.. I go the easy way and just change the default prompt to one with colours..
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;35m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;35m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '
    # GIT-Prompt with "source git-prompt.sh":
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;35m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\[\033[1;31m\]$(__git_ps1)\[\033[0m\]\$ '

fi
unset color_prompt force_color_prompt

## Souce .git-prompt.sh
## Get it from:
## https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
source ~/stuff/git-prompt.sh


#Add timestamps and linenumbers to .bash_history
HISTTIMEFORMAT='%F %T '

# don't put duplicate lines in the history, but lines starting with space
HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend
# and write it immediately to .bash_history! not only when the shell exists (cleanly)!!!
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# Aliases
alias ll='ls -lach'
alias lS='ls -lachS'
alias lt='ls -lacht'
alias r='sudo -i'
alias doch='sudo "$BASH" -c "$(history -p !!)"'

# Version Control System aliases
alias cvsst='cvs status 2>&1 | egrep "(^\? |Status: )" | grep -v Up-to-date'
alias cvsgrep='grep --exclude=".#*" -r'
alias svngrep='grep --exclude-dir ".svn" -r'
alias svnprop='svn propset svn:keywords "Id Date Author HeadURL Header Revision"'
alias svnpropx='svn propset svn:executable on'
alias svnpropdelx='svn propdel svn:executable'
svngrepfind() { find . -type f -not -path "*/.svn/*" -exec grep -l "$*" '{}' ';';  }
svnaddallindir() { svn add $(svn st | grep ^? | awk '{print $2}' | paste -s); }

alias traceroute='echo -e "\033[1;32mSwitching to ICMP Traceroute\033[0m"; sudo traceroute -I'

# Config file stuff
# Opens all files with the specified name found in the current directory or below
viap() { vi $(find . -name apache.properties | paste -s); }
visp() { vi $(find . -name secret.properties | paste -s); }
vitp() { vi $(find . -name "tomcat?.properties" | paste -s); }

# OpenSSL
openssl_test_connection() { if [ "$#" -lt 1 ]; then
    echo "Usage: openssl_test_connection FQDN <PORT> (Port defaults to 443 if not given)";
  else
    FQDN="$1"
    PORT="$2"

    # If port is empty, set to 443
    if [ -z "$PORT" ]; then
      PORT="443"
    fi

  openssl s_client -connect "$FQDN":"$PORT";
fi;
}

# OpenSSL s_client via Proxy
# Requires OpenSSL of atleast version 1.1.0!
# Connects to the given FQDN via hardcoded proxy. Useful if you can't define http_proxy for whatever reasons
openssl_test_connection_proxy() { if [ "$#" -lt 1 ]; then
    echo "Usage: openssl_test_connection FQDN <PORT> (Port defaults to 443 if not given)";
  else
    FQDN="$1"
    PORT="$2"

    # If port is empty, set to 443
    if [ -z "$PORT" ]; then
      PORT="443"
    fi

    # TODO: Compare proxy variables and if we have more than 1 proxy present a list which one to choose
    # We just check if there is ANY value
    # ... And use https_proxy anyways.. But hey, that's what I need in this environment currently.. ;-)
    # And the sed regex goes for http:// only, not https://..
    # This proxy stuff is a mess.. And not really got specified/enforced..

    if [ -n "$http_proxy" ] || [ -n "$HTTP_PROXY" ] || [ -n "$https_proxy" ] || [ -n "$HTTPS_PROXY" ] || [ -n "$ftp_proxy" ] || [ -n "$FTP_PROXY" ]; then

      read -p "Found proxy environment variables. Use this proxy? (y/N)" -n 1 -r
      echo ""

      if [[ $REPLY =~ ^[Yy]$ ]]; then

        PROXY=$(sed 's#http\:\/\/##' <<< $https_proxy)
        openssl s_client -proxy "$PROXY" -connect "$FQDN":"$PORT";

      fi

    else
      openssl s_client -connect "$FQDN":"$PORT";
    fi
fi;
}

ssl_verify_cert() { openssl x509 -in $1 -text; }
ssl_verify_csr() { openssl req -in $1 -text -verify; }
ssl_verify_ocsp() { openssl ocsp -issuer PATH/TO/ISSUING.crt -CAfile  PATH/TO/ROOT.crt -cert $1 -url OCSP-URL-HERE -nonce; }
ssl_verify_key() { openssl rsa -in $1 -check -noout; }
ssl_verify_cert2key() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: ssl_verify_cert2key certificate privatekey";
  else
    diff  <(openssl x509 -in $1 -pubkey -noout) <(openssl rsa -in $2 -pubout 2>/dev/null);
    if [ "$?" -eq 0 ];then
      echo "Certificate and PrivateKey match";
    else
      echo "Certificate and PivateKey DON'T match";
    fi
  fi;
}
ssl_create_csr() { openssl req -new -newkey rsa:2048 -nodes -subj "/O=some/OU=thing/CN=$1" -keyout "$HOME/csrs/$1.key" -out "$HOME/$1.csr"; }


# rdesktop alias
alias winbox='read -s -p "Enter Password:" mypassword;rdesktop -a 16 -k de -g 1280x1024 -u $USER -d DOMAIN -p $mypassword winbox.lan.domain &'

# Logging of SSL-Session keys to inspect SSL-Traffic
export SSLKEYLOGFILE="$HOME"/.sslkeylog.log

##
## Bash completion for SSH Hosts
##
complete -F _known_hosts s
complete -F _known_hosts host
complete -F _known_hosts ping
complete -F _known_hosts traceroute

# Generate base64 credentials line
## echo without newline is VERY important ;-)
create_base64_creds() {
  if [ "$#" -lt 1 ]; then
    echo "create_base64_creds: Create base64 credentials to use in Basic-Authorization requests"
    echo "Usage: create_base64_creds PASSWORD [USERNAME]"
  elif [ "$#" -eq 1 ]; then
    PASSWORD="$1"
    USERNAME="$USER"
  elif [ "$#" -eq 2 ]; then
    PASSWORD="$1"
    USERNAME="$2"
  else
    echo "More than 2 arguments provided. Aborting."
    echo "Usage: create_base64_creds PASSWORD [USERNAME]"
  fi

  BASE64=$(echo -n "$USERNAME:$PASSWORD" | base64)
  echo "Your string is: $BASE64"
  echo "Use it with curl like: curl -H 'Authorization: Basic $BASE64'"
}

# Foreman API - delete Hosts
# Don't forget to generate BASE64 string WITHOUT newline ;-)
foreman2delete() { curl -XDELETE http://foreman.domain.tld/api/hosts/$1; }
foreman4delete() { curl -H 'Authorization: Basic BLABLABLABASE64=' -XDELETE https://foreman.domain.tld/api/hosts/$1; }

# man alias
# to prevent color codes spreading into other commands, as they can't be properly escaped with the end codes
# This makes the LESS_TERMCAP_* variables below redundant, as they have to be set via the pager script
# script is under scripts in this repo.
alias man="PAGER=$HOME/stuff/man-pager man"

# Colored manpages
# CHANGE FIRST NUMBER PAIR FOR COMMAND AND FLAG COLOR
# currently 1;31 which is bold red
##export LESS_TERMCAP_md=$'\E[1;31;5;74m'  # begin bold

# CHANGE FIRST NUMBER PAIR FOR PARAMETER COLOR
# currently 0;32 which is green
##export LESS_TERMCAP_us=$'\E[0;32;5;146m' # begin underline

# don't change anything here
##export LESS_TERMCAP_mb=$'\E[1;31m'       # begin blinking
##export LESS_TERMCAP_me=$'\E[0m'           # end mode
##export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
##export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
##export LESS_TERMCAP_ue=$'\E[0m'           # end underline


# SSH Agent config
# Preferrably use keychain.. 

# If not running interactively, don't do anything
# Needed when not already present, as scp still executes "ssh -c $shell" which sources .bashrc, etc.
# And then any dialog will prevent logging on (looking at you SuSE!)
# Else this has to come BEFORE the agent stuff (generally on top of your .bashrc/.profile/etc.)
[ -z "$PS1" ] && return

if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_filename
fi

# Alternatively: Keychain config
# Keychain Config
#/usr/bin/keychain --nogui -q --agents ssh $USER
#[ -z "$HOSTNAME" ] && HOSTNAME=`uname -n`
#[ -f $HOME/.keychain/$HOSTNAME-sh ] && . $HOME/.keychain/$HOSTNAME-sh

# Searches all files older than X days and prints their size in GB
oldfilesize() {

  if [[ -z "$1" ]]; then
    read -p "Find files older than how many days? " -r
  else
    REPLY="$1"
  fi

  regexint='^[0-9]+$'

  if ! [[ $REPLY =~ $regexint ]] ; then
     echo "Error: Enter a number" >&2
  else
    find . -type f -mtime +$REPLY -printf '%s\n' | awk  '{a+=$1;} END {printf "Files older than %d days consume: %.1f GB\n", REPLY, a/2**30;}' REPLY="$REPLY"
  fi

}

# Taken from: https://www.netmeister.org/ip.sh
# After reading: https://twitter.com/jschauma/status/1366601263740239874
# A few simple shell functions to convert IP addresses
# from hex or binary to decimal (IPv4) / hex (IPv6)
# notation.
#
# This file is in the public domain.
#
# Made by @jschauma - hit me up if you want to golf it
# down, but simple shell commands only, ok?
#
# Examples:
# IPv4
#
# $ binaryToIPv4 01001010000001101000111100011001
# 74.6.143.25
# $ ipv4ToHex 74.6.143.25
# 4A 06 8F 19
# $ hexToIPv4 4A 06 8F 19
# 74.6.143.25
# $ ipv4ToBinary 74.6.143.25
# 01001010000001101000111100011001
# $ binaryIPv4ToHex 01001010000001101000111100011001
# 4A 06 8F 19
#
# IPv6
#
# $ ipv6ToBinary 2001:4998:124:1507::f000
# 00100000000000010100100110011000000000010010010000010101000001110000000000000000000000000000000000000000000000001111000000000000
# $ binaryToIPv6 00100000000000010100100110011000000000010010010000010101000001110000000000000000000000000000000000000000000000001111000000000000
# 2001:4998:124:1507::F000

binaryToIPv4() {
	ip="$@";
	if [ -z "$ip" ]; then
		read ip;
	fi;
	echo "$ip" | \
		sed 's/\(.\{8\}\)/\1 /g' | tr ' ' '\n' | \
		( echo ibase=2; xargs -n 1 ) | bc |	\
		tr '\n' '.' | sed -e 's/\.$//';
}

binaryIPv4ToHex() {
	ip="$@";
	if [ -z "$ip" ]; then
		read ip;
	fi;
	echo "$ip" | binaryToIPv4 | ipv4ToHex
}

hexToIPv4() {
	ip="$@";
	if [ -z "$ip" ];
		then read ip;
	fi;
	echo "$ip" | \
		tr -d '[:space:]' |	\
		tr '[a-z]' '[A-Z]' | \
		sed 's/\(.\{2\}\)/\1 /g' | tr ' ' '\n' | \
		( echo ibase=16; xargs -n 1 ) | bc | \
		tr '\n' '.' | sed -e 's/\.$//' | xargs;
}

ipv4ToBinary() {
	ip="$@";
	if [ -z "$ip" ];
		then read ip;
	fi;
	echo "$ip" | tr . '\n' | \
		( echo obase=2; xargs -n 1; ) | bc | \
		sed -e :a -e 's/^.\{1,7\}$/0&/;ta' | \
		tr -d '\n' | xargs;
}


ipv4ToHex() {
	ip="$@";
	if [ -z "$ip" ];
		then read ip;
	fi;
	echo "$ip" | tr . '\n' | \
		( echo obase=16; xargs -n 1; ) | bc | \
		sed -e :a -e 's/^.\{1,1\}$/0&/;ta' | \
		tr '\n' ' ' | xargs;
}

ipv6ToBinary() {
	ip="$@";
	if [ -z "$ip" ];
		then read ip;
	fi;
	echo "$ip" | \
		sed -e "s/::/:$(jot -b 0000 $(( 8 - $(echo "${ip}" | tr ':' '\n' | grep . | wc -l) )) 0 0 2>/dev/null | \
		tr '\n' ':')/" | tr ':' '\n' | \
		sed -e :a -e 's/^.\{1,4\}$/0&/;ta' | \
		tr '[a-z]' '[A-Z]' | \
		( echo "ibase=16; obase=2;"; xargs -n 1; ) | \
		bc | sed -e :a -e 's/^.\{1,15\}$/0&/;ta' | \
		tr -d '\n' | xargs
}

binaryToIPv6() {
	ip="$@";
	if [ -z "$ip" ]; then
		read ip;
	fi;
	echo "$ip" | \
		sed 's/\(.\{16\}\)/\1 /g' | tr ' ' '\n' | \
		( echo 'obase=16; ibase=2;';  xargs -n 1 ) | bc | \
		tr '\n' ':' | \
		sed -e 's/:[0:]*:/::/' -e 's/^0*//' -e 's/:$//'
}

# Source: https://twitter.com/rfc3849/status/1366412469577674755
# Put in .bashrc and use as "stdwhat <command>" to see what is stderr and stdout.
stdwhat() {
  $* 2> >(sed 's/^/stderr(2): /') > >(sed 's/^/stdout(1): /')
}





