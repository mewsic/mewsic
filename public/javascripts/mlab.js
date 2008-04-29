var MlabItem = Class.create({

  initialize: function(type, attributes, slider) {   
    this.type = type;    
    this.attributes = attributes; 
    this.attributes.mlab_id = this.extractMlabId();
    this.slider = slider;
    this.slider.addItem(this);
  },
  
  extractMlabId: function() {
    if(this.attributes.mlabs) {
      return this.attributes.mlabs[0].id;
    } else {
      return this.attributes.mlab.id;
    }
  }
  
});

var MlabSlider = Class.create(PictureSlider, {      
  
  template: '<div id="mlab_element_#{attributes.mlab_id}" class="elements #{even_odd} clear-block" style="height: 50px;">' +
  	        '  <div class="float-left">' +
            '    <p class="name">#{type} by <a href="/users/#{attributes.user.id}">#{attributes.user.login}</a></p>' +
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
    this.scroll_clip = this.element.down('div#scroll-clip');
    MlabSlider.instance = this;
    this.windowSize = this.options.windowSize;
    this.user_id = this.element.down('div.user-id').id;
    this.authenticity_token = this.element.down('div.auth-token').id;
    this.loadElements();    
    this.initTrackButtons();
    this.initSongButtons(); 
    this.loadingItems = new Array();
    this.setupMlab();
  }, 
  
  toggleTriggers: function() {
    this.isBackSlidable()    ? this.back_trigger.down('img').setOpacity(1.0)     : this.back_trigger.down('img').setOpacity(0.2);
    this.isForwardSlidable() ? this.forward_trigger.down('img').setOpacity(1.0)  : this.forward_trigger.down('img').setOpacity(0.2);
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
    this.updateScrollingDiv();
    this.updateScrollClip();
    this.toggleTriggers();
  },    
  
  updateScrollingDiv: function() {
    this.scrolling_div.setStyle({
      height: (MlabSlider.items.keys().length * 60) + 'px'
    });
  },
  
  updateScrollClip: function() {
    if(MlabSlider.items.keys().length <= this.windowSize) {
      this.scroll_clip.setStyle({
        height: (MlabSlider.items.keys().length * 60) + 'px'
      });
    }
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
    var item_key = item.type + '_' + item.attributes.id;
    if(this.loadingItems.include(item_key)) this.loadingItems.splice(this.loadingItems.indexOf(item_key), 1);
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
      new Effect.Puff(element, {
        duration: 0.5,
        afterFinish: function() {
          element.remove();
        }
      });
      MlabSlider.items.unset(type + '_' + id);
      this.update();
    }
  },
  
  destroyItem: function(item) { 
    var element = $('mlab_element_' + item.attributes.mlab_id);
    var img = element.down('a.button.mlab.remove img');    
    new Ajax.Request('/users/' + this.user_id + '/mlabs/' + item.attributes.mlab_id + '.js', {
      method: 'DELETE',
      parameters: {
        authenticity_token: encodeURIComponent(this.authenticity_token)
      },
      onLoading: function() {
        img.src = "/images/spinner.gif";
      }
    });
  },
  
  initTrackButtons: function(only_dynamic) {
    var selector = 'a.button.mlab.track.add';
    if(only_dynamic) selector += '.dynamic';
    $$(selector).each(function(link) {
      link.observe('click', this.onAddTrack.bindAsEventListener(this, link));
    }.bind(this));
  },    
  
  initSongButtons: function(only_dynamic) {
    var selector = 'a.button.mlab.song.add';
    if(only_dynamic) selector += '.dynamic';
    $$(selector).each(function(link) {
      link.observe('click', this.onAddSong.bindAsEventListener(this, link));
    }.bind(this));
  },
  
  onAddTrack: function(event, link) {    
    this.handleItemAddition(event, link, 'track');
  },
  
  onAddSong: function(event, link) {    
    this.handleItemAddition(event, link, 'song');
  },
  
  handleItemAddition: function(event, link, itemType) {    
    event.stop(); 
    var image = link.down('img');
    var item_id = image.id.match(/^(\d+)_/)[1];
    var item_key = itemType + '_' + item_id;    
    if(MlabSlider.items.get(item_key)) return;
    if(this.loadingItems.include(item_key)) return;
    this.loadingItems.push(item_key);
    image.src = "/images/spinner.gif";    
    new Ajax.Request('/users/' + this.user_id + '/mlabs.js', {
      method: 'POST',
      evalJS: true,
      parameters: {
        type: itemType,
        item_id: item_id,
        authenticity_token: encodeURIComponent(this.authenticity_token)        
      },
      onComplete: function() {
        image.src = '/images/button_mlab.png';
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