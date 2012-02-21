set history save on
set history size 10000
set history filename ~/.gdb_history
set print pretty on
set print static-members off
set charset ASCII

# See http://d.hatena.ne.jp/moriyoshi/20070927/1190910311
define dump_rb_bt
  set $t = ruby_frame
  while $t
    printf "[0x%08x] ", $t
    if $t->last_func
      printf "%s ", rb_id2name($t->last_func)
    else
      printf "..."
    end
    if $t->node.nd_file
      printf "(%s:%d)\n", $t->node.nd_file, ($t->node.flags >> 19) & ((1 << (sizeof(NODE*) * 8 - 19)) - 1)
    else
      printf "(UNKNOWN)\n"
    end
    set $t = $t->prev
  end
end

document dump_rb_bt
  dumps the current frame stack. usage: dump_rb_bt
end
