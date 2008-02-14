module UsersHelper
  
  def radio_button_for_user(name, value, options = {})
    checked = params[:user] && params[:user][name.to_sym] == value.to_s ? 'checked="checked"' : ''
    _class = options.include?(:class) ? "class=\"#{options[:class]}\"" : ''
    %|<input #{checked} #{_class} id="user_#{name}_#{value}" name="user[#{name}]" type="radio" value="#{value}" />|
  end
   
  def current_user_page?
    logged_in? && current_user == @user
  end
  
  def signup_error_message
    %|<p class="alert">There were errors during the signup process, please check the fields.</p>| unless @user.errors.empty?
  end
  
  def gender_icon
    icons = {:male => 'M', :female => 'F', :other => 'O'}
    %|<img alt="#{@user.gender.to_s}" id="user_gender" class="#{icons[@user.gender.to_sym]}" src="/images/gender_ico_#{icons[@user.gender.to_sym]}.gif"/>| unless @user.gender.blank?
  end
  
  def track_icon(track, color = nil)
    icon_color = "_#{color.to_s}" unless color.nil?
    %|<img width="29" height="29" alt="#{track.instrument}" src="/images/instrument_#{track.instrument}#{icon_color}.png"/>|
  end     
  
  def user_photo_link
    content = ''
    unless @user.photos_url.blank?
      content << %|<a href="#{@user.photos_url}"><img class="float-left" alt="" src="/images/icone_link_photo.gif"/></a><p><a href="#{@user.photos_url}">Photo</a></p>|
    end
    content
  end
  
  def user_blog_link
    content = ''
    unless @user.blog_url.blank?
      content << %|<a href="#{@user.blog_url}"><img width="16" height="19" class="float-left" alt="" src="/images/icone_link_blog.gif"/></a><p><a href="#{@user.blog_url}">Blog</a></p>|
    end
    content
  end
  
  def user_myspace_link
    content = ''
    unless @user.myspace_url.blank?
      content << %|<a href="#{@user.myspace_url}"><img width="16" height="19" class="float-left" alt="" src="/images/icone_link_myspace.gif"/></a><p><a href="#{@user.myspace_url}">MySpace</a></p>|
    end
    content
  end
  
  def user_skype_link
    content = ''
    if !@user.skype.blank? && @user.skype_public?
      content << %|<a href="#{@user.skype}"><img width="17" height="19" class="float-left" alt="" src="/images/icone_link_skype.gif"/></a><p><a href="#{@user.skype}">Skype</a></p>|
    end
    content    
  end
  
  def user_msn_link
    content = ''
    if !@user.msn.blank? && @user.msn_public?
      content << %|<a href="#{@user.msn}"><img width="21" height="19" class="float-left" alt="" src="/images/icone_link_MSN.gif"/></a><p><a href="#{@user.msn}">MSN</a></p>|
    end
    content    
  end
  
  def user_edit_button(field)
    %|<a href="#" class="edit" id="edit_button_user_#{field.to_s}">[edit]</a>| if current_user_page?
  end
  
  def user_icon_link(user)
    link_to(image_tag('button_mlab.png'), user_path(user))
  end
  
end