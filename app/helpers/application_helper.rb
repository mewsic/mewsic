# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Use to build a star rating
  def stars(n, color = 'green')
    result = ""
    n.to_f.round.times { result << "<img src=\"/images/star_#{color}.png\" alt=\"\" width=\"10\" height=\"9\" />"}
    (5 - n.to_f.round).times { result << "<img src=\"/images/star_gray.png\" alt=\"\" width=\"10\" height=\"9\" />"}
    result
    # result = '<div class="rating" id="ciao">'
    # 5.times do |i|
    #   result << "<div class=\"star#{i < 2 ? ' selected' : ''}\"></div>"
    # end
    # result << '<div style="clear:both"></div></div>'
  end
  
  def rating(rateable)
    type_class = rateable.class.name.downcase
    type_class = 'user' if %w[dj band].include?(type_class)
    result = %|<div class="rating #{type_class}_rating" id="#{type_class}_#{rateable.id}"><div class="stars">|
    1.upto(5) do |i| 
      on_class    = rateable.rating_avg.to_f >= i ? ' on' : ''
      half_class  = rateable.rating_avg.to_f < i && rateable.rating_avg.to_f > (i -1) ? ' on half' : ''
      result << "<div class=\"star#{on_class}#{half_class}\"></div>"
    end
    result << %|</div><div class="clearer"></div></div>|
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
      if controller.respond_to?(:to_breadcrumb_link)
        text, path = controller.to_breadcrumb_link
        default_breadcrumb += ' : ' + link_to(text, path)
      else
        default_breadcrumb += ' : ' + link_to(controller.send(:to_breadcrumb).capitalize, send("#{controller.controller_name}_path"))
      end      
      default_breadcrumb += ' : ' + link_to(model_crumb.to_breadcrumb, send("#{controller.controller_name.singularize}_path", [model_crumb.id])) if model_crumb
    end    
    default_breadcrumb += '</div>'
    content_for :breadcrumb, default_breadcrumb
  end
  
  def render_breadcrumb
    breadcrumb unless @content_for_breadcrumb
    @content_for_breadcrumb
  end
      
  def tags_for_cloud(klass, group, attribute, css_classes)
    options = { :include => group, :group => group, :order => "#{group.to_s.pluralize}.#{attribute} ASC", :order => 'count_all DESC', :limit => 40 }
    options[:conditions] = ["songs.published = ?", true] if klass == Song
    weighted_list = klass.count(options)
    
    counts = weighted_list.transpose.last.sort
    min = counts.first
    max = counts.last
        
    divisor = ((max - min) / css_classes.size) + 1

    weighted_list = weighted_list.sort{|a, b| a[0].name <=> b[0].name }
    
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
      result += "&nbsp;\n"
      counter +=1
      return result if options[:limit] && counter >= options[:limit]
    end
    
    result
  end
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end    
  
  def render_sidebar   
    content = ''
    if params[:controller] == 'users' && (params[:action] == 'new' || params[:action] == 'create')
      content << render(:partial => 'shared/share_myousica')
    else
      content << render(:partial => 'shared/login_box') unless logged_in?
      content << render(:partial => 'shared/mlab') if logged_in?
    end
    content
  end    
  
  def avatar_image(model, size, css_class = '')
    image_tag((model.avatars.last.nil? ? "/images/default_avatars/avatar_#{size}.gif" : model.avatars.last.public_filename(size)), :class => css_class)
  end
end
