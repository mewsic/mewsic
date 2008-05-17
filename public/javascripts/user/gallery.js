var GalleryItem = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();
  },
  setup: function() {
    this.element.observe('mouseover', this.handleMouseOver.bind(this));
    this.element.observe('mouseout', this.handleMouseOut.bind(this));
    this.delete_button = this.element.down('.button.delete');
    this.view_button   = this.element.down('.button.view');
    this.image_thumb   = this.element.down('a.image');

    if (this.delete_button) {
      this.delete_button.observe('mouseover', this.handleDeleteMouseOver.bind(this));
      this.delete_button.observe('mouseout', this.handleDeleteMouseOut.bind(this));
    }
  },
  handleMouseOver: function() {
    this.image_thumb.addClassName('active');
    if (this.delete_button)
      this.delete_button.show();
    this.view_button.show();
  },
  handleMouseOut: function() {
    this.image_thumb.removeClassName('active');
    if (this.delete_button)
      this.delete_button.hide();
    this.view_button.hide();
  },
  handleDeleteMouseOver: function() {
    this.delete_button.addClassName('active');
    this.view_button.addClassName('inactive');
  },
  handleDeleteMouseOut: function() {
    this.delete_button.removeClassName('active');
    this.view_button.removeClassName('inactive');
  }
});

var Gallery = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.elements = new Array();
    this.setup();
  },
  setup: function() {
    this.element.select('.gallery-photo-thumb').each(function(element) {
      if(!this.elements.include(element)) {
        new GalleryItem(element);
        this.elements.push(element);
      }      
    }.bind(this));
  }
});


document.observe('dom:loaded', function() {
  Gallery.instance = new Gallery('gallery');
});
