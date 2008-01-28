# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Use to build a star rating
  def stars(n, color = 'green')
    result = ""
    n.to_i.times { result << "<img src=\"/images/star_#{color}.png\" alt=\"\" width=\"10\" height=\"9\" />"}
    result
  end
  
  def body_class
    controller.controller_name == "dashboard" ? "home" : ""
  end
  
  def check_active(*controller_name)
    controller_name.include?(controller.controller_name) ? "active" : ""
  end
  
  def clickable_logo
    if controller.controller_name == "dashboard"
      image_tag "logo_myousica.gif"
    else
      link_to image_tag("logo_myousica.gif"), root_path
    end
  end
  
  def breadcrumb(model_crumb = nil)
    default_breadcrumb = '<div id="path"><a href="/">Home</a>'
    unless controller.controller_name == 'dashboard'
      default_breadcrumb += ' : ' + link_to(controller.send(:to_breadcrumb).capitalize, send("#{controller.controller_name}_path"))
      default_breadcrumb += ' : ' + link_to(model_crumb.to_breadcrumb, send("#{controller.controller_name.singularize}_path", [model_crumb.id])) if model_crumb
    end    
    default_breadcrumb + '</div>'
  end
      
  def tags_for_cloud(klass, group, attribute, css_classes)
    weighted_list = klass.count :include => group, :group => group, :order => "#{group.to_s.pluralize}.#{attribute} ASC"
    
    counts = weighted_list.transpose.last.sort
    min = counts.first
    max = counts.last
        
    divisor = ((max - min) / css_classes.size) + 1
    
    weighted_list.each do |t|
      yield t[0], css_classes[(t[1] - min) / divisor]
    end
  end

  def render_tag_cloud(klass, group, attribute, other_options = {})
    options = {:with_paragraphs => false, :limit => nil}.merge(other_options)
    
    counter = 0
    result = ""
    
    tags_for_cloud(klass, group, attribute, %w(cloud1 cloud2 cloud3 cloud4 cloud5)) do |obj, css_class|
      anchor = link_to obj[attribute], {:controller => "#{group.to_s.pluralize}", :action => 'show', :id => obj}, {:class => css_class} 
      result += options[:with_paragraphs] ? "<p>#{anchor}</p>" : anchor
      counter +=1
      return result if options[:limit] && counter >= options[:limit]
    end
    
    result
  end
  
end
