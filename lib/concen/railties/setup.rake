namespace :concen do
  desc "Create initial setup for Control Center."
  task :setup => [:environment, :copy_assets] do
  end

  desc "Copy assets for Control Center."
  task :copy_assets => :environment do
    origin      = File.join(Concen::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    if Dir.exist?("#{destination}/concen") || File.exist?("#{destination}/concen")
      FileUtils.rm_r "#{destination}/concen"
    end
    FileUtils.cp_r "#{origin}/concen/", "#{destination}/"
  end

  desc "Symlink assets."
  task :symlink_assets => :environment do
    origin      = File.join(Concen::Engine.root, "public")
    destination = File.join(Rails.root, "public")
    FileUtils.rm_r "#{destination}/concen" if File.directory?("#{destination}/concen")
    FileUtils.ln_s "#{origin}/concen/", "#{destination}/"
  end
end
