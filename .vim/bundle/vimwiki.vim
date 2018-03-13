if filewritable(expand('~/Dropbox/Library/Application Support'))
  let s:default_wiki = {}
  let s:default_wiki.path = '~/Dropbox/Library/Application Support/vimwiki'
  let s:default_wiki.path_html = '~/Dropbox/Library/Application Support/vimwiki/html'

  let g:vimwiki_list = [s:default_wiki]
endif
