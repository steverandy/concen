namespace :concen do
  namespace :page do
    desc "Reset publish_month for all the pages. Should be used when time zone is changed."
    task :reset_publish_month => :environment do
      Time.zone = Rails::Application.config.time_zone
      for page in Concen::Page.all
        page.send(:set_publish_month)
        page.save
      end
    end
  end
end
