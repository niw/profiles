begin
  require 'rubygems'

  if RUBY_VERSION < '1.9.0'
    $KCODE='u'
  end

  require 'wirble'
  Wirble.init
  Wirble.colorize

  # make save_history not to do Hisotry.to_a.uniq
  class Wirble::History
    alias :save_history_default :save_history
    def save_history
      path, max_size, perms = %w{path size perms}.map { |v| cfg(v) }

      # read lines from history, and truncate the list (if necessary)
      lines = Readline::HISTORY.to_a
      lines = lines[-max_size, -1] if lines.size > max_size

      # write the history file
      real_path = File.expand_path(path)
      File.open(real_path, perms) { |fh| fh.puts lines }
    end
  end
rescue LoadError
  require 'irb/completion'
  ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

  require 'pp'

  require 'irb/ext/save-history'
  IRB.conf[:SAVE_HISTORY] = 100
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
end

# vim:ft=ruby
