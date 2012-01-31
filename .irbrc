begin
  if RUBY_VERSION < '1.9.0'
    $KCODE='u'
  end

  require 'irb/completion'
  unless 'macirb' == File.basename($0)
    ARGV.concat ['--readline', '--prompt-mode', 'simple']
  end

  require 'pp'

  require 'irb/ext/save-history'
  IRB.conf[:SAVE_HISTORY] = 100
  IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
rescue Object => e
  STDERR.puts "Fail to initialize irb. #{e.inspect}"
end

begin
  require 'rubygems'
  require 'wirb'
  Wirb.start
rescue LoadError
  STDERR.puts 'Fail to load wirb gem.'
rescue Object => e
  STDERR.puts "Fail to start wirb gem. #{e.inspect}"
end

# vim:ft=ruby
