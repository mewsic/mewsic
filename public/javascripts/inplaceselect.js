/**
- Ajax.InPlaceSelect.js -
  Creates a <select> control in place of the html element with the id
  specified.  It functions similar to "Ajax.InPlaceEditor" but instead
  of an <input> control, it creates a <select> control with a list of
  <options> from which to choose.  The parameters 'values' and 'labels'
  are arrays (of the same length) from which the <options> are defined.

- Syntax -
  new Ajax.InPlaceSelect('id', 'url', 'values[]', 'labels[]', { options });

- Example -
  new Ajax.InPlaceSelect('someId', 'someURL', [1,2], ['first','second'],
    { paramName: 'asset_type', parameters: "moreinfo=extra info" } );

- Options('default value') -
  - paramName('selected'): name of the default parameter sent
  - hoverClassName(null): class added when mouse hovers over the control
  - hightlightcolor("#FFFF99"): initial color (mouseover)
  - hightlightendcolor("#FFFFFF"): final color (mouseover)
  - parameters(null): additional parameters to send with the request
      (in addition to the data sent by default)

- Modified Feb 22, 2006 by Thom Porter (www.thomporter.com)
  - Modified to use Single Click
  - Added "cancelLink" to options - Defaults to true, set to false to not
    show the cancel link
  - Commented the following Lines:
      //this.menu.onblur = this.onCancel.bind(this);
      //this.menu.onmouseout = this.onCancel.bind(this);
    I found that these lines made it switch back when the user would 
    mouse off of the select and didn't like that feature. =)
   
- Modified Feb 25, 2006 by Thom Porter
  - Modified to include callback function.  Function to accept 2 
    parameters, value & text.  The first being the value=""
    of the choose option, and the second being the text that
    is displayed.
  - IMPORTANT CHANGE: If you don't provide your own call back 
    function, your server-side script should expect the following
    POST variables: 
     newval = Value of the chosen <option>
     newtxt = Text of the chosen <option>

- Example using Call Back Function: 
  new Ajax.InPlaceSelect('someId', 'someURL', [1,2], ['first','second'],
    { 
    	callback: function(value, text) { return 'newval='+value+'&newtxt='+text; }
    	
    } );
  (this example actually does the same things as the default call back function.)
  
  
- Modified Sep 21, 2006 by Andreas Norman
  - Added option "okButton" (default true)
  - Added option "okText" (default 'ok')
  - Added option "cancelText" (default 'cancel')
  - Added option to take use of the onChange method or not. (default false)
		
	- Example using Call Back Function with the new options: 
  	new Ajax.InPlaceSelect('someId', 'someURL', [1,2], ['first','second'],
    { 
    	okText:'spara', cancelText:'avbryt', callback: function(value, text) { return 'newval='+value+'&newtxt='+text; }
    	
    } );
  - If you have troubles with it to select the correct default value, take note 
  	of that the string must match exactly (remove whitespace). If using swedish 
  	letters for example, you'll need to convert them to UTF-8.
  	
- Modified Nov 14, 2006 by Jay Buffing
  - I had problems with inplace edit not being able to determine what value
		was already selected.  I added code to strip the spaces first
		and this fixed my problem. 
		
- Modified Aug 6, 2007 by Andreas Norman
	- Added support for selectboxes with multiple attribute. Results will be posted as a comma-delimited string.
  - Added option "multiSelect" (default false)
  - Added option "multiDelimiter" (default '<br>')
		
*/

Ajax.InPlaceSelect = Class.create({
  initialize:function(element,url,options) {
    this.element = $(element);
    this.url = url;
    this.options = Object.extend({
      onChange: false,
      multiSelect: false,
      lazyLoading: false,
      values: [],
      values_url: false,
      labels: [],
      labels_url: false,
      multiDelimiter: '<br>',
      okButton: true,
      okText: "ok",
      cancelText: "cancel",
      paramName: 'selected',
      htmlOptions: {},
      highlightcolor: "#FFFF99",
      highlightendcolor: "#FFFFFF",
      onComplete: function(transport, element) {
        new Effect.Highlight(element, {startcolor: this.options.highlightcolor});
      },
      onFailure: function(transport) {
        alert("Error communicating with the server: " + transport.responseText.stripTags());
      },
      callback: function(value, text) {
        return ((this.paramName + '=' + value).toQueryParams())
      },
      savingText: "Saving...",
      savingClassName: 'inplaceselect-saving',
      clickToEditText: "Click to edit",
      cancelLink: true
    }, options || {} );

    this.options.htmlOptions = Object.extend({class: element + '-inplaceselect'}, this.options.htmlOptions);
    this.originalBackground = Element.getStyle(this.element, 'background-color');
    if (!this.originalBackground) {
      this.originalBackground = "transparent";
    }

    if (this.options.externalControl)
      this.options.externalControl = $(this.options.externalControl);
    if (!this.options.externalControl)
      this.options.externalControlOnly = false;

    this.element.title = this.options.clickToEditText;

    this.registerListeners();
  },
  registerListeners: function() {
    this._listeners = { };
    var listener;
    $H(Ajax.InPlaceSelect.Listeners).each(function(pair) {
      listener = this[pair.value].bind(this);
      this._listeners[pair.key] = listener;
      if (!this.options.externalControlOnly)
        this.element.observe(pair.key, listener);
      if (this.options.externalControl)
        this.options.externalControl.observe(pair.key, listener);
    }.bind(this));
  },
  unregisterListeners: function() {
    $H(this._listeners).each(function(pair) {
      if (!this.options.externalControlOnly)
        this.element.stopObserving(pair.key, pair.value);
      if (this.options.externalControl)
        this.options.externalControl.stopObserving(pair.key, pair.value);
    }.bind(this));
  },
  destroy: function() {
    if (this._oldInnerHTML)
      this.element.innerHTML = this._oldInnerHTML;
    this.leaveEditMode();
    this.unregisterListeners();
  },
  parseValues: function(transport) {
    this.options.values = transport.responseJSON;

    if (!this.options.labels_url)
      this.options.labels = this.options.values;

    if (this.options.labels.size() > 0)
      this.enterEditMode();
  },
  parseLabels: function(transport) {
    this.options.labels = transport.responseJSON;

    if (this.options.values.size() > 0)
      this.enterEditMode();
  },
  lazilyLoadValues: function(evt) {
    new Ajax.Request(this.options.values_url,
      {
        method: 'GET',
        evalJSON: true,
        onSuccess: this.parseValues.bind(this),
        onFailure: function() { alert("Error while communicating with server..."); }
      });

    if (this.options.labels_url)
    {
      new Ajax.Request(this.options.labels_url,
        {
          method: 'GET',
          evalJSON: true,
          onSuccess: this.parseLabels.bind(this),
          onFailure: function() { alert("Error while communicating with server..."); }
        });
    }
    if (evt) Event.stop(evt);
  },
  enterEditMode: function(evt) {
    if (this.saving) return;
    if (this.editing) return;
    if (this.options.lazyLoading && this.options.values.size() == 0 && this.options.labels.size() == 0)
    {
      this.lazilyLoadValues(evt);
      return false;
    }

    this.editing = true;
    if (this.options.externalControl)
      this.options.externalControl.hide();
    Element.hide(this.element);
    this.createControls();
    this.element.parentNode.insertBefore(this.menu, this.element);
    
    if (this.options.okButton) {
      this.element.parentNode.insertBefore(this.submitButton, this.element);
    }

    if (this.options.cancelLink) {
      this.element.parentNode.insertBefore(this.cancelButton, this.element);
    }
    if (evt) Event.stop(evt);
  },
  createControls: function() {
    var options = new Array();
    for (var i=0;i<this.options.values.length;i++)
      options[i] = Builder.node('option', {value:this.options.values[i]}, this.options.labels[i]);

    if (this.options.multiSelect) {
      this.menu = Builder.node('select', Object.extend({multiple:'multiple'}, this.options.htmlOptions), options);
    } else {
      this.menu = Builder.node('select', this.options.htmlOptions, options);
    }
  
    if (this.options.onChange) {
      this.menu.onchange = this.onChange.bind(this);
    }
		
    var value = this.element.innerHTML.replace(/\s*$/, ''); 
    if (this.options.multiSelect) {
      value = value.replace(new RegExp(this.options.multiDelimiter, "gi"), ','); 

      this.menu.selectedIndex = -1;
      var valueArray = value.split(',');
      for (var i=0;i<valueArray.length;i++) {
        var pos = this.options.labels.indexOf(valueArray[i]);

        if (pos != -1) {
          this.menu[pos].selected = true;
        }
      }
    } else {
      this.menu.selectedIndex = this.options.labels.indexOf(value);
    }
		
    if (this.options.okButton) {
     this.submitButton = Builder.node('button', this.options.okText);
     this.submitButton.onclick = this.onChange.bind(this);
     this.submitButton.className = 'editor_ok_button';
    }
    
    if (this.options.cancelLink) {
     this.cancelButton = Builder.node('a', this.options.cancelText);
     this.cancelButton.onclick = this.onCancel.bind(this);
     this.cancelButton.className = 'editor_cancel_link';
     this.cancelButton.href = '#'
    }
  },
  onCancel: function() {
    this.onComplete();
    this.leaveEditMode();
    return false;
  },
  onChange: function() {
	if (this.options.multiSelect) {
		var value = new Array();
		var text = new Array();
		var j=0;
		for (var i=0; i<this.menu.length; i++) {
			if (this.menu[i].selected) {
				value[j] = this.options.values[i];
				text[j] = this.options.labels[i];
				j++;
			}
		}
	} else {
      var value = this.options.values[this.menu.selectedIndex];
      var text = this.options.labels[this.menu.selectedIndex];
	}
    this.onLoading();
    params = this.options.callback(value, text);
    if (Object.isString(params))
      params = params.toQueryParams();
    new Ajax.Updater(
      {
        success:this.element
      }, 
      this.url, 
      Object.extend({
        parameters: params,
        onComplete: this.onComplete.bind(this),
        onFailure: this.onFailure.bind(this)
      }, this.options.ajaxOptions)
    );
  },
  onLoading: function() {
    this.saving = true;
    this.removeControls();
    this.leaveHover();
    this.showSaving();
  },
  removeControls:function() {
    if(this.menu) {
      if (this.menu.parentNode) Element.remove(this.menu);
      this.menu = null;
    }
    if (this.cancelButton) {
      if (this.cancelButton.parentNode) Element.remove(this.cancelButton);
      this.cancelButton = null;
    }
    if (this.submitButton) {
      if (this.submitButton.parentNode) Element.remove(this.submitButton);
      this.submitButton = null;
    }
  },
  showSaving:function() {
    this.oldInnerHTML = this.element.innerHTML;
    this.element.innerHTML = this.options.savingText;
    Element.addClassName(this.element, this.options.savingClassName);
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
  },
  onComplete: function() {
    this.leaveEditMode();
    //this.options.onComplete.bind(this)(transport, this.element);
  },
  onFailure: function(transport) {
    this.options.onFailure(transport);
    if (this.oldInnerHTML) {
      this.element.innerHTML = this.oldInnerHTML;
      this.oldInnerHTML = null;
    }
    return false;
  },
  enterHover: function() {
    if (this.saving) return;
    this.element.style.backgroundColor = this.options.highlightcolor;
    if (this.effect) { this.effect.cancel(); }
    Element.addClassName(this.element, this.options.hoverClassName)
  },
  leaveHover: function() {
    if (this.options.backgroundColor) {
      this.element.style.backgroundColor = this.oldBackground;
    }
    Element.removeClassName(this.element, this.options.hoverClassName)
    if (this.saving) return;
    this.effect = new Effect.Highlight(this.element, {
      startcolor: this.options.highlightcolor,
      endcolor: this.options.highlightendcolor,
      restorecolor: this.originalBackground
    });
  },
  leaveEditMode:function(transport) {
    Element.removeClassName(this.element, this.options.savingClassName);
    this.removeControls();
    this.leaveHover();
    this.element.style.backgroundColor = this.originalBackground;
    Element.show(this.element);
    if (this.options.externalControl)
      this.options.externalControl.show();
    this.editing = false;
    this.saving = false;
    this.oldInnerHTML = null;
  },
});

Object.extend(Ajax.InPlaceSelect.prototype, {
  dispose: Ajax.InPlaceSelect.prototype.destroy
});

Object.extend(Ajax.InPlaceSelect, {
  Listeners: {
    click: 'enterEditMode',
    mouseover: 'enterHover',
    mouseout: 'leaveHover'
  }
});
