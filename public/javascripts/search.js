document.observe('dom:loaded', function() {
  $w("user song track idea").each(function(name) {
    if (!$(name + '-results'))
      return;

    new Pagination({
      container: name + '-results',
      spinner: name + '-results-spinner',
      selector: 'div.pagination.' + name + ' a'
    });
  });  
});
