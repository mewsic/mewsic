var GalleryItem = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();
  },
  setup: function() {
    this.b_handleMouseOver = this.handleMouseOver.bind(this);
    this.b_handleMouseOut  = this.handleMouseOut.bind(this);

    this.element.observe('mouseover', this.b_handleMouseOver);
    this.element.observe('mouseout', this.b_handleMouseOut);

    this.delete_button = this.element.down('.button.delete');
    this.view_button   = this.element.down('.button.view');
    this.image_thumb   = this.element.down('a.image');

    if (this.delete_button) {
      this.b_handleDeleteMouseOver = this.handleDeleteMouseOver.bind(this);
      this.b_handleDeleteMouseOut  = this.handleDeleteMouseOut.bind(this);

      this.delete_button.observe('mouseover', this.b_handleDeleteMouseOver);
      this.delete_button.observe('mouseout', this.b_handleDeleteMouseOut);
    }
  },
  destroy: function() {
    this.view_button = null;
    this.image_thumb = null;

    this.element.stopObserving('mouseover', this.b_handleMouseOver);
    this.element.stopObserving('mouseout', this.b_handleMouseOut);
    this.element = null;

    if (this.delete_button) {
      this.delete_button.stopObserving('mouseover', this.b_handleDeleteMouseOver);
      this.delete_button.stopObserving('mouseout', this.b_handleDeleteMouseOut);
      this.delete_button = null;
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
    this.elements = [];
    this.items = [];
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },
  setup: function() {
    this.element.select('.gallery-photo-thumb').each(function(element) {
      if(!this.elements.include(element)) {
        this.items.push(new GalleryItem(element));
        this.elements.push(element);
      }      
    }.bind(this));
  },
  destroy: function() {
    this.element = null;
    this.elements.clear();
    this.items.invoke('destroy');
    this.items.clear();
  }
});

var GalleryUpload = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },
  setup: function() {
    this.upload_section = $('gallery-upload-open');
		this.form = $('gallery-upload-form');
		this.status = $('gallery-upload-status');
		this.alert = $('gallery-upload-alert');
    this.button = $('gallery-upload-button');

    this.upload_trigger = $('gallery-upload-trigger');
    this.b_displayUploadForm = this.displayUploadForm.bind(this)
    this.upload_trigger.observe('click', this.b_displayUploadForm);

    this.close_trigger = $('gallery-upload-close');
    this.b_hideUploadForm = this.hideUploadForm.bind(this);
    this.close_trigger.observe('click', this.b_hideUploadForm);

		this.file_input = $('gallery-upload-file-input');
    this.b_uploadPhoto = this.uploadPhoto.bind(this);
		this.file_input.observe('change', this.b_uploadPhoto);
  },
  destroy: function() {
    this.element = null;

    this.upload_section = null;
    this.form = null;
    this.status = null;
    this.alert = null;
    this.button = null;

    this.upload_trigger.stopObserving('click', this.b_displayUploadForm);
    this.upload_trigger = null;

    this.close_trigger.stopObserving('click', this.b_hideUploadForm);
    this.close_trigger = null;

    this.file_input.stopObserving('change', this.b_uploadPhoto);
    this.file_input = null;
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
