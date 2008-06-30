var Tooltips = Class.create({
  initialize: function() {
    $$('.instrument').each(this.addInstrument);

    if (!$('current-user-id')) {
      $$('div.rating').each(this.addRating);
      $$('img.button.mlab').each(this.addMlab);
    }

    Ajax.Responders.register({
      onComplete: this.responder.bindAsEventListener(this)
    });
  },

  addInstrument: function(element) {
    new Tip(element, element.getAttribute('rel'), {style: 'instrument'});
  },

  addRating: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to vote!", {style: 'login'});
  },

  addMlab: function(element) {
    new Tip(element, "<a href=/login>Login</a> or <a href=/signup>sign up</a> to use the <a href=/help>Mlab</a>!", {style: 'login'});
  },

  responder: function() {
    var orphans = Tips.tips.select(function(t) {
      return t.element.parentNode == null;
    });

    orphans.each(function(t) {
      Tips.remove(t.element);
    });

    $$('.instrument').each(function(element) {
      this.rehash(element, this.addInstrument);
    }.bind(this));

    if (!$('current-user-id')) {
      $$('img.button.mlab').each(function(element) {
        this.rehash(element, this.addMlab);
      }.bind(this));
    }
  },

  rehash: function(element, callback) {
    if (Tips.tips.find(function(t) { return t.element == element; }))
      return;

     callback(element);
  }
});

document.observe('dom:loaded', function() {
  Tooltips.instance = new Tooltips();
});