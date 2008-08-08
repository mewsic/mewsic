module PlayersHelper
  
  def play_button(playable, options = {})    
    options = {}
    options[:color] = playable.is_a?(Track) ? :orange : :green
    options.merge(options)
    link_to(image_tag("button_play_#{options[:color]}.png", :alt => 'PLAY'), send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html') << "?#{(rand * 10**12).to_i}", 
      :class => 'player'
    ) 
  end
  
end
