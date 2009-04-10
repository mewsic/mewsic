$(function() {
	/* ROUNDED CORNERS CLASSES */
	$('.roundTop10').corner("top 10px");
	$('.roundBottom10').corner("bottom 10px");
	$('.round10').corner("cc:#ffffff 10px");
	$('.round7').corner("cc:#ffffff 7px");		
});


// Facebook connect stuff
//
function loadFacebookFeatures(is_session_loaded) {
  try {

    FB_RequireFeatures(["XFBML", "CanvasUtil", "Api"], function(){
      FB.Facebook.init('8b03aa5c7dae2e65e155bdcd41634d25', '/sessions/connect');
      
      FB.Facebook.get_sessionState().waitUntilReady(function(session) {
        var is_now_logged_into_facebook = !!session;

        if (is_now_logged_into_facebook != is_session_loaded) {
          // user logged in and changed status
          //
          // XXX this code isn't solid, FIX IT
          window.location = '/';
        }
      });
    })

  } catch(e) {
    if (isLoggerAvailable())
      console.log("Facebook connect support is not available");
  }

}

function isLoggerAvailable() {
  var ret = false; try { ret = console.log != undefined; } catch (e) {}; return (ret);
}

