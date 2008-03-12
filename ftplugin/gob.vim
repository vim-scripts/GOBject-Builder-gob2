" Vim filetype plugin file
" Language:     GObject Builder (gob)
" Maintainer:	Ding-Yi Chen <dchen at redhat.com>
" Modified from cpp.vim 
" Last Change:  2008 Feb 21


" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Behaves just like C
runtime! ftplugin/c.vim ftplugin/c_*.vim ftplugin/c/*.vim

" Let the matchit plugin know what items can be matched.

runtime! macros/matchit.vim 
if exists("loaded_matchit")
    let b:match_ignorecase = 0
    let b:match_words =
                \ '\<public\>:\<protected\>:\<private\>:\<signal\>:\<virtual\>:\<override\>' 
    " Ignore ":syntax region" commands, the 'end' argument clobbers if-endif
    let b:match_skip = 'getline(".") =~ "^\\s*sy\\%[ntax]\\s\\+region" ||
                \ synIDattr(synID(line("."),col("."),1),"name") =~? "comment\\|string"'
endif

