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
  
  def gender_icon_for(user)
    icons = {:male => 'M', :female => 'F', :other => 'O'}
    %|<img alt="#{user.gender.to_s}" id="user_gender" class="#{icons[user.gender.to_sym]}" src="/images/gender_ico_#{icons[user.gender.to_sym]}.png"/>| unless @user.gender.blank?
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
    return content
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
      content << %|<a class="button popup" href="#{im_contact_user_path(@user)}"><img width="17" height="19" class="float-left" alt="" src="/images/icone_link_skype.gif"/></a><p><a class="button popup" href="#{im_contact_user_path(@user)}">Skype</a></p>|
    end
    content    
  end
  
  def user_msn_link
    content = ''
    if !@user.msn.blank? && @user.msn_public?
      content << %|<a class="button popup" href="#{im_contact_user_path(@user)}"><img width="21" height="19" class="float-left" alt="" src="/images/icone_link_MSN.gif"/></a><p><a class="button popup" href="#{im_contact_user_path(@user)}">MSN</a></p>|
    end
    content    
  end

  def user_edit_button(field)
    %|<a href="#" class="edit" id="edit_button_user_#{field.to_s}">[edit]</a>| if current_user_page?
  end    
   
  def switch_type_images_for(user)
    content = ""
    %w[user band dj].each do |type|	 
      image_name = "change_#{type}_"
      user_type = user.type.nil? ? 'user' : user.type.downcase
      image_name += (user_type == type ? 'active' : 'inactive' )
      content << link_to(image_tag("#{image_name}.png"), switch_type_user_path(user, :type => type), :method => 'put')
    end
    content
  end
  
  def page_label_for(user)
    user_type = user.type.nil? ? 'user' : user.type.downcase
    %|<img src="/images/#{user_type}_page_label.png" alt="" width="41" height="56" />|
  end
  
  def user_inbox_link
    content = link_to("inbox (#{current_user.unread_message_count})", user_path(current_user));
    content = "<strong>#{content}</strong>" if current_user.unread_message_count > 0
    content
  end

  def empty_collection_message(collection, options = {})
    return unless collection.size.zero?
    options.assert_valid_keys(:current_user, :any_user)
    message = current_user_page? ? options[:current_user] : options[:any_user] 

    %[<p class="centered grey-text"><em>#{message}</em></p>] if message
  end
end

