/*!
 * zz.login.js
 * 
 * Functions dealing with login logic.
 * Things in this file should be agnostic to specific elements
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */


var zz = zz || {};


(function(){
	zz.login = zz.login || {};
	zz.login.add_validation = add_validation;

	
	// Private ----------------------------------------------------
	
	// takes a jquery element
	function add_validation(element) {
		add_regex_validator();
		
		element.validate( {
			rules : {
				'user[name]' : {
					required : true,
					minlength : 1
				},
				'user[username]' : {
					required : true,
					minlength : 1,
					maxlength : 25,
					regex : "(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",
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
					required : 'please enter your name',
					minlength : 'please enter your name'
				},
				'user[username]' : {
					required : 'please enter a username',
					regex : 'only lower case letters and numbers',
					remote : 'username already taken'
				},
				'user[email]' : {
					required : 'promise we won&rsquo;t spam you',
					email : 'valid email, please',
					remote : 'email already taken'
				},
				'user[password]' : '6 characters or more, please'
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


}());