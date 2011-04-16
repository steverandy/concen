module ControlCenter
  module PagesHelper
    def pages_for(page)
      for child in Page.where(:parent_id => page.id)
        haml_tag :ul, :class => "pages level-#{child.level}" do
          haml_tag :li do
            haml_tag :p do
              haml_tag :span, child.title
              haml_tag :a, "New Page", :href => new_control_center_page_path(:level => child.level + 1, :parent_id => child.id)
            end
            if Page.where(:parent_id => child.id).count > 0
              pages_for child
            end
          end
        end
      end
    end
  end
end