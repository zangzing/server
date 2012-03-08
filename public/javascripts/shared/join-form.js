/**

 Use: Shared join page logic across homepage, blog, invitations, join page, and joinbanner.
 Author: Bowen Li

 Copyright 2012, ZangZing LLC. All rights reserved.

 **/

var zz = zz || {};


(function(){
	zz.joinform = zz.joinform || {};
    zz.joinform.add_validation = add_validation;
    zz.joinform.submit_form = submit_form;
    zz.joinform.add_regex_validator = add_regex_validator;

	// takes a jquery element
    function add_validation(element) {
        add_regex_validator();

        return element.validate( {
            rules : {
                'user[email]' : {
                    required : true,
                    email : true,
                    remote : '/service/users/validate_email'
                },
                'user[password]' : {
                    required : true,
                    minlength : 6
                }
            },
            messages : {
                'user[email]' : {
                    required : 'Please enter your email.',
                    email : 'Please type a valid email.',
                    remote : 'This email already has an account.'
                },
                'user[password]' : 'Password must be at least 6 characters.'
            }
        });
    }

    // add regex to validator if it doesn't exist
    function add_regex_validator() {
        if(!jQuery.validator.methods.regex){
            jQuery.validator.addMethod("regex", function(value, element, regexp) {
                var check = false;
                var re = new RegExp(regexp);
                return this.optional(element) || re.test(value);
            }, "Please check your input.");
        }
    }
    
    // takes a jquery element that is both the form and contains the fields
    // this function does the checking for the form and passes to submit_data if fields validate
    function submit_form(form_element, validator, zza_string){
        var num_fields_nonempty = 0;
		num_fields_nonempty =
			(form_element.find('#user_email').val().length != 0) +
			(form_element.find('#user_password').val().length != 0);
		
        if(form_element.valid()){
            submit_data(form_element);
    		ZZAt.track(zza_string+".click");
    		ZZAt.track(zza_string+".click.valid");
    	} else {
    		var num_fields_valid = 0;
    		var bit_notation = 0;

    		bit_notation =
                // Starts at 16 for backwards compat with when name and username were in the same form
    			16 * form_element.find('#user_email').valid() +
    			32 * (form_element.find('#user_email').val().length != 0) +
    			64 * form_element.find('#user_password').valid() +
    			128 * (form_element.find('#user_password').val().length != 0);

    		num_fields_valid = 
                form_element.find('#user_email').valid() +
                form_element.find('#user_password').valid();
    		
    			ZZAt.track(zza_string+".click");
    			ZZAt.track(zza_string+".invalid", {
    				Zjoin_num_fields_nonempty: num_fields_nonempty,
    				Zjoin_num_fields_valid: num_fields_valid,
    				Zjoin_bit_fields: bit_notation
    			});
    	}
    	
    } // submit_form

    function submit_data(form_element){
        var login_url = "https://"+ document.location.host +"/zz_api/login_or_create";
        var finish_profile_url = "/finish_profile";
        var join_url = "/join";

        var email, password, email_pw_hash;

        email = form_element.find('#user_email').val();
        password = form_element.find('#user_password').val();
        email_pw_hash = {email: email, password: password, create: true};

        // Current page is https
        // Call API directly
        if (location.protocol === 'https:'){
            $.ajax({
                url: login_url,
                type: 'POST',
                data: email_pw_hash,
                success: function(data){
                    console.debug(JSON.stringify(data));
                    window.location = finish_profile_url;
                }, // success
                error:function(jqXHR, textStatus, errorThrown){
                    var response = null;

                    try {
                        response = JSON.parse(jqXHR.responseText);
                        console.debug('parsing worked');
                        console.debug(JSON.stringify(response));
                        alert(response.message); // TODO: change this to real message
                    } catch (e) {
                        // TODO: generic error goes here
                        console.debug('error in parsing');
                        return false;
                    }

                } // error
            });
        }

        // Current page is not https
        // use JSONP
        else {
            $.jsonp({
                url: login_url,
                callback: "_jsonp_callback",
                callbackParameter: "_jsonp_callback",
                cache: false,
                pageCache: false,
                data: email_pw_hash,
                success: function(response) {
                    console.debug(response);

                    if(response._jsonp_error){
                        var err = response._jsonp_error;
                        alert(err.message);
                    } else if (response.user_credentials != null) {
                        console.debug("success");
                        window.r = response;
                        window.location = finish_profile_url;
                    } else { // Some unexpected error. Fallback to join page
                        window.location = join_url;
                    }
                },
                error: function() { // Should never get here unless we timeout.
                    console.debug(response);
                    alert("Couldn't log you in.\nPlease check your email/password and try again.");
                }
            });
        }
    }

})();
