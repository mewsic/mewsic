# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def load_prototype
    if RAILS_ENV == 'production'
      return %[<script src="http://www.google.com/jsapi"></script>] + javascript_tag(%[
          google.load('prototype', '1.6.0.2');
          google.load('scriptaculous', '1.8.1'); ])
    else
      javascript_include_tag 'protoculous'
    end
  end

  def google_analytics(id = 'UA-3674352-1')
    return if RAILS_ENV == 'development'
    javascript_tag(%[
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    ]) +
    javascript_tag(%[
      var pageTracker = _gat._getTracker("#{id}");
      pageTracker._initData();
      pageTracker._trackPageview();
    ])
  end
  
  def rating(rateable, options = {})
    type_class = rateable.class.name.downcase
    type_class = 'user' if %w[dj band].include?(type_class)

    options = options.symbolize_keys
    clear_class = 'clear-block' if options.delete(:clear)
    options[:class] = "rating #{clear_class} #{type_class} #{options[:class]}"
    options[:class] += " locked" if logged_in? && !rateable.rateable_by?(current_user)

    tag_options = options.map { |k,v| %(#{k}="#{v}") }.join(' ')

    %[<div id="#{type_class}_#{rateable.id}" rel="#{rateable.rating_avg.to_f} #{rateable.rating_count}"  #{tag_options}></div>]
  end
  
  def body_class
    controller.controller_name == "dashboard" ? "home" : ""
  end
  
  def check_active(*controllers)
    current = controller.controller_name
    if controllers.last.kind_of?(ActiveRecord::Base)
      model = controllers.pop
      if model.class.name == 'User' && controllers.include?('users') or
        %w[Band Dj Mband].include?(model.class.name) && controllers.include?('bands_and_deejays')
        'active'
      end
    else
      controllers.include?(current) ? "active" : ""
    end

  end
  
  def clickable_logo
    logo = image_tag "logo_myousica.gif", :title => 'myousica logo'
    if controller.controller_name == "dashboard"
      logo
    else
      link_to logo, root_path
    end
  end
  
  def breadcrumb(model_crumb = nil, klass = nil)
    return if controller.controller_name == 'dashboard'

    bread = []
    title = []

    if controller.respond_to?(:to_breadcrumb_link)
      text, path = controller.send(:to_breadcrumb_link)

      bread.push path ? link_to(text, path) : text
      title.push text.downcase
    else
      text = controller.send(:to_breadcrumb)
      path = send("#{controller.controller_name}_path")

      bread.push link_to(text.capitalize, path)
      title.push text.downcase
    end

    if model_crumb
      text = h(model_crumb.to_breadcrumb)

      bread.push text
      title.push text
    end

    content_for :breadcrumb, %[<div id="path" class="#{klass}"><a href="/">Home</a> : #{bread.join(' : ')}</div>]
    content_for :title, '- ' << title.join(' - ') unless title.empty?
  end
  
  def render_breadcrumb
    breadcrumb unless @content_for_breadcrumb
    @content_for_breadcrumb
  end

  def render_title
    breadcrumb unless @content_for_title
    @content_for_title
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
    #  content << render(:partial => 'shared/share_myousica')
    content = render(:partial => 'shared/banners')
    if logged_in?
      content << render(:partial => 'shared/mlab')
    else
      unless params[:controller] == 'sessions' || (params[:controller] == 'users' && (params[:action] == 'new' || params[:action] == 'create'))
        content << render(:partial => 'shared/login_box')
      end
    end
  end    
  
  def avatar_path(model, size)
    model.avatars.last.nil? ? "default_avatars/avatar_#{size}.gif" : model.avatars.last.public_filename(size)
  end

  def avatar_image(model, size, options = {})
    path = avatar_path(model, size)
    options = {:id => "avatar_#{model.avatars.last.id}"}.merge(options) unless model.avatars.last.nil?
    options.update(:alt => model.to_breadcrumb, :title => model.to_breadcrumb) if model.respond_to? :to_breadcrumb
    image_tag path, options
  end
  
  def user_type_image(model, options = {})
    image_tag("#{model.class.name.downcase}_type.png", options)
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

  def hidden_iframe(name)
    %[<iframe name="#{name}-iframe" id="#{name}-iframe" src="about:blank"
          style="position:absolute;left:-100px;width:0px;height:0px;border:0px"></iframe>]
  end
end
