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
alias doch='sudo !!'

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

# Colored manpages
# CHANGE FIRST NUMBER PAIR FOR COMMAND AND FLAG COLOR
# currently 1;31 which is bold red
export LESS_TERMCAP_md=$'\E[1;31;5;74m'  # begin bold

# CHANGE FIRST NUMBER PAIR FOR PARAMETER COLOR
# currently 0;32 which is green
export LESS_TERMCAP_us=$'\E[0;32;5;146m' # begin underline

# don't change anything here
export LESS_TERMCAP_mb=$'\E[1;31m'       # begin blinking
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline

# Keychain Config
/usr/bin/keychain --nogui -q --agents ssh $USER
[ -z "$HOSTNAME" ] && HOSTNAME=`uname -n`
[ -f $HOME/.keychain/$HOSTNAME-sh ] && . $HOME/.keychain/$HOSTNAME-sh
