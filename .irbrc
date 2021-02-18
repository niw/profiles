begin
  if RUBY_VERSION < '1.9.0'
    $KCODE='u'
  end

  require 'pp'

  require 'irb/completion'
  require 'irb/ext/save-history'

  # --readline
  IRB.conf[:USE_READLINE] = true

  # --prompt-mode simple
  IRB.conf[:PROMPT_MODE] = :SIMPLE
  IRB.conf[:SAVE_HISTORY] = 100

  # See <http://bugs.ruby-lang.org/issues/show/1556>.
  # This is a patch to fix the bug in same way.
  if RUBY_VERSION == '1.8.7' &&
     IRB::HistorySavingAbility.respond_to?(:create_finalizer)
    module IRB
      class << self
        def irb_at_exit
          @CONF[:AT_EXIT].each{|hook| hook.call} if @CONF[:AT_EXIT]
        end
      end

      # NOTE See `/lib/irb.rc`.
      # I know this is not good, but there are no goot ways to patch
      # `IRB.start` from here because this method itself is called from there.
      # This hack if the caller can be assumed `IRB.start`, run `IRB.irb_at_exit`
      # at `eval_input` level.
      class Irb
        alias :_eval_input :eval_input
        def eval_input
          if caller.first =~ /irb.rb:[0-9]+:in `start'/
            begin
              _eval_input
            ensure
              IRB.irb_at_exit
            end
          else
            _eval_input
          end
        end
      end

      module HistorySavingAbility
        class << self
          def extended(obj)
            IRB.conf[:AT_EXIT] ||= []
            IRB.conf[:AT_EXIT].push(create_finalizer)
            obj.load_history
            obj
          end
        end
      end
    end
  end
end

if RUBY_VERSION < '2.7.0'
  begin
    require 'rubygems'
    require 'wirb'
    Wirb.start
  end
end
