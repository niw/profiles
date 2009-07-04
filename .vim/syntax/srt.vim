syn case ignore
syn match sequenceNumber /\v^[0-9]+$/
syn match time /\v[0-9][0-9]:[0-9][0-9]:[0-9][0-9](\,[0-9][0-9][0-9])?/
syn match arrow /-->/
syn match tag /\v\<\/?[^>]+\>/
hi def link sequenceNumber Title 
hi def link arrow Operator
hi def link time Statement
hi def link tag Comment
