module PlayersHelper
  
  def play_button(playable, options = {})    
    options = {}
    options[:color] = playable.is_a?(Track) ? :orange : :green
    options.merge(options)
    image_tag "button_play_#{options[:color]}.png", :alt => 'PLAY', :class => 'player',
      :rel => send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html')
  end
  
end
