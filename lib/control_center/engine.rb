require "rails"

module ControlCenter  
  class Engine < Rails::Engine
    # initializer "static assets" do |app|
    #   app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    # end

    rake_tasks do
      load "control_center/railties/setup.rake"
      load "control_center/railties/visit_statistic.rake"
    end
  end
end