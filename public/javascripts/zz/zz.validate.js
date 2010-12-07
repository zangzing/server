/* Custom validators
 --------------------------------------------------------------------------- */

jQuery.validator.addMethod(
        "regex",
        function(value, element, regexp) {
            var check = false;
            var re = new RegExp(regexp);
            return this.optional(element) || re.test(value);
        },
        "Please check your input."
);



/* Form Validation objects 
 --------------------------------------------------------------------------- */
zz.validate = {

    sign_in: {
        element: '#new_user_session',
        errorContainer: 'div#sign-in p.error-notice',
        rules: {
            'user_session[email]': { required: true, minlength: 5 },
            'user_session[password]': { required: true, minlength: 5 }
        },
        messages: {
            'user_session[email]': 'Please enter your username or email address.',
            'user_session[password]': 'Please enter your password.'
        },
        errorPlacement: function(message) {
            $('div#sign-in p.error-notice').html('Please check the highlighted field(s) below...');
        }

    },

    join: {
        element: '#join-form',
        errorContainer: 'div#sign-up p.error-notice',
        rules: {
            'user[name]':     { required: true,
                                minlength: 5 },
            'user[username]': { required: true,
                                minlength: 5,
                                regex: "^[a-z0-9]+$",
                                remote: '/users/validate_username' },
            'user[email]':    { required: true,
                                email: true,
                                remote: '/users/validate_email' },
            'user[password]': { required: true,
                                minlength: 5 }
        },
        messages: {
            'user[name]':    { required: 'Please enter your name.',
                               minlength: 'Please enter at least 5 letters'},
            'user[username]':{ required: 'A username is required.',
                               regex: 'Only lowercase alphanumeric characters allowed',
                               remote: 'username not available'},
            'user[email]':   { required: 'We promise we won&rsquo;t spam you.',
                               email: 'Is that a valid email?',
                               remote: 'Email already used'},
            'user[password]': 'Six characters or more please.'
        }
    },

//================================= Profile Form - Settings Wizard ================================

//=========================== Social Post Form - Edit/New Album Wizard ============================


//============================ Email Share Form - Edit/New Album Wizard ===========================






//    sample_sign_up: {
//        element: '#sample-sign-up',
//        rules: {
//            first_name: { required: true, minlength: 2 },
//            last_name: { required: true, minlength: 3 },
//            email: { required: true, email: true },
//            password: { required: true, minlength: 6 },
//            terms: { required: true }
//        },
//        messages: {
//            first_name: {
//                required: '',
//                minlength: ''
//            },
//            last_name: {
//                required: '',
//                minlength: ''
//            },
//            email: {
//                required: '',
//                email: ''
//            },
//            password: {
//                required: '',
//                minlength: ''
//            },
//            terms: {
//                required: ''
//            }
//        }
//
//    } // end zz.validation.sample_sign_up

}; // end zz.validation