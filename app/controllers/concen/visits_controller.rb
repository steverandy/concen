require "domainatrix"

module Concen
  class VisitsController < ApplicationController

    def visit_recorder_js
      if cookies[:visitor_id].blank?
        cookies[:visitor_id] = {:value => ActiveSupport::SecureRandom.uuid, :expires => 20.years.from_now}
      end
      render :layout => false, :mime_type => "text/javascript"
    end

    def record
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
      image_path = "#{Concen::Engine.root}/app/assets/images/concen/record-visit.gif"
      send_file image_path, :type => "image/gif", :disposition => "inline"
    end
  end
end
