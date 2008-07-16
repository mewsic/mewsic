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

  def track_instrument_icon(track, options = {})
    instrument_icon track.instrument, options
  end     

  def instrument_icon(instrument, options = {})
    icon = instrument.icon.dup
    icon.sub! /^instruments/, '\&/grey' if options[:grey]
    image_tag icon, {:class => 'instrument', :alt => instrument.description, :rel => instrument.description, :size => '29x29'}.merge(options)
  end
  
  def user_photo_link
    content = ''
    unless @user.photos_url.blank?
      content << %|<a class="tip-link" rel="tip-photos" title="PHOTOS" href="#"><img class="float-left" alt="" src="/images/icone_link_photo.gif"/>Photos</a><div id="tip-photos" style="display:none"><a href="#{@user.photos_url}" target="_new">#{@user.nickname}'s photos</a></div>|
    end
    return content
  end
  
  def user_blog_link
    content = ''
    unless @user.blog_url.blank?
      content << %|<a class="tip-link" rel="tip-blog" title="BLOG" href="#"><img class="float-left" alt="" src="/images/icone_link_blog.gif"/>Blog</a><div id="tip-blog" style="display:none"><a href="#{@user.blog_url}" target="_new">#{@user.nickname}'s blog</a></div>|
    end
    content
  end
  
  def user_myspace_link
    content = ''
    unless @user.myspace_url.blank?
      content << %|<a class="tip-link" rel="tip-myspace" title="MYSPACE PAGE" href="#"><img class="float-left" alt="" src="/images/icone_link_myspace.gif"/>MySpace</a><div id="tip-myspace" style="display:none"><a href="#{@user.myspace_url}" target="_new">#{@user.nickname}'s myspace</a></div>|
    end
    content
  end
  
  def user_skype_link
    content = ''
    if !@user.skype.blank? && @user.skype_public?
      content << %|<a class="tip-link" rel="tip-skype" title="SKYPE CONTACT" href="#"><img class="float-left" alt="" src="/images/icone_link_skype.gif"/>Skype</a><div id="tip-skype" style="display:none"><a href="callto://#{@user.skype}">#{@user.skype}</a></div>|
    end
    content    
  end
  
  def user_msn_link
    content = ''
    if !@user.msn.blank? && @user.msn_public?
      content << %|<a class="tip-link" rel="tip-msn" title="MSN CONTACT" href="#"><img class="float-left" alt="" src="/images/icone_link_MSN.gif"/>MSN</a><div id="tip-msn" style="display:none"><a href="#{@user.msn}" class="msn-link">#{@user.msn}</a></div>|
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
            :class => 'lightview', :id => "user-switch-#{to}")
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

  def refresh_block_image_link(url_options = {})
    link_to image_tag('refresh.png', :class => 'refresh-block'), top_users_path(url_options), :class => 'trigger'
  end

  def idea_icon_for(track)
    image_tag(track.idea? ? 'ideas_yes.png' : 'ideas_no.png', :class => 'idea-icon')
  end
  def idea_link_for(track)
    image = idea_icon_for(track)
    if current_user_page?
      link_to_remote image, :url => toggle_idea_user_track_path(current_user, track), :method => :put, :html => {:id => "toggle_idea_#{track.id}"}
    else
      image
    end
  end
end

