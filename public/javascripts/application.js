Event.observe(window, 'load', function(event) {

	// Login Behavior
	if ( $('log-in') != null ) {
		$('log-in').down('input', 1).focus()
	} else {
		$('search').down('input').focus()
	}
	
	if ( $('log-in-errors') != null && $('log-in-errors').visible() ) {
		$('log-in').down('input', 2).clear().focus()
	}
	
});