" Denite requires Neovim or Vim 8.0, and +python3.
" Early exit if it doesn't support Denite.
if ! has('python3') || !has('nvim') && v:version < 800
  finish
endif

" Denite customization
"{{{
" `jj` to enter normal mode.
call denite#custom#map('insert', 'jj', '<denite:enter_mode:normal>', 'noremap')
" Immediately exit Denite by <ESC> anyways.
call denite#custom#map('normal', '<ESC>', '<denite:quit>', 'noremap')

" Open window top top left. Default is 'botright'.
call denite#custom#option('default', 'direction', 'topleft')
" Narrow window. Default is 20.
call denite#custom#option('default', 'winheight', 10)
"}}}

" Key Mappings
" {{{
nmap f [Denite]
nnoremap [Denite] <Nop>

nnoremap <silent> [Denite]f :<C-u>Denite buffer file_mru file/rec<CR>
nnoremap <silent> [Denite]k :<C-u>DeniteBufferDir file<CR>
nnoremap <silent> [Denite]l :<C-u>Denite file_mru<CR>

function! s:ExecuteCommandOnCR(command)
  if &buftype == ''
    execute a:command
  else
    call feedkeys("\r", 'n')
  endif
endfunction

nnoremap <silent> <CR> :<C-u>call <SID>ExecuteCommandOnCR('Denite buffer')<CR>
" }}}

" vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
