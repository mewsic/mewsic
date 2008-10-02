module BandMembersHelper
  def instruments_select(player, name = nil, selected = nil)
    %(<select name="#{name}" id="#{name.gsub(/[\[\]]/, '_').sub(/_$/,'')}"><option value=""></option>#{instrument_groups_tags(player, selected)}</select>)
  end

  def instrument_groups_tags(player, selected = nil)
    InstrumentCategory.find(:all, :order => :description).map { |category| instrument_group_option_tags(category, player.instrument_id) }.join("\n")
  end

  def instrument_group_option_tags(category, selected = nil)
    %(<optgroup label="#{category.description}">#{instrument_option_tags(category.instruments.find(:all, :order => :description), selected)}</optgroup>)
  end

  def instrument_option_tags(instruments, selected = nil)
    instruments.map { |i| instrument_option(i, selected) }.join("\n")
  end

  def instrument_option(instrument, selected = nil)
    selected = instrument.id == selected ? ' selected="selected"' : ''
    %(<option rel="#{instrument.icon}" value="#{instrument.id}"#{selected}>#{instrument.description}</option>)
  end

  def member_name(member)
    if member.linked_to_myousica_user?
      link_to member.linked_user.login, user_path(member.linked_user)
    else
      member.nickname
    end
  end
end
