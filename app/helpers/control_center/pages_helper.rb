module ControlCenter
  module PagesHelper
    def nested_pages_for(page)
      for child in Page.where(:parent_id => page.id)
        haml_tag :ul, :class => "pages level-#{child.level}" do
          haml_tag :li do
            haml_tag :p do
              haml_tag :span, child.title
              haml_concat link_to "Edit", edit_control_center_page_path(child)
              haml_concat link_to "Delete", control_center_page_path(child), :method => :delete, :confirm => "Are you sure?"
              haml_concat link_to "Add Child", new_control_center_page_path(:level => child.level + 1, :parent_id => child.id)
            end
            nested_pages_for child if Page.where(:parent_id => child.id).count > 0
          end
        end
      end
    end
  end
end
