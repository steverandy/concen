# CONCEN

## Requirements:

1. MongoDB Database for data persistence storage.
2. mongoid gem for ORM.
3. devise gem for authentication.
4. user-agent gem.
5. geo_ip gem.

## Installation

1. Add the following to the Gemfile.
	gem 'control_center', :path => './vendor/gems/control_center'
2. Add initializer file for control_center configurations.
	ControlCenter.setup do |config|
	  config.application_name = 'Frame'
	  config.geoip_api_key = '5e548c942b4f25bf77b751600e09fde5ada9eb07ddbb7f688a8e1988855ac313'
	end
3. Add/update the following to devise.rb initializer.
	require 'devise/orm/mongoid'
	config.scoped_views = true
4. Control Center comes with schedule.rb (whenever gem) for cron jobs to generate statistics.
In deployment, integrate whenever with Capistrano to update the crontab.

## Accessing Control Center

To access Control Center, please visit [http://controlcenter.domain.com](http://controlcenter.domain.com). Sign in with admin account to continue.

## Insert Visit Recorder JavaScript

Visit Recorder will record the visitors' information for pages, which include the Visit Recorder JavaScript.
To do so, please follow these steps:

1. Insert the Visit Recorder JavaScript.
	= javascript_include_tag visit_recorder_js_url
2. Call record function.
	:javascript
		VisitRecorder.record({});
