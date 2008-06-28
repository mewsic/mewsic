document.observe('dom:loaded', function() {
  $w('tracks songs').each(function(name) {
    new Pagination({
      container: name,
      spinner: name + '_spinner',
      selector: 'span.nav-bottom a',
      dynamic_spinner: true,
      update_mlab: true
    });
  });
});
