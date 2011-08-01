module ControlCenter
  class Visit
    include Mongoid::Document

    store_in "control_center.visits"

    field :hour, :type => Time
    field :url, :type => String
    field :count, :type => Integer, :default => 1
    field :title, :type => String

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
        end_time = options[:start_time] || Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        start_time = end_time - (hour-1).hours
        available_hours = []

        # Aggregate.
        stats = self.only(:hour).where(:hour.gte => start_time, :hour.lte => end_time).aggregate.map do |s|
          h = s["hour"]
          available_hours << h
          if options[:time_in_integer]
            h = h.to_i
            h *= 1000 if options[:precision] == "millisecond"
          end
          [h, s["count"].to_i]
        end

        # Fill the empty hours.
        (0..hour-1).each do |h|
          hour = (end_time-h.hours)
          unless available_hours.include? hour
            if options[:time_in_integer]
              hour = hour.to_i
              hour *= 1000 if options[:precision] == "millisecond"
            end
            stats << [hour, 0]
          end
        end

        # Sort.
        stats.sort! {|x,y| x[0] <=> y[0]}
      end
    end
  end
end
