require "rails"

module ControlCenter  
  class Engine < Rails::Engine
    # Use Rails.application.routes.prepend on Rails 3.1
    # and disasble the following code block.
    initializer :prepend_routing_paths do |app|
      paths.config.routes.to_a.each do |route|
        app.routes_reloader.paths.unshift(route) if File.exists?(route)
        app.routes_reloader.paths.uniq!
      end
    end
    
    rake_tasks do
      load "control_center/railties/setup.rake"
      load "control_center/railties/visit_statistic.rake"
    end
    
    # Add a load path for this specific Engine
    # config.autoload_paths << File.expand_path("../markdown.rb", __FILE__)
  end
end