var Tooltips = Class.create({
  initialize: function() {
    if (Prototype.Browser.IE && navigator.userAgent.indexOf('6.'))
      return;

    this.addAll($(document.body), 10);

    Ajax.Responders.register({
      onComplete: this.responder.bindAsEventListener(this)
    });

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },

  destroy: function() {
    Tips.tips.each(function(tip) { Tips.remove(tip.element) })
  },

  addAll: function(element, limit) {
    // Tips for anonymous users
    if (!$('current-user-id')) {
      element.select('.rating').slice(0,limit).each(this.addRating);
      element.select('img.button.mlab').slice(0,limit).each(this.addMlab);
      element.select('.download').slice(0,limit).each(this.addDownload);
    }

    element.select('img.instrument').each(this.addInstrument);
    element.select('.rating.locked').slice(0,limit).each(this.addLockedRating);
    element.select('.status').slice(0,20).each(this.addStatus);
  },

  addInstrument: function(element) {
    new Tip(element, element.getAttribute('rel'), {style: 'instrument'});
  },

  addRating: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to vote!", {style: 'login'});
  },

  addLockedRating: function(element) {
    var tip = new Tip(element, '0.00 ratings from 0.00 votes', {style: 'locked-rating'});
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
    if (element.hasClassName('no-tip'))
      return;

    if (element.hasClassName('on')) {
      content = "<strong>ONLINE</strong>";
    } else if (element.hasClassName('rec')) {
      content = "<strong> M-LAB </strong>";
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
