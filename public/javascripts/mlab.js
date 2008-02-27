var MlabSong = Class.create({

  initialize: function(element, slider) {
    this.element  = $(element);
    this.slider   = slider;              
    this.tracks = new Array();
    this.setup();
  },
  
  setup: function() {
    this.element.down('a.button.mlab.add_track').observe('click', this.onAddSong.bind(this));
    this.element.select('div.tracks div.mlab_song_track').each(function(element) {
      this.tracks.push(new MlabTrack(element, this.slider));
    }.bind(this));
  },
  
  onAddSong: function(event) {
    event.stop();
    this.tracks.each(function(track) {
      this.slider.addTrack(track);
    }.bind(this));
    this.slider.slideToStart();
  }
  
});

var MlabTrack = Class.create({

  initialize: function(element, slider) {
    this.element  = $(element);
    this.slider   = slider;
    this.setup();
  },
  
  setup: function() {    
    this.title        = this.element.down('ul.info li.title').innerHTML;
    this.author_login = this.element.down('ul.info li.author_login').innerHTML;    
  },
    
  initTrackButton: function() {
    this.element.up().up().down('a.button.mlab.add_track').observe('click', this.onAddTrack.bind(this));
  },
  
  onAddTrack: function(event) {
    event.stop();
    this.slider.addTrack(this);
    this.slider.slideToStart();
  }
  
});

var MlabSlider = Class.create(PictureSlider, {  
  
  tracks: new Array(),
  
  template: '<div class="elements #{even_odd} %> clear-block" style="height: 50px">' +
  	        '  <div class="float-left">' +
            '    <p class="name"><a href="#">#{author_login}</a></p>' +
            '    <p class="abstract">#{title}</p>' +
          	'  </div>' +
          	'  <div class="float-left align-right">' +
          	'	  <p class="button">' +
          	'	    <a href="#"><img src="/images/button_play_green.png" alt="" width="23" height="15" /></a>' +
          	'	  </p>' +
          	'  </div>' +
            '</div>',

  
  initialize: function($super, element, options) {
    $super(element, options);
    this.windowSize = this.options.windowSize;
    this.setupMlab();
  },
  
  setupMlab: function() {
    this.container = this.element.down('div.container');
    $$('div.mlab_track').each(function(element) {
      new MlabTrack(element, this).initTrackButton();
    }.bind(this));
    $$('div.mlab_song').each(function(element) {
      new MlabSong(element, this);
    }.bind(this));
  },
  
  addTrack: function(track) {
    track.even_odd = ['even', 'odd'][this.tracks.length % 2];
    var tpl = new Template(this.template);
    var content = tpl.evaluate(track);
    this.scrolling_div.insert({
      top: content
    });
    this.tracks.push(track);    
    this.update();    
  },
  
  update: function() {
    this.updateContainer();
    this.updateScrollingDiv();
  },
  
  updateContainer: function() {    
    if(this.tracks.length <= this.windowSize) {
      this.container.setStyle({
        height: (this.tracks.length * 60) + 'px'
      });
    }
  },
  
  updateScrollingDiv: function() {
    this.scrolling_div.setStyle({
      height: (this.tracks.length * 60) + 'px'
    });
  }    
  
});