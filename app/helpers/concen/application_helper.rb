module Concen
  module ApplicationHelper
    # Remove all the new lines from the output.
    # This is very useful when used for inline-block elements, because
    # white spaces will transform into extra gaps between element.
    def one_line(&block)
      (capture_haml(&block).gsub("\n", '')).html_safe
    end
  end
end
