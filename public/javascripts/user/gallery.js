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

// TODO: use CSS classes instead of ids and create either a base class
// to inherit from or a component with callbacks, in order to DRY this
// code and the change avatar one.
//
var GalleryUpload = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();
  },
  setup: function() {
    this.upload_trigger = this.element.down('#gallery-upload-trigger');
    this.upload_section = this.element.down('#gallery-upload-open');
    this.close_trigger = this.element.down('#gallery-upload-close');

    this.upload_trigger.observe('click', this.displayUploadForm.bind(this));
    this.close_trigger.observe('click', this.hideUploadForm.bind(this));

		this.form = this.element.down('#gallery-upload-form');
		this.status = this.element.down('#gallery-upload-status');
		this.alert = this.element.down('#gallery-upload-alert');
    this.button = this.element.down('#gallery-upload-button');

		this.file_input = this.element.down('#gallery-upload-file-input');
		this.file_input.observe('change', this.uploadPhoto.bind(this));
  },
  displayUploadForm: function() {
    this.upload_trigger.style.cursor = 'default';

    new Effect.Appear(this.upload_section, {duration: 0.3});
  },
  hideUploadForm: function() {
    this.upload_trigger.style.cursor = 'pointer';
    this.status.className = ''
    this.alert.className = '';
    this.alert.hide();
    this.button.show();

    new Effect.Fade(this.upload_section, {duration: 0.3});
  },
  uploadPhoto: function() {
    this.alert.hide();
		this.status.className = 'loading';
		this.form.submit();
    this.file_input.value = '';
  },
  uploadCompleted: function() {
    this.status.className = 'ok';
		this.hideUploadForm.bind(this).delay(1.0);
  },
  uploadFailed: function() {
		this.status.className = 'error';
		this.alert.show();
	},
  uploadLimitReached: function(limit) {
    this.status.className = '';
    this.alert.className = 'limit-reached';
    this.alert.innerHTML = 'You can upload a maximum of ' + limit + ' pictures at the moment ;-)';
    this.button.hide();
    this.alert.show();
  }
});

document.observe('dom:loaded', function() {
  Gallery.instance = new Gallery('gallery');

  if ($('gallery-upload')) {
    GalleryUpload.instance = new GalleryUpload('gallery-upload');
  }
});
