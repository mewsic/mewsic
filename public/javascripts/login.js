$(document).ready(function() {
  $('#login-form').submit(function() {
    var username = $('#login');
    var password = $('#password');
    var err = false;

    if (username.val() == '') {
      username.addClass('error');
      err = true;
    }

    if (password.val() == '') {
      password.addClass('error');
      err = true;
    }

    if (err) {
      $('.validateTips').show();
      return false;
    } else {
      $('#login-spinner').show();
      return true;
    }
  });

  $('#login, #password').change(function() {
    if ($(this).val() == '')
      $(this).addClass('error');
    else
      $(this).removeClass('error');
  }).focus(function() {
    $(this).removeClass('error');
  });
});
