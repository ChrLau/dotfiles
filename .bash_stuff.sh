# Prompt settings
# Yeah.. Debian.. I go the easy way and just change the default prompt to one with colours..
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;35m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;34m\]\u\[\033[0m\]@\[\033[1;35m\]\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\]\$ '
fi
unset color_prompt force_color_prompt


#Add timestamps and linenumbers to .bash_history
HISTTIMEFORMAT='%F %T '

# don't put duplicate lines in the history, but lines starting with space
HISTCONTROL=ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# Aliases
alias ll='ls -lach'
alias lS='ls -lachS'

alias r='sudo -i'

# Version Control System aliases
alias cvsst='cvs status 2>&1 | egrep "(^\? |Status: )" | grep -v Up-to-date'
alias cvsgrep='grep --exclude=".#*" -r'
alias svngrep='grep --exclude-dir ".svn" -r'

# rdesktop alias
alias winbox='read -s -p "Enter Password:" mypassword;rdesktop -a 16 -k de -g 1280x1024 -u $USER -d DOMAIN -p $mypassword winbox.lan.domain &'


##
## Bash completion for SSH Hosts
##
complete -F _known_hosts s
complete -F _known_hosts host
complete -F _known_hosts ping
complete -F _known_hosts traceroute

# Keychain Config
/usr/bin/keychain --nogui -q --agents ssh chrlauf
[ -z "$HOSTNAME" ] && HOSTNAME=`uname -n`
[ -f $HOME/.keychain/$HOSTNAME-sh ] && . $HOME/.keychain/$HOSTNAME-sh


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

