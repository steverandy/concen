module ControlCenter
  class StatisticsController < ApplicationController
    layout "control_center/application"

    before_filter :authenticate_user

    # Supports OS X and Linux, require top command.
    #   @current_month_visits = Statistic.visits_for_current :month
    # Real time visits
    # Historical statistics
    # Month: visits
    def index
      @page_title = "Statistics"
    end

    def visits
      @stats = Visit.aggregate_count_by_time(:hour => params[:hour], :time_in_integer => true, :precision => "millisecond")
      @stats.map! do |s|
        time = Time.zone.at s[0]/1000
        zone_offset = Time.zone_offset(time.zone)
        [(Time.zone.at(s[0]/1000).utc.to_i + zone_offset)*1000, s[1]]
      end
      respond_to do |format|
        format.json { render :json => @stats }
      end
    end

    def popular_pages
      @popular_pages_stats = ControlCenter::Visit.aggregate_count_by_url(:limit => 6)
      respond_to do |format|
        format.html { render :partial => "control_center/statistics/popular_pages" }
      end
    end

    def server
      processor_stat = []
      memory_stat = []
      @server_stats = {}
      if RUBY_PLATFORM.downcase.include?("darwin")
        top = `top -l 1 -pid 0`.split(/\n+/)
        if top.present?
          processor_stat = top[3].scan(/[0-9]+\.\d+/)
          memory_stat = top[6].scan(/[0-9]\d+/)
          @server_stats = {
            :processor => {:user => processor_stat[0], :sys => processor_stat[1], :idle => processor_stat[2]},
            :memory => {:wired => memory_stat[0], :active => memory_stat[1], :inactive => memory_stat[2], :used => memory_stat[3], :free => memory_stat[4]}
          }
        end
      elsif RUBY_PLATFORM.downcase.include?("linux")
        top = `top -b -n 1 -p 0`.split(/\n+/)
        if top.present?
          processor_stat = top[2].scan(/[0-9]+\.\d+/)
          memory_stat = top[3].scan(/[0-9]\d+/)
          @server_stats = {
            :processor => {:user => processor_stat[0], :sys => processor_stat[1], :idle => processor_stat[3]},
            :memory => {:total => memory_stat[0].to_i/1024, :used => memory_stat[1].to_i/1024, :free => memory_stat[2].to_i/1024}
          }
        end
      end
      uptime_array = `uptime`.split("up")[1].strip.split("user")[0].split(","); uptime_array.delete_at(uptime_array.length - 1)
      if uptime_array.present?
        uptime = uptime_array.join(",")
        @server_stats[:uptime] = uptime
      end

      @mongodb_stats = Mongoid.database.stats

      begin
        @mongodb_grid_fs_stats = Mongoid.database.collection("fs.chunks").stats["storageSize"]
      rescue
        @mongodb_grid_fs_stats = 0
      end
      respond_to do |format|
        format.html { render :partial => "control_center/statistics/server" }
      end
    end
  end
end
