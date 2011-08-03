module ControlCenter
  class Visit
    include Mongoid::Document

    store_in self.name.underscore.gsub("/", ".").pluralize

    field :hour, :type => Time
    field :url, :type => String
    field :count, :type => Integer, :default => 1
    field :title, :type => String

    index :hour, :background => true
    index :url, :background => true

    def self.aggregate_count_by_url(*args)
      options = args.extract_options!

      map = <<-EOF
        function() {
          emit(this.url, this.count);
        }
      EOF

      reduce = <<-EOF
        function(time, counts) {
          var count = 0;
          for (index in counts) { count += counts[index]; };
          return count;
        }
      EOF

      results = self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true)["results"]
      results = results.sort {|x,y| y["value"] <=> x["value"]}
      results = results[0..options[:limit]-1] if options[:limit]
      results = results.map do |result|
        [result["_id"], result["value"].to_i]
      end
    end

    def self.aggregate_count_by_time(*args)
      options = args.extract_options!
      if hour = options[:hour]
        hour = hour.to_i
        current_time = Time.now.utc
        end_time = options[:start_time] || Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        start_time = end_time - (hour-1).hours
        hours = []
        (0..hour-1).each do |h|
          hours << (end_time - h.hours).to_i
        end

        map = <<-EOF
          function() {
            var hours = #{hours.to_json};
            for (index in hours) {
              if (this.hour.getTime() == hours[index]*1000) {
                emit(hours[index], this.count);
              } else {
                emit(hours[index], 0);
              };
            };

          }
        EOF

        reduce = <<-EOF
          function(time, counts) {
            var count = 0;
            for (index in counts) { count += counts[index]; };
            return count;
          }
        EOF

        query = {:hour => {"$gte" => start_time, "$lte" => end_time}}

        results = self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true, :query => query)["results"]
        results = results.sort { |x,y| x["id"] <=> y["id"] }
        results = results.map do |result|
          time = result["_id"].to_i
          time *= 1000 if options[:precision] == "millisecond"
          [time, result["value"].to_i]
        end
      end
    end
  end
end
