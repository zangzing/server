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
    	
        $("#header-join-banner").html(banner_html());
    	
    	zz.image_utils.pre_load_image(join_picture(), function(image) {
    		var css = zz.image_utils.scale_center_and_crop(image, {width: 48, height: 48});
    		$("#header-join-banner .picture div img.profile-photo").css(css);
    	});
    	
    	$('.join-form li label').inFieldLabels();
    	
    	$('#header-join-banner form input').focus(function (object) { $(object.target).css("border", "1px solid orange"); });
    	$('#header-join-banner form input').focusout(function (object) { $(object.target).css("border", "1px solid #666"); });
    	
    	$('#header-join-banner .join-form').first().attr("action", 'https://'+document.domain+zz.routes.users.create_user_url());
	
    	validator = zz.joinform.add_validation( $('#header-join-banner .join-form') );
    	
    	$('#header-join-banner .join-form .submit-button').click(function(){
    		submit_form(validator);
        });

        element.find('.join-form').bind('keypress', function(e){
            if ( e.keyCode == 13 ) {
            	submit_form(validator);
            }
        });

    }


    // This goes inside of #header-join-banner
    function banner_html(){
		    html = '<div class="picture"><div class="container"><div class="mask"><img src="'+ join_picture() +'" class="profile-photo"/></div><img class="bottom-shadow" src="/images/photo/bottom-full.png"/></div></div>' +
		    		'<div class="header">'+join_message()+'</div>' +    
		            '<div class="feature">' +
		                '<form method="post" class="join-form" enctype="multipart/form-data" action="foo">' +
		                '<input type="hidden" name="follow_user_id" id="follow_user_id" value="'+ zz.page.displayed_user_id +'" />' + 
		                '<ul>' +
		                '<li><label for="user_name">First &amp; Last Name</label><input type="text" name="user[name]" id="user_name" value="" /></li>' +
		                '<li><label for="user_username">Username</label><input type="text" name="user[username]" id="user_username" value="" /></li>' +
		                '<li><label for="user_email">Email address</label><input type="text" name="user[email]" id="user_email" value="" /></li>' +
		                '<li><label for="user_password">Password</label><input type="password" name="user[password]" id="user_password" value="" maxlength="40" /></li>' +
		                '<li><a class="submit-button newgreen-button" rel="nofollow"><span>Join for Free</span></a></li>' +
		                '</ul>' +
		                '</form>' +
		            '</div>';
    	return html;
    	
    }
    

    function empty_message_html(){
    	return '<label for="user_name" generated="true" class="error">Please enter your info and click join.</label>';
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
    	var img = "http://downloads.zangzing.com/images/join_default.jpg";
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
    

    

    function submit_form(validator){
    	var num_fields_nonempty = 0;
		num_fields_nonempty =
			($('#header-join-banner #user_name').val().length != 0) +
			($('#header-join-banner #user_username').val().length != 0) +
			($('#header-join-banner #user_email').val().length != 0) +
			($('#header-join-banner #user_password').val().length != 0);
		
    	if(num_fields_nonempty == 0){
    		validator.resetForm();
    		$(".join-form ul li").first().append(empty_message_html());
    		$('#header-join-banner #user_name').addClass("error");
    		
    		ZZAt.track("join.toolbarbanner.click");
    		ZZAt.track("join.toolbarbanner.invalid", {
				Zjoin_num_fields_nonempty: 0,
				Zjoin_num_fields_valid: 0,
				Zjoin_bit_fields: 0
			});
    	} else if($('#header-join-banner .join-form').valid()){
        	$('#header-join-banner .join-form').submit();
    		ZZAt.track("join.toolbarbanner.click");
    		ZZAt.track("join.toolbarbanner.click.valid");
    	} else {
    		var num_fields_valid = 0;
    		var bit_notation = 0;

    		bit_notation = 
    			1 * $('#header-join-banner #user_name').valid() +
    			2 * ($('#header-join-banner #user_name').val().length != 0) + 
    			4 * $('#header-join-banner #user_username').valid() +
    			8 * ($('#header-join-banner #user_username').val().length != 0) + 		
    			16 * $('#header-join-banner #user_email').valid() +
    			32 * ($('#header-join-banner #user_email').val().length != 0) + 		
    			64 * $('#header-join-banner #user_password').valid() +
    			128 * ($('#header-join-banner #user_password').val().length != 0);			

    		num_fields_valid = 
    			$('#header-join-banner #user_name').valid() + 
    			$('#header-join-banner #user_username').valid() + 
    			$('#header-join-banner #user_email').valid() + 
    			$('#header-join-banner #user_password').valid();
    		
    			ZZAt.track("join.toolbarbanner.click");
    			ZZAt.track("join.toolbarbanner.invalid", {
    				Zjoin_num_fields_nonempty: num_fields_nonempty,
    				Zjoin_num_fields_valid: num_fields_valid,
    				Zjoin_bit_fields: bit_notation
    			});
    	}
    }
    
}());
