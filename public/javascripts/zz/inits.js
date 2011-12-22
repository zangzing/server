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

    	var should_hide_banner = (zz.session.current_user_id != null) || $.cookie('hide_join_banner') == "true";  
    	
    	if(!should_hide_banner) {
            $('#article').prepend('<div id="article-join-banner"></div>');
            $("#article-join-banner").html(banner_html());
            setup_banner();    		
    	}


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
    
    
    // Private:

    function banner_html(){
    return  '<div class="logo"></div>' +
            '<div class="feature">' +
                '<form method="post" class="join-form" enctype="multipart/form-data" action="foo">' +
                '<div class="field"><label for="user_name">First &amp; Last Name</label><input type="text" name="user[name]" id="user_name" value="" /></div>' +
                '<div class="field"><label for="user_username">Username</label><input type="text" name="user[username]" id="user_username" value="" /></div>' +
                '<div class="field"><label for="user_email">Email address</label><input type="text" name="user[email]" id="user_email" value="" /></div>' +
                '<div class="field"><label for="user_password">Password</label><input type="password" name="user[password]" id="user_password" value="" maxlength="40" /></div>' +
                '<button type="submit" id="signup" class="big shiny default">Join for Free</button>' +
                '</form>' +
            '</div>'
            ;

    }
    
    function setup_banner(){
    	$('.field label').inFieldLabels();
    	
    	$('#article-join-banner .join-form').first().attr("action", 'https://'+document.domain+zz.routes.users.create_user_url());
	
    	zz.login.add_validation( $('#article-join-banner .join-form') );
    	
    	$('#article-join-banner .join-form').submit(function(){
    		//zz.login.on_form_submit('TODO-STRING'); // TODO: something like homepage.join.click
    	});
    }
   


}());



