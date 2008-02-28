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
    this.slider.slideToStart({
      afterFinish: function() {
        this.tracks.each(function(track) {
          // Effect.Appear('mlab_element_' + track.id, { duration: 0.2 });
        });
      }.bind(this)
    });
  }
  
});

var MlabTrack = Class.create({

  initialize: function(element, slider) {
    this.element  = $(element);
    this.slider   = slider;
    this.setup();
  },
  
  setup: function() {    
    this.id           = this.element.down('ul.info li.id').innerHTML;
    this.title        = this.element.down('ul.info li.title').innerHTML;
    this.author_id    = this.element.down('ul.info li.author_id').innerHTML;    
    this.author_login = this.element.down('ul.info li.author_login').innerHTML;    
  },
    
  initTrackButton: function() {
    this.element.up().up().down('a.button.mlab.add_track').observe('click', this.onAddTrack.bind(this));
  },
  
  onAddTrack: function(event) {
    event.stop();
    this.slider.addTrack(this);
    this.slider.slideToStart({
      afterFinish: function() {
        // new Effect.Appear('mlab_element_' + this.id, { duration: 0.2 });
      }.bind(this)
    });
  }
  
});

var MlabSlider = Class.create(PictureSlider, {      
  
  template: '<div id="mlab_element_#{id}" class="elements #{even_odd} clear-block" style="height: 50px;">' +
  	        '  <div class="float-left">' +
            '    <p class="name"><a href="/users/#{author_id}">#{author_login}</a></p>' +
            '    <p class="abstract">#{title}</p>' +
          	'  </div>' +
          	'  <div class="float-left align-right">' +
          	'	  <p class="button">' +
          	'	    <a href="#"><img src="/images/button_play_green.png" alt="" width="23" height="15" /></a>' +
          	'	    <a href="#" onclick="MlabSlider.removeTrack(#{id}); return false;">remove</a>' +
          	'	  </p>' +
          	'  </div>' +
            '</div>',

  
  initialize: function($super, element, options) {
    $super(element, options);    
    MlabSlider.instances.set(this.element.id, this);
    this.windowSize = this.options.windowSize;
    this.setupMlab();
  },    
  
  setupMlab: function() {
    this.container = this.element.down('div.container');    
    this.initTracks();
    this.initSongs();
  },
  
  initTracks: function() {
    $$('div.mlab_track').each(function(element) {
      new MlabTrack(element, this).initTrackButton();
    }.bind(this));
  },
  
  initSongs: function() {
    $$('div.mlab_song').each(function(element) {
      new MlabSong(element, this);
    }.bind(this));
  },    
  
  update: function($super) {
    this.updateContainer();
    this.updateScrollingDiv();
    this.toggleTriggers();
  },
  
  updateContainer: function() {    
    if(MlabSlider.tracks.keys().length <= this.windowSize) {
      this.container.setStyle({
        height: (MlabSlider.tracks.keys().length * 60) + 'px'
      });
    }
  },
  
  updateScrollingDiv: function() {
    this.scrolling_div.setStyle({
      height: (MlabSlider.tracks.keys().length * 60) + 'px'
    });
  },
  
  addTrack: function(track) {
    if(MlabSlider.tracks.get(track.id)) return;    
    var first_element = this.scrolling_div.down();
    var _class = (first_element && first_element.hasClassName('even')) ? 'odd' : 'even';    
    track.even_odd = _class;
    var tpl = new Template(this.template);
    var content = tpl.evaluate(track);
    this.scrolling_div.insert({
      top: content
    });
    MlabSlider.tracks.set(track.id, track);
    this.addTrackToCookie(track.id);
    this.update();
  },
  
  removeTrack: function(id) {
    var track = MlabSlider.tracks.get(id);
    if(track) {
      var element = $('mlab_element_' + id);
      element.nextSiblings().each(function(sibling) {
        var class_to_remove = sibling.hasClassName('even') ? 'even' : 'odd';
        var class_to_add    = (class_to_remove == 'even') ? 'odd' : 'even';
        sibling.removeClassName(class_to_remove);
        sibling.addClassName(class_to_add);
      });
      $('mlab_element_' + id).remove();
      MlabSlider.tracks.unset(id);
      this.removeTrackFromCookie(track.id);
      this.update();
    }
  },
  
  readCookie: function() {
    var matches = document.cookie.match(/mlab_tracks=([^;]+)/);
    var values  = matches ? matches[1].split('|') : new Array();
		return values;
  },

	addTrackToCookie: function(track_id) {
	  var track_ids = this.readCookie();
	  track_ids.push(track_id);
    this.setCookie(track_ids);
	},
	
	removeTrackFromCookie: function(track_id) {
	  var track_ids = this.readCookie();
	  var index = track_ids.indexOf(track_id);
	  if(index > -1) {	    
      track_ids.splice(index, 1);
	    this.setCookie(track_ids);
	  }    
	},
	
	loadCurrentTracks: function() {
    this.scrolling_div.select('div.elements').each(function(element) {
      var m = element.id.match(/^mlab_element_([0-9]+)/);
      var id = m[1];
      MlabSlider.tracks.set(id, {
        id:     id,
        slider: this
      });
    }.bind(this));
	},
	
	setCookie: function(track_ids) {
	  document.cookie = "mlab_tracks=" + track_ids.join('|') + "; path=/";
	}
  
});


MlabSlider.tracks = $H();
MlabSlider.instances = $H();

MlabSlider.getInstance = function(element) {
  return MlabSlider.instances.get(element);
}

MlabSlider.removeTrack = function(id) {
  var track = MlabSlider.tracks.get(id);
  if(track) {
    track.slider.removeTrack(id);
  }
}