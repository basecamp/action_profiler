require 'ruby-prof'
require 'set'

module ActionController
  module ActionProfiler
    MODES = Set.new(%w(process_time wall_time cpu_time allocated_objects))

    def self.included(base)
      base.send :around_filter, :action_profiler
    end

    # Pass profile=1 query param to profile the page load.
    def action_profiler(&block)
      if !RubyProf.running? && mode = params[:profile]
        if MODES.include?(mode)
          RubyProf.measure_mode = RubyProf.const_get(mode.upcase)
        end

        result = RubyProf.profile(&block)

        if response.body.is_a?(String)
          output = StringIO.new
          min_percent = (params[:profile_percent] || 10).to_i
          RubyProf::GraphHtmlPrinter.new(result).print(output, :min_percent => min_percent)

          if output.string =~ /<body>(.*)<\/body>/m
            response.body.sub! '</body>', %(<div id="RubyProf">#{$1}</div></body>)
          else
            ActionController::Base.logger.info "[PROFILE] Non-HTML profile result: #{output.string}"
          end
        else
          ActionController::Base.logger.info '[PROFILE] Non-HTML response body, skipping results'
        end
      else
        yield
      end
    end
  end
end
