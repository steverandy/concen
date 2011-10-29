require "rails"
require "mongoid"
require "mongo/rails/instrumentation/railtie"

module Concen
  class Engine < Rails::Engine
    rake_tasks do
      load "concen/railties/setup.rake"
      load "concen/railties/page.rake"
    end

    # Add a load path for this specific Engine
    # config.autoload_paths << File.expand_path("../markdown.rb", __FILE__)
  end
end
