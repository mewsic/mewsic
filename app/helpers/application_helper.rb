# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Use to build a star rating
  def stars(n, color = 'green')
    result = ""
    n.times { result << "<img src=\"/images/star_#{color}.png\" alt=\"\" width=\"10\" height=\"9\" />"}
    result
  end
  
  def body_class
    controller.controller_name == "dashboard" ? "home" : ""
  end
  
  def check_active(controller_name)
    controller.controller_name == controller_name ? "active" : ""
  end
  
  def clickable_logo
    if controller.controller_name == "dashboard"
      image_tag "logo_myousica.gif"
    else
      link_to image_tag("logo_myousica.gif"), root_path
    end
  end
  
  def breadcrumb
    '<div id="path"><a href="#">Home</a> : people (todo breadcrumb)</div>'
  end
  
end
