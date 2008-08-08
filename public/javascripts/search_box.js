var SearchBox = Class.create({
  initialize: function(element) {
    this.element = $(element);
    if (!this.element)
      return;

    this.form = this.element.down('form');
    this.string = this.form.down('#q');
    this.submit = this.form.down('.submit-button');

    this.b_onSubmit = this.onSubmit.bind(this);
    this.submit.observe('click', this.b_onSubmit);
    this.form.observe('submit', this.b_onSubmit);

    this.b_showAdvancedBox = this.showAdvancedBox.bind(this);
    this.collapsed_box = this.element.down('.collapsed-box');
    this.collapsed_box.down('.trigger').observe('click', this.b_showAdvancedBox);

    this.b_showCollapsedBox = this.showCollapsedBox.bind(this);
    this.advanced_box = this.element.down('.advanced-box');
    this.advanced_box.down('.trigger').observe('click', this.b_showCollapsedBox);

    this.links = this.advanced_box.select('a');
    this.links.invoke('observe', 'click', this.toggleCheckBox);

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function(event) {
    this.element = null;
    this.string = null;

    this.form.stopObserving('submit', this.b_onSubmit);
    this.form = null;

    this.submit.stopObserving('click', this.b_onSubmit);
    this.submit = null;

    this.collapsed_box.down('.trigger').stopObserving('click', this.b_showAdvancedBox);
    this.collapsed_box = null;

    this.advanced_box.down('.trigger').stopObserving('click', this.b_showCollapsedBox);
    this.advanced_box = null;

    this.links.invoke('stopObserving', 'click', this.toggleCheckBox);
    this.links.clear();
    this.links = null;
  },

  toggleCheckBox: function(event) {
    event.stop();
    var box = event.element().previous();
    box.checked = !box.checked;
  },
    
  showAdvancedBox: function(event) {
    event.stop();
    new Effect.Fade(this.collapsed_box, {duration: 0.3});
    new Effect.Appear(this.advanced_box, {duration: 0.3, queue: 'end'});
  },

  showCollapsedBox: function(event) {
    event.stop();
    this.links.each(function(link) { link.previous().checked = false; });

    new Effect.Fade(this.advanced_box, {duration: 0.3});
    new Effect.Appear(this.collapsed_box, {duration: 0.3, queue: 'end'});
  },

  onSubmit: function(event) {
    event.stop();

    if (!this.string.value.blank()) {
      this.form.submit();
    } else {
      alert('Please enter something to search!');
    }

  }
});  

document.observe('dom:loaded', function(event) {
  SearchBox.instance = new SearchBox('search');
});
