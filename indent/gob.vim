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
"setlocal indentkeys& indentkeys+=0=from
setlocal indentkeys+==public\ ,=protected\ ,=private\ ,=property\ ,=%},0\\


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



function IsCBlockHeader(linenum)
  let ret=getline(a:linenum) =~ '^\s*%.*{'
  return  ret
endfunction

function IsHashedLine(linenum)
  let ret=getline(a:linenum) =~ '^#'
  echo "#linenum=" a:linenum " ret=" ret
  return  ret
endfunction

function SkipGobBlanksAndCommentsAndHashedLine(startline)
  let lnum = a:startline
  while lnum>1
    let lnum = SkipGobBlanksAndComments(lnum)
    if (IsHashedLine(lnum))
      let lnum -=1
    else
      break
    endif  
  endwhile
  return lnum
endfunction


function IsLineHasAccess(linenum)
  let ret=getline(a:linenum) =~ '^\s*\(public\|protected\|private\|property\)\s'
"  if (ret)
"    echo "linenum=" a:linenum " ret=" ret " yes"
"  else  
"    echo "linenum=" a:linenum " ret=" ret " no"
"  endif
  return  ret
endfunction

function IsLineHasMethodModifiers(linenum)
  let ret=getline(a:linenum) =~ '^\s*\(virtual\|signal\|override\)'
  "  if (ret)
  "    echo "linenum=" a:linenum " ret=" ret " yes"
  "  else  
  "    echo "linenum=" a:linenum " ret=" ret " no"
  "  endif
  return  ret
endfunction

function! FindPrevAccessLine(startline)
  let lnum = a:startline
  let dirty=0
  while lnum > 1
    let lnum = SkipGobBlanksAndComments(lnum)
    if IsLineHasAccess(lnum)
       return lnum
    elseif getline(lnum) =~ '^\s*class\s'
       return 0
    endif
    let lnum -=1
  endwhile
  return a:startline
endfunction

function! FindPrevCommentHead(startline)
  let lnum = a:startline
  let dirty=0
  while lnum > 1
    let lnum = prevnonblank(lnum)
    if getline(lnum) =~ '^\s*/*'
      return lnum
    elseif getline(lnum) =~ '^\s*\*/$'
      return 0
    endif
    let lnum -=1
  endwhile
  return a:startline
endfunction


function GetGobIndent()

  " Gob is just like C; use the built-in C indenting and then correct a few
  " specific cases.
  let theIndent = cindent(v:lnum)

"  if getline(v:lnum) =~ '^\s**'
"    let retlnum=FindPrevCommentLine(v:lnum -1)
"    echo  "v:lnum=" v:lnum " lnum=" lnum " retlnum=" retlnum " theIndent=" theIndent " cindent(retlnum)=" cindent(retlnum) " indent(retlnum)=" indent(retlnum)
"    if retlnum
"      return indent(retlnum)+1
"    endif
"  endif

  " If we're in the middle of a comment then just trust cindent
  if getline(v:lnum) =~ '^\s*\*'
    return theIndent
  endif

  " Adjust the access line
  if IsLineHasAccess(v:lnum)
    let retlnum=FindPrevAccessLine(v:lnum -1)
"    echo "v:lnum=" v:lnum " lnum=" lnum " retlnum=" retlnum
    if retlnum
"      echo  "v:lnum=" v:lnum " lnum=" lnum " retlnum=" retlnum " cindent(retlnum)=" cindent(retlnum) " indent(retlnum)=" indent(retlnum)
      return indent(retlnum)
    endif
  endif

  " Adjust the lines after method modifiers
  if IsLineHasMethodModifiers(v:lnum -1)
    return indent(v:lnum-1)
  endif


  " find start of previous line, in case it was a continuation line
  " Adjust lines in CBlocks
  let lnum = SkipGobBlanksAndCommentsAndHashedLine(v:lnum - 1)
  let prev = lnum
  while prev > 1
    let next_prev = SkipGobBlanksAndCommentsAndHashedLine(prev - 1)
    if getline(next_prev) !~ ',\s*$'
      break
    endif
    let prev = next_prev
  endwhile

  "echo  "v:lnum=" v:lnum " lnum=" lnum " prev=" prev " cindent(prev)=" cindent(prev) " indent(prev)=" indent(prev)

  if IsCBlockHeader(prev)
    return cindent(prev)
  endif

  

  " Try to align "destroywith", "destroy", "unrefwith", "unref" lines
"  if getline(v:lnum) =~ '^\s*\(destroywith\|destroy\|unrefwith\|unref\)\s'
"    call cursor(v:lnum, 1)
"    silent normal %
"    let lnum = line('.')
"    if lnum < v:lnum
"      while lnum > 1
"        let next_lnum = SkipGobBlanksAndComments(lnum - 1)
"        if getline(lnum) !~ '^\s*\(from\|onerror\|defreturn\)\>'
"              \ && getline(next_lnum) !~ ',\s*$'
"          break
"        endif
"        let lnum = prevnonblank(next_lnum)
"      endwhile
"      return indent(lnum) + &sw
"    endif
"  endif

  " Try to align the line after "destroywith", "destroy", "unrefwith", "unref"
  "let lnum=FindPrevAccessLine(v:lnum)
  "let thIndent = indent(lnum)

  " Try to align "onerror" and "defreturn" lines for methods and "from" for
  " classes.
"  if getline(v:lnum) =~ '^\s*\from\>'
"        \ && getline(lnum) !~ '^\s*\from\>'
"    let theIndent = theIndent + &sw
"  endif

"  " correct for continuation lines of "onerror", "defreturn" and "from"
"  let cont_kw = matchstr(getline(prev),
"        \ '^\s*\zs\(onerror\|defreturn\|from\)\>\ze.*,\s*$')
"  if strlen(cont_kw) > 0
"    let amount = strlen(cont_kw) + 1
"    if getline(lnum) !~ ',\s*$'
"      let theIndent = theIndent - (amount + &sw)
"      if theIndent < 0
"        let theIndent = 0
"      endif
"    elseif prev == lnum
"      let theIndent = theIndent + amount
"      if cont_kw ==# 'onerror'
"        let theIndent = theIndent + &sw
"      endif
"    endif
"  elseif getline(prev) =~ '^\s*\(onerror\|defreturn\|from\)\>'
"        \ && (getline(prev) =~ '{\s*$'
"        \  || getline(v:lnum) =~ '^\s*{\s*$')
"    let theIndent = theIndent - &sw
"  endif

"  " When the line starts with a }, try aligning it with the matching {,
"  " skipping over "from", "onerror" and "defreturn" clauses.
"  if getline(v:lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$'
"    call cursor(v:lnum, 1)
"    silent normal %
"    let lnum = line('.')
"    if lnum < v:lnum
"      while lnum > 1
"        let next_lnum = SkipGobBlanksAndComments(lnum - 1)
"        if getline(lnum) !~ '^\s*\(from\|onerror\|defreturn\)\>'
"              \ && getline(next_lnum) !~ ',\s*$'
"          break
"        endif
"        let lnum = prevnonblank(next_lnum)
"      endwhile
"      return indent(lnum)
"    endif
"  endif

"  " Below a line starting with "}" never indent more.  Needed for a method
"  " below a method with an indented "throws" clause.
"  let lnum = SkipGobBlanksAndComments(v:lnum - 1)
"  if getline(lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$' && indent(lnum) < theIndent
"    let theIndent = indent(lnum)
"  endif

  return theIndent
endfunction

" vi: sw=2 et
