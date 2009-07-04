if v:version < 700
	finish
endif

command! Webcolor call s:WebColor()

function! s:WebColor()
	call <SID>ScanWholeBuffer()
	inoremap <ESC> <ESC>:call <SID>ScanLineForColorDefs(line('.'))<CR>
	inoremap <C-C> <C-C>:call <SID>ScanLineForColorDefs(line('.'))<CR>
endfunction

function! s:ScanLineForColorDefs(line_n)
	let matches = matchlist(getline(a:line_n), '#\%(\x\{6}\|\x\{3}\)')
	for m in matches
		call s:AddColorSyntax(m)
	endfor
endfunction

function! s:ScanWholeBuffer()
	let l = 1
	while l <= line('$')
		call <SID>ScanLineForColorDefs(l)
		let l = l + 1
	endwhile
endfunction

function! s:AddColorSyntax(color)
	if a:color =~ '^#\x\{6}$'
		let color = strpart(a:color, 1)
	elseif a:color =~ '^#\x\{3}$'
		let color = substitute(a:color, '^#\(.\)\(.\)\(.\)', '\1\1\2\2\3\3', '')
	else
		return
	endif

	let highlight = 'highlight color' . color . ' guibg=#' . color
	if eval('0x' . color[0:1] . '> 0xAA') && eval('0x' . color[2:3] . '> 0xAA') && eval('0x' . color[4:5] . '> 0xAA')
		let highlight = highlight . ' guifg=black'
	endif
	execute highlight

	let syntax = 'syntax match color' . color . ' "' . a:color . '" display containedin=ALL'
	execute syntax
endfunction
