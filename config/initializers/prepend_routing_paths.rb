# TODO: Use Rails.application.routes.prepend on Rails 3.1
# and disasble the following code block.
Concen::Engine.paths["config/routes"].to_a.each do |route|
  Rails.application.routes_reloader.paths.unshift(route) if File.exists?(route)
  Rails.application.routes_reloader.paths.uniq!
end

# Concen::Engine.paths.config.routes.to_a.each
