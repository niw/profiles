syn case ignore
syn region wikiH1 start="^="    end="="
syn region wikiH2 start="^=="   end="=="
syn region wikiH3 start="^==="  end="==="
syn match wikiOperator /[\/@\*\:]/
syn region wikiBlanket start="\["  end="\]"
hi def link wikiH1 Title 
hi def link wikiH2 Title 
hi def link wikiH3 Title 
hi def link wikiOperator Operator
hi def link wikiBlanket Comment
