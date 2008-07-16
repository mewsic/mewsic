document.observe('dom:loaded', function() {
  $w('tracks songs').each(function(name) {
    new Pagination({
      container: name,
      spinner: name + '_spinner',
      selector: 'a.navigation',
      dynamic_spinner: true,
      update_mlab: true
    });
  });
});
