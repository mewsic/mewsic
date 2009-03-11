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
    'gender_ico_' << {:male => 'M', :female => 'F', :other => 'O'}[gender.to_sym] << '.gif'
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
    # XXX TMP
    from = user.type.nil? ? 'user' : user.type.downcase

    %w[user band dj].map do |to|
      if from == to
        image_tag("change_#{to}_active.gif", :title => "You are currently a #{from}")
      else
        link_to(image_tag("change_#{to}_inactive.gif", :title => "Switch your user type to #{to}"),
          formatted_switch_type_user_path(user, 'html', :type => to),
          :class => 'lightview', :id => "user-switch-#{to}", :title => ' :: :: width:400, height:330')
      end
    end.join
  end

  def page_label_for(user)
    user_type = user.type.nil? ? 'user' : user.type.downcase
    image_tag("#{user_type}_page_label.gif", :alt => user_type.upcase)
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
    link_to image_tag('refresh.gif', :class => 'refresh-block'), top_users_path(url_options), :class => 'trigger'
  end

  def podcast_link_for(user, url)
    content = link_to(image_tag('icon_podcast.png'), '#', :id => 'podcast-link', :title => "#{user.nickname.upcase}'S PODCAST", :rel => 'tip-pcast')
    content << content_tag(:div, "Copy this address and subscribe in iTunes:<br/>#{link_to url, url}", :id => 'tip-pcast', :style => 'display:none;width:350px')
    content_tag(:div, content, :style => 'margin:4px 0px 0px 25px;float:left;')
  end


  def friend_link_for(user, text = nil)
    if current_user.is_friends_with?(user)
      link_to text || 'Unfriend', user_friendship_path(current_user, current_user.friendship(user)), :method => 'delete'
    elsif current_user.is_pending_friends_by_me_with?(user)
      link_to text || 'Unadmire', user_friendship_path(current_user, current_user.friendship(user)), :method => 'delete'
		elsif user.is_pending_friends_by_me_with?(current_user)
      link_to text || 'Become friend', user_friendships_path(current_user, :friend_id => user.id), :method => 'post'
    else
      link_to text || 'Admire', user_friendships_path(current_user, :friend_id => user.id), :method => 'post'
    end
  end

  # Quick & dirty, but it works. Used both on users/ and bands_and_deejays/ views.
  #
  def navigation_arrows_for(object_name, section, position = nil)
    object = instance_variable_get "@#{object_name.intern}"
    path = "#{object_name}_#{section}_path"

    links = content_tag(:p, :class => 'float-right') do
      navigation_arrow_for(object, :previous_page, path) + ' ' +
      navigation_arrow_for(object, :next_page, path)
    end

    spinner = content_tag(:div, :id => "#{object_name}-spinner%s" % (position ? "-#{position}" : nil), :class => 'float-right', :style => 'display:none') do
      image_tag 'spinner.gif'
    end

    links + spinner
  end

  def navigation_arrow_for(object, method, path)
    direction = method == :previous_page ? 'left' : 'right'
    if object.send(method)
      link_to image_tag("move_arrow_#{direction}.png"), send(path, :page => object.send(method)), :class => 'navigation'
    else
      image_tag("move_arrow_#{direction}.png", :class => 'faded')
    end
  end

end
