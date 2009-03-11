# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def jquery_javascript_tags
    if RAILS_ENV == 'production'
      # Load from google APIs
      #
      #  return %[<script src="http://www.google.com/jsapi"></script>] + javascript_tag(%[
      #      google.load('jquery', '1.3.2');
      #      google.load('jquery-ui', '1.6.0'); ])
      javascript_include_tag 'jquery-1.3.2.min.js', 'jquery-ui-1.7.custom.min.js'
    else
      javascript_include_tag 'jquery-1.3.2.js', 'jquery-ui-1.7.custom.js'
    end
  end

  def jquery_stylesheet_tags
    stylesheet_include_tag 'themes/base/ui.all.css'
  end

  def google_analytics_load
    return if RAILS_ENV == 'development'
    javascript_tag(%[
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    ])
  end

  def google_analytics_track(pagename = nil, id = nil)
    return if RAILS_ENV == 'development'
    pagename = %("#{escape_javascript(pagename)}") unless pagename.nil?
    javascript_tag(%[
      var pageTracker = _gat._getTracker("#{id}");
      pageTracker._initData();
      pageTracker._trackPageview(#{pagename});
    ])
  end

  def firebug_lite
    return if RAILS_ENV != 'development'
    %[<script type='text/javascript' src='http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js'></script>]
  end
  
  def rating(rateable, options = {})
    klass = rateable.class.name.downcase

    options = options.symbolize_keys
    options[:class] = "rating #{klass} #{options[:class]}"
    options[:class] += " locked" if logged_in? && !rateable.rateable_by?(current_user)

    tag_options = options.map { |k,v| %(#{k}="#{v}") }.join(' ')

    # XXX TMP
    %[<div id="#{type_class}_#{rateable.id}" rel="#{rateable.rating_avg.to_f} #{rateable.rating_count}"  #{tag_options}></div>]
  end
  
  def status(model, options = {})
    name = {'on' => 'online', 'off' => 'offline', 'rec' => 'recording'}[model.status]
    content_tag(:div, image_tag("status_#{name}.png", :alt => name.upcase), :class => "status #{name} #{options[:class]}")
  end
  
  def active_class(controller, klass = 'current')
    (self.controller.controller_name == controller) ? klass, '' 
  end
  
  def clickable_logo(image)
    logo = image_tag image, :alt => 'MEWSIC'
    if controller.controller_name == "dashboard"
      logo
    else
      link_to logo, root_path
    end
  end

  def breadcrumb(model_crumb = nil, klass = nil)
    return if controller.controller_name == 'dashboard'

    bread = []

    if controller.respond_to?(:to_breadcrumb_link)
      text, path = controller.send(:to_breadcrumb_link)
      bread.push path ? link_to(text, path) : text
    else
      text = controller.send(:to_breadcrumb)
      path = send("#{controller.controller_name}_path")
      bread.push link_to(text.capitalize, path)
    end

    if model_crumb
      text = h(truncate(model_crumb.to_breadcrumb, :length => 50))
      bread.push text
    end

    content_for :breadcrumb, %[<div id="path" class="#{klass}"><a href="/">Home</a> : #{bread.join(' : ')}</div>]
  end

  def title(text)
    content_for :title, h(text)
  end

  def meta_description(description)
    content_for :meta_description, h(description)
  end
  
  def render_breadcrumb
    breadcrumb unless @content_for_breadcrumb
    @content_for_breadcrumb
  end

  def render_title
    @content_for_title 
  end
 
  def render_meta_description
    @content_for_meta_description
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
    # XXX TMP
    unless logged_in? || (params[:controller] == 'sessions' || (params[:controller] == 'users' && (params[:action] == 'new' || params[:action] == 'create')))
    end
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

  def ie?(version = 6)
    request.headers['HTTP_USER_AGENT'] =~ /MSIE #{version}\.\d+/
  end

  def notification_url(path)
    APPLICATION[:url] + path
  end

  # Builds an anchor element using the APPLICATION[:url] URI base.
  # Used in e-mail notifications, where the context doesn't contain
  # the current site URI base.
  #
  def notification_link_to(text, path = nil)
    if path.nil?
      path = notification_url(text)
      link_to path, path
    else
      link_to text, notification_url(path)
    end
  end

end

class AjaxUploadFormBuilder < ActionView::Helpers::FormBuilder
  def ajax_file_field(name)
    file_field name, :size => 1
  end

  def hidden_iframe(name)
    %[<iframe name="#{name}-iframe" id="#{name}-iframe" src="about:blank"
          style="position:absolute;left:-100px;width:0px;height:0px;border:0px"></iframe>]
  end
end
