
# # All time data are stored in UTC time.
# TODO: Create cron job to calculate unique_visits on every hour.

module ControlCenter
  class Visit
    include Mongoid::Document

    store_in "control_center.visits"

    field :hour, :type => Time
    field :url, :type => String
    field :count, :type => Integer, :default => 1
    field :title, :type => String
    # field :visits, :type => Integer, :default => 1

    index :hour, :background => true
    index :url, :background => true

    def self.aggregate_count_for(*args)
      options = args.extract_options!
      if day = options[:day]
        start_time = options[:start_time] || Time.now.utc
        day = day.to_i
        days = []
        0.upto day-1 do |index|
          if index == 0
            days << (Time.new(start_time.year, start_time.month, start_time.day) + 1.days).to_i * 1000
          end
          days << (Time.new(start_time.year, start_time.month, start_time.day) - index.days).to_i * 1000
        end

        map = <<-EOF
          function() {
            #{'var times =' + days.to_s}

            for (index in times) {
              if (this.hour.getTime() < times[index]) {
                emit(times[parseInt(index+1)], this.count);
              };
            };
          }
        EOF

        query = {:hour => {"$lte" => start_time}}
      elsif hour = options[:hour]
        hour = hour.to_i
        current_time = Time.now.utc
        start_time = options[:start_time] || Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        end_time = start_time - (hour-1).hours
        map = <<-EOF
          function() {
            emit(this.hour, this.count);
          }
        EOF
        query = {:hour => {"$gte" => end_time, "$lte" => start_time}}
      end

      reduce = <<-EOF
        function(time, counts) {
          var count = 0;
          for (index in counts) { count += counts[index]; };
          return count;
        }
      EOF

      results = self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true, :query => query).find().to_a.first[1]
      results.map do |result|
        [result["_id"].to_i, result["value"].to_i]
      end
    end
  end
end
