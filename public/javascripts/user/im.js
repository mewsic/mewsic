var UserLinks = Class.create({

  initialize: function() {
    this.element = $('user-links');
    this.tooltip = this.element.down('div.container');
    var links = this.element.select('a.tip-link');
    if ($('podcast-link'))
      links.push($('podcast-link'));

    links.each(function(link) {
      var contents = $(link.getAttribute('rel'));
      var title = link.title;
      link.observe('click', function(event) { event.stop(); });
      new Tip(link, contents, {style: 'user-link', title: title});
    });
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

    $$('a.msn-link').invoke('observe', 'click', this.onMSNClick.bind(this));
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
