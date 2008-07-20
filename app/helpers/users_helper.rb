module UsersHelper
  
  def radio_button_for_user(name, value, options = {})
    checked = params[:user] && params[:user][name.to_sym] == value.to_s ? 'checked="checked"' : ''
    _class = options.include?(:class) ? "class=\"#{options[:class]}\"" : ''
    %|<input #{checked} #{_class} id="user_#{name}_#{value}" name="user[#{name}]" type="radio" value="#{value}" />|
  end
   
  def current_user_page?(options = {})
    options[:admin] = true unless options.has_key? :admin
    logged_in? && (current_user == @user or (options[:admin] && current_user.is_admin?))
  end
  
  def signup_error_message
    %|<p class="alert">There were errors during the signup process, please check the fields.</p>| unless @user.errors.empty?
  end
  
  def gender_icon_path(gender)
    'gender_ico_' << {:male => 'M', :female => 'F', :other => 'O'}[gender.to_sym] << '.png'
  end

  def gender_icon_for(user)
    image_tag gender_icon_path(user.gender), :alt => user.gender, :id => 'user_gender' unless user.gender.blank?
  end

  def gender_switcher_for(user)
    return unless user.gender.blank? and current_user_page?

    link_to('[set]', '#', :id => 'change-gender-trigger') <<
      %|<div id="change-gender">| << %w(male female other).map { |gender|
        image_tag gender_icon_path(gender), :alt => gender, :title => gender }.join << '</div>'
  end
  
  def user_photo_link
    unless @user.photos_url.blank?
      %|<a class="tip-link" rel="tip-photos" title="PHOTOS" href="#"><img class="float-left" alt="" src="/images/icone_link_photo.gif"/>Photos</a><div id="tip-photos" style="display:none"><a href="#{@user.photos_url}" target="_new">#{@user.nickname}'s photos</a></div>|
    end
  end
  
  def user_blog_link
    unless @user.blog_url.blank?
      %|<a class="tip-link" rel="tip-blog" title="BLOG" href="#"><img class="float-left" alt="" src="/images/icone_link_blog.gif"/>Blog</a><div id="tip-blog" style="display:none"><a href="#{@user.blog_url}" target="_new">#{@user.nickname}'s blog</a></div>|
    end
  end
  
  def user_myspace_link
    unless @user.myspace_url.blank?
      %|<a class="tip-link" rel="tip-myspace" title="MYSPACE PAGE" href="#"><img class="float-left" alt="" src="/images/icone_link_myspace.gif"/>MySpace</a><div id="tip-myspace" style="display:none"><a href="#{@user.myspace_url}" target="_new">#{@user.nickname}'s myspace</a></div>|
    end
  end
  
  def user_skype_link
    if !@user.skype.blank? && @user.skype_public?
      %|<a class="tip-link" rel="tip-skype" title="SKYPE CONTACT" href="#"><img class="float-left" alt="" src="/images/icone_link_skype.gif"/>Skype</a><div id="tip-skype" style="display:none"><a href="callto://#{@user.skype}">#{@user.skype}</a></div>|
    end
  end
  
  def user_msn_link
    if !@user.msn.blank? && @user.msn_public?
      %|<a class="tip-link" rel="tip-msn" title="MSN CONTACT" href="#"><img class="float-left" alt="" src="/images/icone_link_MSN.gif"/>MSN</a><div id="tip-msn" style="display:none"><a href="#{@user.msn}" class="msn-link">#{@user.msn}</a></div>|
    end
  end

  def user_full_name(user)
    if @user.name_public?
      %|<div class="mypage-name grey-text">#{"%s %s" % [user.first_name, user.last_name]}</div>|
    end
  end

  def user_edit_button(field)
    %|<a href="#" class="edit" id="edit_button_user_#{field.to_s}">[edit]</a>| if current_user_page?
  end    
   
  def switch_type_images_for(user)
    content = ""
    %w[user band dj].each do |to|
      from = user.type.nil? ? 'user' : user.type.downcase
      icon = image_tag("change_#{to}_#{from == to ? 'active' : 'inactive'}.png")
      if from == to
        content << icon
      else
        content <<
          link_to(icon, formatted_switch_type_user_path(user, 'html', :type => to),
            :class => 'lightview', :id => "user-switch-#{to}", :title => ' :: :: width:400, height:300')
      end
    end
    content
  end
  
  def page_label_for(user)
    user_type = user.type.nil? ? 'user' : user.type.downcase
    %|<img src="/images/#{user_type}_page_label.png" />|
  end
  
  def user_inbox_link
    content = link_to("inbox (#{current_user.unread_message_count})", user_path(current_user) + '#inbox', :id => 'inbox-link');
    content = "<strong>#{content}</strong>" if current_user.unread_message_count > 0
    content
  end

  def empty_collection_message(collection, options = {})
    return unless collection.size.zero?
    current, any = options.delete(:current_user), options.delete(:any_user)
    message = send(options.delete(:method) || :current_user_page?) ? current : any

    options[:class] = "centered abstract #{options[:class]}"

    content_tag :p, message, options if message
  end

  def refresh_block_image_link(url_options = {})
    link_to image_tag('refresh.png', :class => 'refresh-block'), top_users_path(url_options), :class => 'trigger'
  end

end

