$(document).ready(function() {
  $('.instr_block').hover(
    function() { $(this).children('.instr_avatar').removeClass('shadow_white'); },
    function() { $(this).children('.instr_avatar').addClass('shadow_white'); }
  );

  $('.song_controls .control_mix').click(function() {
    $('#flash')[0].loadSong(this.rel);
    return false;
  });

  $('.track_controls .control_mix').click(function() {
    $('#flash')[0].loadTrack(this.rel);
    return false;
  });
});

function refreshStatus(status) {
  if (!status) {
    status = $('#flash')[0].status();
  }

  $('.project_overview .runtime').empty().append(status.runtime);

  var tracks = status.tracks;
  var count = tracks.length;
  $('.project_overview .count').empty().append(count);

  var missing_tag = tracks.filter(function(t) { return t.tags == '' }).length;
  if (missing_tag > 0) {
    $('.project_overview .missing_tag .tag_count').empty().append(missing_tag);
    $('.project_overview .missing_tag').show();
  } else {
    $('.project_overview .missing_tag').hide();
  }

  var missing_instr = tracks.filter(function(t) { return t.instrument == 0 }).length;
  if (missing_instr > 0) {
    $('.project_overview .missing_instr .instr_count').empty().append(missing_instr);
    $('.project_overview .missing_instr').show();
  } else {
    $('.project_overview .missing_instr').hide();
  }
}
