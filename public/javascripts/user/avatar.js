var UserAvatar = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.setup();
  },
  setup: function() {
    this.element.observe('mouseover', this.handleMouseOver.bind(this));
    this.element.observe('mouseout', this.handleMouseOut.bind(this, false));

		this.container = this.element.down('#user-avatar-container');
		this.change_avatar = this.element.down('#change-avatar');
		this.container.observe('click', this.displayUploadForm.bind(this));
		this.change_avatar.observe('click', this.displayUploadForm.bind(this));

		this.close_link = this.element.down('#change-avatar-close');
		this.close_link.observe('click', this.hideUploadForm.bind(this));

		this.upload_section = this.element.down('#change-avatar-upload')
		this.upload_section.style.display = 'none';

		this.form = this.element.down('#change-avatar-form');
		this.status = this.element.down('#change-avatar-status');
		this.alert = this.element.down('#change-avatar-alert');

		this.file_input = this.element.down('#change-avatar-file-input');
		this.file_input.observe('change', this.uploadNewAvatar.bind(this));
  },
  handleMouseOver: function() {
	  if(this.upload_section.visible())
		  return;

	  this.container.addClassName('active');
	  this.change_avatar.addClassName('active');
  },
  handleMouseOut: function(force) {
	  if(this.upload_section.visible() && !force)
		  return;

    this.container.removeClassName('active');
    this.change_avatar.removeClassName('active');
  },
  displayUploadForm: function() {
    new Effect.Appear(this.upload_section, {duration: 0.5});
  },
  hideUploadForm: function() {
    new Effect.Fade(this.upload_section, {duration: 0.5});
		this.alert.removeClassName('active');
		this.status.className = ''
  },
  uploadNewAvatar: function() {
    this.alert.removeClassName('active');
		this.status.addClassName('loading');
		this.form.submit();
	},
  uploadCompleted: function() {
    this.status.removeClassName('loading');
		this.status.addClassName('ok');

		this.hideUploadForm.bind(this).delay(1.0);
		this.handleMouseOut.bind(this, true).delay(1.4);
  },
  uploadFailed: function() {
    this.status.removeClassName('loading');
		this.status.addClassName('error');
		this.alert.addClassName('active');
	}
});

document.observe('dom:loaded', function() {
  UserAvatar.instance = new UserAvatar('user-avatar');
});
