document.observe('dom:loaded', function() {
  $w('newest coolest').each(function(name) {
    if (!$(name + '-ideas'))
      return;

    new Pagination({
      container: name + '-ideas',
      spinner: name + '_spinner',
      selector: 'a.navigation',
      dynamic_spinner: true
    });
  });
});
