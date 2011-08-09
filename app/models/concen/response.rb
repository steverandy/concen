module Concen
  class Response
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in self.name.underscore.gsub("/", ".").pluralize

    def self.aggregate_average_runtime(*args)
      options = args.extract_options!

      if options[:type]
        runtime_type = "#{options[:type]}_runtime"
      else
        runtime_type = "total_runtime"
      end

      map = <<-EOF
        function() {
          emit(this.controller + "#" + this.action, this.#{runtime_type});
        }
      EOF

      reduce = <<-EOF
        function(controller_action, runtimes) {
          var runtime = 0;
          for (index in runtimes) { runtime += runtimes[index]; };
          return runtime/runtimes.length;
        }
      EOF

      results = self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true)["results"]
      results = results.sort {|x,y| y["value"] <=> x["value"]}
      results = results[0..options[:limit]-1] if options[:limit]
      results = results.map do |result|
        [result["_id"], result["value"]]
      end
    end
  end
end
