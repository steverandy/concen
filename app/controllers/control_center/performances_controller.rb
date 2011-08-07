module ControlCenter
  class PerformancesController < ApplicationController
    def show

    end

    def responses
      # current_time = Time.now.utc
      # current_hour = Time.utc(current_time.year, current_time.month, current_time.day, current_time.hour)
      @stats = {}
      @stats[:total_runtime] = Response.where(:created_at.gte => Time.now - 30.minutes).asc(:created_at).map do |response|
        [(response.created_at.utc.to_f + response.created_at.utc_offset)*1000, response.total_runtime]
      end
      @stats[:view_runtime] = Response.where(:created_at.gte => Time.now - 30.minutes).asc(:created_at).map do |response|
        if response.respond_to?("view_runtime")
          [(response.created_at.utc.to_f + response.created_at.utc_offset)*1000, response.view_runtime]
        end
      end
      @stats[:mongo_runtime] = Response.where(:created_at.gte => Time.now - 30.minutes).asc(:created_at).map do |response|
        if response.respond_to?("mongo_runtime")
          [(response.created_at.utc.to_f + response.created_at.utc_offset)*1000, response.mongo_runtime]
        end
      end

      respond_to do |format|
        format.json { render :json => @stats }
      end
    end
  end
end
