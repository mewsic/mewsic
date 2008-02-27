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
    if(this.options.toggleTriggers) this.toggleTriggers();
	},
	
	toggleTriggers: function() {
    this.isBackSlidable()    ? this.back_trigger.setOpacity(1.0)     : this.back_trigger.setOpacity(0.2);
    this.isForwardSlidable() ? this.forward_trigger.setOpacity(1.0)  : this.forward_trigger.setOpacity(0.2);
	},

	slideBack: function(event) {
		if (this.isBackSlidable()) this.slide(this.step);
		Event.stop(event);
	},

	slideForward: function(event) {		  
	  var size = parseInt(this.scrolling_div.getStyle(this.options.axis == 'vertical' ? 'height' : 'width'));
		if (this.isForwardSlidable()) {
			this.slide(-this.step);
		}			
		Event.stop(event);
	},
	 
	isBackSlidable: function() {
	  return this.getPosition() < 0
	},
	
	isForwardSlidable: function() {
	  var size = parseInt(this.scrolling_div.getStyle(this.options.axis == 'vertical' ? 'height' : 'width'));
	  return (this.getPosition() + size > this.options.size)
	},
	
	getPosition: function() {
	  return parseInt(this.scrolling_div.getStyle(this.options.axis == 'vertical' ? 'top' : 'left')) || 0;
	},
  
  slideToStart: function() {
    var options = Object.extend({
      afterFinish: Prototype.emptyFunction()
    }, arguments[0] || {});
    this.slide(-(this.getPosition()), options);
  },
  
	slide: function(pixel, options) {
		if(!this.working) {
			this.working = true;
			new Effect.Move(this.scrolling_div, {
				x: (this.options.axis == 'horizontal' ? pixel : 0),
				y: (this.options.axis == 'vertical'   ? pixel : 0),
				afterFinish: function(){
				  this.working = false;
				  if(options && options.afterFinish) options.afterFinish();
				  if(this.options.toggleTriggers) this.toggleTriggers();
        }.bind(this),
				duration: 0.5
			});
		}
	}
});