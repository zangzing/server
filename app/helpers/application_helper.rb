# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #Return a base title with decorations if any
  def title
    base_title = "Ruby Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{h(@title)}"
    end
  end
  
  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

end
