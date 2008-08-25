module SongsHelper

  def download_link_for(item, text)
    if logged_in?
      link_to text, send("download_#{item.class.name.downcase}_url", item), :class => 'download'
    else
      link_to text, '#', :class => 'download', :onclick => 'return false;'
    end
  end

  def download_button_for(item)
    if logged_in?
      download_link_for item, image_tag('icon_download.png', :class => 'download')
    else
      image_tag 'icon_download.png', :class => 'c download'
    end
  end

  def edit_button(song)
    link_to image_tag('button_edit.png', :alt => 'EDIT'), multitrack_edit_path(song)
  end

end
