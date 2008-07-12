var Tooltips = Class.create({
  initialize: function() {
    this.addAll(document.body);

    Ajax.Responders.register({
      onComplete: this.responder.bindAsEventListener(this)
    });
  },

  addAll: function(element) {
    element.select('.instrument').each(this.addInstrument);

    if (!$('current-user-id')) {
      element.select('.rating').each(this.addRating);
      element.select('img.button.mlab').each(this.addMlab);
    }
    element.select('.rating.locked').each(this.addLockedRating);
    element.select('.status').each(this.addStatus);
  },

  addInstrument: function(element) {
    new Tip(element, element.getAttribute('rel'), {style: 'instrument'});
  },

  addRating: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to vote!", {style: 'login'});
  },

  addLockedRating: function(element) {
    new Tip(element, "You cannot rate yourself!", {style: 'locked-rating'});
  },

  addMlab: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to use the <a href=/help>Mlab</a>!", {style: 'login'});
  },

  addStatus: function(element) {
    if (element.up('.user-profile') ||
      element.up('#friend-box') ||
      element.up('#admirers-box') ||
      element.up('#mband-members') ||
      element.up('#newest-users'))
      return;

    if (element.hasClassName('online')) {
      content = "User is online now!";
    } else {
      content = "User is offline";
    }
    new Tip(element, content, {style: 'status'});
  },

  responder: function(r) {
    Tips.tips.select(function(t) {
      return t.element.parentNode == null;
    }).each(function(t) {
      Tips.remove(t.element);
    });

    var container = $(r.container.success);
    if (container) {
      this.addAll(container);
    }
  },

});

document.observe('dom:loaded', function() {
  Tooltips.instance = new Tooltips();
});
