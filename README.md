# Concen

## Installation

Add the following to the Gemfile.

```
gem "concen"
```
	
Add initializer file for concen configurations.

```
Concen.setup do |config|
  config.application_name = "My Application Name"
end
```

## Accessing Concen

To access Concen, use "concen" subdomain for example http://concen.domain.com. Sign in with admin account to continue. [Pow](http://pow.cx/) rack server is recommended because it provides access to subdomain by default.

## Insert Visit Recorder JavaScript for Real Time Traffic Monitoring

Visit Recorder will record the visitors' information for pages, which include the Visit Recorder JavaScript.
To do so, please follow these steps:

Insert the Visit Recorder JavaScript in your layout.

```
= javascript_include_tag visit_recorder_js_url
```
      
Call record function before the closing <body> tag.

```
:javascript
  VisitRecorder.record({});
```
