# Concen

Concen is a Rails Engine for controlling and monitoring a Rails application from a web interface. It includes content capturing system, real-time traffic monitoring, and real-time performance monitoring. It's built to be flexible and customizable to fit custom needs.

## Requirements

- **Rails 3.0.x**. Concen only supports Rails 3.0 application. Support for Rails 3.1 is planned to be added in near future.
- **MongoDB 1.8.x**. All data are stored in MongoDB database, including all of the files uploaded (stored in GridFS).
- **Typekit** (optional). Concen uses [Proxima Nova](http://typekit.com/fonts/proxima-nova) font. This font can be obtained from Typekit.

## Installation

Add the following to the Gemfile of a Rails application.

    gem "concen", "~> 0.1"

Add initializer file for concen configurations.

    Concen.setup do |config|
      config.application_name = "My Application Name"
      config.typekit_id = "qxq7sbk"
    end

## Content Capturing System

Any Rails application will require static contents at some point or another. Many of us will just write those content in Rails views. Quite recently I have begun to think that this is a wrong thing to do. We don't need a full blown Content Management System (CMS) to handle them. We rather need a Content Capturing System (CCS). Most of these contents might not come from you, but other people. Most often they are several people involved. A CCS does not focus in managing content. It focuses on capturing content from the content creator.

The CCS itself has a simple text editor and a simple file uploader. Contents these days are not only in the form of text but also images, audios and videos. CCS offers a quick and easy way to capture all of them.

Back to the Rails application, the developer/programmer could place these contents in the views. For example with the following method call.

    Concen::Page.published.desc(:publish_time)

The above method call will return all the contents that have been marked as published and sort them by publish time. In this fashion, Rails views could be free from any static content.

Generating static content should not be performed for every request because it is expensive. Concen does not have a mechanism of caching. However it is very simple in Rails to cache a page. You don't have to use Rails page caching mechanism. You simple need to set the proper Cache-Control header. For example the following code will cache a page for 5 minutes in any reverse proxy and in the client browser. You can add a [Rack Cache](http://rtomayko.github.com/rack-cache/) or setup [Nginx reverse proxy cache](http://wiki.nginx.org/HttpProxyModule#proxy_cache) easily or even [Varnish](http://varnish-cache.org/) when the time comes.

    expires_in 5.minutes, :public => true
    fresh_when :etag => @article, :public => true

## Real Time Traffic Monitoring

Insert the Visit Recorder JavaScript in your layout.

For layout in Haml:

    = javascript_include_tag visit_recorder_js_url
    :javascript
      VisitRecorder.record({});

For layout in ERB:

    <script src="http://steverandytantra.com/visits/js" type="text/javascript"></script>
    <script>
      //<![CDATA[
        VisitRecorder.record({});
      //]]>
    </script>

## Real Time Performance Monitoring

There are many commercial performance monitoring solutions for a Rails application. But when starting out with a simple application you might not want the extra steps to setup these commercial solutions. Concen comes with a simple real-time performance monitoring. It doesn't give you an extensive reports like the commercial solutions, but it's just enough to get you going to the next level. When the time comes, you can add a more suitable solution.

There is no extra setup for this free real-time performance monitoring. And there is no more reason not to know which controller actions are slow.

## Concen Web Interface

To access Concen web interface, use "concen" subdomain for example http://concen.domain.com. When it's accessed for the first time, it will prompt to create a new master user. This user will have full control over the Concen. [Pow](http://pow.cx/) rack server is recommended because it provides access to subdomain by default.
