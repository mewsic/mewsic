var PictureSlider = Class.create({	
		initialize: function(id) {				
			this.options = Object.extend({}, arguments[1] || {});				
			this.working = false;	 
			this.left_trigger = $(id).down('.trigger.left')
			this.right_trigger = $(id).down('.trigger.right')
			this.scrolling_div = $(id).down('.horizontal-scroll div')

			this.setup();
		},

		setup: function() {
			Event.observe(this.left_trigger, 'click', this.slideLeft.bind(this));
			Event.observe(this.right_trigger, 'click', this.slideRight.bind(this));
		},

		slideLeft: function(event) {
			this.slide(315);
			Event.stop(event);
		},

		slideRight: function(event) {
			this.slide(-315);
			Event.stop(event);
		},

		slide: function(pixel) {
			if(!this.working) {
				this.working = true;
				new Effect.Move(this.scrolling_div, {
					x: pixel,
					afterFinish: function(){ this.working = false; }.bind(this),
					duration: 0.5
				});
			}
		}
});
	
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
		new PictureSlider('most-friends-scroller');
	} 

});
