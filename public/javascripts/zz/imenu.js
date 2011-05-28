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
    var imenuTemplate = '<div id="i-menu"class="iMenu">'+
			                            '<div class="menu-top"></div>'+
			                            '<ul>'+
				                            '<li class="download"><a href="#download">Download</a></li>'+
//				                            '<li class="privacy"><a href="#privacy">Privacy</a></li>'+
                                            '<li class="rotater"><a href="#rotater">Right 90º</a></li>'+
                                            '<li class="rotatel"><a href="#rotatel">Left 90º</a></li>'+
				                            '<li class="setcover"><a href="#setcover">Set as Cover</a></li>'+
                                            '<li class="delete"><a href="#delete">Delete</a></li>'+
			                            '</ul>'+
			                            '<div class="menu-bottom"></div>'+
	                               '</div>';

	$.extend($.fn, {
		
		iMenu: function(o, callback) {
			// Defaults
			if( o.inSpeed == undefined ) o.inSpeed = 150;
			if( o.outSpeed == undefined ) o.outSpeed = 75;

			// 0 needs to be -1 for expected results (no fade)
			if( o.inSpeed == 0 ) o.inSpeed = -1;
			if( o.outSpeed == 0 ) o.outSpeed = -1;

			// Loop each i menu
			$(this).each( function() {
				var el = $(this);
                var menu = $( imenuTemplate );
                el.append( menu );
				var offset = $(el).offset();
                
				el.click( function(e) {
                    logger.debug('click on anchor for imenu');
					var evt = e;
                    var srcElement = $(this);

    				evt.stopPropagation();
                    if( el.hasClass('disabled') ) return false;

					// Hide iMenus that may be showing
					$(".iMenu").hide();

                    // Show imenu below and center of the clicked element
                    // The toolbar is dynamic so the position of the menu relative
                    // to the toolbar is always x:-48 y:23 for a 120px menu
                    //var pos, x, y;
                    //pos = srcElement.position();
                    //x =  pos.left + srcElement.outerWidth() - $(menu).outerWidth();
                    //y =  pos.top + srcElement.outerHeight() + 5;

                    // Show the menu
                    $(document).unbind('click');
                    //menu.css({ top: y, left: x }).fadeIn(o.inSpeed);
                    menu.css({ top: 23, left: -48 }).fadeIn(o.inSpeed);

					// Hover events
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
					        $(document).unbind('click').unbind('keypress');
					        $(".iMenu").hide();
								// Callback
								if( o.callback ) o.callback( $(this).attr('href').substr(1), o.subject_type, o.subject_id );
								return false;
					});
							
					// Hide bindings
					setTimeout( function() { // Delay for Mozilla
								$(document).click( function() {
									$(document).unbind('click').unbind('keypress');
									menu.fadeOut(o.outSpeed);
									return false;
								});
					}, 0);
				});
				
				// Disable text selection
				if( $.browser.mozilla ) {
					menu.each( function() { $(this).css({ 'MozUserSelect' : 'none' }); });
				} else if( $.browser.msie ) {
					menu.each( function() { $(this).bind('selectstart.disableTextSelect', function() { return false; }); });
				} else {
					menu.each(function() { $(this).bind('mousedown.disableTextSelect', function() { return false; }); });
				}
								
			});
			return $(this);
		},
		
		// Disable i menu items on the fly
		disableIMenuItems: function(o) {
			if( o == undefined ) {
				// Disable all
				$(this).find('LI').addClass('disabled');
				return( $(this) );
			}
			$(this).each( function() {
				if( o != undefined ) {
					var d = o.split(',');
					for( var i = 0; i < d.length; i++ ) {
						$(this).find('A[href="' + d[i] + '"]').parent().addClass('disabled');
						
					}
				}
			});
			return( $(this) );
		},
		
		// Enable i menu items on the fly
		enableIMenuItems: function(o) {
			if( o == undefined ) {
				// Enable all
				$(this).find('LI.disabled').removeClass('disabled');
				return( $(this) );
			}
			$(this).each( function() {
				if( o != undefined ) {
					var d = o.split(',');
					for( var i = 0; i < d.length; i++ ) {
						$(this).find('A[href="' + d[i] + '"]').parent().removeClass('disabled');
						
					}
				}
			});
			return( $(this) );
		},
		
		// Disable i menu(s)
		disableIMenu: function() {
			$(this).each( function() {
				$(this).addClass('disabled');
			});
			return( $(this) );
		},
		
		// Enable i menu(s)
		enableIMenu: function() {
			$(this).each( function() {
				$(this).removeClass('disabled');
			});
			return( $(this) );
		},
		
		// Destroy i menu(s)
		destroyIMenu: function() {
			// Destroy specified i menus
			$(this).each( function() {
				// Disable action
				$(this).unbind('mousedown').unbind('mouseup');
			});
			return( $(this) );
		}
		
	});
})(jQuery);