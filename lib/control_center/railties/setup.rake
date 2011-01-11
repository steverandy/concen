namespace :control_center do
  desc "Create initial setup for Control Center."
  task :setup => [:environment, :add_schedule, :copy_assets, :create_first_admin] do
  end
  
  desc "Add schedule.rb file to be used by whenever gem (cron jobs)."
  task :add_schedule => :environment do
    origin      = File.join(ControlCenter::Engine.root, "lib", "control_center")
    destination = File.join(Rails.root, "config")
    File.open("#{destination}/schedule.rb", "a") {|f| f.puts("\n\n"); f.puts(File.read("#{origin}/schedule.rb")); }
  end
  
  desc "Copy assets for Control Center."
  task :copy_assets => :environment do
    origin      = File.join(ControlCenter::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    if Dir.exist?("#{destination}/control_center") || File.exist?("#{destination}/control_center")
      FileUtils.rm_r "#{destination}/control_center" 
    end
    FileUtils.cp_r "#{origin}/control_center/", "#{destination}/"
  end
  
  desc "Symlink assets."
  task :symlink_assets => :environment do
    origin      = File.join(ControlCenter::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    FileUtils.rm_r "#{destination}/control_center" if File.directory?("#{destination}/control_center")
    FileUtils.ln_s "#{origin}/control_center/", "#{destination}/"
  end

  desc "Create the first admin."
  task :create_first_admin => :environment do
    if ControlCenter::Admin.first.blank? && ControlCenter::Admin.create!(:username => "admin", :email => "admin@mail.com", :full_name => "Admin", :password => "jfds93hfds9", :password_confirmation => "jfds93hfds9")
      puts "Admin has been created. Username is admin and password is jfds93hfds9. Please login and change email or password."
    end
  end
end