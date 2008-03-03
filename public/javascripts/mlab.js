var MlabItem = Class.create({

  initialize: function(type, attributes, slider) {
    this.type = type;
    this.attributes = attributes; 
    this.slider = slider;
    this.slider.addItem(this);
  }    
  
});

var MlabSlider = Class.create(PictureSlider, {      
  
  template: '<div id="mlab_element_#{attributes.mlab_id}" class="elements #{even_odd} clear-block" style="height: 50px;">' +
  	        '  <div class="float-left">' +
            '    <p class="name">#{type} by <a href="/users/#{attributes.author.id}">#{attributes.author.login}</a></p>' +
            '    <p class="abstract">#{attributes.title}</p>' +
          	'  </div>' +
          	'  <div class="float-left align-right">' +
          	'	  <p class="button">' +
          	'	    <a href="#"><img src="/images/button_play_green.png" alt="" width="23" height="15" /></a>' +
          	'	    <a href="#" class="button mlab remove" onclick="MlabSlider.destroyItem(\'#{type}\', #{attributes.id}); return false;"><img src="/images/button_mlab.png" /></a>' +
          	'	  </p>' +
          	'  </div>' +
            '</div>',  
  
  initialize: function($super, element, options) {
    $super(element, options);    
    MlabSlider.instance = this;
    this.windowSize = this.options.windowSize;
    this.user_id = this.element.down('div.user-id').id;
    this.loadElements();    
    this.initTrackButtons();
    this.initSongButtons();
    this.setupMlab();
  },    
  
  loadElements: function() {
    new Ajax.Request('/users/' + this.user_id + '/mlabs.js', {
      method: 'GET',
      onComplete: this.parseLoadedItems.bind(this)
    });
  },
  
  parseLoadedItems: function(response) {
    var elements = response.responseText.evalJSON();
    elements.each(function(attributes) {          
      var type = attributes.song_id ? 'track' : 'song';
      var item = new MlabItem(type, attributes, this);      
    }.bind(this))
  },
  
  setupMlab: function() {
    this.container = this.element.down('div.container');
  },    
  
  update: function($super) {     
    this.updateContainer();
    this.updateScrollingDiv();
    this.toggleTriggers();
  },
  
  updateContainer: function() {    
    if(MlabSlider.items.keys().length <= this.windowSize) {
      this.container.setStyle({
        height: (MlabSlider.items.keys().length * 60) + 'px'
      });
    }
  },
  
  updateScrollingDiv: function() {
    this.scrolling_div.setStyle({
      height: (MlabSlider.items.keys().length * 60) + 'px'
    });
  },
  
  addItem: function(item) {    
    var first_element = this.scrolling_div.down();
    var _class = (first_element && first_element.hasClassName('even')) ? 'odd' : 'even';    
    item.even_odd = _class;    
    var tpl = new Template(this.template);
    var content = tpl.evaluate(item);    
    this.scrolling_div.insert({
      top: content
    });
    MlabSlider.items.set(item.type + '_' + item.attributes.id, item);    
    this.update();
  },

  removeItem: function(type, id) {
    var item = MlabSlider.items.get(type + '_' + id);
    if(item) {
      var element = $('mlab_element_' + item.attributes.mlab_id);      
      element.nextSiblings().each(function(sibling) {
        var class_to_remove = sibling.hasClassName('even') ? 'even' : 'odd';
        var class_to_add    = (class_to_remove == 'even') ? 'odd' : 'even';
        sibling.removeClassName(class_to_remove);
        sibling.addClassName(class_to_add);
      });      
      new Effect.Puff(element, {duration: 0.5});
      MlabSlider.items.unset(type + '_' + id);
      this.update();
    }
  },
  
  destroyItem: function(item) { 
    var element = $('mlab_element_' + item.attributes.mlab_id);
    var img = element.down('a.button.mlab.remove img');    
    new Ajax.Request('/users/' + this.user_id + '/mlabs/' + item.attributes.mlab_id + '.js', {
      method: 'DELETE',
      onLoading: function() {
        img.src = "/images/spinner.gif";
      }
    });
  },
  
  initTrackButtons: function() {
    $$('a.button.mlab.track.add').invoke('observe', 'click', this.onAddTrack.bind(this));
  },    
  
  initSongButtons: function() {
    $$('a.button.mlab.song.add').invoke('observe', 'click', this.onAddSong.bind(this));
  },
  
  onAddTrack: function(event) {
    event.stop(); 
    var element = event.element();
    var track_id = element.id;
    if(MlabSlider.items.get('track_' + track_id)) return;
    element.src = "/images/spinner.gif";    
    new Ajax.Request('/users/' + this.user_id + '/mlabs.js', {
      method: 'POST',
      evalJS: true,
      parameters: {
        type: 'track',
        track_id: track_id
      },
      onComplete: function() {
        element.src = '/images/button_mlab.png';
      }
    });
  },
  
  onAddSong: function(event) {
    event.stop();
    var element = event.element();
    var song_id = element.id;
    if(MlabSlider.items.get('song_' + song_id)) return;
    element.src = "/images/spinner.gif";    
    new Ajax.Request('/users/' + this.user_id + '/mlabs.js', {
      method: 'POST',
      evalJS: true,
      parameters: {
        type: 'song',
        song_id: song_id
      },
      onComplete: function() {
        element.src = '/images/button_mlab.png';
      }
    });
  }  
  
});


MlabSlider.items    = $H();
MlabSlider.instance = null;

MlabSlider.getInstance = function(element) {
  return MlabSlider.instance;
}

MlabSlider.destroyItem = function(type, id) {
  var item = MlabSlider.items.get(type + '_' + id);
  if(item) {
    item.slider.destroyItem(item);
  }
}

MlabSlider.removeItem = function(type, id) {  
  var item = MlabSlider.items.get(type + '_' + id);
  if(item) {
    item.slider.removeItem(type, id);
  }
}