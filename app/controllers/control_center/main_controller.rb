module ControlCenter
  class MainController < ApplicationController
    layout "control_center/application"

    before_filter :authenticate_user

    def index
      redirect_to :action => :statistics
    end

    # Supports OS X and Linux, require top command.
    #   @current_month_visits = Statistic.visits_for_current :month
    # Real time visits
    # Historical statistics
    # Month: visits
    def statistics
      @page_title = "Statistics"

      @current_time = Time.zone.now
      @current_hour = Time.zone.local(@current_time.year, @current_time.month, @current_time.day, @current_time.hour, 0, 0, 0)
      @current_day = Time.zone.local(@current_time.year, @current_time.month, @current_time.day)
      @current_month = Time.zone.local(@current_time.year, @current_time.month, 1, 0, 0, 0, 0)

      processor_statistic = []
      memory_statistic = []
      @server_statistics = {}
      if RUBY_PLATFORM.downcase.include?("darwin")
        top = `top -l 1 -pid 0`.split(/\n+/)
        if top.present?
          processor_statistic = top[3].scan(/[0-9]+\.\d+/)
          memory_statistic = top[6].scan(/[0-9]\d+/)
          @server_statistics = {
            :processor => {:user => processor_statistic[0], :sys => processor_statistic[1], :idle => processor_statistic[2]},
            :memory => {:wired => memory_statistic[0], :active => memory_statistic[1], :inactive => memory_statistic[2], :used => memory_statistic[3], :free => memory_statistic[4]}
          }
        end
      elsif RUBY_PLATFORM.downcase.include?("linux")
        top = `top -b -n 1 -p 0`.split(/\n+/)
        if top.present?
          processor_statistic = top[2].scan(/[0-9]+\.\d+/)
          memory_statistic = top[3].scan(/[0-9]\d+/)
          @server_statistics = {
            :processor => {:user => processor_statistic[0], :sys => processor_statistic[1], :idle => processor_statistic[3]},
            :memory => {:total => memory_statistic[0].to_i/1024, :used => memory_statistic[1].to_i/1024, :free => memory_statistic[2].to_i/1024}
          }
        end
      end
      uptime_array = `uptime`.split("up")[1].strip.split("user")[0].split(","); uptime_array.delete_at(uptime_array.length - 1)
      if uptime_array.present?
        uptime = uptime_array.join(",")
        @server_statistics[:uptime] = uptime
      end

      @mongodb_stats = Mongoid.database.stats

      # Disabled because it's uncertain the result is what as intended.
      # begin
      #   @assets_storage_usage = Mongoid.database.collection("fs.chunks").stats["storageSize"]
      # rescue
      #   @assets_storage_usage = 0
      # end
    end

    def assets
    end
  end
end
