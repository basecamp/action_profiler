begin
  require 'action_profiler'
  ActionController::Base.send :include, ActionController::ActionProfiler
  ActionController::Base.logger.info "Action profiling enabled. Add around_filter :action_profiler to ApplicationController then append ?profile=true to any URL to embed a call graph."
rescue LoadError
  class ActionController::Base
    def action_profiler(*args)
      logger.info "`gem install ruby-prof` to enable action profiling."
      yield
    end
  end
end
