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

    	// If we aren't hiding join banner, add it to the page      	
    	if(!should_hide_banner()) { 
    		var large_banner = $(window).width() > 800;
    		
    		var is_photos_page = zz.page.album_id != null; // Use this as a hack to proxy whether there is .photogrid
    		
            $('#header').after('<div id="header-join-banner"></div>');
            
            if( !is_photos_page ){
            	$("#article").prepend('<div class="spacer"></div>');	
            }
          
            $("#header-join-banner").html(banner_html(large_banner));
            
    		if(large_banner) {
    			setup_banner();
    		} else {
    			setup_small_banner();
    		}
    		
            $(window).resize(function(event) {
            	// TODO: 
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

    };0
    
    
    // Private:

    function setup_banner(){
    	
    	// Show Banner
    	
    	// Add padding to article so we don't block elements
    	//$("#article").addClass("joinshift");
    	
    	$('.join-form li label').inFieldLabels();
    	
    	$('#header-join-banner .join-form').first().attr("action", 'https://'+document.domain+zz.routes.users.create_user_url());
	
    	zz.login.add_validation( $('#header-join-banner .join-form') );
    	
    	$('#header-join-banner .join-form').submit(function(){
    		//zz.login.on_form_submit('TODO-STRING'); // TODO: something like homepage.join.click
    	});
        
    }
    
    function setup_small_banner(){
    	
    }
    
    
    
    // This goes inside of #header-join-banner
    function banner_html(isLarge){
    	var html = "";
    	if(isLarge){
		    html = '<div class="picture"><span><img src="'+ join_picture() +'"></img></span></div>' +
		    		'<div class="header">'+join_message(isLarge)+'</div>' +    
		            '<div class="feature">' +
		                '<form method="post" class="join-form" enctype="multipart/form-data" action="foo">' +
		                '<ul>' +
		                '<li><label for="user_name">First &amp; Last Name</label><input type="text" name="user[name]" id="user_name" value="" /></li>' +
		                '<li><label for="user_username">Username</label><input type="text" name="user[username]" id="user_username" value="" /></li>' +
		                '<li><label for="user_email">Email address</label><input type="text" name="user[email]" id="user_email" value="" /></li>' +
		                '<li><label for="user_password">Password</label><input type="password" name="user[password]" id="user_password" value="" maxlength="40" /></li>' +
		                '<li><button type="submit" id="signup" class="big shiny default">Join for Free</button></li>' +
		                '</ul>' +
		                '</form>' +
		            '</div>'
		            ;
    	} else  {
    		// else return small banner	
    	}
    	
    	return html;
    	
    }
    
    function join_message(isLarge){
    	var message;
    	
    	if(isLarge){
    		if(zz.page.displayed_user_name){
        		message = "<strong>" + zz.page.displayed_user_name + "</strong> is using ZangZing. Join for free and follow " + zz.page.displayed_user_name + ".";
        	} else {
        		message = "ZangZing is a free and easy photo sharing service.";
        	}
    	} else {
    		
    	}
    	
    	return message;
    }
    
    function join_picture(){
    	var img = "/images/zangzing-logo-black.png"; // TODO: change default
    	if(zz.page.displayed_user_pic_url != "/images/profile-default-55.png"){
    		img = zz.page.displayed_user_pic_url;
    	}
    	return img;
    }
    
    function should_hide_banner() {
    	// Not currently using: $.cookie('hide_join_banner') == "true";	
    	return (zz.session.current_user_id != null)
    }

}());



