module IdeasHelper

  def idea_icon_for(track)
    image_tag(track.idea? ? 'ideas_yes.png' : 'ideas_no.png', :class => 'idea-icon')
  end

  def idea_link_for(track)
    image = idea_icon_for(track)
    if track.user == current_user
      link_to_remote image, :url => toggle_idea_user_track_path(current_user, track), :method => :put, :html => {:id => "toggle_idea_#{track.id}"}
    else
      image
    end
  end

  def instrument_browse_link(text, id)
    link_to text, by_instrument_ideas_path(:instrument_id => id), :class => 'browse', :rel => "instrument_#{id}"
  end

  def instrument_browse_icon(instrument, options = {})
    if instrument.ideas.count.zero?
      instrument_icon(instrument, :grey => true)
    else
      klass = "instrument #{options.delete(:class)}"
      image = instrument_icon instrument, :class => klass, :id => options.delete(:id)
      link_to image, by_instrument_ideas_path(:instrument_id => instrument.id),
        :class => 'browse', :rel => options.delete(:rel)
    end
  end

end
