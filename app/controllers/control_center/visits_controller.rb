require "domainatrix"

module ControlCenter
  class VisitsController < ApplicationController

    def visit_recorder_js
      @visit_key = Visit::Key.create(:expire => Time.now.utc + 30.seconds)
      cookies[:visitor_id] = {:value => SecureRandom.uuid, :expires => 20.years.from_now} if cookies[:visitor_id].blank?
      render :layout => false, :mime_type => "text/javascript"
    end

    def record
      Visit::Key.safely(false).where(:expire.lte => Time.now.utc).delete_all
      if params[:k] && visit_key = Visit::Key.where(:_id => params[:k]).first
        current_time = Time.now.utc
        current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
        Visit::Page.collection.update(
          {:url => params[:u], :hour => current_hour},
          {"$inc" => {:count => 1}, "$set" => {:title => params[:t]}},
          :upsert => true, :safe => false
        )
        begin
          referral_url = params[:r]
          referral = Domainatrix.parse(referral_url)
          referral_domain = referral.domain + "." + referral.public_suffix
        rescue
          referral_url = nil
          referral_domain = nil
        end
        Visit::Referral.collection.update(
          {:url => referral_url, :hour => current_hour},
          {"$inc" => {:count => 1}, "$set" => {:domain => referral_domain}},
          :upsert => true, :safe => false
        )
        visit_key.safely(false).delete
      end
      image_path = "#{Rails.root}/public/control_center/images/record-visit.gif"
      send_file image_path, :type => "image/gif", :disposition => "inline"
    end
  end
end
