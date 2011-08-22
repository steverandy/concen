# encoding: utf-8

namespace :concen do
  desc "Create initial setup for Control Center."
  task :setup do
    if ["development", "test"].include? Rails.env
      Rake::Task["concen:generate_mongoid_config"].invoke
      Rake::Task["concen:generate_initializer"].invoke
      Rake::Task["concen:symlink_assets"].invoke
    else
      Rake::Task["concen:copy_assets"].invoke
    end
    message = "Concen setup for #{Rails.env} environment is complete."
    puts "\n\e[32m#{message}\e[0m\n" # Green.

    if ["development", "test"].include? Rails.env
      message = "\n"
      message += "To access Concen's web interface, use concen as the subdomain.\n"
      message += "Go to concen.#{Dir.pwd.split("/").last}.dev if you are using Pow (recommended).\n"
      message += "Go to concen.lvh.me:3000 if you are using standard Rails server.\n\n"
      message += "Once you can access the web interface, you will be prompted to create a new master user.\n"
      message += "This user will have full control and can invite new users.\n\n"
      message += "Visit https://github.com/steverandy/concen for more detailed documentation.\n\n"
      message += "Enjoy.\n\n"
      message += "— Steve Randy Tantra"
      puts "#{message}\n"
    end
    puts "\n"
  end

  desc "Generate mongoid.yml config file."
  task :generate_mongoid_config do
    if File.exist?("config/mongoid.yml")
      message = "mongoid.yml config file already exists."
      puts "\n\e[32m#{message}\e[0m\n" # Green.
    else
      system "rails generate mongoid:config > /dev/null 2>&1"
      message = "config/mongoid.yml has been successfully generated."
      puts "\n\e[32m#{message}\e[0m\n" # Green.
      message = "For more configuration options checkout the Mongoid documentation.\n"
      message += "Available from http://mongoid.org/docs/installation/configuration.html"
      puts "\n#{message}\n"
    end
  end

  desc "Generate concen initializer file."
  task :generate_initializer do
    file_path = "config/initializers/concen.rb"
    if File.exist? file_path
      message = "concen.rb initializer file already exists."
      puts "\n\e[32m#{message}\e[0m\n" # Green.
    else
      File.open(file_path, 'w') do |f|
        f.puts <<-INITIALIZER
Concen.setup do |config|
  config.application_name = "My Application Name"
  # config.typekit_id = "qxq7sbk"
end
INITIALIZER
      end
      message = "#{file_path} has been successfully generated."
      puts "\n\e[32m#{message}\e[0m\n" # Green.
    end
  end

  desc "Copy assets for Control Center."
  task :copy_assets do
    origin      = File.join(Concen::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    if Dir.exist?("#{destination}/concen") || File.exist?("#{destination}/concen")
      FileUtils.rm_r "#{destination}/concen"
    end
    FileUtils.cp_r "#{origin}/concen/", "#{destination}/"
    message = "Assets have been copied to #{destination}."
    puts "\n\e[32m#{message}\e[0m\n" # Green.
  end

  desc "Symlink assets."
  task :symlink_assets do
    origin      = File.join(Concen::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    FileUtils.rm_r "#{destination}/concen" if File.directory?("#{destination}/concen")
    FileUtils.ln_s "#{origin}/concen/", "#{destination}/"
    message = "Assets have been symlinked to #{destination}."
    puts "\n\e[32m#{message}\e[0m\n" # Green.
  end
end
