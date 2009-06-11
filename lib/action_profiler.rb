require 'ruby-prof'
require 'set'

module ActionController
  module ActionProfiler
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Add an around_filter :action_profiler to ApplicationController. Examples:
      #
      #   action_profiler :if => lambda { |c| c.request.subdomains.first == 'live' }
      #
      #   PROFILER_IPS = ['127.0.0.1']
      #   action_profiler :if => lambda { |c| PROFILER_IPS.include?(c.request.remote_ip) }
      def action_profiler(options = {})
        around_filter :action_profiler, options
      end
    end

    protected
      MODES = %w(process_time wall_time cpu_time allocations memory gc_runs gc_time).to_set

      def action_profiler(&block)
        if !RubyProf.running? && mode = params[:profile]
          if MODES.include?(mode)
            RubyProf.measure_mode = RubyProf.const_get(mode.upcase)
          end

          result = RubyProf.profile(&block)

          if response.body.is_a?(String)
            min_percent = (params[:profile_percent] || 0.01).to_f
            output = StringIO.new

            RubyProf::CallTreePrinter.new(result).print(output, :min_percent => min_percent)
            response.body.replace(output.string)

            response.status = '200 OK'
            response.headers.delete('Location')

            response.headers['Content-Length'] = response.body.size
            response.headers['Content-Type'] = 'application/octet-stream'
            response.headers['Content-Disposition'] = %(attachment; filename="#{File.basename(request.path)}.#{mode}.tree")
          end
        else
          yield
        end
      end
  end
end
