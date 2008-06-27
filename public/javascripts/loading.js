var Loading = Class.create({
  initialize: function(options) {
    this.options = Object.extend({
      container: 'container',
      spinner: 'spinner'
    }, arguments[0] || {});

    this.options.container = $(this.options.container);
    this.options.spinner = $(this.options.spinner);
    this.options.image = this.options.spinner.tagName == 'IMG' ?
                           this.options.spinner :
                           this.options.spinner.down('img');
  },

  show: function() {
    this.options.spinner.style.top = '-4000px';
    this.options.spinner.show();

    var container = this.options.container.getDimensions();
    var spinner = this.options.image.getDimensions();
    var minimum = this.options.minimum_spinner_height || 15;

    if (spinner.height > container.height) {
      var height = container.height < minimum ? minimum : container.height;
      spinner.height = spinner.width = height;
      this.options.image.style.height = this.options.image.style.width = this.integerToPixels(height);
    }

    this.options.container.setOpacity(0.2);

    this.options.spinner.style.top = this.integerToPixels((container.height - spinner.height) / 2);
    this.options.spinner.style.left = this.integerToPixels((container.width - spinner.width) / 2);
  },

  hide: function() {
    this.options.spinner.style.top = this.options.spinner.style.left = this.integerToPixels(0);
    this.options.image.style.width = this.options.image.style.height = null;
    this.options.spinner.hide();
    this.options.container.setOpacity(1.0);
  },

  integerToPixels: function(x) {
    return (String(parseInt(x)) + 'px');
  }
});
