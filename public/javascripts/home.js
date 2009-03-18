$(function() {

  /* JQUERY UI TABS */
  $("#playlist_tabs").tabs();

  /* NOTIFICATION COUNT */
  $("#addthis").click(function () {
    $(this).effect("transfer", { to: "#notification_holder", className: 'ui-effects-transfer' }, 1000);
    return false;
  });

  /* HIDE BANNER */
  $("#expl_hide").click(function () {
    $('#expl_banner').hide("blind", {}, 1000);
  });

});
