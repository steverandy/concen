require "rails"

module ControlCenter  
  class Engine < Rails::Engine
    # initializer "static assets" do |app|
    #   app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    # end
    
    # Add a load path for this specific Engine
    config.autoload_paths << File.expand_path("../without_subdomain.rb", __FILE__)

    rake_tasks do
      load "control_center/railties/setup.rake"
      load "control_center/railties/visit_statistic.rake"
    end
  end
end