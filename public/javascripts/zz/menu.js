// 
// derived and inspired from jQuery Context Menu Plugin
// Version 1.01 by Cory S.N. LaViska
// A Beautiful Site (http://abeautifulsite.net/)
// More info: http://abeautifulsite.net/2008/09/jquery-context-menu-plugin/
// Terms of Use
// This plugin is dual-licensed under the GNU General Public License
// and the MIT License and is copyright A Beautiful Site, LLC.
//
if(jQuery)( function() {

    $.widget("ui.zz_menu",{
        options:{
            subject_id      : '',
            subjet_type     : '',
            auto_open       : false,  //open upon creation
            bind_click_open : false,  //bind open to the elements click.
            callback        : function(action, subject_id, subject_type) {
					                           alert(   'Action: ' + action + '\n\n' +
                                                        'Subject Type: ' + subject_type + '\n\n' +
						                                'Subject ID: ' + subject_id + '\n\n');
                                               },
            direction       : 'up',
            animation_lenght: 200,
            animation_y     : 10,
            menu_template   : '<ul>'+
                                '<li class="download"><a href="#download">Download</a></li>'+
//	                            '<li class="privacy"><a href="#privacy">Privacy</a></li>'+
                                '<li class="rotater"><a href="#rotater">Right</a></li>'+
                                '<li class="rotatel"><a href="#rotatel">Left</a></li>'+
                                '<li class="setcover"><a href="#setcover">Set as Cover</a></li>'+
                                '<li class="delete"><a href="#delete">Delete</a></li>'+
                             '</ul>'
        },

        _create: function() {
            var self = this,
                el   = self.element,
                o    = self.options;

            var menu = $('<div class="zz_menu">')
                    .append('<div id="menu-top">')
                    .append( o.menu_template )
                    .append('<div id="menu-bottom"></div>');
            //$('body').append(menu);
            el.append( menu );
            self.menu = menu;

            // Style Menu
            if( o.direction == 'down' ){
                menu.find('#menu-top').addClass('arrowtop');
                menu.find('#menu-bottom').addClass('flatbottom');
            }else{
                menu.find('#menu-top').addClass('flattop');
                menu.find('#menu-bottom').addClass('arrowbottom')
            }

            // Disable text selection
            if( $.browser.mozilla ) {
                menu.each( function() { $(this).css({ 'MozUserSelect' : 'none' }); });
            } else if( $.browser.msie ) {
                menu.each( function() { $(this).bind('selectstart.disableTextSelect', function() { return false; }); });
            } else {
                menu.each(function() { $(this).bind('mousedown.disableTextSelect', function() { return false; }); });
            }

            // if the anchor option is set, bind to the elements click
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

        open: function(){
            logger.debug('open zz_menu');
            var self = this,
                el   = self.element,
                menu = self.menu,
                o    = self.options;

            if( el.hasClass('disabled') ) return false;

            // Hide other zz_menus that may be showing
            $(".zz_menu").hide();

            //var x = offset.left+ ( $(el).outerWidth()/2 ) +  - (menu.width()/2);
            //var y = offset.top - $(el).outerHeight();

            //var  x = el.position().left +(menu.width()/2) - (el.width()/2);
            //var  y = el.position().top -el.height()+10;

            //var x = el.offset().left + (el.width() / 2) - (menu.width() / 2);
            //var y = el.offset().top - menu.height();

            //Use this when appending the element to the end of the document
            //var offset = $(el).offset();
            //var y, x = offset.left+ ( $(el).outerWidth()/2 )  - (menu.width()/2);
            // down       y = offset.top + el.height()+10;
            //  up        y = $(document).height() - offset.top+10;

            //Use this when appending the element to an anchor element
            var  x = -( (menu.width()/2) - (el.width()/2));
            var  y = el.height()+12;

            logger.debug('x:'+x+',y:'+y);
            // Show the menu
            $(document).unbind('click');
            if( o.direction == 'down' ){
                // Show zz_menu below and center of the clicked element
                menu.css({display:'block',opacity:0,left:-x,top:y-o.animation_y });
                menu.animate({top:y,opacity:1}, o.animation_lenght, self._bind_hover);
            } else {
                // Show zz_menu above and center of the clicked element
                menu.css({display:'block',opacity:0,left:x,bottom:y-o.animation_y});
                menu.animate({bottom:y,opacity:1},o.animation_lenght, self._bind_hover);
            }

            // bind hover events
            menu.find('A').mouseover( function() {
                menu.find('LI.hover').removeClass('hover');
                $(this).parent().addClass('hover');
            }).mouseout( function() {
                menu.find('LI.hover').removeClass('hover');
            });

            // Keyboard
            $(document).keypress( function(e) {
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

            // When items are selected
            menu.find('A').unbind('click');
            menu.find('LI:not(.disabled) A').click( function() {
                self.close();
                var action = $(this).attr('href').substr(1);
                // Callbacks
                if( o[action+'_action'] == undefined){
                    if( o.callback ) o.callback( $(this).attr('href').substr(1), o.subject_type, o.subject_id );
                } else{
                    o[action+'_action']( o.subject_type, o.subject_id );
                }
                return false;
            });

            // Close menu if anybody clicks anywhere outside menu
            setTimeout( function() { // Delay for Mozilla
                $(document).click( function() {
                    self.close();
                    return false;
                });
            }, 0);

            //Close menu when mouse hovers out of the menu or clicks
            menu.hover(function(){},function(){ self.close() });
            
            //If the window resizes close menu (its bottom positioned so it will look out of place if not removed)
            $(window).one('resize',function() {  $(menu).css('display','none');  });
        },

        close: function(){
            var self=this;
            $(document).unbind('click').unbind('keypress');
            self.menu.fadeOut(self.options.animation_length);
        },

        _bind_hover: function(){
            //Close menu when mouse hovers out of the menu or clicks
            $(this).hover(function(){},function(){ self.close() });
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
		}
    });
})(jQuery);