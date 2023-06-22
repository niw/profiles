" Denite requires Neovim or Vim 8.0, and +python3.
" Early exit if it doesn't support Denite.
if !((has('nvim') || v:version >= 800) && has('python3'))
  finish
endif

" Denite customization
"{{{
autocmd FileType denite call s:SetDeniteKeyMappings()

function! s:SetDeniteKeyMappings() abort
  " <CR> to do action.
  nnoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  " `i` to open filter buffer.
  nnoremap <silent><buffer><expr> i denite#do_map('open_filter_buffer')
  " <Space> to toggle cursor candidate selection.
  nnoremap <silent><buffer><expr> <Space> denite#do_map('toggle_select')
  " <ESC> to exit denite.
  nnoremap <silent><buffer><expr> <ESC> denite#do_map('quit')
  " <C-w> to move up path.
  nnoremap <silent><buffer><expr> <C-w> denite#do_map('move_up_path')
endfunction

autocmd FileType denite-filter call s:SetDeniteFilterKeyMappings()

function! s:SetDeniteFilterKeyMappings() abort
  " <CR> to do action in filter buffer.
  inoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  " `jj` to exit filter buffer in insert mode.
  imap <silent><buffer> jj <Plug>(denite_filter_quit)
  " <ESC> to immediately exit filter buffer in insert mode.
  imap <silent><buffer> <ESC> <Plug>(denite_filter_quit)
endfunction

autocmd FileType denite-filter call s:DisableDeopleteAutoComplete()

function! s:DisableDeopleteAutoComplete() abort
  " TODO: Find a better way to disable auto_complete,
  " also find a better way to find if there is deoplete or not.
  if exists('g:deoplete#_initialized')
    deoplete#custom#buffer_option('auto_complete', v:false)
  endif
endfunction

" Open window top top left. Default is 'botright'.
call denite#custom#option('default', 'direction', 'topleft')
call denite#custom#option('default', 'filter_split_direction', 'topleft')

" Narrow window. Default is 20.
call denite#custom#option('default', 'winheight', 10)
"}}}

" Key Mappings
"{{{
nmap f [Denite]
nnoremap [Denite] <Nop>

nnoremap <silent> [Denite]f :<C-u>Denite buffer file_mru file/rec<CR>
nnoremap <silent> [Denite]k :<C-u>DeniteBufferDir file<CR>
nnoremap <silent> [Denite]l :<C-u>Denite file_mru<CR>
"}}}

" vim: tabstop=2 shiftwidth=2 textwidth=0 expandtab foldmethod=marker nowrap
