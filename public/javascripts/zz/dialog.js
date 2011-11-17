var zz = zz || {};


zz.dialog = {

    show_square_dialog: function(content, options) {
        var scrim_element = $(zz.dialog.SQUARE_TEMPLATE);
        scrim_element.appendTo($('body'));

        var dialog_element = scrim_element.find('.square-dialog');
        dialog_element.css({width: options.width, height: options.height});
        dialog_element.find('.content').html($(content));
        dialog_element.click(function(event){
            event.stopPropagation();
        });



        var close = function(){
            if(options.on_close){
                options.on_close();
            }

            scrim_element.fadeOut('fast', function(){
                scrim_element.remove();
            });
        };


        var close_button = dialog_element.find('.close-button');
        close_button.click(function(){
            close();
        });


        scrim_element.click(function(){
            close();
        });


        dialog_element.center(scrim_element, true, true);


        return {
            element: dialog_element,
            close: close
        };
    },


    show_dialog: function(element, options) {
        return $(element).zz_dialog(options).data().zz_dialog;
    },



    show_confirmation_dialog: function(message, on_ok, on_cancel) {

    },

    show_alert_dialog: function(message, on_ok) {

    },

    show_flash_dialog: function(message) {
        var content = $("<div id='flash-dialog'><div><div id='flash'></div><a id='ok' class='newgreen-button'><span>OK</span></a></div></div>");
        content.find('#flash').text(message);

        var dialog = zz.dialog.show_dialog(content, {cancelButton: false});

        content.find('#ok').click(function() {
           dialog.close();
        });
    },


    show_spinner_progress_dialog: function(message) {
        var template = '<span class="progress-dialog-content"><div id="dspin_here"></div>' + message + '</span>';
        var dialog = zz.dialog.show_dialog(template, { width: 300, height: 90, modal: true, autoOpen: true, cancelButton: false });
        new Spinner({ lines: 12,
                          length: 6,
                          width: 3,
                          radius: 6,
                          color: '#333',
                          speed: 1,
                          trail: 40, // Afterglow percentage
                          shadow: false
                      }).spin( document.getElementById('dspin_here'));
        return dialog;
    },

    show_progress_dialog: function(message) {
        var template = '<span class="progress-dialog-content"><img src="/images/loading.gif">' + message + '</span>';
        var dialog = zz.dialog.show_dialog(template, { width: 300, height: 90, modal: true, autoOpen: true, cancelButton: false });
        return dialog;
    },


    CONFIRMATION_TEMPLATE: '<div class="message">{{message}}</div>',
    ALERT_TEMPLATE: '<div class="message">{{message}}</div>',
    BASE_Z_INDEX: 99990,
    open_dialog_count: 0,


    SQUARE_TEMPLATE:'<div class="square-dialog-scrim">' +
                        '<div class="square-dialog">' +
                            '<div class="tl-corner"></div>' +
                            '<div class="tr-corner"></div>' +
                            '<div class="br-corner"></div>' +
                            '<div class="bl-corner"></div>' +
                            '<div class="t-side"></div>' +
                            '<div class="b-side"></div>' +
                            '<div class="r-side"></div>' +
                            '<div class="l-side"></div>' +
                            '<div class="content"></div>' +
                            '<div class="close-button"></div>' +
                        '</div>' +
                     '</div>',




    scrim_z_index: function() {
        return this.BASE_Z_INDEX + this.open_dialog_count * 10;
    },

    dialog_z_index: function() {
        return this.scrim_z_index() + 1;
    }

};



(function($, undefined) {

    $.widget('ui.zz_dialog', {
        options: {
            modal: true,
            cancelButton: true,
            top: 'auto',
            left: 'auto',
            autoOpen: true,
            height: 'auto',
            width: 'auto'
        },

        _create: function() {
            var self = this;
            var element = this.element;

            //Check if element is already in DOM, if not, insert it at end of body.
            if (element.parent().parent().size() <= 0) {
                element.css('display', 'none');
                $('body').append(element);
            }

            //wrap element with 2 divs for inner and outer borders
            element.wrap('<div class="zz_dialog"><div class="zz_dialog_inner"></div><a href="javascript:void(0)" class="zz_dialog_closer"></a></div>');

            // set element to visible to be able to control visibility
            element.css('display', 'block');
            // set display to inherit to be able to control visibility
            element.css('border', 0);
            element.css('margin', 0);


            //Set the element to the top dialog div and save it in the instance
            self.dialogDiv = element.parent().parent();
            self.dialogDiv.data('originalelement', self.element);


            //Insert and activate the dialog closer
            if (self.options.cancelButton) {
                self.dialogDiv.find('.zz_dialog_closer').show().click(function() {
                    self.close();
                });
            }


            //Set size and create a resize handler to be used when the dialog is shown
            self._setSize();
            self.resize_handler = function() {
                self._setPosition();
            };
            self.keypress_handler = function(event) {
                event.stopPropagation();
            };

            //create scrim for modal insert it the end of the body
            if (self.options.modal) {
                self.scrim = $('<div class="zz_dialog_scrim"></div>');
                self.scrim.insertBefore(self.dialogDiv);
            }
        },

        _init: function() {
            if (this.options.autoOpen) this.open();
        },

        open: function() {
            var self = this;

            zz.dialog.open_dialog_count++;


            if (self._trigger('beforeopen') === false) return; //If any listeners return false, then do not open

//            //close all other open dialogs
//            $("div.zz_dialog").not(self.dialogDiv).each(function(){
//                $(this).data("originalelement").zz_dialog("close");
//            });

            //calculate dialog position
            self._setPosition();

            // set window resize handler
            $(window).resize(self.resize_handler);
            if (self.options.modal) {
                self.scrim.css({'z-index': zz.dialog.scrim_z_index()});
                self.scrim.show();
                $(window).keypress(self.keypress_handler);
            }

            self.dialogDiv.css({'z-index': zz.dialog.dialog_z_index()});
            self.dialogDiv.fadeIn('fast');
            self._trigger('open');
        },


        close: function() {
            if (this._trigger('beforeclose') === false) return; //If any listeners return false, then do not close
            this.dialogDiv.fadeOut('fast');
            if (this.options.modal) $(this.scrim).hide();
            $(window).unbind('resize', this.resize_handler);
            $(document).unbind('keypress', this.keypress_handler);
            this._trigger('close');
            this.destroy();
            zz.dialog.open_dialog_count--;
        },

        toggle: function() {
            var self = this;
            if (self.dialogDiv.css('display') == 'none') {
                self.open();
            } else {
                self.close();
            }
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
            if (this.options.modal) {
                this.scrim.remove();
            }
            this.dialogDiv.empty().remove();
        },

        _setSize: function() {
            var self = this;
            var o = self.options;

            if (o.height == 'auto') {
                var height = $(self.element).outerHeight(true);
                self.dialogDiv.css('height', height);
            } else {
                self.dialogDiv.css('height', o.height);
            }

            if (o.width == 'auto') {
                var width = $(self.element).outerWidth(true);
                self.dialogDiv.css('width', width);
            } else {
                self.dialogDiv.css('width', o.width);
            }
        },

        _setPosition: function() {
            if (this.options.top == 'auto') {
                var top = ($(window).height() / 2) - (this.dialogDiv.height() / 2);
                this.dialogDiv.css('top', top);
            } else {
                this.dialogDiv.css('top', this.options.top);
            }

            if (this.options.left == 'auto') {
                var left = ($(window).width() / 2) - (this.dialogDiv.width() / 2);
                this.dialogDiv.css('left', left);
            } else {
                this.dialogDiv.css('left', this.options.left);
            }
        }

    });

})(jQuery);

