var zz = zz || {};


(function(){
	zz.joinform = zz.joinform || {};
    zz.joinform.add_validation = add_validation;
    zz.joinform.add_profile_validation = add_profile_validation;
    zz.joinform.submit_form = submit_form;

	// takes a jquery element
    function add_validation(element) {
        add_regex_validator();

        return element.validate( {
            rules : {
                'user[email]' : {
                    required : true,
                    email : true,
                    remote : zz.routes.path_prefix + '/users/validate_email'
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

    // takes a jquery element
    function add_profile_validation(element) {
        add_regex_validator();

        return element.validate( {
            rules : {
                'user[name]' : {
                    required : true,
                    minlength : 1
                },
                'user[username]' : {
                    required : true,
                    minlength : 1,
                    maxlength : 25,
                    regex : "(^[a-zA-Z0-9]+$|^[a-zA-Z0-9]+:.{8}$)",
                    remote : zz.routes.path_prefix + '/users/validate_username'
                }
            },
            messages : {
                'user[name]' : {
                    required : 'Please enter your name.',
                    minlength : 'Please enter your name.'
                },
                'user[username]' : {
                    required : 'Please enter a username.',
                    regex : 'Only letters and numbers.',
                    remote : 'This username is already taken.'
                }
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
            // name and username no longer in this form
            //(form_element.find('#user_name').val().length != 0) +
            //(form_element.find('#user_username').val().length != 0) +
			(form_element.find('#user_email').val().length != 0) +
			(form_element.find('#user_password').val().length != 0);
		
//    	if(num_fields_nonempty == 0){
//            validator.resetForm();
//    		form_element.find('ul li').first().append(empty_message_html());
//    		form_element.find('#user_name').addClass("error");
//
//    		ZZAt.track(zza_string+".click");
//    		ZZAt.track(zza_string+".invalid", {
//				Zjoin_num_fields_nonempty: 0,
//				Zjoin_num_fields_valid: 0,
//				Zjoin_bit_fields: 0
//			});
//    	} else
        if(form_element.valid()){
            submit_data(form_element);
    		ZZAt.track(zza_string+".click");
    		ZZAt.track(zza_string+".click.valid");
    	} else {
    		var num_fields_valid = 0;
    		var bit_notation = 0;

    		bit_notation =
                // name and username no longer in this form
    			//1 * form_element.find('#user_name').valid() +
    			//2 * (form_element.find('#user_name').val().length != 0) +
    			//4 * form_element.find('#user_username').valid() +
    			//8 * (form_element.find('#user_username').val().length != 0) +
    			16 * form_element.find('#user_email').valid() +
    			32 * (form_element.find('#user_email').val().length != 0) +
    			64 * form_element.find('#user_password').valid() +
    			128 * (form_element.find('#user_password').val().length != 0);

    		num_fields_valid = 
    			//$('#header-join-banner #user_name').valid() +
    			//$('#header-join-banner #user_username').valid() +
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

    function empty_message_html(){
        return '<label for="user_name" generated="true" class="error">Please enter your info and click join.</label>';
    }

    function submit_data(form_element){
        var login_url = "/zz_api/login_or_create"; // TODO: try to keep it self-contained
        var finish_profile_url = "/finish_profile";

        var email, password, email_pw_hash;

        email = form_element.find('#user_email').val();
        password = form_element.find('#user_password').val();
        email_pw_hash = {email: email, password: password, create: true};

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
                    alert(response.message[0]); // TODO: change this to real message
                } catch (e) {
                    // TODO: generic error goes here
                    console.debug('error in parsing');
                    return false;
                }

            } // error
        });


    }

})();
