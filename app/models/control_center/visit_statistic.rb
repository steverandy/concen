# All time data are stored in UTC time.
# TODO: Create cron job to calculate unique_visits on every hour.

module ControlCenter
  class VisitStatistic
    include Mongoid::Document
  
    embeds_many :referrers, :class_name => "ControlCenter::Referrer"
    embeds_many :resolutions, :class_name => "ControlCenter::Resolution"
    embeds_many :browsers, :class_name => "ControlCenter::Browser"
    embeds_many :operating_systems, :class_name => "ControlCenter::OperatingSystem"
    embeds_many :locations, :class_name => "ControlCenter::Location"
  
    field :hour, :type => Time
    field :day, :type => Time
    field :month, :type => Time
    field :url, :type => String
    field :visits, :type => Integer, :default => 1
    field :unique_visits, :type => Integer
    field :total_unique_visits, :type => Integer
    field :title, :type => String
    field :hourly_location_done, :type => Boolean, :default => false
    field :monthly_referrer_done, :type => Boolean, :default => false
    field :monthly_resolution_done, :type => Boolean, :default => false
    field :monthly_browser_done, :type => Boolean, :default => false
    field :monthly_operating_system_done, :type => Boolean, :default => false
    field :monthly_location_done, :type => Boolean, :default => false
    field :timezone, :type => String
  
    index :hour
    index :url
    index :timestamp
  
    def self.visits_for_current(length, *args)
      options = args.extract_options!
      current_time = Time.zone.now
      if length == :hour
        current_hour = Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)
        if options[:unique]
          return Visit.only(:visitor_id).where(:timestamp.gte => current_hour, :timestamp.lt => current_hour + 1.hour).group.count
        else
          return statistic = VisitStatistic.where(:hour => current_hour).sum(:visits).to_i || 0
        end
      end
      if length == :day
        current_day = Time.zone.local(current_time.year, current_time.month, current_time.day)
        start_hour = Time.zone.local(current_time.year, current_time.month, current_time.day, 0)
        end_hour = Time.zone.local(current_time.year, current_time.month, current_time.day, 23)
        if options[:unique]
          return Visit.only(:visitor_id).where(:timestamp.gte => start_hour, :timestamp.lt => end_hour + 1.hour).group.count || 0
        else
          return VisitStatistic.where(:hour.gte => start_hour, :hour.lte => end_hour).sum(:visits).to_i || 0
        end
      end
      if length == :month
        current_month = Time.zone.local(current_time.year, current_time.month)
        start_month = Time.zone.local(current_time.year, current_time.month)
        end_month = Time.zone.local(current_time.year, current_time.month, Time.days_in_month(7, 2010), 23)
        if options[:unique]
          return Visit.only(:visitor_id).where(:timestamp.gte => start_month, :timestamp.lt => end_month + 1.hour).group.count || 0
        else
          return VisitStatistic.where(:hour.gte => start_month, :hour.lte => end_month).sum(:visits).to_i || 0
        end
      end
    end
  
    def self.visits_for_last_24_hours(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      current_hour = Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)
      all_visits = []
      (0..23).each do |num|
        if options[:unique]
          all_visits << Visit.only(:visitor_id).where(:timestamp.gte => current_hour - num.hour, :timestamp.lt => current_hour - num.hour + 1.hour).group.count
        else
          all_visits << VisitStatistic.where(:hour => current_hour - num.hour).sum(:visits).to_i || 0
        end
      end
      return all_visits
    end
  
    def self.popular_pages(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      statistic = Visit.only(:url).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
      statistic.first(options[:limit] || 5)
    end
  
    def self.resolutions(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      statistic = Visit.only(:screen_height, :screen_width).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
      statistic.first(options[:limit] || 5)
    end
  
    def self.referrers(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      if options[:unique_domain]
        statistic = Visit.only(:referrer_domain).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
        statistic.delete_if {|x| x["referrer_domain"].blank? }
      else
        statistic = Visit.only(:referrer_url).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
        statistic.delete_if {|x| x["referrer_url"].blank? }
      end
      statistic.first(options[:limit] || 5)
    end
  
    def self.browsers(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      if options[:version]
        statistic = Visit.only(:browser, :browser_version).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
      else
        statistic = Visit.only(:browser).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
      end
      statistic.first(options[:limit] || 5)
    end
  
    def self.operating_systems(*args)
      options = args.extract_options!
      current_time = Time.zone.now
      statistic = Visit.only(:os).where(:timestamp.gte => current_time - 2.years, :timestamp.lte => current_time).aggregate.sort! {|x,y| y["count"] <=> x["count"] }
      statistic.first(options[:limit] || 5)
    end
  
    def self.locations(*args)
      options = args.extract_options!
      current_time = Time.now.utc
      current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
      map = 
        "function() {
          this.locations.forEach(function(location){
            emit({country: location.country, country_code: location.country_code}, {count: location.count});
          });
        }"
      reduce = 
        "function(key, values) {
          var total = 0;
          values.forEach(function(value){                  
            total += value.count;
          });
          return {count: total};
        };"
      if VisitStatistic.where(:hourly_location_done => true, :hour.lte => current_hour).to_a.count > 0
        result = VisitStatistic.collection.map_reduce(map, reduce, :query => {"hourly_location_done" => true, "hour" => {"$lte" => current_hour}}).find().to_a
        result.sort! {|x,y| y["value"]["count"].to_i <=> x["value"]["count"].to_i }
      else
        return false
      end
    end
  end
end