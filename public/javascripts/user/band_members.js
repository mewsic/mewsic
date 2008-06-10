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

var BandMembers = Class.create({
  initialize: function(element, user_id) {
    this.element = $(element);
    if (!this.element)
      return;

    this.user_id = user_id;

    this.spinner = this.element.down('#band_edit_spinner');

    this.core_box = this.element.down('#band_core');
    this.edit_box = this.element.down('#band_edit_link');

    this.b_loadBandForm = this.loadBandForm.bind(this);
    this.edit_box.down('a').observe('click', this.b_loadBandForm);
  },

  loadBandForm: function(event) {
    event.stop();

    this.edit_box.hide();
    this.spinner.show();

    new Effect.BlindUp(this.core_box, {duration: 0.3, queue: 'end'});
    new Ajax.Request('/users/' + this.user_id + '/members/new', {
      method: 'GET',
      onComplete: this.showBandForm.bind(this)
    });
  },

  showBandForm: function(r) {
    this.core_box.update(r.responseText);
    new Effect.BlindDown(this.core_box, {duration: 0.3, queue: 'end'});

    this.member_name_box = this.element.down('#band_member_add');
    this.instrument_box = this.element.down('#band_instrument_select');
    this.avatar_box = this.element.down('#band_upload_avatar');

    this.add_button = this.element.down('#band_button_add');
    this.b_addMember = this.addMember.bind(this);
    this.add_button.observe('click', this.b_addMember);

    this.buttons = this.element.down('#band_form_buttons');
    this.ok_button = this.element.down('#band_button_ok');

    this.b_cancelAddMember = this.cancelAddMember.bind(this);
    this.cancel_button = this.element.down('#band_button_cancel');
    this.cancel_button.observe('click', this.b_cancelAddMember);

    this.instrument_select = this.element.down('select');
    this.member_name_input = this.element.down('.input_member_name');

    this.makeInstrumentsSelect();

    this.b_unloadBandForm = this.unloadBandForm.bind(this);
    this.edit_box.down('a').stopObserving('click', this.b_loadBandForm);
    this.edit_box.down('a').innerHTML = '[done]';
    this.edit_box.down('a').observe('click', this.b_unloadBandForm);

    this.element.select('a.edit').each(this.enableMemberEditLink.bind(this));

    this.spinner.hide();
    this.edit_box.show();
  },

  enableMemberEditLink: function(link) {
    var member_id = parseInt(link.up('.band_member').id.sub('^band_member_', ''));
    var member_name = link.up('.band_member').down('.band_member_name').innerHTML
    var instrument_id = parseInt(link.up('.band_member').down('.instrument').id.sub('^band_member_instrument_', ''));

    link.observe('click', this.editMember.bind(this, member_name, member_id, instrument_id));
  },

  makeInstrumentsSelect: function() {

    if (this.instrument_list == null) { // build it once
      instrument_list = new Element('div', {id: 'instrument_list', style: 'display:none;'});
    
      this.instrument_select.select('optgroup').each(function(group) {
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
    }

    this.instrument_select.up().insert({bottom: this.instrument_layer});
    this.instrument_select.up().insert({bottom: this.instrument_list});

    this.instrument_layer.observe('click', this.showInstrumentsSelect.bind(this));
    this.instrument_list.select('a').each(this.instrumentClick.bind(this));
  },

  instrumentClick: function(link) {
    link.observe('click', this.instrumentSelected.bind(this, link.getAttribute('rel')));
  },

  showInstrumentsSelect: function(event) {
    event.stop();
    Effect.toggle(this.instrument_list, 'blind', {duration: 0.3});
  },

  instrumentSelected: function(value, event) {
    event.stop();
    new Effect.BlindUp(this.instrument_list, {duration: 0.3});
    this.instrument_select.value = value;
  },

  unloadBandForm: function(event) {
    event.stop();

    this.edit_box.hide();
    this.spinner.show();

    new Effect.BlindUp(this.core_box, {duration: 0.3, queue: 'end'});
    new Ajax.Request('/users/' + this.user_id + '/members', {
      method: 'GET',
      onComplete: this.showBandMembers.bind(this)
    });
  },

  showBandMembers: function(r) {
    this.core_box.update(r.responseText);

    this.edit_box.down('a').stopObserving('click', this.b_unloadBandForm);
    this.edit_box.down('a').innerHTML = '[edit]';
    this.edit_box.down('a').observe('click', this.b_loadBandForm);

    this.spinner.hide();
    this.edit_box.show();

    new Effect.BlindDown(this.core_box, {duration: 0.3, queue: 'end'});

    this.cancel_button.stopObserving('click', this.b_cancelAddMember);
    this.add_button.stopObserving('click', this.b_addMember);

    this.b_addMember = null;
    this.add_button = this.ok_button = this.cancel_button = null;
    this.member_name_box = this.instrument_box = this.avatar_box = null;
  },

  addMember: function(event) {
    this.add_button.hide();
    this.buttons.show();

    new Effect.BlindDown(this.member_name_box, {duration: 0.3});
    new Effect.BlindDown(this.instrument_box, {duration: 0.3});
    //new Effect.BlindDown(this.avatar_box, {duration: 0.3});
  },

  cancelAddMember: function(event) {
    this.buttons.hide();
    this.add_button.show();

    this.member_name_input.value = '';
    this.instrument_select.value = '';

    new Effect.BlindUp(this.member_name_box, {duration: 0.3});
    new Effect.BlindUp(this.instrument_box, {duration: 0.3});
    //new Effect.BlindUp(this.avatar_box, {duration: 0.3});
  },

  editMember: function(member_name, member_id, instrument_id, event) {
    event.stop();

    this.add_button.hide();
    this.buttons.show();

    this.member_name_input.value = member_name;
    this.instrument_select.value = instrument_id;

    new Effect.BlindDown(this.member_name_box, {duration: 0.3});
    new Effect.BlindDown(this.instrument_box, {duration: 0.3});
  },

  destroy: function(user_id, member_id) {
    if(!confirm('Are you sure?')) return;
    new Ajax.Request('/users/' + user_id + '/members/' + member_id + '.js', {
      method: 'DELETE',
      parameters: {
        authenticity_token: encodeURIComponent($('authenticity-token').value)
      }
    });
  },  

  remove: function(id) {
    Effect.Fade('band_member_' + id);
  }
});

document.observe('dom:loaded', function() {
  BandMembers.instance = new BandMembers('band-members-box', $('user-id').value);
});
