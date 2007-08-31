unless RAILS_ENV == 'production'
  begin
    require 'action_profiler'
    ActionController::Base.send :include, ActionController::ActionProfiler
  rescue LoadError
    ActionController::Base.logger.info "`gem install ruby-prof` to enable action profiling! Then add ?profile=true to any URL to embed a call graph profiling the page load."
  end
end
