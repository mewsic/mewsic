document.observe('dom:loaded', function() {
	new SimpleSlider('friends-scroller', {x: 210, y:0});
  new SimpleSlider('admirers-scroller',  {x: 210, y:0});

  $w('tracks songs').each(function(name) {
    if (!$(name))
      return;

    new Pagination({
      container: name,
      spinner: name + '_spinner',
      selector: 'a.navigation',
      dynamic_spinner: true,
      update_mlab: true,
      onComplete: function() { Lightview.updateViews(); }
    });
  });

});
