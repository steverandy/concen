module ControlCenter
  class VisitsController < ApplicationController

    def visit_recorder_js
      @visit_key = Visit::Key.create(:expire => Time.now.utc + 30.seconds)
      cookies[:visitor_id] = {:value => SecureRandom.uuid, :expires => 20.years.from_now} if cookies[:visitor_id].blank?
      render :layout => false, :mime_type => "text/javascript"
    end

    def record
      Visit::Key.where(:expire.lte => Time.now.utc).destroy_all
      if params[:k] && visit_key = Visit::Key.where(:_id => params[:k]).first
        current_time = Time.now.utc
        current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        visit_url_collection = Visit::URL.collection
        visit_url_collection.update(
          {:url => params[:u], :hour => current_hour},
          {"$inc" => {:count => 1}, "$set" => {:title => params[:t]}},
          :upsert => true
        )
        visit_source_collection = Visit::Referral.collection
        visit_source_collection.update(
          {:source => params[:r], :hour => current_hour},
          {"$inc" => {:count => 1}},
          :upsert => true
        )
        visit_key.delete
      end
      image_path = "#{Rails.root}/public/control_center/images/record-visit.gif"
      send_file image_path, :type => "image/gif", :disposition => "inline"
    end
  end
end
