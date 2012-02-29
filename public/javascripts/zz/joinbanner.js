/*!
 * zz.joinbanner.js
 * 
 * Functions dealing with joinbanner logic.
 * Copyright 2012, ZangZing LLC. All rights reserved.
 */


var zz = zz || {};


(function(){
	zz.joinbanner = zz.joinbanner || {};
	
	// Public functions
	zz.joinbanner.should_show_banner = should_show_banner;
	zz.joinbanner.setup_banner = setup_banner;
    zz.joinbanner.on_show_banner = on_show_banner;

    var element = null;

    function setup_banner(){
        element = $(banner_html());
        return element;
    }

    function on_show_banner(){
    	var validator;
    	
    	zz.image_utils.pre_load_image(join_picture(), function(image) {
    		var css = zz.image_utils.scale_center_and_crop(image, {width: 48, height: 48});
            element.find("img.profile-photo").css(css);
    	});

    	if(zz.invitation.invitername){
    		element.find("#follow_user_id").remove();
    	}
    	
    	element.find('.join-form li label').inFieldLabels();
    	
    	element.find('form input').focus(function (object) { $(object.target).css("border", "1px solid orange"); });
    	element.find('form input').focusout(function (object) { $(object.target).css("border", "1px solid #666"); });
    	
    	validator = zz.joinform.add_validation( element.find('.join-form') );
    	
    	element.find('.join-form .submit-button').click(function(){
            zz.joinform.submit_form($('#header-join-banner .join-form'), validator, "join.toolbarbanner");
        });

        element.find('.join-form').bind('keypress', function(e){
            if ( e.keyCode == 13 ) {
                zz.joinform.submit_form($('#header-join-banner .join-form'), validator, "join.toolbarbanner");
            }
        });

        ZZAt.track("join.toolbarbanner.show");

    }


    // This goes inside of #header-join-banner
    function banner_html(){
		    html = '<div class="picture"><div class="container"><div class="mask"><img src="'+ join_picture() +'" class="profile-photo"/></div><img class="bottom-shadow" src="/images/photo/bottom-full.png"/></div></div>' +
		    		'<div class="header">'+join_message()+'</div>' +    
		            '<div class="feature">' +
		                '<form class="join-form" enctype="multipart/form-data">' +
		                '<input type="hidden" name="follow_user_id" id="follow_user_id" value="'+ zz.page.displayed_user_id +'" />' + 
		                '<ul>' +
		                '<li><label for="user_email">Email address</label><input type="text" name="user[email]" id="user_email" value="" /></li>' +
		                '<li><label for="user_password">Password</label><input type="password" name="user[password]" id="user_password" value="" maxlength="40" /></li>' +
		                '<li><a class="submit-button newgreen-button" rel="nofollow"><span>Join for Free</span></a></li>' +
		                '</ul>' +
		                '</form>' +
		            '</div>';
    	return html;
    	
    }
    

	function join_message(){
		var message;
		if(zz.invitation.invitername) {
			message = "<strong>" + zz.invitation.invitername + "</strong> has invited you to ZangZing. Join now and you each get 250MB of extra space free.";
		} else if(zz.page.displayed_user_name){
			message = "<strong>" + zz.page.displayed_user_name + "</strong> is using ZangZing. Join for free to share your favorite photos.";
		} else {
			message = "ZangZing is a free and easy photo sharing service.";
		}
		return message;
	}
    
    function join_picture(){
    	var img;
    	if(zz.invitation.inviterprofileurl){
    		img = zz.invitation.inviterprofileurl;
    	} else if(zz.page.displayed_user_pic_url != null && zz.page.displayed_user_pic_url != "/images/profile-default-55.png"){
    		img = zz.page.displayed_user_pic_url;
    	} else {
    		img = "http://downloads.zangzing.com/images/join_default.jpg";
    	}
    	return img;
    }
    
    // Returns true/false for whether a banner should be shown at all, ie. user is signed in
    function should_show_banner() {
    	// Not currently using: $.cookie('hide_join_banner') == "true";	
    	return zz.session.current_user_id == null && 
    		!( zz.page.rails_controller_name == 'users' && zz.page.rails_action_name == 'join' );
    }
    

    


    
}());
