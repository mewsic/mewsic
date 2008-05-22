var Pagination = Class.create({ 

  initialize: function() {
    this.options = Object.extend({
      container: 'container',
      selector: 'div.pagination a',
    }, arguments[0] || {});
    this.initLinks();
  },  

  initLinks: function() {
    $(this.options.container).select(this.options.selector).invoke('observe', 'click', this.linkHandler.bind(this));
  },  

  linkHandler: function(event) {
    event.stop(); 
    new Ajax.Updater(this.options.container, event.element().getAttribute('href'), {
      method: 'get',
      onLoading: function(event){ if(this.options.spinner) $(this.options.spinner).show(); }.bind(this),
      onComplete: this.initLinks.bind(this)
    });
  }

});

document.observe('dom:loaded', function() {
  $w("user song track").each(function(name) {
    new Pagination({
      container: name + '-results',
      spinner: name + '-results-spinner',
      selector: 'div.pagination.' + name + ' a'
    });
  });
  
});