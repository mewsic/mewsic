document.observe('dom:loaded', function() {
	new SimpleSlider('friends-scroller', {x: 210, y:0});
  new SimpleSlider('admirers-scroller',  {x: 210, y:0});

	$('path').addClassName('mypage');

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
