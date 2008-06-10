module BandMembersHelper
  def instruments_select(player, selected = nil)
    %(<select id="player_instrument_id" name="player[instrument]"><option></option>#{instrument_groups_tags(player, selected)}</select>)
  end

  def instrument_groups_tags(player, selected = nil)
    InstrumentCategory.find(:all).map { |category| instrument_group_option_tags(category, player.instrument.id) }.join("\n")
  end

  def instrument_group_option_tags(category, selected = nil)
    %(<optgroup label="#{category.description}">#{instrument_option_tags(category.instruments, selected)}</optgroup>)
  end

  def instrument_option_tags(instruments, selected = nil)
    instruments.map { |i| instrument_option(i, selected) }.join("\n")
  end

  def instrument_option(instrument, selected = nil)
    selected = instrument.id == selected ? ' selected="selected"' : ''
    %(<option rel="#{instrument.icon}" value="#{instrument.id}"#{selected}>#{instrument.description}</option>)
  end
end
