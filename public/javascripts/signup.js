$(document).ready(function() {
  $('#user_login, #user_email, #user_password, #user_password_confirmation').addErrorWhenEmptied();

  $('#reset').click(function() {
    window.location.href = '/';
  });

  $('#signup-form').submit(function() {
    $('#signup-spinner').show();
  });
});
