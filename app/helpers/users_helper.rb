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

  def track_instrument_icon(track, options = {})
    instrument_icon track.instrument
  end     

  def instrument_icon(instrument, options = {})
    image_tag instrument.icon, {:class => 'instrument', :alt => instrument.description, :rel => instrument.description, :size => '29x29'}.merge(options)
  end
  
  def user_photo_link
    content = ''
    unless @user.photos_url.blank?
      content << %|<a href="#{@user.photos_url}" target="_new"><img class="float-left" alt="" src="/images/icone_link_photo.gif"/></a><p><a href="#{@user.photos_url}" target="_new">Photo</a></p>|
    end
    return content
  end
  
  def user_blog_link
    content = ''
    unless @user.blog_url.blank?
      content << %|<a href="#{@user.blog_url}" target="_new"><img width="16" height="19" class="float-left" alt="" src="/images/icone_link_blog.gif"/></a><p><a href="#{@user.blog_url}" target="_new">Blog</a></p>|
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
      content << %|<a class="button popup" href="#{im_contact_user_path(@user, :type => 'skype')}"><img width="17" height="19" class="float-left" alt="" src="/images/icone_link_skype.gif"/></a><p><a class="button popup" href="#{im_contact_user_path(@user, :type => 'skype')}">Skype</a></p>|
    end
    content    
  end
  
  def user_msn_link
    content = ''
    if !@user.msn.blank? && @user.msn_public?
      content << %|<a class="button popup" href="#{im_contact_user_path(@user, :type => 'msn')}"><img width="21" height="19" class="float-left" alt="" src="/images/icone_link_MSN.gif"/></a><p><a class="button popup" href="#{im_contact_user_path(@user, :type => 'msn')}">MSN</a></p>|
    end
    content    
  end

  def user_full_name(user)
    "%s %s" % [user.first_name, user.last_name]
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
            :class => 'lightwindow', :id => "user-switch-#{to}", :title => 'Change user type')
      end
    end
    content
  end
  
  def page_label_for(user)
    user_type = user.type.nil? ? 'user' : user.type.downcase
    %|<img src="/images/#{user_type}_page_label.png" alt="" width="41" height="56" />|
  end
  
  def user_inbox_link
    content = link_to("inbox (#{current_user.unread_message_count})", user_path(current_user) + '#inbox', :id => 'inbox-link');
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

