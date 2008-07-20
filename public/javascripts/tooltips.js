var Tooltips = Class.create({
  initialize: function() {
    this.addAll(document.body, 15);

    Ajax.Responders.register({
      onComplete: this.responder.bindAsEventListener(this)
    });
  },

  addAll: function(element, limit) {
    // Tips for anonymous users
    if (!$('current-user-id')) {
      if (!Prototype.Browser.IE) {
        element.select('.rating').slice(0,limit).each(this.addRating);
      }
      element.select('img.button.mlab').slice(0,limit).each(this.addMlab);
      element.select('.download').slice(0,limit).each(this.addDownload);
    }

    element.select('img.instrument').each(this.addInstrument);

    if (!Prototype.Browser.IE) {
      element.select('.rating.locked').slice(0,limit).each(this.addLockedRating);
      element.select('.status').slice(0,limit).each(this.addStatus);
    }
  },

  addInstrument: function(element) {
    new Tip(element, element.getAttribute('rel'), {style: 'instrument'});
  },

  addRating: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to vote!", {style: 'login'});
  },

  addLockedRating: function(element) {
    var tip = new Tip(element, '  0 ratings from   0 votes', {style: 'locked-rating'});
    element.observe('prototip:shown', function() {
      tip.tip.update(this.down('.indicator').innerHTML);
    });
  },

  addMlab: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a><br/>to use the <a href=/help>multitrack</a>!", {style: 'login'});
  },

  addDownload: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to download!", {style: 'login'});
  },

  addStatus: function(element) {
    if (element.up('.user-profile') ||
      element.up('#friend-box') ||
      element.up('#admirers-box') ||
      element.up('#mband-members') ||
      element.up('#newest-users'))
      return;

    if (element.hasClassName('on')) {
      content = "<strong>ONLINE</strong>";
    } else if (element.hasClassName('rec')) {
      content = "<strong>MTRACK</strong>";
    } else {
      content = "<strong>OFFLINE</strong>";
    }
    new Tip(element, content, {style: 'status'});
  },

  responder: function(r) {
    Tips.tips.each(function(t) {
      if (t.element.parentNode == null)
        Tips.remove(t.element);
    });

    var container = $(r.container.success);
    if (container) {
      this.addAll(container, 5);
    }
  }

});

document.observe('dom:loaded', function() {
  Tooltips.instance = new Tooltips();
});
