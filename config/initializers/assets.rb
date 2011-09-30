if Rails.env.production?
  Rails.application.config.assets.precompile += %w(concen/ie.css concen/non_ios.css)
  Rails.application.config.assets.precompile += %w(concen/pages.js concen/performances.js concen/statuses.js concen/traffics.js concen/users.js concen/excanvas.js)
end
