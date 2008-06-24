var Templateable = Class.create({
  toHTML: function() {
    return new Template(this.template).evaluate(this);
  }
});

var Instrument = Class.create(Templateable, {
  template: '<p class="instrument"><a href="#" rel="#{value}"><img src="/images/#{icon}" class="icon" /><span class="name">#{name}</span></a></p>',

  initialize: function(icon, name, value) {
    this.icon = icon;
    this.name = name;
    this.value = value;
  }
});

var InstrumentGroup = Class.create(Templateable, {
  template: '<div class="instrument_group"><p class="label">#{label}</p>#{instruments}</div>',

  initialize: function(label) {
    this.label = label;
    this.instruments = '';
  },

  addInstrument: function(instrument) {
    this.instruments += instrument.toHTML();
  }
});

var InstrumentsSelect = Class.create({
  initialize: function(element) { 
    this.element = $(element);
    if (!this.element)
      return;

    this.instrument_list = null;
    this.build();
  },

  build: function() {
    if (this.instrument_list == null) { // build it once
      instrument_list = new Element('div', {id: 'instrument_list', style: 'display:none;'});
    
      this.element.select('optgroup').each(function(group) {
        var group_html = new InstrumentGroup(group.label);
        group.descendants().each(function(option) {
          var icon = option.getAttribute('rel');
          var name = option.text;
          var value = option.value;
          group_html.addInstrument(new Instrument(icon, name, value));
        });

        instrument_list.insert({bottom: group_html.toHTML()});
      });

      this.instrument_list = instrument_list;
      this.instrument_layer = new Element('div', {id: 'instrument_layer'});
      if (Prototype.Browser.IE) {
        // IE hack.. it reacts to onclick events only if the div actually
        // contains some text..... there should be a better way .....
        this.instrument_layer.setOpacity(0);
        this.instrument_layer.innerHTML = 'MMMMMMMMMMMMMMMMMMMM';
      }
    }

    this.element.up().insert({bottom: this.instrument_layer});
    this.element.up().insert({bottom: this.instrument_list});

    this.instrument_layer.observe('click', this.toggle.bind(this));
    this.instrument_list.select('a').each(this.onInstrumentClick.bind(this));
  },

  toggle: function(event) {
    event.stop();
    Effect.toggle(this.instrument_list, 'blind', {duration: 0.3});
  },

  onInstrumentClick: function(link) {
    link.observe('click', this.instrumentSelected.bind(this, link.getAttribute('rel')));
  },

  instrumentSelected: function(value, event) {
    event.stop();

    this.instrument_list.blindUp({duration: 0.3});
    this.setValue(value);
  },

  setValue: function(value) {
    this.element.value = value;
  }

});
