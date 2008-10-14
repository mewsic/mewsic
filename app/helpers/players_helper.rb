module PlayersHelper
  
  def play_button(playable, options = {})    
    options.reverse_update(:color => playable.is_a?(Track) ? :orange : :green)
    image_tag "button_play_#{options[:color]}#{options[:size]}.png", :alt => 'PLAY', :class => 'player',
      :rel => send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html')
  end
  
  def delete_button(playable)
    class_name = playable.class.name.downcase
    url = send("confirm_destroy_#{class_name}_url", playable)
    link_to image_tag('button_delete_mypage.png', :alt => 'DELETE', :title => "Delete #{class_name}"),
      url, :rel => 'ajax', :class => 'lightview', :title => "Confirm #{class_name} removal :: :: width:400, height:330, ajax:{ method: 'get' }"
  end

end
