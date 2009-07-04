if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet (fun (function($){<CR>".st.et."<CR><BS>})(jQuery);"
exec "Snippet $( $(function(){<CR>".st.et."<CR><BS>});"
exec "Snippet $.fn $.fn.".st."functionName".et." = function(options){<CR>"."var options = $.extend({<CR>".st."options".et."<CR>"."}, options);<CR><CR>"."$(this).each(function(){<CR>".st.et."<CR>"."});<CR>"."return $(this);<CR>"."};"
exec "Snippet $.each $.each(".st."enumerable".et.", function(index) {<CR>".st.et."<CR>"."});"
