require "uuid"

module ControlCenter
  class VisitsController < ApplicationController
    skip_before_filter :authenticate_admin!
    
    def record
      VisitKey.where(:expire.lte => Time.now.utc).destroy_all
      if params[:k]
        visit_key = 
        if visit_key = VisitKey.find(params[:k])
          cookies[:visitor_id] = {:value => UUID.new.generate, :expires => 20.years.from_now} if cookies[:visitor_id].blank?
          # Parsing user agent on server side may cause some slow down.
          # TODO: May implement on client side.
          user_agent = Agent.new request.env["HTTP_USER_AGENT"]
          current_time = Time.now.utc
          current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
          current_day = Time.utc(current_time.year, current_time.month, current_time.day)
          current_month = Time.utc(current_time.year, current_time.month)
          visits_collection = Visit.collection
          statistics_collection = VisitStatistic.collection
          visits_collection.insert({
            :url => params[:u], 
            :timestamp => current_time,
            :ip_address => request.remote_ip,
            :visitor_id => cookies[:visitor_id],
            :user_agent => request.env["HTTP_USER_AGENT"],
            :screen_width => params[:w],
            :screen_height => params[:h],
            :referrer_url => params[:r] || "",
            :referrer_domain => URI.split(params[:r] || "")[2],
            :os => user_agent.os.to_s || "",
            :browser => user_agent.name.to_s || "",
            :browser_version => user_agent.version.to_s || ""
          })
          statistics_collection.update({:url => params[:u], :hour => current_hour}, {"$inc" => {:visits => 1}, "$set" => {:title => params[:t]}}, :upsert => true)
          statistics_collection.update({:url => params[:u], :day => current_day}, {"$inc" => {:visits => 1}, "$set" => {:title => params[:t]}}, :upsert => true)
          statistics_collection.update({:url => params[:u], :month => current_month}, {"$inc" => {:visits => 1}, "$set" => {:title => params[:t]}}, :upsert => true)
          visit_key.delete
        end
      end
      image = File.open("#{Rails.root}/public/control_center/images/record-visit.gif")
      send_data image.read, :type => "image/gif", :filename => "record-visit.gif", :disposition => "inline"
    end
  
    def visit_recorder_js
      @visit_key = SecureRandom.hex(8)
      @visit_key = VisitKey.create(:expire => Time.now.utc + 30.seconds)
      cookies[:visitor_id] = {:value => UUID.new.generate, :expires => 20.years.from_now} if cookies[:visitor_id].blank?
      render :layout => false, :mime_type => "text/javascript"
    end
  end
end
