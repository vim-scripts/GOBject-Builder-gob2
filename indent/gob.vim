" Vim indent file
" Language:	GObject Builder (Gob)
" Maintainer:	Ding-Yi Chen <dchen@redhat.com>
" Modified from java.vim 
" Last Change:  2008 Feb 08

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" Use cindent.
setlocal cindent 

" The "from"  lines start off with the wrong indent.
setlocal indentkeys& indentkeys+=0=from

" Set the function to do the work.
setlocal indentexpr=GetGobIndent()

let b:undo_indent = "set cin< cino< indentkeys< indentexpr<"

" Only define the function once.
if exists("*GetGobIndent")
  finish
endif

function! SkipGobBlanksAndComments(startline)
  let lnum = a:startline
  while lnum > 1
    let lnum = prevnonblank(lnum)
    if getline(lnum) =~ '\*/\s*$'
      while getline(lnum) !~ '/\*' && lnum > 1
        let lnum = lnum - 1
      endwhile
      if getline(lnum) =~ '^\s*/\*'
        let lnum = lnum - 1
      else
        break
      endif
    elseif getline(lnum) =~ '^\s*//'
      let lnum = lnum - 1
    else
      break
    endif
  endwhile
  return lnum
endfunction


function GetGobIndent()

  " Gob is just like C; use the built-in C indenting and then correct a few
  " specific cases.
  let theIndent = cindent(v:lnum)

  " If we're in the middle of a comment then just trust cindent
  if getline(v:lnum) =~ '^\s*\*'
    return theIndent
  endif

  " find start of previous line, in case it was a continuation line
  let lnum = SkipGobBlanksAndComments(v:lnum - 1)
  let prev = lnum
  while prev > 1
    let next_prev = SkipGobBlanksAndComments(prev - 1)
    if getline(next_prev) !~ ',\s*$'
      break
    endif
    let prev = next_prev
  endwhile

  " Try to align "onerror" and "defreturn" lines for methods and "from" for
  " classes.
  if getline(v:lnum) =~ '^\s*\from\>'
        \ && getline(lnum) !~ '^\s*\from\>'
    let theIndent = theIndent + &sw
  endif

  " correct for continuation lines of "onerror", "defreturn" and "from"
  let cont_kw = matchstr(getline(prev),
        \ '^\s*\zs\(onerror\|defreturn\|from\)\>\ze.*,\s*$')
  if strlen(cont_kw) > 0
    let amount = strlen(cont_kw) + 1
    if getline(lnum) !~ ',\s*$'
      let theIndent = theIndent - (amount + &sw)
      if theIndent < 0
        let theIndent = 0
      endif
    elseif prev == lnum
      let theIndent = theIndent + amount
      if cont_kw ==# 'onerror'
        let theIndent = theIndent + &sw
      endif
    endif
  elseif getline(prev) =~ '^\s*\(onerror\|defreturn\|from\)\>'
        \ && (getline(prev) =~ '{\s*$'
        \  || getline(v:lnum) =~ '^\s*{\s*$')
    let theIndent = theIndent - &sw
  endif

  " When the line starts with a }, try aligning it with the matching {,
  " skipping over "from", "onerror" and "defreturn" clauses.
  if getline(v:lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$'
    call cursor(v:lnum, 1)
    silent normal %
    let lnum = line('.')
    if lnum < v:lnum
      while lnum > 1
        let next_lnum = SkipGobBlanksAndComments(lnum - 1)
        if getline(lnum) !~ '^\s*\(from\|onerror\|defreturn\)\>'
              \ && getline(next_lnum) !~ ',\s*$'
          break
        endif
        let lnum = prevnonblank(next_lnum)
      endwhile
      return indent(lnum)
    endif
  endif

  " Below a line starting with "}" never indent more.  Needed for a method
  " below a method with an indented "throws" clause.
  let lnum = SkipGobBlanksAndComments(v:lnum - 1)
  if getline(lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$' && indent(lnum) < theIndent
    let theIndent = indent(lnum)
  endif

  return theIndent
endfunction

" vi: sw=2 et
