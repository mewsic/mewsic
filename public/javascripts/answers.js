document.observe('dom:loaded', function() {
  $w("open top newest").each(function(name) {
    new Pagination({
      container: name + '-answers-container',
      spinner: name + '-answers-spinner',
      selector: '.pagination.answers a'
    });
  });  
});
