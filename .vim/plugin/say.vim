if system('uname') =~? "Darwin"
  " Sayコマンド
  noremap <silent> say :call system("say " . expand("<cword>"))<cr>
endif
