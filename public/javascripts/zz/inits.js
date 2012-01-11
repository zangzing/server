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

    	if(should_show_banner()) { 
    		var is_photos_page = zz.page.album_id != null; // Use this as a hack to determine whether there is .photogrid 		
            
    		$('#header').after('<div id="header-join-banner"></div>');
            
            if( !is_photos_page ){
            	$("#article").prepend('<div class="join-banner-spacer"></div>');	
            }
          
            $("#header-join-banner").html(banner_html());
            
    		setup_banner();
    		if(banner_resize() == 1){
    			// Showing banner
        		ZZAt.track("join.toolbarbanner.show");	
    		}
    		
            $(window).resize(function(event) {
            	banner_resize();
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
    
    
    // Private -------------------------------------------------------------------------------------------

    function setup_banner(){
    	$('.join-form li label').inFieldLabels();
    	
    	$('#header-join-banner .join-form').first().attr("action", 'https://'+document.domain+zz.routes.users.create_user_url());
	
    	zz.login.add_validation( $('#header-join-banner .join-form') );
    	
    	$('#header-join-banner .join-form').submit(function(){
    		ZZAt.track("join.toolbarbanner.click");
    	});        
    }
    
    // This goes inside of #header-join-banner
    function banner_html(){
		    html = '<div class="picture"><span><img src="'+ join_picture() +'"></img></span></div>' +
		    		'<div class="header">'+join_message()+'</div>' +    
		            '<div class="feature">' +
		                '<form method="post" class="join-form" enctype="multipart/form-data" action="foo">' +
		                '<input type="hidden" name="follow_user_id" id="follow_user_id" value="'+ zz.page.displayed_user_id +'" />' + 
		                '<ul>' +
		                '<li><label for="user_name">First &amp; Last Name</label><input type="text" name="user[name]" id="user_name" value="" /></li>' +
		                '<li><label for="user_username">Username</label><input type="text" name="user[username]" id="user_username" value="" /></li>' +
		                '<li><label for="user_email">Email address</label><input type="text" name="user[email]" id="user_email" value="" /></li>' +
		                '<li><label for="user_password">Password</label><input type="password" name="user[password]" id="user_password" value="" maxlength="40" /></li>' +
		                '<li><button type="submit" id="signup">Join for Free</button></li>' +
		                '</ul>' +
		                '</form>' +
		            '</div>'
		     ;
    	return html;
    	
    }

	function join_message(){
		var message;
		if(zz.page.displayed_user_name){
			message = "<strong>" + zz.page.displayed_user_name + "</strong> is using ZangZing. Join for free and follow " + zz.page.displayed_user_name + ".";
		} else {
			message = "ZangZing is a free and easy photo sharing service.";
		}
		return message;
	}
    
    function join_picture(){
    	var img = "/images/zangzing-logo-black.png"; // TODO: change default
    	if(zz.page.displayed_user_pic_url != null && zz.page.displayed_user_pic_url != "/images/profile-default-55.png"){
    		img = zz.page.displayed_user_pic_url;
    	}
    	return img;
    }
    
    // Returns true/false for whether a banner should be shown at all, ie. user is signed in
    function should_show_banner() {
    	// Not currently using: $.cookie('hide_join_banner') == "true";	
    	return zz.session.current_user_id == null;
    }
    
    // Returns true/false for whether the large banner will fit current window width
    function should_show_large_banner(){
    	return $(window).width() > 866; // 846px + 20px;
    }
    
    function banner_resize(){
    	if(should_show_large_banner()){ 
    		$("#header-join-banner").removeClass("none");
    		$(".join-banner-spacer").removeClass("none");
    		return 1;
    	} else {
    		$("#header-join-banner").addClass("none");
    		$(".join-banner-spacer").addClass("none");
    		return 0;
    	}
    }
    

}());
