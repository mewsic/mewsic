# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def stars(n, color = 'green')
    result = ""
    n.times { result << "<img src=\"/images/star_#{color}.png\" alt=\"\" width=\"10\" height=\"9\" />"}
    result
  end
  
end
