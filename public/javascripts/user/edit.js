var InPlaceEditorGenerator = Class.create({
  
  initialize: function(fields, options) {
    this.fields = fields;
    this.options = options;
    this.user_id = $('user_id').value;
    this.setup();
  },
  
  setup: function() {  
    this.fields.each(function(name) {
      new Ajax.InPlaceEditor('field_' + name, this.options.url + this.user_id, {
        ajaxOptions: { 
          method: 'PUT'
        },
        paramName: this.options.model + '[' + name + ']'
      });
    }.bind(this));
  }  
});

var AjaxFieldGenerator = Class.create({
  
  initialize: function() {
    
  }
  
});

document.observe('dom:loaded', function() {
  var fields = $w('city country');
  var options = {
    url: '/users/',
    model: 'user'
  };  
  new InPlaceEditorGenerator(fields, options);
});
