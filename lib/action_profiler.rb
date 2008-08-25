require 'ruby-prof'
require 'set'

module ActionController
  module ActionProfiler
    MODES = Set.new(%w(process_time wall_time cpu_time allocations memory gc_runs gc_time))

    # Pass profile=1 query param to profile the page load.
    def action_profiler(&block)
      if !RubyProf.running? && mode = params[:profile]
        if MODES.include?(mode)
          RubyProf.measure_mode = RubyProf.const_get(mode.upcase)
        end

        result = RubyProf.profile(&block)

        if response.body.is_a?(String)
          min_percent = (params[:profile_percent] || 0.05).to_f
          output = StringIO.new

          RubyProf::CallTreePrinter.new(result).print(output, :min_percent => min_percent)
          response.body.replace(output.string)

          response.headers['Content-Length'] = response.body.size
          response.headers['Content-Type'] = 'application/octet-stream'
          response.headers['Content-Disposition'] = %(attachment; filename="#{File.basename(request.path)}.tree")
        end
      else
        yield
      end
    end
  end
end
