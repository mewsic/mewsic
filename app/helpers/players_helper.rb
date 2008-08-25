module PlayersHelper
  
  def play_button(playable, options = {})    
    options.reverse_update(:color => playable.is_a?(Track) ? :orange : :green)
    image_tag "button_play_#{options[:color]}#{options[:size]}.png", :alt => 'PLAY', :class => 'player',
      :rel => send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html')
  end
  
end
