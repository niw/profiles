function! GetVisualRegionString()
	let reg = getreg('a')
	let regtype = getregtype('a')
	silent normal! gv"ay
	let selected = @a
	call setreg('a', reg, regtype)
	return selected
endfunction

function! Alc(word)
	let tmpfile = tempname()
	call system("alc \"" . a:word . "\" > " . tmpfile)
	exec "silent! bot pedit " . tmpfile
	call delete(tmpfile)

	silent! wincmd P
	if &previewwindow
		match none
		syn match Label /\v【[^】]+】/
		syn match Comment /\v｛[^｝]+｝/
		syn match Comment /\v〔[^〕]+〕/
		syn match Operator /\v[〜～~＝◆→［］・]/
		exec "syn match Identifier /\\c" . a:word . "/"
	endif
endfunction

nmap <silent> <S-K> :call Alc(expand("<cword>"))<CR>
vmap <silent> <S-K> :call Alc(GetVisualRegionString())<CR>
