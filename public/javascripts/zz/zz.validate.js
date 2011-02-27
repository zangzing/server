/*!
 * zz.validate.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

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
                                minlength: 1,
                                maxlength:25,
                                regex: "(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",
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
    }

}; // end zz.validation