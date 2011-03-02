//
// Copyright 2011 ZangZing LLC
//
(function( $, undefined ) {

    $.widget("ui.zz_dialog", {
        options: {
            modal:         true,
            cancelButton:  true,
            top:          'auto',
            left:         'auto',
            autoOpen:      true,
            height:       'auto',
            width:        'auto'
        },

        _create: function() {
            var self = this;
            var element = this.element;

            //Check if element is already in DOM, if not, insert it at end of body.
            if( element.parent().parent().size() <= 0 ){
               element.css('display','none');
               $('body').append(element);
            }

            //wrap element with 2 divs for inner and outer borders
            element.wrap('<div class="zz_dialog"><div id="zz_dialog_inner"></div></div>');

            // set element to visible to be able to control visibility
            element.css('display','block');
            // set display to inherit to be able to control visibility
            element.css('border', 0);
            element.css('margin',0);

            //Insert and activate the dialog closer
            if( self.options.cancelButton ){
                element.before('<a href="javascript:void(0)" class="zz_dialog_closer"></a>');
                $('.zz_dialog_closer').click( function(){ self.close()} );
            }

            //Set the element to the top dialog div and save it in the instance
            self.dialogDiv = element.parent().parent();
            self.dialogDiv.data( 'originalelement', self.element );
            
            //Set size and create a resize handler to be used when the dialog is shown
            self._setSize();
            self.resizeHandler = function(){ self._setPosition(); };


            //create scrim for modal insert it the end of the body
            if(self.options.modal){
                self.dialogDiv.css('z-index', 99999);
                $('body').append( '<div class="zz_dialog_scrim"></div>' );
                self.scrim = $('body').find(".zz_dialog_scrim");
            }
        },

        _init: function(){
            if(this.options.autoOpen) this.open();
        },

        open: function() {
            var self = this;
            if(self._trigger('beforeopen') === false) return; //If any listeners return false, then do not open

            //close all other open dialogs
            $("div.zz_dialog").not(self.dialogDiv).each(function(){
                $(this).data("originalelement").zz_dialog("close");
            });

            //calculate dialog position
            self._setPosition();

            // set window resize handler
            $(window).resize(  self.resizeHandler );
            if(self.options.modal) $(self.scrim).show();
            self.dialogDiv.fadeIn('fast');
            self._trigger('open');
        },


        close: function() {
            if(this._trigger('beforeclose') === false) return; //If any listeners return false, then do not close
            this.dialogDiv.fadeOut('fast');
            if(this.options.modal) $(this.scrim).hide();
            $(window).unbind( 'resize', this.resizeHandler );
            this._trigger('close');
        },

        toggle: function(){
            var self = this;
            if(self.dialogDiv.css('display') == 'none'){
                self.open();
            } else {
                self.close();
            }
        },

        destroy: function() {
          $.Widget.prototype.destroy.apply(this, arguments);
          if(this.options.modal){
                this.scrim.remove();
          }
          this.dialogDiv.empty().remove();
        },

        _setSize: function() {
            var self = this;
            var o = self.options;

            if( o.height == 'auto'){
                var height = $(self.element).outerHeight( true );
                self.dialogDiv.css('height', height);
            } else {
                self.dialogDiv.css('height', o.height)
            }

            if( o.width == 'auto'){
                var width = $(self.element).outerWidth( true );
                self.dialogDiv.css('width', width);
            } else {
                self.dialogDiv.css('width', o.width)
            }
        },

        _setPosition: function(){
            if( this.options.top == 'auto'){
                var top  = ( $(window).height()/2 ) - (this.dialogDiv.height() / 2);
                this.dialogDiv.css('top', top);
            }else{
                this.dialogDiv.css('top', this.options.top);
            }

            if( this.options.left == 'auto'){
                var left = ( $(window).width()/2  ) - (this.dialogDiv.width() / 2);
                this.dialogDiv.css('left', left);
            }else{
                this.dialogDiv.css('left', this.options.left);
            }
        }

    });

})( jQuery );
