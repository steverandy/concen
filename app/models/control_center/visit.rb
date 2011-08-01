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

    def self.aggregate_count_by_url(*args)
      options = args.extract_options!
      stats = self.only(:url).aggregate.map do |s|
        [s["url"], s["count"].to_i]
      end
      stats.sort! {|x,y| y[1] <=> x[1]}
      stats[0..options[:limit]-1] if options[:limit]
    end

    def self.aggregate_count_by_time(*args)
      options = args.extract_options!
      if hour = options[:hour]
        hour = hour.to_i
        current_time = Time.now.utc
        start_time = options[:start_time] || Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        end_time = start_time - (hour-1).hours
        stats = self.only(:hour).where(:hour.gte => end_time, :hour.lte => start_time).aggregate.map do |s|
          hour = s["hour"]
          if options[:time_in_integer]
            hour = hour.to_i
            hour *= 1000 if options[:precision] == "millisecond"
          end
          [hour, s["count"].to_i]
        end
      end
    end
  end
end
