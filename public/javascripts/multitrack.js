$(document).ready(function() {
  $('.instr_block').hover(
    function() { $(this).children('.instr_avatar').removeClass('shadow_white'); },
    function() { $(this).children('.instr_avatar').addClass('shadow_white'); }
  );
})
