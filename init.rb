class ActionController::Base
  begin
    require 'action_profiler'
    include ActionProfiler
    logger.info "Action profiling enabled. Add around_filter :action_profiler to ApplicationController then append ?profile=process_time to any URL to profile the page load and download a calltree file. Open it with kcachegrind."
  rescue LoadError
    def action_profiler(*args)
      logger.info "`gem install ruby-prof` to enable action profiling."
      yield
    end
  end
end
