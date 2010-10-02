if filewritable(expand('~/Dropbox'))
	let s:default_wiki = {}
	let s:default_wiki.path = '~/Dropbox/vimwiki'
	let s:default_wiki.path_html = '~/Dropbox/vimwiki/html'

	let g:vimwiki_list = [s:default_wiki]
endif
