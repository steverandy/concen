# Concen

Concen is a Rails Engine for controlling and monitoring a Rails application from a web interface. It includes content capturing system, real-time traffic monitoring, and real-time performance monitoring. It's built to be flexible and customizable to fit custom needs.

## Requirements

- **Rails 3.1**. Concen only supports Rails 3.1 application.
- **MongoDB 1.8.x**. All data are stored in MongoDB database, including all of the files uploaded (stored in GridFS).
- **Typekit** (optional). Concen uses [Proxima Nova](http://typekit.com/fonts/proxima-nova) font. This font can be obtained from Typekit.

## Installation

Add the following to the Gemfile of a Rails application.

    gem "concen", "~> 0.1"

Concen uses Compass to generate its stylesheets so include Compass' gem in assets group in the Gemfile. If you face a problem when precompiling the assets it's most likely because Compass' gem isn't included in the Gemfile.

    group :assets do
      gem "compass", "~> 0.12.alpha"
    end

Run the rake task to setup Concen.

    rake concen:setup

Follow the brief guide upon completion of the rake task.

## Content Capturing System

Any Rails application will require static contents at some point or another. Many of us will just write those contents in the Rails views. Quite recently I have begun to think that this is a wrong approach. We don't need a full blown Content Management System (CMS) to handle them. We rather need a Content Capturing System (CCS). Most of these contents might not come from you, but other people. Most often, there are several people involved. A CCS does not focus in managing content. It focuses on capturing content from the content creators.

The CCS itself has a simple text editor and a simple file uploader. Contents these days are not only in the form of text but also images, audios and videos. CCS offers a quick and easy way to capture all of them.

Back to the Rails application, the developer/programmer could place these contents in the views. For example with the following method call.

    Concen::Page.published.desc(:publish_time)

The above method call will return all the contents that have been marked as published and sort them by publish time. In this fashion, Rails views could be free from any static content.

Concen also comes with a configurable Markdown parser. [Markdown](http://daringfireball.net/projects/markdown/syntax) is a recommended text format to be used in Concen. Markdown is easy to understand and always in plain text mode. You can easily generate HTML from the Markdown formatted content with the following method call.

    Concen::Page.published.desc(:publish_time).first.content_in_html

Generating static content should not be performed for every request because it is expensive. Concen does not have a mechanism of caching. However it is very simple in Rails to cache a page. You don't have to use Rails page caching mechanism. You simply need to set the proper Cache-Control header. For example the following code will cache a page for 5 minutes in any reverse proxy and in the client browser. You can add a [Rack Cache](http://rtomayko.github.com/rack-cache/) or setup [Nginx reverse proxy cache](http://wiki.nginx.org/HttpProxyModule#proxy_cache) easily or even [Varnish](http://varnish-cache.org/) when the time comes.

    expires_in 5.minutes, :public => true
    fresh_when :etag => @article, :public => true

## Writing Style for Content Capturing System

There are no rules enforced for writing content with Concen CCS. But there are certain writing styles that will help writing content more manageable and convenient.

Here is an example with single-segment content.

    Title: 1984

    Description: Nineteen Eighty-Four (sometimes written 1984) is a 1948 dystopian fiction written by George Orwell about a society ruled by an oligarchical dictatorship.

    Publish Time: tomorrow

    -----

    It was a bright cold day in April, and the clocks were striking thirteen. Winston Smith, his chin nuzzled into his breast in an effort to escape the vile wind, slipped quickly through the glass doors of Victory Mansions, though not quickly enough to prevent a swirl of gritty dust from entering along with him.

Here is another example with multiple-segment content.

    Title: 1984

    Description: Nineteen Eighty-Four (sometimes written 1984) is a 1948 dystopian fiction written by George Orwell about a society ruled by an oligarchical dictatorship.

    Publish Time: tomorrow

    -----

    @ Chapter 1

    It was a bright cold day in April, and the clocks were striking thirteen. Winston Smith, his chin nuzzled into his breast in an effort to escape the vile wind, slipped quickly through the glass doors of Victory Mansions, though not quickly enough to prevent a swirl of gritty dust from entering along with him.

    -----

    @ Chapter 2

    As he put his hand to the door-knob Winston saw that he had left the diary open on the table. DOWN WITH BIG BROTHER was written all over it, in letters almost big enough to be legible across the room. It was an inconceivably stupid thing to have done. But, he realized, even in his panic he had not wanted to smudge the creamy paper by shutting the book while the ink was wet.

Content can be divided with 3 or more hyphen (-). The first part will always be metadata declaration. The rest will be the content.

"Publish Time" meta data has special treatment, where it accepts date in natural language format, relative to the current time.

To obtain the content, you typically will call the following.

    Concen::Page.published.desc(:publish_time).first.content

Or if you want the content in HTML format, simply call the following.

    Concen::Page.published.desc(:publish_time).first.content_in_html

`content_in_html` accepts an argument of the content segment key. In this example if you declare "Chapter 2", the key will be "chapter_2".

## Real Time Traffic Monitoring

Insert the Visit Recorder JavaScript in your layout. It's recommended to append this code block right before the closing `</body>` tag.

For layout in Haml, insert the following code block.

    = javascript_include_tag visit_recorder_js_url
    :javascript
      VisitRecorder.record({});

For layout in ERB, insert the following code block.

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

## Websites That Have Used Concen in Production

- [http://steverandytantra.com/](http://steverandytantra.com/)

If you have used Concen for any of your websites and would like to be listed here. Please send me a message.

## Version History

- **0.2.0**:

  - Rails 3.1 compatibility.

- **0.1.7**:

  - Fix installation error when using Ruby 1.8.7.

- **0.1.6**:

  - Fix gemspec encoding issue.

- **0.1.5**:

  - A better approach of handling slug. Slug by default is generated from title. It can then be overwritten by specifying "Slug" in metadata declaration (from the text editor).

- **0.1.4**:

  - Simpler setup process (only in 2 steps).
  - Brief guide is available upon the completion of setup.
  - Fix a bug in file path drag and drop function.

- **0.1.3**: Minor bug fixes.

- **0.1.2**: Minor bug fixes.

- **0.1.1**: Minor bug fixes.

- **0.1**: Initial release.
