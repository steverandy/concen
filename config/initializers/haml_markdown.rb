module Haml::Filters::Markdown
  include Haml::Filters::Base
  lazy_require "redcarpet"

  def render(text)
    Redcarpet.new(text, :smart, :fenced_code, :gh_blockcode).to_html
  end
end