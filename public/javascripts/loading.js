var Loading = Class.create({
  initialize: function(options) {
    this.options = Object.extend({
      container: 'container',
      spinner: 'spinner'
    }, arguments[0] || {});

    this.options.container = $(this.options.container);
  },

  show: function() {
    var s = $(this.options.spinner);
    s.style.top = '-4000px';
    s.show();

    var image = s.tagName == 'IMG' ? s : s.down('img');
    var container = this.options.container.getDimensions();
    var spinner = image.getDimensions();
    var minimum = this.options.minimum_spinner_height || 15;

    if (spinner.height > container.height) {
      var height = container.height < minimum ? minimum : container.height;
      spinner.height = spinner.width = height;
      image.style.height = image.style.width = this.integerToPixels(height);
    }

    this.options.container.setOpacity(0.2);

    s.style.top = this.integerToPixels((container.height - spinner.height) / 2);
    s.style.left = this.integerToPixels((container.width - spinner.width) / 2);
  },

  hide: function() {
    var s = $(this.options.spinner);
    s.hide();
    s.style.top = s.style.left = this.integerToPixels(0);

    this.options.container.setOpacity(1.0);
  },

  integerToPixels: function(x) {
    return (String(parseInt(x)) + 'px');
  }
});
