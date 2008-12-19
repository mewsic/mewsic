var GenderSwitcher = Class.create({
  initialize: function(element) {
    this.element = $(element);
    if (!this.element)
      return;

    this.genders = {male: 'M', female: 'F', other: 'O'};
    this.element.style.display = 'none';

    this.b_showGenders = this.showGenders.bind(this);
    this.trigger = $(this.element.id + '-trigger');
    this.trigger.observe('click', this.b_showGenders);

    this.b_setGender = this.setGender.bind(this);
    this.element.select('img').invoke('observe', 'click', this.b_setGender);

    Event.observe(window, 'unload', this.destroy.bind(this));
  },

  destroy: function(element) {
    this.trigger.stopObserving('click', this.b_showGenders);
    this.trigger = null;

    this.element.select('img').invoke('stopObserving', 'click', this.b_setGender);
    this.element = null;
  },

  showGenders: function(event) {
    event.stop();
    this.trigger.hide();
    new Effect.Appear(this.element, {duration: 0.3});
  },

  setGender: function(event) {
    event.stop();
    var element = event.element();
    var gender = element.getAttribute('alt');
    if (!this.genders[gender])
      return;

    new Ajax.Request('/users/' + $('user-id').value, {
      method: 'PUT',
      parameters: 'user[gender]=' + gender,
      onComplete: this.onSetGenderSuccess.bind(this),
      onFailure: this.onSetGenderFailure.bind(this)
    });
  },

  onSetGenderSuccess: function(response) {
    var gender = response.responseText;
    if (!this.genders[gender]) {
      onSetGenderFailure();
      return;
    }

    new Effect.Fade(this.element, {
      duration: 0.4,
      afterFinish: function(gender) {
        this.trigger.up().insert({
          top: new Element('img', { src: '/images/gender_ico_' + gender + '.gif' })
        });
        this.trigger.remove();
        this.element.remove();
      }.bind(this, this.genders[gender])
    });
  },

  onSetGenderFailure: function() {
    alert('error. please try again'); // should not happen, lazy solution for now.
  }
});
