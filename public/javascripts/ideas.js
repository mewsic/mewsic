document.observe('dom:loaded', function() {
  $w('newest coolest').each(function(name) {
    new Pagination({
      container: name + '-ideas',
      spinner: name + '_spinner',
      selector: 'a.navigation',
      dynamic_spinner: true
    });
  });
});
