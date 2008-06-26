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

    this.core_box.blindUp({duration: 0.3, queue: 'end'});
    new Ajax.Request('/users/' + this.user_id + '/members/new', {
      method: 'GET',
      onComplete: this.showBandForm.bind(this)
    });
  },

  showBandForm: function(r) {
    this.core_box.update(r.responseText);
    this.core_box.blindDown({duration: 0.3, queue: 'end'});

    this.member_name_box = this.element.down('#band_member_add');
    this.instrument_box = this.element.down('#band_instrument_select');
    this.avatar_box = this.element.down('#band_upload_avatar');
    this.country_box = this.element.down('#band_country_container');

    this.add_button = this.element.down('#band_button_add');
    this.b_addMember = this.addMember.bind(this);
    this.add_button.observe('click', this.b_addMember);

    this.form = this.element.down('#band_member_form');
    this.alert = this.element.down('#band_alert');
    this.members = this.element.down('#band_members');

    this.avatar_form = this.element.down('#band_member_avatar-form');
    this.avatar_file_input = this.element.down('#avatar_uploaded_data');
    this.avatar_file_input.observe('change', this.uploadNewAvatar.bind(this));
    this.avatar_preview = this.element.down('#band_member_avatar_preview').down('img');

    this.buttons = this.element.down('#band_form_buttons');

    this.b_submitForm = this.submitForm.bind(this);
    this.ok_button = this.element.down('#band_button_ok');
    this.ok_button.observe('click', this.b_submitForm);

    this.b_cancelAddMember = this.cancelAddMember.bind(this);
    this.cancel_button = this.element.down('#band_button_cancel');
    this.cancel_button.observe('click', this.b_cancelAddMember);

    this.b_watchMemberName = this.watchMemberName.bind(this);
    this.member_name_input = this.element.down('.input_member_name');
    this.member_name_input.observe('keyup', this.b_watchMemberName);

    this.member_country = this.element.down('#band_member_country');

    this.instrument_select = new InstrumentsSelect(this.element.down('select'));

    this.b_unloadBandForm = this.unloadBandForm.bind(this);
    this.edit_box.down('a').stopObserving('click', this.b_loadBandForm);
    this.edit_box.down('a').innerHTML = '[done]';
    this.edit_box.down('a').observe('click', this.b_unloadBandForm);

    this.members.select('a').each(this.enableMemberLinks.bind(this));

    if (this.members.descendants().size() == 0) {
      this.addMember(null);
    }

    this.spinner.hide();
    this.edit_box.show();
  },

  enableMemberLinks: function(link) {
    var member_id = parseInt(link.up('.band_member').id.sub('^band_member_', ''));
    var member_name = link.up('.band_member').down('.band_member_name').innerHTML;
    var member_country = link.up('.band_member').down('.band_member_country').innerHTML;
    var instrument_id = parseInt(link.up('.band_member').down('.instrument').id.sub('^band_member_instrument_', ''));

    if (link.className == 'edit') {
      link.observe('click', this.editMember.bind(this, member_name, member_id, instrument_id, member_country));
    } else if (link.className == 'delete') {
      link.observe('click', this.deleteMember.bind(this, member_id));
    }
  },

  watchMemberName: function(event) {
    var value = event.element().value;

    if (value.blank() || value.match(/^\d+/)) { // this is a myousica ID
      //if (this.avatar_box.visible())
        this.avatar_box.hide();//fade({duration: 0.3});
        this.country_box.hide();
    } else {
      //if (!this.avatar_box.visible())
        this.avatar_box.show();//appear({duration: 0.3});
        this.country_box.show();
    }
  },

  destroyCurrentAvatar: function() {
    if (this.avatar_id) {
      // Destroy previous avatar
      new Ajax.Request('/avatars/' + this.avatar_id, {
        method: 'DELETE',
        asynchronous: true,
        evalScripts: false,
        parameters: {
          authenticity_token: encodeURIComponent($('authenticity-token').value)
        }
      });
    }
  },

  uploadNewAvatar: function() {
    this.edit_box.hide();
    this.spinner.show();
    this.avatar_form.submit();
    this.avatar_file_input.value = '';
  },

  uploadCompleted: function(id, path) {
    this.alert.hide();
    this.destroyCurrentAvatar();
    this.setAvatarID(id);
    this.avatar_preview.src = path;
    this.spinner.hide();
    this.edit_box.show();
  },

  setAvatarID: function(id) {
    this.avatar_id = id;
    this.form.down('#band_member_avatar_id').value = id;
  },

  uploadFailed: function() {
    this.alert.innerHTML = 'Upload failed, please try again';
    this.alert.show();
    this.spinner.hide();
    this.edit_box.show();
  },

  unloadBandForm: function(event) {
    event.stop();

    this.edit_box.hide();
    this.spinner.show();

    this.core_box.blindUp({duration: 0.3, queue: 'end'});
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

    this.core_box.blindDown({duration: 0.3, queue: 'end'});

    this.ok_button.stopObserving('click', this.b_submitForm);
    this.cancel_button.stopObserving('click', this.b_cancelAddMember);
    this.add_button.stopObserving('click', this.b_addMember);
    this.input_member_name.stopObserving('keypress', this.b_watchMemberName);

    this.b_addMember = null;
    this.add_button = this.ok_button = this.cancel_button = null;
    this.member_name_box = this.instrument_box = this.avatar_box = this.country_box = null;
  },

  addMember: function(event) {
    if (event)
      event.stop();

    this.add_button.hide();
    this.buttons.show();

    this.form.action = '/users/' + this.user_id + '/members';
    this.form._method = 'POST';
    this.form.callback = this.memberAdded.bind(this);

    this.member_name_box.show();//appear({duration: 0.3});
    this.instrument_box.show();//appear({duration: 0.3});
  },

  cancelAddMember: function(event) {
    event.stop();

    this.destroyCurrentAvatar();
    this.closeEditPane();
  },

  closeEditPane: function(event) {
    this.alert.hide();
    this.buttons.hide();
    this.add_button.show();

    this.member_name_input.value = '';
    this.instrument_select.setValue('');

    this.member_name_box.hide();//fade({duration: 0.3});
    this.instrument_box.hide();//fade({duration: 0.3});
    this.country_box.hide();
    //if (this.avatar_box.visible())
      this.avatar_box.hide();//fade({duration: 0.3});
    this.avatar_preview.src = '/images/default_avatars/avatar_icon.gif';
  },

  editMember: function(member_name, member_id, instrument_id, member_country, event) {
    event.stop();

    this.add_button.hide();
    this.buttons.show();

    this.form.action = '/users/' + this.user_id + '/members/' + member_id;
    this.form._method = 'PUT';
    this.form.callback = this.memberEdited.bind(this, member_id);

    this.member_name_input.value = member_name;
    this.member_country.value = member_country;
    this.instrument_select.setValue(instrument_id);

    //if (!this.member_name_box.visible() && !this.instrument_box.visible()) {
      this.member_name_box.show();//appear({duration: 0.3});
      this.instrument_box.show();//appear({duration: 0.3});
    //}

    // If this is not a myousica user...
    if (this.member_name_input.value.match(/^(\w[\w\s\d]*)$/)) {
      // ...and has got a current avatar...
      var current_avatar = this.members.down('#band_member_'+member_id+' img.avatar');

      // ..show it!
      this.avatar_preview.src = current_avatar.src;

      // and cache its id so if the user changes it it'll be destroyed
      if (!current_avatar.id.blank()) {
        this.avatar_id = current_avatar.id;
      }

      // finally make the avatar box appear, if it's not yet visible
      //if (!this.avatar_box.visible()) {
        this.avatar_box.show();//appear({duration: 0.3});
      //}

      this.country_box.show();
    } else {
      this.avatar_box.hide();
      this.country_box.hide();
    }
  },

  deleteMember: function(member_id, event) {
    event.stop();

    if(!confirm('Are you sure?'))
      return;

    new Ajax.Request('/users/' + this.user_id + '/members/' + member_id, {
      method: 'DELETE',
      asynchronous: true,
      evalScripts: false,
      parameters: {
        authenticity_token: encodeURIComponent($('authenticity-token').value)
      },
      onSuccess: this.memberDeleted.bind(this, member_id),
      onLoading: this.submitting.bind(this),
      onFailure: function() { alert("Error while deleting band member. Please refresh the page and try again"); }
    });
  },  

  submitForm: function(event) {
    event.stop();

    new Ajax.Request(this.form.action, {
      method: this.form._method,
      asynchronous: true,
      evalScripts: false,
      parameters: Form.serialize(this.form) + '&authenticity_token=' + encodeURIComponent($('authenticity-token').value),
      onSuccess: this.form.callback,
      onLoading: this.submitting.bind(this),
      onFailure: this.submitFailed.bind(this)
    });
  },

  submitting: function() {
    this.alert.hide();
    this.edit_box.hide();
    this.spinner.show();
  },

  memberAdded: function(request) {
    this.members.insert({bottom: request.responseText});
    this.members.select('.band_member').last().select('a').each(this.enableMemberLinks.bind(this));

    this.setAvatarID('');
    this.closeEditPane();
    this.updateMemberCount(1);
    this.spinner.hide();
    this.edit_box.show();
  },

  memberEdited: function(id, request) {
    var element = this.members.down('#band_member_' + id);
    element.replace(request.responseText);
    element = this.element.down('#band_member_' + id);
    element.highlight();
    element.select('a').each(this.enableMemberLinks.bind(this));

    this.setAvatarID(null);
    this.closeEditPane();
    this.spinner.hide();
    this.edit_box.show();
  },

  memberDeleted: function(id) {
    var element = this.members.down('#band_member_' + id);
    element.fade({afterFinish: element.remove});

    this.setAvatarID(null);
    this.updateMemberCount(-1);
    this.closeEditPane();
    this.spinner.hide();
    this.edit_box.show();
  },

  submitFailed: function(request) {
    this.edit_box.show();
    this.spinner.hide();
    this.alert.innerHTML = 'Please insert all fields!';
    this.alert.show();
  },

  updateMemberCount: function(delta) {
    var e = $('band_members_count');
    var count = parseInt(e.innerHTML) + delta;

    if (count == 1) { // poor man's pluralize() :)
      e.innerHTML = '1 member';
    } else {
      e.innerHTML = count + ' members';
    }

    e.highlight({startcolor: '#FFFFFF', endcolor: '#E1EAEE'}); // XXX infer bg color from element
  },

  __dummy__: function() {}
});

document.observe('dom:loaded', function() {
  BandMembers.instance = new BandMembers('band-members-box', $('user-id').value);
});
