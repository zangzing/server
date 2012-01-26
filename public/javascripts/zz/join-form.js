var zz = zz || {};


(function(){
	zz.joinform = zz.joinform || {};
    zz.joinform.add_validation = add_validation;

	// takes a jquery element
    function add_validation(element) {
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
                },
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
                'user[name]' : {
                    required : 'Please enter your name.',
                    minlength : 'Please enter your name.'
                },
                'user[username]' : {
                    required : 'Please enter a username.',
                    regex : 'Only letters and numbers.',
                    remote : 'This username is already taken.'
                },
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

})();
