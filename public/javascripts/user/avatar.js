var UserAvatar = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();

    Event.observe(window, 'unload', this.destroy.bind(this));		
  },
  setup: function() {
		this.form   = $('change-avatar-form');
		this.alert  = $('change-avatar-alert');
    this.image  = $('user-avatar-image');
		this.status = $('change-avatar-status');
		this.upload = $('change-avatar-upload');

    this.b_handleMouseOver = this.handleMouseOver.bind(this);
    this.b_handleMouseOut = this.handleMouseOut.bind(this);
    this.element.observe('mouseover', this.b_handleMouseOver);
    this.element.observe('mouseout', this.b_handleMouseOut);

    this.b_displayUploadForm = this.displayUploadForm.bind(this);
		this.container = $('user-avatar-container');
		this.container.observe('click', this.b_displayUploadForm);
		this.change_avatar = $('change-avatar');
		this.change_avatar.observe('click', this.b_displayUploadForm);

    this.b_hideUploadForm = this.hideUploadForm.bind(this);
		this.close_link = $('change-avatar-close');
		this.close_link.observe('click', this.b_hideUploadForm);

    this.b_uploadNewAvatar = this.uploadNewAvatar.bind(this);
		this.file_input = $('change-avatar-file-input');
		this.file_input.observe('change', this.b_uploadNewAvatar);
  },
  destroy: function() {
    this.form   = null;
    this.alert  = null;
    this.image  = null;
    this.status = null;
    this.upload = null;

    this.element.stopObserving('mouseover', this.b_handleMouseOver);
    this.element.stopObserving('mouseout', this.b_handleMouseOut);
    this.element = null;

    this.container.stopObserving('click', this.b_displayUploadForm);
    this.container = null;

    this.change_avatar.stopObserving('click', this.b_displayUploadForm);
    this.change_avatar = null;

    this.close_link.stopObserving('click', this.b_hideUploadForm);
    this.close_link = null;

    this.file_input.stopObserving('change', this.b_uploadNewAvatar);
    this.file_input = null;
  },
  handleMouseOver: function() {
	  if(this.upload.visible())
		  return;

	  this.container.addClassName('active');
	  this.change_avatar.addClassName('active');
  },
  handleMouseOut: function(force) {
	  if(this.upload.visible() && !force)
		  return;

    this.container.removeClassName('active');
    this.change_avatar.removeClassName('active');
  },
  displayUploadForm: function() {
    new Effect.Appear(this.upload, {duration: 0.5});
    this.element.stopObserving('mouseout', this.b_handleMouseOut);
  },
  hideUploadForm: function() {
    new Effect.Fade(this.upload, {duration: 0.5, afterFinish: this.b_handleMouseOut});
		this.alert.hide();
		this.status.className = ''
    this.element.observe('mouseout', this.b_handleMouseOut);
  },
  uploadNewAvatar: function() {
    this.alert.hide();
		this.status.className = 'loading';
		this.form.submit();
    this.file_input.value = '';
	},
  uploadCompleted: function(path) {
		this.status.className = 'ok';
    this.image.src = path;

		this.hideUploadForm.bind(this).delay(1.0);
		this.handleMouseOut.bind(this, true).delay(1.4);
  },
  uploadFailed: function() {
		this.status.className = 'error';
		this.alert.show();
	}
});

document.observe('dom:loaded', function() {
  UserAvatar.instance = new UserAvatar('user-avatar');
});
