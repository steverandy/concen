# Concen

## Installation

1. Add the following to the Gemfile.

    gem 'concen'
	
2. Add initializer file for concen configurations.

  	Concen.setup do |config|
  	  config.application_name = "My Application Name"
  	end

## Accessing Concen

To access Concen, please visit [http://concen.domain.com](http://concen.domain.com). Sign in with admin account to continue.

## Insert Visit Recorder JavaScript

Visit Recorder will record the visitors' information for pages, which include the Visit Recorder JavaScript.
To do so, please follow these steps:

1. Insert the Visit Recorder JavaScript.

    = javascript_include_tag visit_recorder_js_url
      
2. Call record function.
    
    :javascript
      VisitRecorder.record({});
