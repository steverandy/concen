require "rails"

module ControlCenter  
  class Engine < Rails::Engine
    initializer "haml_markdown" do
      module Haml::Filters::Markdown
        include Haml::Filters::Base
        lazy_require "redcarpet"

        def render(text)
          Redcarpet.new(text, :smart).to_html
        end
      end
    end
    
    # Add a load path for this specific Engine
    # config.autoload_paths << File.expand_path("../markdown.rb", __FILE__)

    rake_tasks do
      load "control_center/railties/setup.rake"
      load "control_center/railties/visit_statistic.rake"
    end
  end
end