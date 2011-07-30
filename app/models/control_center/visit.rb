
# # All time data are stored in UTC time.
# TODO: Create cron job to calculate unique_visits on every hour.

module ControlCenter
  class Visit
    include Mongoid::Document

    store_in "control_center.visits"

    field :hour, :type => Time
    field :url, :type => String
    # field :visits, :type => Integer, :default => 1
    field :count, :type => Integer, :default => 1
    field :title, :type => String

    index :hour, :background => true
    index :url, :background => true

    def self.recent(*args)
      options = args.extract_options!
      day = (options[:day] || 30).to_i
      current_time = Time.now
      days = []
      0.upto day-1 do |index|
        if index == 0
          days << (Time.new(current_time.year, current_time.month, current_time.day) + 1.days).to_i * 1000
        end
        days << (Time.new(current_time.year, current_time.month, current_time.day) - index.days).to_i * 1000
      end

      map = <<-EOF
        function() {
          var days = #{days};
          for (index in days) {
            if ( this.hour.getTime() < days[index]) {
              emit(days[parseInt(index+1)], this.count);
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

      query = {:hour => {"$lte" => Time.now}}

      self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true, :query => query).find().to_a
    end
  end
end
