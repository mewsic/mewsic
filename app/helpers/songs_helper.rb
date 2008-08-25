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

  def delete_button(song)
    link_to image_tag('button_delete_mypage.png', :alt => 'DELETE', :title => 'Confirm song removal'),
      confirm_destroy_user_song_path(current_user, song), :rel => 'ajax',
      :class => 'lightview', :title => 'Confirm song removal :: :: width:400, height:330, ajax:{ method: "get" }'
  end
end
