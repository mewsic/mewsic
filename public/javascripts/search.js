document.observe('dom:loaded', function() {
  $w("user song track idea").each(function(name) {
    new Pagination({
      container: name + '-results',
      spinner: name + '-results-spinner',
      selector: 'div.pagination.' + name + ' a'
    });
  });  
});
