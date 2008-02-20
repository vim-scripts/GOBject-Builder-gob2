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
