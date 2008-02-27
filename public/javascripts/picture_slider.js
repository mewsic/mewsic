var PictureSlider = Class.create({	
  initialize: function(element) {
	  this.element = $(element);
		this.options = Object.extend({
		  axis: 'horizontal'
		}, arguments[1] || {});
		this.scrolling_div = this.element.down('.scroll')
		this.working = false;			
		this.setup();           		
	},

	setup: function() {
	  this.step             = this.options.size;
    this.back_trigger     = this.element.down('.trigger.back');
		this.forward_trigger  = this.element.down('.trigger.forward');		
		Event.observe(this.back_trigger,    'click', this.slideBack.bind(this));
		Event.observe(this.forward_trigger, 'click', this.slideForward.bind(this));		 
	},				

	slideBack: function(event) {
		if (this.getPosition() < 0) this.slide(this.step);
		Event.stop(event);
	},

	slideForward: function(event) {		  
	  var size = parseInt(this.scrolling_div.getStyle(this.options.axis == 'vertical' ? 'height' : 'width'));
		if (this.getPosition() + size > this.options.size) {
			this.slide(-this.step);
		}			
		Event.stop(event);
	},
	
	getPosition: function() {
	  return parseInt(this.scrolling_div.getStyle(this.options.axis == 'vertical' ? 'top' : 'left')) || 0;
	},
  
  slideToStart: function() {
    this.slide(-(this.getPosition()));
  },
  
	slide: function(pixel) {
		if(!this.working) {
			this.working = true;
			new Effect.Move(this.scrolling_div, {
				x: (this.options.axis == 'horizontal' ? pixel : 0),
				y: (this.options.axis == 'vertical'   ? pixel : 0),
				afterFinish: function(){ this.working = false; }.bind(this),
				duration: 0.5
			});
		}
	}
});