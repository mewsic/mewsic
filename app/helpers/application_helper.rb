# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def rating(rateable, options = {})
    type_class = rateable.class.name.downcase
    type_class = 'user' if %w[dj band].include?(type_class)

    options = options.symbolize_keys
    clear_class = 'clear-block' if options.delete(:clear)
    options[:class] = "rating #{clear_class} #{type_class} #{options[:class]}"
    options[:class] += " locked" if logged_in? && !rateable.rateable_by?(current_user)

    tag_options = options.map { |k,v| %(#{k}="#{v}") }.join(' ')

    %[<div id="#{type_class}_#{rateable.id}" rel="#{rateable.rating_avg.to_f}" #{tag_options}></div>]
  end
  
  def body_class
    controller.controller_name == "dashboard" ? "home" : ""
  end
  
  def check_active(*controller_name)
    controller_name.include?(controller.controller_name) ? "active" : ""
  end
  
  def clickable_logo
    logo = image_tag "logo_myousica.gif", :title => 'myousica logo'
    if controller.controller_name == "dashboard"
      logo
    else
      link_to logo, root_path
    end
  end
  
  def breadcrumb(model_crumb = nil)
    default_breadcrumb = '<div id="path"><a href="/">Home</a>'
    unless controller.controller_name == 'dashboard'
      if controller.respond_to?(:to_breadcrumb_link)
        text, path = controller.send(:to_breadcrumb_link)
        default_breadcrumb += ' : ' + link_to(text, path)
      else
        default_breadcrumb += ' : ' + link_to(controller.send(:to_breadcrumb).capitalize, send("#{controller.controller_name}_path"))
      end      
      default_breadcrumb += ' : ' + h(model_crumb.to_breadcrumb) if model_crumb
    end    
    default_breadcrumb += '</div>'
    content_for :breadcrumb, default_breadcrumb
  end
  
  def render_breadcrumb
    breadcrumb unless @content_for_breadcrumb
    @content_for_breadcrumb
  end
      
  def tags_for_cloud(klass, group, attribute, css_classes, limit = nil)
    limit ||= 40
    options = { :include => group, :group => group, :order => "#{group.to_s.pluralize}.#{attribute} ASC", :order => 'count_all DESC', :limit => limit }
    options[:conditions] = ["songs.published = ? AND songs.genre_id IS NOT NULL", true] if klass == Song
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
    
    result = ""
    
    tags_for_cloud(klass, group, attribute, %w(cloud1 cloud2 cloud3 cloud4 cloud5), options[:limit]) do |obj, css_class|
      anchor = link_to obj[attribute], send("#{group}_url", obj), {:class => css_class}
      result += options[:with_paragraphs] ? "<p>#{anchor}</p>" : anchor
      result += "&nbsp;\n"
    end
    
    result
  end
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end    
  
  def render_sidebar   
    content = ''
    return content if params[:controller] == 'sessions'

    if params[:controller] == 'users' && (params[:action] == 'new' || params[:action] == 'create')
      content << render(:partial => 'shared/share_myousica')
    else
      content << render(:partial => 'shared/login_box') unless logged_in?
      content << render(:partial => 'shared/mlab') if logged_in?
    end
    content
  end    
  
  def avatar_image(model, size, options = {})
    path = model.avatars.last.nil? ? "default_avatars/avatar_#{size}.gif" : model.avatars.last.public_filename(size)
    options = {:id => "avatar_#{model.avatars.last.id}"}.merge(options) unless model.avatars.last.nil?

    image_tag path, options
  end
  
  def user_type_image(model, options = {})
    image_tag("#{model.class.name.downcase}_type.png", options)
  end
  
  def download_link_for(item, text)
    link_to text, send("download_#{item.class.name.downcase}_url", item), :class => 'download'
  end

  def download_button_for(item)
    download_link_for item, image_tag('icon_download.png')
  end

  def ajax_upload_form(model, options, &block)
    klass = model.kind_of?(User) ? User : model.class
    url = options[:url] || send("formatted_%s_%s_path" % [klass.name.underscore, options[:name]], model, 'js')
    form_for(options[:name], :url => url,
      :builder => AjaxUploadFormBuilder, :html => {
        :id => "#{options[:id]}-form", :multipart => true,
        :target => "#{options[:id]}-iframe", :method => options[:method] || 'post'
    }, &block)
  end

end

class AjaxUploadFormBuilder < ActionView::Helpers::FormBuilder
  def ajax_file_field(name)
    file_field name, :size => 1
  end

  def hidden_iframe(name) # XXX this name is useless remove it
    %[<iframe name="#{name}-iframe" id="#{name}-iframe" src="about:blank"
          style="position:absolute;left:-100px;width:0px;height:0px;border:0px"></iframe>]
  end
end
