module Haml::Filters::Markdown
  include Haml::Filters::Base
  lazy_require "redcarpet"

  def render(text)
    Redcarpet.new(text, :smart, :fenced_code).to_html
  end
end