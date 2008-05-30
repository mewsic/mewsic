var LoginBox = Class.create({
  initialize: function(element) {
    this.element = $(element);

    this.username = this.element.down('input.username');
    this.password = this.element.down('input.password');
    this.email = this.element.down('input.email');

    this.login_box = this.element.down('div#login-box-core');
    this.forgot_box = this.element.down('div#login-box-forgot');

    this.forgot_link = this.element.down('a.forgot');
    this.cancel_link = this.element.down('a.cancel');

    this.forgot_form = this.element.down('form#forgot-box');
    this.forgot_spinner = this.element.down('img#forgot-box-spinner');

    this.setup();
  },

  setup: function() {
    this.observeInputFocus('username', this.username);
    this.observeInputFocus('password', this.password);
    this.observeInputFocus('Your email address', this.email);

    this.forgot_link.observe('click', this.showForgotBox.bind(this));
    this.cancel_link.observe('click', this.showLoginBox.bind(this));

    this.forgot_form.observe('submit', this.handleForgotPassword.bind(this));
  },

  observeInputFocus: function(default_text, element) {
    element.observe('blur', this.handleInputFocus.bind(this, default_text));
    element.observe('focus', this.handleInputFocus.bind(this, default_text));
  },

  handleInputFocus: function(default_text, event) {
    var element = event.element();
    event.stop();
    if (event.type == 'blur') {
      if (element.value == '') element.value = default_text;
    } else {
      if (element.value == default_text) element.value = '';
    }
  },

  handleForgotPassword: function(event) {
    event.stop();
    this.forgot_spinner.show();
    new Ajax.Request(this.forgot_form.getAttribute('action'), {
      asynchronous: true,
      evalScripts: true,
      onComplete: this.showLoginBox.bind(this),
      parameters: Form.serialize(this.forgot_form)
    });
  },

  showForgotBox: function(event) {
    event.stop();
    new Effect.Fade(this.login_box, {duration: 0.3});
    new Effect.Appear(this.forgot_box, {duration: 0.3, queue: 'end'});
  },

  showLoginBox: function(event) {
    try {event.stop();} catch(e) { }
    this.forgot_spinner.hide();
    new Effect.Fade(this.forgot_box, {duration: 0.3});
    new Effect.Appear(this.login_box, {duration: 0.3, queue: 'end'});
  }
});

document.observe('dom:loaded', function() {
  if ($('login')) {
    LoginBox.instance = new LoginBox('login');
  }
});
