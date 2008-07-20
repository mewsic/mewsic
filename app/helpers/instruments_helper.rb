module InstrumentsHelper

  def track_instrument_icon(track, options = {})
    instrument_icon track.instrument, options
  end     

  def instrument_icon(instrument, options = {})
    icon = instrument.icon.dup
    icon.sub! /^instruments/, '\&/grey' if options[:grey]
    image_tag icon, {:class => 'instrument', :alt => instrument.description, :rel => instrument.description, :size => '29x29'}.merge(options)
  end

end
