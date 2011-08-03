module ControlCenter
  class TrafficsController < ApplicationController
    layout "control_center/application"

    before_filter :authenticate_user

    # Supports OS X and Linux, require top command.
    #   @current_month_visits = Statistic.visits_for_current :month
    # Real time visits
    # Historical statistics
    # Month: visits
    def show
      @page_title = "Traffic"
    end

    def visits_count
      @stats = Visit.aggregate_count_by_time(:hour => params[:hour], :precision => "millisecond")
      # Readjust timestamp because flot graph doesn't handle time zone.
      @stats.map! do |s|
        time = Time.zone.at s[0]/1000
        [(time.utc.to_i + time.utc_offset)*1000, s[1]]
      end
      respond_to do |format|
        format.json { render :json => @stats }
      end
    end

    def pages
      @pages_stats = ControlCenter::Visit.aggregate_count_by_url(:limit => 6)
      respond_to do |format|
        format.html { render :partial => "control_center/traffics/pages" }
      end
    end
  end
end
