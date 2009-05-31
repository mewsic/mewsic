$(document).ready(function() {

  $('#login, #password').addErrorWhenEmptied();

  $('#login-form').submit(function() {
    var err = $('#login, #password').addErrorIfEmpty().length;

    if (err > 0) {
      $('.validateTips').show();
      return false;
    } else {
      $('#login-spinner').show();
      return true;
    }
  });
});
