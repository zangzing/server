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

        /* Click Handlers    ----------------------------------------------------------------------- */
        //join banner
        $('#join-banner #close-button').click(function() {
            $('#join-banner').fadeOut(200, function() {
                $('#page-wrapper').animate({top: 0}, 200);
                $('body').removeClass('show-join-banner');

                //create cookie that expires in 1 hour or when user quits browser
                var expires = new Date();
                expires.setTime(expires.getTime() + 60 * 60 * 1000);
                jQuery.cookie('hide_join_banner', 'true', {expires: expires});
            });
        });
        
        if($('body').hasClass('show-join-banner')){
        	ZZAt.track('join.topbanner.show');
        }

        $('#join-banner #join-button').click(function() {
        	ZZAt.track('join.topbanner.click');
            document.location.href = '/join';
        });

        $('#join-banner #signin-button').click(function() {
            document.location.href = '/signin?return_to=' + encodeURIComponent(document.location.href);
        });


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

};


}());

