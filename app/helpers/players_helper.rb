module PlayersHelper
  
  def play_button(playable, options = {})    
    link_to(image_tag('button_play_green.png'), send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html'), 
      :class => 'lightwindow',
      :params => "lightwindow_width=300,lightwindow_height=50,lightwindow_show_images=2"
    ) 
  end
  
end
