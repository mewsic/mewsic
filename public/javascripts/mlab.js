var MlabItem = Class.create({
  template: new Template(
    '<div id="mlab_element_#{attributes.mlab_id}" class="elements #{even_odd} #{type} clear-block" style="height: 55px;">' +
    '  <div class="info">' +
    '    <div class="thumb"><a href="/users/#{attributes.user_id}"><img src="#{attributes.avatar}"/></a></div>' +
    '    <div>' +
    '      <p class="title">#{attributes.title}</p>' +
    '      <p class="abstract">#{attributes.original_author}</p>' +
    '    </div>' +
  	'  </div>' +
  	'  <div class="buttons">' +
  	'	   <a class="button mlab play player" href="/#{type}s/#{attributes.id}/player.html"></a>' +
  	'	   <a href="#" class="button mlab remove" onclick="MlabSlider.destroyItem(\'#{type}\', #{attributes.id}); return false;"></a>' +
  	'  </div>' +
    '  <p class="genre">#{attributes.genre_name}</p>' +
    '</div>'
  ),

  initialize: function(attributes, slider) {
    this.type = attributes.type;
    this.attributes = attributes;

    if (this.type == 'song') {
      this.attributes.title =
        this.link_to('/songs/' + this.attributes.id, this.attributes.title);
    }

    if (this.attributes.genre_name) {
      this.attributes.genre_name =
        this.link_to('/genres/' + this.attributes.genre_name.gsub(/ +/, '+'), this.attributes.genre_name);
    }

    this.slider = slider;
    this.slider.addItem(this);
  },

  key: function() {
    return this.type + '_' + this.attributes.id;
  },

  element: function() {
    return $('mlab_element_' + this.attributes.mlab_id);
  },

  toHTML: function() {
    return this.template.evaluate(this);
  },

  link_to: function(path, text) {
    return('<a href="' + path + '">' + text + '</a>');
  }

});

var MlabBanner = Class.create({
  template:
    '<div id="mlab_element_banner" class="elements banner even clear-block" style="height: 55px">' +
    '  <p class="centered grey-text">This panel contains the elements you collect by clicking the <img class="remove" src="/images/button_mlab.png"/> button.' +
    '    <a href="/help/mlab">Click here to learn more</a></p>' +
    '</div>'
  ,

  initialize: function(slider) {
    this.type = 'banner';
    this.slider = slider;
    this.attributes = {skip_highlight: true};
    this.slider.addItem(this);
  },

  key: function() {
    return 'banner';
  },

  element: function() {
    return $('mlab_element_banner');
  },

  toHTML: function() {
    return this.template;
  }
});

var MlabSlider = Class.create(PictureSlider, {

  initialize: function($super, element, options) {
    $super(element, options);
    this.scroll_clip = this.element.down('div#scroll-clip');
    MlabSlider.instance = this;
    this.windowSize = this.options.windowSize;
    this.user_id = $('current-user-id').value;
    this.authenticity_token = $('authenticity-token').value;
    this.loadElements();
    this.items = new Array();
    this.loadingItems = new Array();
    this.setupMlab();
    Event.observe(window, 'unload', this.destroyMlab.bind(this));
  },

  destroyMlab: function() {
    this.scroll_clip = null;
    MlabSlider.instance = null;
  },

  toggleTriggers: function() {
    if (this.isBackSlidable()) {
      this.back_trigger.setOpacity(1.0);
      this.back_trigger.addClassName('c');
    } else {
      this.back_trigger.setOpacity(0.20);
      this.back_trigger.removeClassName('c');
    }

    if (this.isForwardSlidable()) {
      this.forward_trigger.setOpacity(1.0);
      this.forward_trigger.addClassName('c');
    } else {
      this.forward_trigger.setOpacity(0.20);
      this.forward_trigger.removeClassName('c');
    }
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
      attributes.skip_highlight = true;
      new MlabItem(attributes, this);
    }.bind(this))

    if (elements.size() == 0) {
      this.banner = new MlabBanner(this);
    }
    elements = null;
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
    if (this.banner) {
      MlabSlider.items.unset(this.banner.key());
      this.banner.element().remove();
      this.banner = null;
    }

    var first_element = this.scrolling_div.down();
    var _class = (first_element && first_element.hasClassName('even')) ? 'odd' : 'even';
    item.even_odd = _class;
    this.scrolling_div.insert({
      top: item.toHTML()
    });

    var key = item.key();

    MlabSlider.items.set(key, item);
    if (this.loadingItems.include(key))
      this.loadingItems.splice(this.loadingItems.indexOf(key), 1);

    if (!(Prototype.Browser.IE && navigator.userAgent.indexOf('6.0') > -1) && !item.attributes.skip_highlight) {
      id = 'mlab_element_' + item.attributes.mlab_id;
      new Effect.Pulsate(id, {duration:2.0, from: 0.3, pulses: 3, queue: 'end'});
    }

    this.update();
  },

  removeItem: function(type, id) {
    var item = MlabSlider.items.get(MlabSlider.item_key(type, id));
    if(item) {
      this._removeItem(item);
    }
  },

  _removeItem: function(item) {
    var element = item.element();
    element.down('.remove').addClassName('loading');
    element.nextSiblings().each(function(sibling) {
      var class_to_remove = sibling.hasClassName('even') ? 'even' : 'odd';
      var class_to_add    = (class_to_remove == 'even') ? 'odd' : 'even';
      sibling.removeClassName(class_to_remove);
      sibling.addClassName(class_to_add);
    });

    new Effect.Fade(element, {
      duration: 0.7, queue: 'end',
      afterFinish: function(item) {
        element.remove();
        MlabSlider.items.unset(item.key());
        if (MlabSlider.items.size() == 0) {
          this.banner = new MlabBanner(this);
        }
        this.update();
      }.bind(this, item)
    });
  },

  destroyItem: function(item) {
    var element = item.element();
    var img = element.down('a.button.mlab.remove img');
    new Ajax.Request('/users/' + this.user_id + '/mlabs/' + item.attributes.mlab_id + '.js', {
      method: 'DELETE',
      parameters: {
        authenticity_token: encodeURIComponent(this.authenticity_token)
      },
      onLoading: function() {
        img.src = "/images/spinner.gif";
      },
      onSuccess: this._removeItem.bind(this, item),
      onFailure: function() { window.location.reload(); }.bind(this)
    });
  },

  addTrack: function(element) {
    this.handleItemAddition(element, 'track');
  },

  addSong: function(element) {
    this.handleItemAddition(element, 'song');
  },

  handleItemAddition: function(element, itemType) {
    var image = element;
    var item_id = image.id.match(/^(\d+)_/)[1];
    var key = MlabSlider.item_key(itemType, item_id);

    if(MlabSlider.items.get(key)) {
      alert("this item is already in your list!");
      return;
    }
    if(this.loadingItems.include(key)) return;

    this.loadingItems.push(key);
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

MlabSlider.item_key = function(type, id) {
  var key = type;
  if (id)
    key += '_' + id;
  return key;
}

MlabSlider.destroyItem = function(type, id) {
  var item = MlabSlider.items.get(MlabSlider.item_key(type, id));
  if(item) {
    item.slider.destroyItem(item);
  }
}

MlabSlider.removeItem = function(type, id) {
  var item = MlabSlider.items.get(MlabSlider.item_key(type, id));
  if(item) {
    item.slider.removeItem(type, id);
  }
}
