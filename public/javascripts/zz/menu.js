//
//
// Inspiration drawn from jQuery Context Menu Plugin by Cory S.N. LaViska
//
//
if(jQuery)( function() {

    $.widget("ui.zz_menu",{
        options:{
            subject_id      : '',
            subject_type     : '',
            auto_open       : false,  //open upon creation
            bind_click_open : false,  //bind open to the elements click.
            click        : function(event, data) {
                                               var opts = $(this).data().zz_menu.options;
					                           alert(   'Action: ' + data.action + '\n\n' +
                                                        'Subject Type: ' + data.options.subject_type + '\n\n' +
						                                'Subject ID: ' + data.options.subject_id + '\n\n');
                                               },
            style       : 'dropdown',
            animation_length: 200,
            animation_y     : 10,
            menu_template   : '',
            append_to_element: false,
            container       : null
        },

        _create: function() {
            var self = this,
                el   = self.element,
                o    = self.options;

            var menu = $('<div class="zz_menu">')
                    .append('<div id="menu-top">')
                    .append( o.menu_template )
                    .append('<div id="menu-bottom"></div>');
            self.menu = menu;
            if(o.append_to_element){
                el.append( menu );
            }else{
                $('body').append(menu);
            }


            // Disable text selection
            if( $.browser.mozilla ) {
                menu.each( function() { $(this).css({ 'MozUserSelect' : 'none' }); });
            } else if( $.browser.msie ) {
                menu.each( function() { $(this).bind('selectstart.disableTextSelect', function() { return false; }); });
            } else {
                menu.each(function() { $(this).bind('mousedown.disableTextSelect', function() { return false; }); });
            }

            // bind hover events
            menu.find('A').mouseover( function() {
                menu.find('LI.hover').removeClass('hover');
                $(this).parent().addClass('hover');
            }).mouseout( function() {
                menu.find('LI.hover').removeClass('hover');
            });


             // When items are selected
            //menu.find('A').unbind('click');
            menu.find('LI:not(.disabled) A').click( function() {
                self.close();
                var action = $(this).attr('href').substr(1);
                self._trigger('click', null, {'action':action, 'options': o});
                return false; //Stop the click from bubbling up
            });

            // if the anchor option is set, bind to the elements click
            if( self.options.bind_click_open ){
                el.click( function(e) {
                    e.stopPropagation();
                    self.open();
                });
            }

            //Set a flag if menu has no items
            self.zero_menu_items =  menu.find('li').length <= 0;

            // If auto open, open.
            if( o.auto_open){
                self.open();
            }
        },

        _compute_style: function(){
            var self=this,
                    o = self.options,
                    el = self.element,
                    menu = self.menu;

            self.computed_style = o.style;
            if( o.style == 'auto'){
                if( o.container != null ){
                    // menu_butt is not the bottom property
                    var menu_butt = el.offset().top + el.outerHeight() + menu.height(),
                            container_butt = o.container.offset().top + o.container.innerHeight()-10;
                    if( menu_butt > container_butt ){
                        self.computed_style= 'popup';
                        logger.debug('Menu bottom:'+menu_butt+'> Container Bottom:'+container_butt+' then style is:'+self.computed_style);
                    }else{
                        self.computed_style = 'dropdown';
                        logger.debug('Menu bottom:'+menu_butt+'< Container Bottom:'+container_butt+' then style is:'+self.computed_style);
                    }
                }else{
                    self.computed_style = 'dropdown';
                    logger.debug('Menu: container not defined, defaulting to dropdown' );
                }
            }

            // Style Menu
            if( self.computed_style == 'dropdown' ){
                menu.find('#menu-top').removeClass('flattop').addClass('arrowtop');
                menu.find('#menu-bottom').removeClass('arrowbottom').addClass('flatbottom');
            }else{
                menu.find('#menu-top').removeClass('arrowtop').addClass('flattop');
                menu.find('#menu-bottom').removeClass('flatbottom').addClass('arrowbottom')
            }
        },


        open: function(){
            //logger.debug('open zz_menu');
            var self = this,
                el   = self.element,
                menu = self.menu,
                o    = self.options;
            if( self.zero_menu_items ){
                logger.debug('attempt to display menu with zero elements');
                return;
            }

            if(menu.is(':hidden') && el.not(':disabled') ){

                if(self._trigger('beforeopen') === false) return; //If any listeners return false, then do not open

                self._compute_style();

                // Hide other zz_menus that may be showing,excluding this instance
                $(":ui-zz_menu").not(el).each(function(){
                    $(this).zz_menu("close");
                });
                //var x = offset.left+ ( $(el).outerWidth()/2 ) +  - (menu.width()/2);
                //var y = offset.top - $(el).outerHeight();

                //var  x = el.position().left +(menu.width()/2) - (el.width()/2);
                //var  y = el.position().top -el.height()+10;

                //var x = el.offset().left + (el.width() / 2) - (menu.width() / 2);
                //var y = el.offset().top - menu.height();

                var x,y,offset;
                if( o.append_to_element){
                     //Use this when appending the element to an anchor element
                    x = -( (menu.width()/2) - (el.outerWidth()/2));
                    y = el.height();
                }else{
                    //Use this when appending the element to the end of the document
                    offset = $(el).offset();
                    y = $(document).height() - offset.top;
                    x = offset.left+ ( $(el).outerWidth()/2 )  - (menu.width()/2);
                }

                // These are used to keep toolbar menu open when bound to element
                // and to close menu when user hovers out
                var hover = true;
                var mouse_in = function(){
                    logger.debug( 'menu mousein');
                    hover = true;
                }
                var mouse_out= function(){
                    logger.debug( 'menu mouseout');
                    hover = false;
                    setTimeout( function(){ if(!hover){ self.close();}},200);
                };


                //logger.debug('x:'+x+',y:'+y);
                // Show the menu
                $(document).unbind('click');
                if( self.computed_style == 'dropdown' ){
                    if( !o.append_to_element ){
                        y = offset.top + el.height();
                    }
                    // Show zz_menu below and center of the clicked element after animation is done bind hoverOut to close
                    menu.css({display:'block',opacity:0,left:x,top:y-o.animation_y });
                    menu.animate({top:y,opacity:1}, o.animation_length, function(){
                        menu.bind('mouseenter.zz_menu', mouse_in).bind('mouseleave.zz_menu', mouse_out );
                        el.bind('mouseenter.zz_menu', mouse_in).bind('mouseleave.zz_menu', mouse_out );
                    });
                } else {
                    // Show zz_menu above and center of the clicked element after animation is done bind hoverOut to close
                    menu.css({display:'block',opacity:0,left:x,bottom:y-o.animation_y});
                    menu.animate({bottom:y,opacity:1},o.animation_length, function(){
                            menu.bind('mouseenter.zz_menu', mouse_in).bind('mouseleave.zz_menu', mouse_out );
                            el.bind('mouseenter.zz_menu', mouse_in).bind('mouseleave.zz_menu', mouse_out );
                    });
                }

                // Bind Keyboard
                $(document).bind('keypress.zz_menu', function(e) {
                    e.stopPropagation();
                    switch( e.keyCode ) {
                        case 38: // up
                            if( menu.find('LI.hover').size() == 0 ) {
                                menu.find('LI:last').addClass('hover');
                            } else {
                                menu.find('LI.hover').removeClass('hover').prevAll('LI:not(.disabled)').eq(0).addClass('hover');
                                if( menu.find('LI.hover').size() == 0 ) menu.find('LI:last').addClass('hover');
                            }
                            break;
                        case 40: // down
                            if( menu.find('LI.hover').size() == 0 ) {
                                menu.find('LI:first').addClass('hover');
                            } else {
                                menu.find('LI.hover').removeClass('hover').nextAll('LI:not(.disabled)').eq(0).addClass('hover');
                                if( menu.find('LI.hover').size() == 0 ) menu.find('LI:first').addClass('hover');
                            }
                            break;
                        case 13: // enter
                            menu.find('LI.hover A').trigger('click');
                            break;
                        case 27: // esc
                            $(document).trigger('click');
                            break
                    }

                });

                // Close menu if anybody clicks anywhere outside menu
                setTimeout( function() { // Delay for Mozilla
                    $(document).bind( 'click.zz_menu', function(e){
                        $(document).unbind( e );
                        self.close();
                        e.stopPropagation();
                    });
                }, 0);

                //If the window resizes close menu (its bottom positioned so it will look out of place if not removed)
                //$(window).one('resize',function() {  self.close()  });
                self._trigger('open');
            }else{
             return false;
            }
        },

        close: function(){
            var self=this;
            if( self.menu.not(':hidden') ){
                $(document).unbind('click.zz_menu');
                $(document).unbind('keypress.zz_menu');
                self.menu.unbind('mouseenter.zz_menu').unbind('mouseleave.zz_menu');
                self.element.unbind('mouseenter.zz_menu').unbind('mouseleave.zz_menu');
                self.menu.fadeOut(self.options.animation_length);
            }
            self._trigger('close');
        },

        // Disable i menu items on the fly
        disable_menu_items: function(items) {
            var menu = this.menu;
            if( items == undefined ) {
                // Disable all
                menu.find('LI').addClass('disabled');
            } else {
                var d = items.split(',');
                for( var i = 0; i < d.length; i++ ) {
                    menu.find('A[href="' + d[i] + '"]').parent().addClass('disabled');
                }
            }
            return( menu );

        },

        // Enable i menu items on the fly
        enable_menu_items: function(items) {
            var menu = this.menu;
            if( items == undefined ) {
                // Enable all
                menu.find('LI.disabled').removeClass('disabled');
            } else {
                var d = items.split(',');
                for( var i = 0; i < d.length; i++ ) {
                    menu.find('A[href="' + d[i] + '"]').parent().removeClass('disabled');
                }
            }
            return( menu );
        },

		disable: function(){
				this.menu.addClass('disabled');
		},

		enable: function(){
				this.menu.removeClass('disabled');
		},

		destroy: function(){
				this.element.unbind('click');
                this.menu.remove();
                $.Widget.prototype.destroy.apply( this, arguments );
		}

    });
})(jQuery);