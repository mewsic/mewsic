var InPlaceEditorGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.options = options;
    this.user_id = $(this.options.model + '_id').value;
    this.setup();
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      new Ajax.InPlaceEditor(this.options.model + '_' + name, this.options.url + this.user_id, {
        externalControl: 'edit_button_' + this.options.model + '_' + name,
        ajaxOptions: { method: 'PUT' },
        paramName: this.options.model + '[' + name + ']'
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
    this.user_id = $('user_id').value;
    this.setup();
  },
  
  setup: function() {
    var self = this;
    this.forms.each(function(name) {
      $('form_' + name).observe('submit', function(event) {
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
          onSuccess: function() {
            $('loading_' + self.options.model + '_' + name).hide();
            if(self.options.hideOnLoad) {
              this.select('.' + self.options.hideOnLoad).each(function(e) {
                e.show();
              }.bind(this));
            }
          }.bind(this)
        });        
      });
    }.bind(this));
  }
  
});

function initGenderSwitcher() {
  var genders       = ['M', 'F', 'O'];
  var gender_names  = ['male', 'female', 'other'];
  $('user_gender').observe('click', function() {
    var index = (genders.indexOf(this.className) + 1) % 3;
    var new_gender = genders[index];
    this.src = '/images/gender_ico_' + new_gender + '.gif'
    this.className = new_gender;
    new Ajax.Request('/users/' + $('user_id').value, {
      method: 'PUT',
      parameters: 'user[gender]=' + gender_names[index]
    });
  });  
}

document.observe('dom:loaded', function() {
  new InPlaceEditorGenerator(
    $w('city country motto tastes'),
    {
      url: '/users/',
      model: 'user'
    }
  );
  
  new AjaxFormGenerator(
    $w('photos_url blog_url myspace_url skype msn'),
    {
      url: '/users/',
      model: 'user'
    }
  );  
  
  initGenderSwitcher();
    
});
