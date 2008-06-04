document.observe('dom:loaded', function() {
  $w("top newest").each(function(name) {
    new Pagination({
      container: name + '-answers-container',
      spinner: name + '-answers-spinner',
      selector: 'div.pagination.' + name + ' a'
    });
  });  
});