//
// 2011 Copyright, ZangZing LLC  All Rights Reserved, http://www.zangzing.com
//
if(jQuery)( function() {

    $.widget("ui.zz_menu",{
        options:{
            subject_id       : '',          // This and other user defined options are passed to the click events
            subject_type     : '',          // This and other user defined options are passed to the click events
            auto_open        : false,       // open after creation
            bind_click_open  : false,       // bind open to the elements click.
            style            : 'dropdown',  // 'dropdown', 'popup' or 'auto'. 'auto' requires a container to decide
            animation_length : 200,         // How far long is the animation
            animation_y      : 10,          // How far is the opening animation
            menu_template    : '',          // The menu structure, a ul with li's that contain an a
            append_to_element: false,       // Append the html to the el or to the end of <body> (relevant for zzindex)
            container        : null,        // A jquery element used to decide if popup or dropdown see _compute_style
            beforeopen       : $.noop,      // Beforeopen event listener (before starting opening sequence)
            open             : $.noop,      // Open event listener (after menu is already opened and visible)
            close            : $.noop,      // Close event listener (after menu is closed, cleaned up and not visible)
            // the default click listener (an example of how to handle menu clicks
            click            : function(event, data) {
                                    alert(   'Action: ' + data.action + '\n\n' +
                                             'Subject Type: ' + data.options.subject_type + '\n\n' +
                                             'Subject ID: ' + data.options.subject_id + '\n\n');
            }
        },

        _create: function() {
            var self = this,
                    el   = self.element,
                    o    = self.options;
            
            // if  o.bind_click_open option is set, bind open to the el's click
            if( self.options.bind_click_open ){
                el.click( function(e) {
                    e.stopPropagation();
                    self.open();
                });
            }

            // If auto open, open.
            if( o.auto_open){
                self.open();
            }
        },

        _build_and_wire_menu: function(){
            var self = this,
                    el   = self.element,
                    o    = self.options;
            //Create and insert html
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

            // Disable text selection for menu items
            if( $.browser.mozilla ) {
                menu.each( function() { $(this).css({ 'MozUserSelect' : 'none' }); });
            } else if( $.browser.msie ) {
                menu.each( function() { $(this).bind('selectstart.disableTextSelect', function(){ return false; }); });
            } else {
                menu.each(function() { $(this).bind('mousedown.disableTextSelect', function(){ return false; }); });
            }

            // bind hover events for menu items
            menu.find('A').mouseover( function() {
                menu.find('LI.hover').removeClass('hover');
                $(this).parent().addClass('hover');
            }).mouseout( function() {
                menu.find('LI.hover').removeClass('hover');
            });

            // bind click for menu items
            menu.find('LI:not(.disabled) A').click( function() {
                self.close();
                var action = $(this).attr('href').substr(1);
                self._trigger('click', null, {'action':action, 'options': o});
                return false; //Stop the click from bubbling up
            });

            //Set a flag if menu has no items to avoid displaying empty menus
            self.zero_menu_items =  menu.find('li').length <= 0;
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
                        //logger.debug('Menu bottom:'+menu_butt+'> Container Bottom:'+container_butt+' then style is:'+self.computed_style);
                    }else{
                        self.computed_style = 'dropdown';
                        //logger.debug('Menu bottom:'+menu_butt+'< Container Bottom:'+container_butt+' then style is:'+self.computed_style);
                    }
                }else{
                    self.computed_style = 'dropdown';
                    //logger.debug('Menu: container not defined, defaulting to dropdown' );
                }
            }

            // add style components to menu
            if( self.computed_style == 'dropdown' ){
                menu.find('#menu-top').removeClass('flattop').addClass('arrowtop');
                menu.find('#menu-bottom').removeClass('arrowbottom').addClass('flatbottom');
            }else{
                menu.find('#menu-top').removeClass('arrowtop').addClass('flattop');
                menu.find('#menu-bottom').removeClass('flatbottom').addClass('arrowbottom')
            }
        },


        open: function(){
            var self = this,
                    menu = self.menu,
                    el   = self.element,
                    o    = self.options;

            if( _.isUndefined( self.menu )){
                self._build_and_wire_menu();
                menu = self.menu;
            }

            if( self.zero_menu_items ){
                return;
            }

            if(menu.is(':hidden') && el.not(':disabled') ){

                if(self._trigger('beforeopen') === false) return; //If any listeners return false, then do not open

                self._compute_style();

                // Hide other zz_menus that may be showing,excluding this instance
                $(":ui-zz_menu").not(el).each(function(){
                    $(this).zz_menu("close");
                });

                // calculate position
                var x,y,offset;
                if( o.append_to_element){
                    //Use this when appending the element to an anchor element
                    x = -( (menu.width()/2) - (el.outerWidth()/2));
                    y = el.height();
                }else{
                    //Use this when appending the element to the end of the document
                    offset = $(el).offset();
                    x = offset.left+ ( $(el).outerWidth()/2 )  - (menu.width()/2);
                    if( self.computed_style == 'dropdown' ){
                        y = offset.top + el.height();
                    }else{
                        y = $(document).height() - offset.top;
                    }
                }

                // Keep the menu open while hovering from element to menu but not back
                // and to close menu when user hovers out of menu and/or element
                var hover = false;
                var mouse_in = function(){
                    //logger.debug( 'menu mousein');
                    hover = true;
                }
                var mouse_out= function(){
                    //logger.debug( 'menu mouseout');
                    hover = false;
                    setTimeout( function(){ if(!hover){ self.close();}},200);
                };
                $(document).unbind('click');
                el.bind('mouseleave.zz_menu', mouse_out );
                menu.bind('mouseenter.zz_menu', mouse_in);

                // Show the menu and bind mouseleave for menu
                if( self.computed_style == 'dropdown' ){
                    // Show zz_menu below and center of el, after animation is done bind hoverOut to close
                    menu.css({display:'block',opacity:0,left:x,top:y-o.animation_y });
                    menu.animate({top:y,opacity:1}, o.animation_length,
                            function(){menu.bind('mouseleave.zz_menu', mouse_out );});
                } else {
                    // Show zz_menu above and center of el, after animation is done bind hoverOut to close
                    el.bind('mouseleave.zz_menu', mouse_out );
                    menu.css({display:'block',opacity:0,left:x,bottom:y-o.animation_y});
                    menu.bind('mouseenter.zz_menu', mouse_in).bind('mouseleave.zz_menu', mouse_out );
                    menu.animate({bottom:y,opacity:1},o.animation_length,
                            function(){menu.bind('mouseleave.zz_menu', mouse_out );});
                }

                // Bind Keyboard clicks
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
                $(window).one('resize',function() {  self.close()  });
                self._trigger('open');
            }else{
                return false;
            }
        },

        close: function(){
            var self=this;
            if( !_.isUndefined( self.menu ) ){
                if( self.menu.not(':hidden') ){
                    $(document).unbind('click.zz_menu');
                    $(document).unbind('keypress.zz_menu');
                    self.menu.unbind('mouseenter.zz_menu').unbind('mouseleave.zz_menu');
                    self.element.unbind('mouseleave.zz_menu');
                    self.menu.fadeOut(self.options.animation_length);
                }
            }
            self._trigger('close');
        },


//        // Disable i menu items on the fly
//        disable_menu_items: function(items) {
//            var menu = this.menu;
//            if( items == undefined ) {
//                // Disable all
//                menu.find('LI').addClass('disabled');
//            } else {
//                var d = items.split(',');
//                for( var i = 0; i < d.length; i++ ) {
//                    menu.find('A[href="' + d[i] + '"]').parent().addClass('disabled');
//                }
//            }
//            return( menu );
//
//        },
//
//        // Enable i menu items on the fly
//        enable_menu_items: function(items) {
//            var menu = this.menu;
//            if( items == undefined ) {
//                // Enable all
//                menu.find('LI.disabled').removeClass('disabled');
//            } else {
//                var d = items.split(',');
//                for( var i = 0; i < d.length; i++ ) {
//                    menu.find('A[href="' + d[i] + '"]').parent().removeClass('disabled');
//                }
//            }
//            return( menu );
//        },
//
//        disable: function(){
//            this.menu.addClass('disabled');
//        },
//
//        enable: function(){
//            this.menu.removeClass('disabled');
//        },

        destroy: function(){
            this.element.unbind('click');
            this.menu.remove();
            $.Widget.prototype.destroy.apply( this, arguments );
        }

    });
})(jQuery);