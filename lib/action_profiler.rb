require 'ruby-prof'

module ActionController
  module ActionProfiler
    def self.included(base)
      base.send :around_filter, :action_profiler
    end

    # Pass profile=1 query param to profile the page load.
    def action_profiler(&block)
      if !RubyProf.running? && params[:profile]
        result = RubyProf.profile(&block)

        output = StringIO.new
        RubyProf::GraphHtmlPrinter.new(result).print(output, :min_percent => 10)

        if output.string =~ /<body>(.*)<\/body>/m
          response.body.sub! '</body>', %(<div id="RubyProf">#{$1}</div></body>)
        end
      else
        yield
      end
    end
  end
end
