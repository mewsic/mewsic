document.observe('dom:loaded', function() {
	new SimpleSlider('friends-scroller', {x: 210, y:0});
  new SimpleSlider('admirers-scroller',  {x: 210, y:0});

	$('path').addClassName('mypage');

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
