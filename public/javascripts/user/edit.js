var InPlaceEditorGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.editors = $A();
    this.options = options;
    this.current_user_id = $('current-user-id').value;
    this.model_id = $(options.model + '-id').value;
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      this.editors.push(new Ajax.InPlaceEditor(this.options.model + '_' + name, this.options.url + this.model_id, {
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
      }));
    }.bind(this));
  },

  destroy: function() {
    this.editors.each(function(editor) {
      editor.destroy();
      editor.element = null;
      editor.options.externalControl = null;
      editor._controls = null;
      editor._form = null;
    });
    this.editors.clear();
    this.editors = null;
  }
});

var InPlaceSelectGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.editors = $A();
    this.options = options;
    this.model_id = $(options.model + '-id').value;
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      this.editors.push(new Ajax.InPlaceSelect(this.options.model + '_' + name, this.options.url + this.model_id, {
        lazyLoading: true,
        values_url: this.options.values_url,
        externalControl: 'edit_button_' + this.options.model + '_' + name,
        externalControlOnly: true,
        ajaxOptions: { method: 'PUT' },
        paramName: this.options.model + '[' + name + ']',
        onComplete: Prototype.emptyFunction,
        highlightcolor: '#ffffff',
        highlightendcolor: '#ffffff'
      }));
    }.bind(this));
  },

  destroy: function() {
    this.editors.each(function(editor) {
      editor.destroy();
      editor.element = null;
      editor.options.externalControl = null;
    });
    this.editors.clear();
    this.editors = null;
  }
});

var AjaxFormGenerator = Class.create({
  
  initialize: function(forms, options) {
    this.forms = forms;
    this.options = Object.extend({
      hideOnLoad: 'hide-on-load'
    }, options);
    this.model_id = $(options.model + '-id').value;
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));
  },
  
  setup: function() {
    var self = this;
    this.forms.each(function(name) {
      var form = $('form_' + name);
      this.hideButton(form);
      form.compareValue = this.getCompareValue(form);
      this.observeFieldsChanges(form);
      form.submit = function(event) {
        if (event) event.stop();
        new Ajax.Request(self.options.url + self.model_id, {
          parameters: Form.serialize(this),
          onLoading: function() {                        
            if(self.options.hideOnLoad) {
              this.select('.' + self.options.hideOnLoad).invoke('hide');
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
      };
      form.observe('submit', form.submit);

    }.bind(this));
  },

  destroy: function() {
    this.forms.each(function(name) {
      var form = $('form_' + name);
      form.stopObserving('submit', form.submit);
      form.submit = null;
    });
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
    this.element = $(element);
    if (!this.element)
      return;

    this.genders = {male: 'M', female: 'F', other: 'O'};
    this.element.style.display = 'none';

    this.b_showGenders = this.showGenders.bind(this);
    this.trigger = $(this.element.id + '-trigger');
    this.trigger.observe('click', this.b_showGenders);

    this.b_setGender = this.setGender.bind(this);
    this.element.select('img').invoke('observe', 'click', this.b_setGender);

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function(element) {
    this.trigger.stopObserving('click', this.b_showGenders);
    this.trigger = null;

    this.element.select('img').invoke('stopObserving', 'click', this.b_setGender);
    this.element = null;
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
          top: new Element('img', { src: '/images/gender_ico_' + gender + '.gif' })
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
  initialize: function (element) {
    this.element = $(element);
    if (!this.element)
      return;

    this.b_onEdit = this.onEdit.bind(this);
    this.edit_link = this.element.down('.edit-link');
    this.edit_link.observe('click', this.b_onEdit);

    this.b_onCancel = this.onCancel.bind(this)
    this.cancel_link = this.element.down('.cancel-link');
    this.cancel_link.observe('click', this.b_onCancel);

    this.b_onCompleted = this.onCompleted.bind(this);
    this.done_link = this.element.down('.done-link');
    this.done_link.observe('click', this.b_onCompleted);

    this.blurb = $('profile-completeness-container');
    this.fields = $('my-user-share');

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function() {
    this.element = null;
    this.blurb = null;
    this.fields = null;

    this.edit_link.stopObserving('click', this.b_onEdit);
    this.edit_link = null;

    this.cancel_link.stopObserving('click', this.b_onCancel);
    this.cancel_link = null;

    this.done_link.stopObserving('click', this.b_onCompleted);
    this.done_link = null;
  },

  onEdit: function(event) {
    event.stop();

    this.edit_link.hide();
    this.cancel_link.show();
    this.blurb.fade({duration: 0.3, queue: 'end'});
    this.fields.blindDown({duration: 0.3, queue: 'end'});
    new Effect.ScrollTo('personal-details', {duration: 0.5, queue: 'end'});
  },

  onCancel: function(event) {
    event.stop();
    if (this.saving)
      return;

    this.cancel_link.hide();
    this.edit_link.show();
    this.fields.blindUp({duration: 0.3});
    this.blurb.appear({duration: 0.3, queue: 'end'});
  },

  onCompleted: function(event) {
    event.stop();
    if (this.saving)
      return;

    this.saving = true;
    this.cancel_link.innerHTML = 'reloading...';
    this.fields.fade({duration: 0.3, queue: 'end'});
    this.cancel_link.pulsate({duration: 1.0, pulses: 3, queue: 'end'});

    reload.delay(0.8);
  }
});


document.observe('dom:loaded', function() {
  if ($('user-id')) {
    new InPlaceEditorGenerator( $w('city'), { url: '/users/', model: 'user', maxLength: 20 } );  
    new InPlaceEditorGenerator( $w('motto tastes'), { url: '/users/', model: 'user', rows: 6, maxLength: 1000} );  
    new InPlaceSelectGenerator( $w('country'), { url: '/users/', model: 'user', values_url: '/countries.js' } );
    new AjaxFormGenerator( $w('first_name last_name photos_url blog_url myspace_url skype msn podcast_public'), { url: '/users/', model: 'user' } );
    new GenderSwitcher('change-gender');
    new Profile('personal-details');

  } else if ($('mband-id')) {
    new InPlaceEditorGenerator( $w('motto tastes'), { url: '/mbands/', model: 'mband', rows: 6, maxLength: 1000} );  
    new AjaxFormGenerator( $w('photos_url blog_url myspace_url'), { url: '/mbands/', model: 'mband' } );    
  } 
});
