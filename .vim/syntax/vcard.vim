" Vim syntax file
" Language:	VCard
" Maintainer:	L. Husar <lh3@atlas.cz>
" Last Change:	12/14/2005 10:16AM


" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if version >= 600
  setlocal iskeyword+=.
else
  set iskeyword+=.
endif

syn case ignore

"numbers
syn match VCPhone	"\(+\)\{0,1\}\(\d\+\s\{0,1\}\)\+"

"emails
"syn match VCEmail	"[a-zA-Z0-9.-]\{1,\}@[a-zA-Z0-9.-]\{1,\}"
syn match VCEmail	"[a-zA-Z][a-zA-Z0-9._]*@\S*"

"vcard items
syn match VCItem      "^\w\{1,\}:"
syn match VCItem      "^[a-zA-Z;=-]\{1,\}:"

" vcard begin & end, etc.
syn match VCStatement	"^BEGIN:VCARD.*$"
syn match VCStatement	"^END:VCARD.*$"
syn match VCStatement	"^.*VERSION:.*$"

"syn region  basicString		start=+"+  end=+"+  
"syn region  basicString		start=+'+  end=+'+  
"syn region  basicString		start=+\\+  end=+\\+  

"syn region  basicComment	start="REM\s" end="$" contains=basicTodo
"syn region  basicComment	start="*" end="$" contains=basicTodo


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_basic_syntax_inits")
  if version < 508
    let did_basic_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink xx		Label
  HiLink basicConditional	Conditional
  HiLink basicRepeat		Repeat
  HiLink VCStatement		Comment
  HiLink VCPhone		Number
  HiLink basicError		Error
  HiLink VCItem		        Statement
  HiLink VCEmail		String
  HiLink xx		Special
  HiLink basicTodo		Todo
  HiLink basicFunction		Identifier
  HiLink basicTypeSpecifier     Type
  HiLink basicFilenumber        basicTypeSpecifier
  HiLink basicComment		Comment
  "hi basicMathsOperator term=bold cterm=bold gui=bold

  delcommand HiLink
endif

let b:current_syntax = "vcard"

" vim: ts=8
