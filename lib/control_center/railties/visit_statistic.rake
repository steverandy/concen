namespace :control_center do

  namespace :visit_statistic do
    
    desc "Load custom environment for visit_statisitc."
    task :custom_environment => :environment do
      Time.zone = 'UTC' # All time must be in UTC
      GeoIp.api_key = ControlCenter.geoip_api_key # Set GeoIp API key.
    end
  
    # wipe_visit is temporarily disabled until all views are complete.
    desc "Perform all visit statistic tasks."
    task :all => [
      :fix_unknown_ie_version,
      :create_daily_visit_statistic,
      :create_monthly_visit_statistic,
      :hourly_unique_visit,
      :daily_unique_visit,
      :monthly_unique_visit,
      :hourly_location,
      :monthly_referrer,
      :monthly_resolution,
      :monthly_browser,
      :monthly_operating_system,
      :monthly_location
    ] do
    end
  
    desc "Add browser version for Internet Explorer browsers. It is a fix for a bug where user agent didn't parse browser version correctly."
    task :fix_unknown_ie_version => :custom_environment do      
      targets = ControlCenter::Visit.where(:browser => 'Internet Explorer', :browser_version => '')
      for target in targets
        target.browser_version = Agent.new(target.user_agent).version
        target.save
      end
    end

    desc "Use this task to create initial daily visit statistics."
    task :create_daily_visit_statistic => :custom_environment do
      current_time = Time.now.utc
      current_day = Time.utc(current_time.year, current_time.month, current_time.day)
      first_visit = ControlCenter::Visit.where(:timestamp.exists => true).asc(:timestamp).first
      last_visit = ControlCenter::Visit.where(:timestamp.exists => true).asc(:timestamp).last
      if first_visit && last_visit
        start_day = Time.utc(first_visit.timestamp.year, first_visit.timestamp.month, first_visit.timestamp.day)
        end_day = Time.utc(last_visit.timestamp.year, last_visit.timestamp.month, last_visit.timestamp.day)
        (0..((end_day - start_day).to_i / (60*60*24))).each do |day_count|
          day = start_day + day_count.day
          puts day unless Rails.env == 'production'
          for visit in ControlCenter::Visit.only(:url).where(:timestamp.gte => day, :timestamp.lt => day + 1.day).group
            puts visit['url'] unless Rails.env == 'production'
            visit_statistic = ControlCenter::VisitStatistic.where(:day => day, :url => visit['url'])
            if visit_statistic.count < 1
              ControlCenter::VisitStatistic.create(:url => visit['url'], :day => day, 
                :visits => visit['group'].count,
                :title => ControlCenter::VisitStatistic.where(:hour.gte => day, :hour.lt => day + 1.day, :url => visit['url']).asc(:hour).last.title
              )
            end
          end   
        end
      end
    end

    desc "Use this task to create initial monthly visit statistics."
    task :create_monthly_visit_statistic => :custom_environment do
      current_time = Time.now.utc
      current_month = Time.utc(current_time.year, current_time.month)
      first_visit = ControlCenter::Visit.where(:timestamp.exists => true).asc(:timestamp).first
      last_visit = ControlCenter::Visit.where(:timestamp.exists => true).asc(:timestamp).last
      if first_visit && last_visit
        start_month = Time.utc(first_visit.timestamp.year, first_visit.timestamp.month)
        end_month = Time.utc(last_visit.timestamp.year, last_visit.timestamp.month)
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          puts month unless Rails.env == 'production'
          for visit in ControlCenter::Visit.only(:url).where(:timestamp.gte => month, :timestamp.lt => month + 1.month).group
            puts visit['url'] unless Rails.env == 'production'
            visit_statistic = ControlCenter::VisitStatistic.where(:month => month, :url => visit['url'])
            if visit_statistic.count < 1
              ControlCenter::VisitStatistic.create(:url => visit['url'], :month => month, 
                :visits => visit['group'].count,
                :title => ControlCenter::VisitStatistic.where(:hour.gte => month, :hour.lt => month + 1.month, :url => visit['url']).asc(:hour).last.title
              )
            end
          end   
        end
      end
    end
  
    desc "Calculate hourly unique visits."
    task :hourly_unique_visit => :custom_environment do
      if first_visit_statistic = ControlCenter::VisitStatistic.where(:hour.exists => true, :unique_visits.exists => false).asc(:hour).first
        current_time = Time.now.utc
        current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        start_hour = first_visit_statistic.hour
        end_hour = current_hour
        (0..((end_hour - start_hour).to_i / 3600)).each do |hour_count|
          hour = start_hour + hour_count.hour
          visit_statistics = ControlCenter::VisitStatistic.where(:hour => hour)
          for visit_statistic in visit_statistics
            unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => hour, :timestamp.lt => hour + 1.hour, :url => visit_statistic.url).group.count
            total_unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => hour, :timestamp.lt => hour + 1.hour).group.count
            visit_statistic.unique_visits = unique
            visit_statistic.total_unique_visits = total_unique
            visit_statistic.save
          end
        end
      end
    end
  
    desc "Calculate daily unique visits."
    task :daily_unique_visit => :custom_environment do
      if first_visit_statistic = ControlCenter::VisitStatistic.where(:day.exists => true, :unique_visits.exists => false).asc(:day).first
        current_time = Time.now.utc
        current_day = Time.utc(current_time.year, current_time.month, current_time.day)
        start_day = first_visit_statistic.day
        end_day = current_day
        (0..((end_day - start_day).to_i / (60*60*24))).each do |day_count|
          day = start_day + day_count.day
          visit_statistics = ControlCenter::VisitStatistic.where(:day => day)
          for visit_statistic in visit_statistics
            unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => day, :timestamp.lt => day + 1.day, :url => visit_statistic.url).group.count
            total_unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => day, :timestamp.lt => day + 1.day).group.count
            visit_statistic.unique_visits = unique
            visit_statistic.total_unique_visits = total_unique
            visit_statistic.save
          end
        end
      end
    end
  
    desc "Calculate montlhy unique visits."
    task :monthly_unique_visit => :custom_environment do
      if first_visit_statistic = ControlCenter::VisitStatistic.where(:month.exists => true, :unique_visits.exists => false).asc(:month).first
        current_time = Time.now.utc
        current_month = Time.utc(current_time.year, current_time.month)
        start_month = first_visit_statistic.month
        end_month = current_month - 1.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:month => month)
          for visit_statistic in visit_statistics
            unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => month, :timestamp.lt => month + 1.month, :url => visit_statistic.url).group.count
            total_unique = ControlCenter::Visit.only(:visitor_id).where(:timestamp.gte => month, :timestamp.lt => month + 1.month).group.count
            visit_statistic.unique_visits = unique
            visit_statistic.total_unique_visits = total_unique
            visit_statistic.save
          end
        end
      end
    end
  
    desc "Calculate hourly location."
    task :hourly_location => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:hourly_location_done.ne => true, :hour.exists => true).asc(:hour).first
        current_time = Time.now.utc
        end_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        start_hour = starting_statistic.hour
        ips = []; geoips = {}; geoip_fails = 0;
        (0..((end_hour - start_hour).to_i / 3600)).each do |hour_count|
          hour = start_hour + hour_count.hour
          visit_statistics = ControlCenter::VisitStatistic.where(:hourly_location_done.ne => true, :hour => hour)
          for visit_statistic in visit_statistics
            for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => hour, :timestamp.lt => hour + 1.hour)
              ips << visit.ip_address if ips.include?(visit.ip_address) == false
            end
          end
        end
        geoips = GeoIp.geolocation(ips, {:precision => :country, :max_concurrency => 6})
        if geoips.count == ips.count
          (0..((end_hour - start_hour).to_i / 3600)).each do |hour_count|
            hour = start_hour + hour_count.hour
            visit_statistics = ControlCenter::VisitStatistic.where(:hourly_location_done.ne => true, :hour => hour)
            for visit_statistic in visit_statistics
              for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => hour, :timestamp.lt => hour + 1.hour)
                puts "#{visit.ip_address}" unless Rails.env == 'production'
                if geoips[visit.ip_address].present? && geoips[visit.ip_address][:status].downcase == 'ok'
                  puts "#{visit.ip_address}: successful." unless Rails.env == 'production'
                  location = visit_statistic.locations.where(:country => geoips[visit.ip_address][:country_name]).first
                  if location.present?
                    location.count += 1; location.save;
                  else
                    visit_statistic.locations.create(:country_code => geoips[visit.ip_address][:country_code], :country => geoips[visit.ip_address][:country_name])
                  end
                end
              end
              visit_statistic.hourly_location_done = true; visit_statistic.save
            end
          end
        end
      end
    end
  
    desc "Calculate monthly referrer."
    task :monthly_referrer => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:monthly_referrer_done.ne => true, :month.exists => true).asc(:month).first
        current_time = Time.now.utc
        end_month = Time.utc(current_time.year, current_time.month) - 1.month
        start_month = starting_statistic.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:monthly_referrer_done.ne => true, :month => month)
          for visit_statistic in visit_statistics
            for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => month, :timestamp.lt => month + 1.month)
              referrer = visit_statistic.referrers.where(:url => visit.referrer_url, :domain => visit.referrer_domain).first
              if referrer.present?
                referrer.count += 1; referrer.save;
              else
                visit_statistic.referrers.create(:url => visit.referrer_url, :domain => visit.referrer_domain)
              end
            end
            visit_statistic.monthly_referrer_done = true; visit_statistic.save
          end
        end
      end
    end
  
    desc "Calculate monthly resolution."
    task :monthly_resolution => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:monthly_resolution_done.ne => true, :month.exists => true).asc(:month).first
        current_time = Time.now.utc
        end_month = Time.utc(current_time.year, current_time.month) - 1.month
        start_month = starting_statistic.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:monthly_resolution_done.ne => true, :month => month)
          for visit_statistic in visit_statistics
            for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => month, :timestamp.lt => month + 1.month)
              resolution = visit_statistic.resolutions.where(:screen_width => visit.screen_width, :screen_height => visit.screen_height).first
              if resolution.present?
                resolution.count += 1; resolution.save;
              else
                visit_statistic.resolutions.create(:screen_width => visit.screen_width, :screen_height => visit.screen_height)
              end
            end
            visit_statistic.monthly_resolution_done = true; visit_statistic.save
          end
        end
      end
    end

    desc "Calculate monthly browser."
    task :monthly_browser => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:monthly_browser_done.ne => true, :month.exists => true).asc(:month).first
        current_time = Time.now.utc
        end_month = Time.utc(current_time.year, current_time.month) - 1.month
        start_month = starting_statistic.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:monthly_browser_done.ne => true, :month => month)
          for visit_statistic in visit_statistics
            for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => month, :timestamp.lt => month + 1.month)
              browser = visit_statistic.browsers.where(:name => visit.browser, :version => visit.browser_version).first
              if browser.present?
                browser.count += 1; browser.save;
              else
                visit_statistic.browsers.create(:name => visit.browser, :version => visit.browser_version)
              end
            end
            visit_statistic.monthly_browser_done = true; visit_statistic.save
          end
        end
      end
    end
  
    desc "Calculate monthly Operating System."
    task :monthly_operating_system => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:monthly_operating_system_done.ne => true, :month.exists => true).asc(:month).first
        current_time = Time.now.utc
        end_month = Time.utc(current_time.year, current_time.month) - 1.month
        start_month = starting_statistic.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:monthly_operating_system_done.ne => true, :month => month)
          for visit_statistic in visit_statistics
            for visit in ControlCenter::Visit.where(:url => visit_statistic.url, :timestamp.gte => month, :timestamp.lt => month + 1.month)
              operating_system = visit_statistic.operating_systems.where(:name => visit.os).first
              if operating_system.present?
                operating_system.count += 1; operating_system.save;
              else
                visit_statistic.operating_systems.create(:name => visit.os)
              end
            end
            visit_statistic.monthly_operating_system_done = true; visit_statistic.save
          end
        end
      end
    end

    desc "Calculate monthly location."
    task :monthly_location => :custom_environment do
      if starting_statistic = ControlCenter::VisitStatistic.where(:monthly_location_done.ne => true, :month.exists => true).asc(:month).first
        puts "Started at #{Time.now.utc}" unless Rails.env == 'production'
        current_time = Time.now.utc
        end_month = Time.utc(current_time.year, current_time.month) - 1.month
        start_month = starting_statistic.month
        (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
          month = start_month + month_count.month
          visit_statistics = ControlCenter::VisitStatistic.where(:monthly_location_done.ne => true, :month => month)
          for visit_statistic in visit_statistics
            for hourly_visit_statistic in ControlCenter::VisitStatistic.where(:url => visit_statistic.url, :hour.gte => month, :hour.lt => month + 1.month)
              for hourly_location in hourly_visit_statistic.locations
                location = visit_statistic.locations.where(:country => hourly_location.country, :country_code => hourly_location.country_code).first
                if location.present?
                  location.count += hourly_location.count; location.save;
                else
                  visit_statistic.locations.create(:country_code => hourly_location.country_code, :country => hourly_location.country, :count => hourly_location.count)
                end
              end
            end
            visit_statistic.monthly_location_done = true; visit_statistic.save
          end        
        end
      end
    end
  
    desc "Wipe visit collection for the entire month if that month statistics have been created."
    task :wipe_visit => :custom_environment do
      current_time = Time.now.utc
      current_month = Time.utc(current_time.year, current_time.month)
      first_visit = ControlCenter::Visit.where(:timestamp.exists => true).asc(:timestamp).first
      end_month = current_month - 1.month
      start_month = Time.utc(first_visit.timestamp.year, first_visit.timestamp.month)
      (0..((end_month.month - start_month.month) + 12 * (end_month.year - start_month.year))).each do |month_count|
        month = start_month + month_count.month
        if ControlCenter::VisitStatistic.where(
          :monthly_referrer_done => true,
          :monthly_resolution_done => true,
          :monthly_browser_done => true,
          :monthly_operating_system_done => true,
          :monthly_location_done => true,
          :month => month).first
          if month == current_month - 1.month
            # If the month is the last month before the current month, the upper bound must be reduced by 24 hours.
            # It's because of the timezone. Example: the first second of current month in UTC - 1 is included in the previous month in UTC time.
            ControlCenter::Visit.where(:timestamp.gte => month, :timestamp.lt => (month + 1.month - 24.hours)).destroy_all
            ap "Visits deleted for month: #{month} - #{(month + 1.month - 24.hours)}"
          else
            ControlCenter::Visit.where(:timestamp.gte => month, :timestamp.lt => (month + 1.month)).destroy_all
            ap "Visits deleted for month: #{month} - #{month + 1.month}"
          end
        end
      end
    end
  
  end
  
end