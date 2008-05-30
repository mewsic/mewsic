var InPlaceEditorGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.options = options;
    this.current_user_id = $('current-user-id').value;
    this.model_id = $(options.model + '-id').value;
    this.setup();
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      new Ajax.InPlaceEditor(this.options.model + '_' + name, this.options.url + this.model_id, {
        externalControl: 'edit_button_' + this.options.model + '_' + name,
        externalControlOnly: true,
        ajaxOptions: { method: 'PUT' },
        paramName: this.options.model + '[' + name + ']',
        cols: this.options.cols || 0,
        rows: this.options.rows || 1,
        onFailure: function(editor, r) {
          alert(r.responseText);
        },
        onComplete: Prototype.emptyFunction,
        onEnterHover: Prototype.emptyFunction,
        onLeaveHover: Prototype.emptyFunction,
        onEditFieldCustomization: function(editor, fld) {
          if (this.options.maxLength && fld.tagName == 'INPUT')
            fld.maxLength = this.options.maxLength;
        }.bind(this),

        callback: function(form) {
          var input = form.getElements().first()
          if (input.value.length > this.options.maxLength) { 
            input.value = input.value.truncate(this.options.maxLength, '');
            alert ('too long...sorry! max ' + this.options.maxLength + ' chars');
          }
          return Form.serialize(form);
        }.bind(this)
      });
    }.bind(this));
  }
});

var InPlaceSelectGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.options = options;
    this.user_id = $('current-user-id').value;
    this.setup();
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      new Ajax.InPlaceSelect(this.options.model + '_' + name, this.options.url + this.user_id, {
        lazyLoading: true,
        values_url: this.options.values_url,
        externalControl: 'edit_button_' + this.options.model + '_' + name,
        externalControlOnly: true,
        ajaxOptions: { method: 'PUT' },
        paramName: this.options.model + '[' + name + ']',
        onComplete: Prototype.emptyFunction,
        highlightcolor: '#ffffff',
        highlightendcolor: '#ffffff'
      });
    }.bind(this));
  }  
});

var AjaxFormGenerator = Class.create({
  
  initialize: function(forms, options) {
    this.forms = forms;
    this.options = Object.extend({
      hideOnLoad: 'hide-on-load'
    }, options);
    this.user_id = $('current-user-id').value;
    this.setup();
  },
  
  setup: function() {
    var self = this;
    this.forms.each(function(name) {
    var form = $('form_' + name);
    this.hideButton(form);
    form.compareValue = this.getCompareValue(form);
    this.observeFieldsChanges(form);
      form.observe('submit', function(event) {
        event.stop();
        new Ajax.Request(self.options.url + self.user_id, {
          parameters: Form.serialize(this),
          onLoading: function() {                        
            if(self.options.hideOnLoad) {
              this.select('.' + self.options.hideOnLoad).each(function(e) {
                e.hide();
              }.bind(this));
            }
            $('loading_' + self.options.model + '_' + name).show();
          }.bind(this),
          onSuccess: function(r) {
            $('loading_' + self.options.model + '_' + name).hide();

            if(self.options.hideOnLoad) {
              this.select('.' + self.options.hideOnLoad).each(function(e) {
                if($w('user_photos_url user_blog_url user_myspace_url').include(e.id))
                {
                    e.value = r.responseText;
                }
                e.show();
              }.bind(this));
            }
      form.select('input[type="submit"]').invoke('hide');
      form.compareValue = form.select('input.ready-for-edit').invoke('getValue').join(',');
          }.bind(this),
          onFailure: function(r) {
            $('loading_' + self.options.model + '_' + name).hide();
            this.select('.' + self.options.hideOnLoad).each(function(e) {
              e.show();
            });
            alert(r.responseText);
          }.bind(this)
        });        
      });
    }.bind(this));
  },
  
  hideButton: function(form) {
    form.select('input[type="submit"]').invoke('hide');
  },
  
  getCompareValue: function(form) {
    return form.select('input.ready-for-edit').invoke('getValue').join(',');
  },
  
  observeFieldsChanges: function(form){
    fields = form.select('input.ready-for-edit');
    fields.each(function(field){
      new Field.Observer(field, 0.2, function(){
        parentForm = field.up('form');
        //compare = getCompareValue(parentForm);
        if (parentForm.compareValue != this.getCompareValue(parentForm)) {
          parentForm.select('input[type="submit"]').invoke('show');
        }
        else {
          parentForm.select('input[type="submit"]').invoke('hide');
        }
      }.bind(this));
    }.bind(this));
  }
  
});

var GenderSwitcher = Class.create({
  initialize: function(element) {
    this.genders = {male: 'M', female: 'F', other: 'O'};

    this.element = $(element);
    if (!this.element)
      return;

    this.element.style.display = 'none';

    this.trigger = $((element.id||element) + '-trigger');
    this.trigger.observe('click', this.showGenders.bind(this));
    this.element.select('img').invoke('observe', 'click', this.setGender.bind(this));
  },

  showGenders: function(event) {
    event.stop();
    this.trigger.hide();
    new Effect.Appear(this.element, {duration: 0.3});
  },

  setGender: function(event) {
    event.stop();
    var element = event.element();
    var gender = element.getAttribute('alt');
    if (!this.genders[gender])
      return;

    new Ajax.Request('/users/' + $('user-id').value, {
      method: 'PUT',
      parameters: 'user[gender]=' + gender,
      onComplete: this.onSetGenderSuccess.bind(this),
      onFailure: this.onSetGenderFailure.bind(this)
    });
  },

  onSetGenderSuccess: function(response) {
    var gender = response.responseText;
    if (!this.genders[gender]) {
      onSetGenderFailure();
      return;
    }

    new Effect.Fade(this.element, {
      duration: 0.4,
      afterFinish: function(gender) {
        this.trigger.up().insert({
          top: new Element('img', { src: '/images/gender_ico_' + gender + '.png' })
        });
        this.trigger.remove();
        this.element.remove();
      }.bind(this, this.genders[gender])
    });
  },

  onSetGenderFailure: function() {
    alert('error. please try again'); // should not happen, lazy solution for now.
  }
});

var Profile = Class.create({
  initialize: function () {
    this.link = $('my-user-share-more-link');
    if (!this.link)
      return;

    this.blurb = $('my-user-share-fill-in');
    this.fields = $('my-user-share');

    this.setup();
  },

  setup: function () {
    this.link.observe('click', this.handleClick.bind(this));
  },

  handleClick: function(event) {
    event.stop();

    if (!this.editing)
      this.showEditPane();
    else
      this.saveChanges();
  },

  showEditPane: function() {
    this.editing = true;
    this.link.innerHTML = 'done';
    new Effect.BlindUp(this.blurb, {duration: 0.3});
    new Effect.BlindDown(this.fields, {duration: 0.3, queue: 'end'});
  },

  saveChanges: function() {
    if (this.saving)
      return;

    if (!confirm('Done editing?'))
      return;

    this.saving = true;
    this.link.innerHTML = 'reloading...';
    new Effect.BlindUp(this.fields, {duration: 0.3});

    var fn = function() { window.location.href = window.location.href; }
    fn.delay(0.4);
  }
});

var BandMembers = {
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
}

document.observe('dom:loaded', function() {
  var user_id_field   = $('user-id');
  var mband_id_field  = $('mband-id');
  if(user_id_field) {
    new InPlaceEditorGenerator( $w('city'), { url: '/users/', model: 'user', maxLength: 20 } );  
    new InPlaceEditorGenerator( $w('motto tastes'), { url: '/users/', model: 'user', rows: 6, maxLength: 1000} );  

    new InPlaceSelectGenerator( $w('country'), { url: '/users/', model: 'user', values_url: '/countries' } );

    new AjaxFormGenerator( $w('first_name last_name photos_url blog_url myspace_url skype msn'), { url: '/users/', model: 'user' } );

    new GenderSwitcher('change-gender');

    new Profile();

  } else if(mband_id_field) {
    new InPlaceEditorGenerator( $w('motto tastes'), { url: '/mbands/', model: 'mband', rows: 6, maxLength: 1000} );  
    //new AjaxFormGenerator( $w('photos_url blog_url myspace_url'), { url: '/mbands/', model: 'mband' } );    
  } 
});
