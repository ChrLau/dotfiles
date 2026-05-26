syntax on
set nu
set paste
" Some terminal emulators and clipboards automatically set Bracketed Paste
" This will disable our set paste setting automatically, which is annoying
" the next 3 settings fix that.
set t_BE=
set t_CS=
let &t_ti .= "\e[?2004l"
set mouse=
set autoindent
set modeline
" Fix color scheme which can be hard to read on some TTYs
color desert
" Convert tabs to spaces:
"set expandtab
