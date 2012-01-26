/*!
 * zz.inits.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};

(function(){
    $(document).ajaxSend(function(event, request, settings) {
        settings.data = settings.data || '';
        settings.data += (settings.data ? '&' : '') + 'authenticity_token=' + encodeURIComponent(zz.page.rails_authenticity_token);
        request.setRequestHeader('X-CSRF-Token', zz.page.rails_authenticity_token);
    });
    

    
    zz.init = {
    		
     template: function() {

    	if(zz.joinbanner.should_show_banner()) { 
    		var is_photos_page = (zz.page.album_id != null) && (zz.page.rails_controller_name == 'photos'); // Use this as a hack to determine whether there will be .photogrid 		
            
    		$('#header').after('<div id="header-join-banner"></div>');
            
            if( !is_photos_page ){
            	$("#article").prepend('<div class="join-banner-spacer"></div>');	
            }

            
    		zz.joinbanner.setup_banner();
    		
    		zz.joinbanner.banner_refresh();
    		
            $(window).resize(function(event) {
            	zz.joinbanner.banner_refresh();
            });
  		
    	}

        //system message banner
        $('#system-message-banner #close-button').click(function() {
            $('#system-message-banner').fadeOut(200, function() {
                $('#page-wrapper').animate({top: 0}, 200);
                $('body').removeClass('show-join-banner');
                jQuery.cookie('hide_system_message_banner', 'true');
            });
        });

        zz.toolbars.init();

        // todo:should this move into zz.toolbars.init() ?
        zz.profile_pictures.init_profile_pictures($('.profile-picture'));

        zz.mobile.lock_page_scroll();

        setTimeout(function() {
            zz.init.preload_rollover_images();
        }, 500);

    },

    preload_rollover_images: function() {

        //wizard buttons/tabs
        for (var i = 1; i <= 6; i++) {
            var src = '/images/wiz-num-' + i + '-on.png';
            zz.image_utils.pre_load_image(zz.routes.image_url(src));

            var src = '/images/wiz-num-' + i + '.png';
            zz.image_utils.pre_load_image(zz.routes.image_url(src));
        }
    }

    }; // zz.init
    

}());