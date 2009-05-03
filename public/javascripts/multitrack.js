var mTrack = null;

$(document).ready(function() {
  // Visual behaviour
  $('.instr_block').hover(
    function() { $(this).children('.instr_avatar').removeClass('shadow_white'); },
    function() { $(this).children('.instr_avatar').addClass('shadow_white'); }
  );

  var empty_title = $('#project .project_title').val();
  $('#project .project_title').focus(function() { 
    if ($(this).val() == empty_title) $(this).val('')
  }).blur(function() {
    if ($(this).val() == '') $(this).val(empty_title)
  });

  // Controls
  MSDropDown.init("#identity"); // This one *stinks*
  $('#identity').change(function() {
    var sel  = $(this)[0];
    var icon = $(sel.options[sel.selectedIndex]).attr('icon');
    //alert($(this).val() + "\n" + icon);
    $('.project_info .avatar').attr('src', icon);
  });

  // Callbacks
  $('.song_controls .control_mix').click(function() {
    mTrack.loadSong(this.rel);
    return false;
  });

  $('.track_controls .control_mix').click(function() {
    mTrack.loadTrack(this.rel);
    return false;
  });

});


function refreshStatus(status) {
  if (!mTrack) {
    mTrack = $('#flash')[0];
  }

  if (!status) {
    status = mTrack.status();
  }

  $('.project_overview .runtime').text(status.runtime);

  var tracks = status.tracks;
  var count = tracks.length;
  $('.project_overview .count').text(count);

  var missing_tag = tracks.filter(function(t) { return t.tags == '' }).length;
  if (missing_tag > 0) {
    $('.project_overview .missing_tag .tag_count').text(missing_tag);
    $('.project_overview .missing_tag').show();
  } else {
    $('.project_overview .missing_tag').hide();
  }

  var missing_instr = tracks.filter(function(t) { return t.instrument == 0 }).length;
  if (missing_instr > 0) {
    $('.project_overview .missing_instr .instr_count').text(missing_instr);
    $('.project_overview .missing_instr').show();
  } else {
    $('.project_overview .missing_instr').hide();
  }
}
