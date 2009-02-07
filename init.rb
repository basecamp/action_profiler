begin
  gem 'ruby-prof', '>= 0.7.3'
rescue Gem::LoadError
  module MissingActionProfiler
    def action_profiler(*args)
      logger.info "`gem install ruby-prof` to enable action profiling."
      yield if block_given?
    end
  end

  class ActionController::Base
    extend MissingActionProfiler
    include MissingActionProfiler
    logger.info "Action profiling disabled. `gem install ruby-prof` to enable."
  end
else
  require 'action_profiler'
  class ActionController::Base
    include ActionController::ActionProfiler
    logger.info "Action profiling enabled. Add around_filter :action_profiler to ApplicationController then append ?profile=process_time to any URL to profile the page load and download a calltree file. Open it with kcachegrind."
  end
end
