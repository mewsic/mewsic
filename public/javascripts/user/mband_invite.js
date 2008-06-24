var MbandInvite = Class.create({
  initialize: function(element) {
    this.element = $(element);
    if (!this.element)
      return;

    this.mband_select = this.element.down('#mband_id');
    this.new_mband_block = this.element.down('#mband_add_new');

    this.mband_select.observe('change', this.onMbandChange.bind(this));

    this.leader_instrument = new InstrumentsSelect(this.element.down('#leader_instrument_id'));
    this.invitee_instrument = new InstrumentsSelect(this.element.down('#instrument_id'));
  },

  onMbandChange: function(event) {
    if (this.mband_select.value.strip() == '')
      this.new_mband_block.blindDown({duration: 0.3});
    else
      this.new_mband_block.blindUp({duration: 0.3});
  }
});

document.observe('dom:loaded', function() {
  MbandInvite.Instance = new MbandInvite('mband_invite_core');
});
