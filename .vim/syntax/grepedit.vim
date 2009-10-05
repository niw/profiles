syntax region GEBlock           matchgroup=FileLine start=/^# ============================================================ .*$/        end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine

unlet! b:current_syntax
let b:ruby_no_expensive = 1
syntax include @Ruby syntax/ruby.vim
syntax region GEBlockRuby       matchgroup=FileLine start=/^# ============================================================ .*\.rb$/    end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@Ruby

let b:current_syntax = 'grepedit'
unlet! b:current_syntax
syntax include @Css syntax/css.vim
syntax region GEBlockCss      matchgroup=FileLine start=/^# ============================================================ .*\.css$/ end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@Css


unlet! b:current_syntax
syntax include @Javascript syntax/javascript.vim
syntax region GEBlockJavascript matchgroup=FileLine start=/^# ============================================================ .*\.js$/    end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@Javascript

unlet! b:current_syntax
syntax include @Java syntax/java.vim
syntax region GEBlockJava matchgroup=FileLine start=/^# ============================================================ .*\.java$/    end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@Java

unlet! b:current_syntax
syntax include @ERuby syntax/eruby.vim
syntax region GEBlockERuby      matchgroup=FileLine start=/^# ============================================================ .*\.\(rhtml\|erb\)$/ end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@ERuby

unlet! b:current_syntax
syntax include @Html syntax/html.vim
syntax region GEBlockHtml      matchgroup=FileLine start=/^# ============================================================ .*\.html$/ end=/\(^# ============================================================ .*$\)\@=\|\%$/ keepend transparent contains=FileLine,@Html


highlight link FileLine Comment
