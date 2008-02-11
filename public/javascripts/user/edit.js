var InPlaceEditorGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.options = options;
    this.user_id = $('user_id').value;
    this.setup();
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      new Ajax.InPlaceEditor(this.options.model + '_' + name, this.options.url + this.user_id, {
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
});
