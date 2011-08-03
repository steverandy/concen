module ControlCenter
  class VisitsController < ApplicationController
    layout "control_center/application"

    before_filter :authenticate_user, :except => [:visit_recorder_js, :record]

    def visit_recorder_js
      @visit_key = VisitKey.create(:expire => Time.now.utc + 30.seconds)
      cookies[:visitor_id] = {:value => SecureRandom.uuid, :expires => 20.years.from_now} if cookies[:visitor_id].blank?
      render :layout => false, :mime_type => "text/javascript"
    end

    def record
      VisitKey.where(:expire.lte => Time.now.utc).destroy_all
      if params[:k] && visit_key = VisitKey.where(:_id => params[:k]).first
        current_time = Time.now.utc
        current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        visits_collection = Visit.collection
        visits_collection.update(
          {:url => params[:u], :hour => current_hour},
          {"$inc" => {:count => 1}, "$set" => {:title => params[:t]}},
          :upsert => true
        )
        visit_key.delete
      end
      image_path = "#{Rails.root}/public/control_center/images/record-visit.gif"
      send_file image_path, :type => "image/gif", :disposition => "inline"
    end

    # Supports OS X and Linux, require top command.
    #   @current_month_visits = Statistic.visits_for_current :month
    # Real time visits
    # Historical statistics
    # Month: visits
    def index
      @page_title = "Visits"
    end

    def count
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
        format.html { render :partial => "control_center/visits/pages" }
      end
    end
  end
end
