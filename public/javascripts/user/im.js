var UserLinks = Class.create({

  initialize: function() {
    this.element = $('user-links');
    this.tooltip = this.element.down('div.container');
    this.links = this.element.select('a.tip-link');
    this.tips = $A();
    if ($('podcast-link'))
      this.links.push($('podcast-link'));

    this.links.each(function(link) {
      link.observe('click', this.stopEvent);
      this.tips.push(new Tip(link, $(link.getAttribute('rel')), {style: 'user-link', title: link.title}));
    }.bind(this));

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },

  stopEvent: function(event) {
    event.stop();
  },

  destroy: function() {
    this.element = null;
    this.tooltip = null;

    this.tips.each(function(tip) {
      tip.closeButton = null;
      tip.content = null;
      tip.element = null;
      tip.target = null;
      tip.tip = null;
      tip.title = null;
      tip.wrapper = null;
      tip.iframeShim = null;
      tip.tooltip = null;
      tip.toolbar = null;
      tip.stem = null;
      tip.stemBox = null;
      tip.stemImage = null;
      tip.stemWrapper = null;
      tip.borderBottom = null;
      tip.borderCenter = null;
      tip.borderFrame = null;
      tip.borderMiddle = null;
      tip.borderTop = null;

      tip.options.target = null;
      tip.options = null;
    });

    this.links.invoke('stopObserving', 'click', this.stopEvent);
    this.links.clear();
    this.links = null;

    this.tips.clear();
    this.tips = null;
  }

});

var MSNLink = Class.create({
  initialize: function() {
    this.app = new Element('object', {height:0,width:0});

    try {
      this.app.classid = "clsid:B69003B3-C55E-4B48-836C-BC5946FC3B28";
      this.status = this.app.MyStatus;
      this.msn_present = this.status != null;
    }
    catch (e) {
      this.msn_present = false;
    }

    this.b_onMSNClick = this.onMSNClick.bind(this);
    this.links = $$('a.msn-link');
    this.links.invoke('observe', 'click', this.b_onMSNClick);

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },

  destroy: function() {
    this.app = null;

    this.links.invoke('stopObserving', 'click', this.b_onMSNClick);
    this.links.clear();
    this.links = null;
  },

  onMSNClick: function(event) {
    event.stop();

    var element = event.element();
    var handle = element.href;

    if (!this.msn_present) {
      Message.notice("Please copy & paste <em>" + handle + "</em> into your MSN client");
      return;
    }

    if (this.app.MyStatus == 1) {
      Message.notice("You have to log in to MSN for this to work!");
      return;
    }


    this.app.addContact(0, handle);
  }
});

document.observe('dom:loaded', function() {
  UserLinks.instance = new UserLinks();
  MSNLink.instance = new MSNLink();
});
