function! s:CheckTarget()
  let vimproc_paths = globpath(&runtimepath, 'autoload/vimproc.vim')
  if vimproc_paths ==# "" || vimproc#util#is_windows() || has('win32unix') || !executable('make')
    return
  endif

  let target_file = vimproc#util#is_mac() ? 'vimproc_mac.so' : 'vimproc_unix.so'
  let make_file   = vimproc#util#is_mac() ? 'make_mac.mak' : 'make_unix.mak'
  let src_files   = ['proc.c', 'vimstack.c']

  for path in split(vimproc_paths, '\n')
    let autoload_path = fnamemodify(path, ':p:h')
    let vimproc_path = fnamemodify(path, ':p:h:h')

    let target_file_time = getftime(autoload_path . '/' . target_file)
    for src_file in ['proc.c', 'vimstack.c']
      if target_file_time < getftime(autoload_path . '/' . src_file)
        echomsg 'Found ' . target_file . ' is obsoleted, make it again...'
        call system('cd ' . shellescape(vimproc_path) .
        \  ' && make -f ' . make_file . ' clean' .
        \  ' && make -f ' . make_file)
        if v:shell_error
          echomsg 'Filed to make ' . target_file . '.'
          echomsg 'Please make it by hand, otherwise some plugin may not work properly.'
        else
          echomsg 'Done.'
        endif
        break
      endif
    endfor
  endfor
endfunction

call s:CheckTarget()
