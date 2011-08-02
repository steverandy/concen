namespace :control_center do
  desc "Create initial setup for Control Center."
  task :setup => [:environment, :copy_assets] do
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
end
