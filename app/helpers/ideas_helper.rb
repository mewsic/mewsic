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
    link_to_remote text, :update => 'ideas-by-instruments', :method => :get,
      :url => by_instrument_ideas_path(:instrument_id => id),
      :loading => "$('tab-spinner').show()", :complete => "$('tab-spinner').hide()"
  end

  def instrument_browse_icon(instrument, options = {})
    if instrument.ideas.count.zero?
      instrument_icon(instrument, :grey => true)
    else
      active = instrument == @instrument ? 'active' : ''
      klass = options.delete(:class) || "instrument #{active}"

      link_to_remote instrument_icon(instrument, :class => klass),
        {:loading => "$('tab-spinner').show", :complete => "$('tab-spinner').hide()",
        :update => 'ideas-by-instruments', :method => :get,
        :url => by_instrument_ideas_path(:instrument_id => instrument.id)}.merge(options)
    end
  end

end
