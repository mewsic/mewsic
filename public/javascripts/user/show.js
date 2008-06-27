document.observe('dom:loaded', function() {
  new PictureSlider('friends-scroller',  { size: 225 });
  new PictureSlider('admirers-scroller',  { size: 225 });  
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
