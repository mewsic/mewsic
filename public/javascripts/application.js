document.observe('dom:loaded', function(event) {

	// Login Behavior
	if ( $('log-in') != null ) {
		$('log-in').down('input', 1).focus();
	} else {
		$('search').down('input').focus();
	}

	if ( $('log-in-errors') != null && $('log-in-errors').visible() ) {
		$('log-in').down('input', 2).clear().focus();
	}
	
	if ( $('most-friends-scroller') != null ) {
		// new PictureSlider('most-friends-scroller',  { size: 225 });
	} 
	
	if ( $('most-mbands-scroller') != null ) {
		// new PictureSlider('most-mbands-scroller',  { size: 225 });
	}
	
	if ($('mlab-scroller') != null ) {
	  var mlab_slider = new MlabSlider('mlab-scroller',  {
      axis: 'vertical',
      windowSize: 5,
      size: 300,
      toggleTriggers: true
    });
    mlab_slider.loadCurrentTracks();
	}			
			
});

function popitup(url) {
	newwindow=window.open(url,'load_image', 'height=100, width=300');
	if (window.focus) {newwindow.focus()}
	return false;
}