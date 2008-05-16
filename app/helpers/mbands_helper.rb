module MbandsHelper
  
  def current_user_mband_page?
    logged_in? && @mband.members.include?(current_user)
  end
  
  def mband_photo_link
    content = ''
    unless @mband.photos_url.blank?
      content << %|<a href="#{@mband.photos_url}"><img class="float-left" alt="" src="/images/icone_link_photo.gif"/></a><p><a href="#{@mband.photos_url}">Photo</a></p>|
    end
    return content
  end
  
  def mband_myspace_link
    content = ''
    unless @mband.myspace_url.blank?
      content << %|<a href="#{@mband.myspace_url}"><img width="16" height="19" class="float-left" alt="" src="/images/icone_link_myspace.gif"/></a><p><a href="#{@mband.myspace_url}">MySpace</a></p>|
    end
    content
  end
  
  def mband_blog_link
    content = ''
    unless @mband.blog_url.blank?
      content << %|<a href="#{@mband.blog_url}"><img width="16" height="19" class="float-left" alt="" src="/images/icone_link_blog.gif"/></a><p><a href="#{@mband.blog_url}">Blog</a></p>|
    end
    content
  end
  
  def mband_edit_button(field)
    %|<a href="#" class="edit" id="edit_button_user_#{field.to_s}">[edit]</a>| if current_user_page?
  end      
  
end
