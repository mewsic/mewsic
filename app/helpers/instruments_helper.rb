module InstrumentsHelper

  def track_instrument_icon(track, options = {})
    instrument_icon track.instrument, options
  end     

  def instrument_icon(instrument, options = {})
    icon = instrument.icon.dup

    if playable = options.delete(:playable)
      options.update(:rel => send("formatted_#{playable.class.name.downcase}_player_path", playable, 'html'), :class => 'player instrument')
    end

    icon.sub! /^instruments/, '\&/grey' if options[:grey]
    image_tag icon, {:class => 'instrument', :alt => instrument.description, :tip => instrument.description, :size => '29x29'}.merge(options)
  end

end
