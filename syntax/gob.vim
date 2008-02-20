" Vim syntax file example
" Put it to ~/.vim/after/syntax/ and tailor to your needs.
if version < 600
  source <sfile>:p:h/c.vim
else
  runtime! syntax/c.vim
endif


if (g:load_doxygen_syntax || b:load_doxygen_syntax)
  runtime! syntax/doxygen.vim
endif

" vim: set ft=vim :

