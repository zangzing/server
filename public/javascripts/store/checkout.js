var zz = zz || {};
zz.store = zz.store || {};

zz.store.checkout = {};

(function(){

    //add validatore to jquery validate
    jQuery.validator.addMethod("phoneUS", function(phone_number, element) {
        phone_number = phone_number.replace(/\s+/g, "");
        return this.optional(element) || phone_number.length > 9 &&
            phone_number.match(/^(1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/);
    }, "Please specify a valid phone number");

    jQuery.validator.addMethod("postalcode", function(postalcode, element) {
	    return this.optional(element) || postalcode
                .match(/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXYabceghjklmnpstvxy]{1}\d{1}[A-Za-z]{1} ?\d{1}[A-Za-z]{1}\d{1})$/);
        }, "Please specify a valid postal/zip code");

    jQuery.validator.addMethod(
        'regex',
        function(value, element, regexp) {
            var check = false;
            var re = new RegExp(regexp);
            return this.optional(element) || re.test(value);
        }, 'Please check your input.'  );

    //used to place and display form errors as you tab around
    var error_placement_handler = function(error, element) {
        var location, left, top;

        //Insert, position and hide error message
        location = element;
        top    = -40;
        left   = (location.outerWidth()/2)-100;
        error.insertAfter( location );
        error.css({
            top:  0,
            left: 0,
            opacity: 0,
            'z-index': -1
        });

        // Set the distance for the error animation
        // Calculate starting/end  position
        var distance = 3;
        var end    = top;
        var start =  top - distance;

        element.focus(function(){
            // Animate the error message
            error.css({
                opacity: 0,
                top: start,
                left: left+'px',
                'z-index': 100
            }).animate({
                    top: end,
                    opacity: 1
                }, 'fast');
        });

        element.blur(function(){
            error.css({
                top:  0,
                left: 0,
                opacity: 0,
                'z-index': -1
            });

        });
    };
//======================= ship_address =========================
    zz.store.checkout.init_ship_address_screen = function(){
         $('form p.field label').inFieldLabels();
         $('#checkout_form_ship_address').validate({
            //debug: true,
            rules: {
                'order[ship_address_attributes][phone]':{
                    required:true,
                    phoneUS: true
                },
                'order[ship_address_attributes][zipcode]':{
                    required:true,
                    postalcode: true
                }
                
            },
            messages: {
                'order[ship_address_attributes][phone]': {
                    required: 'a phone number required by most shippers',
                    phoneUS: 'is that a US phone?'
                },
                'order[ship_address_attributes][zipcode]':{
                    required: ' your zip is really important!',
                    postalcode: 'huh? is that a zip?'
                }
            },
            submitHandler: function(form){
                form.submit();
            },
            errorElement: "div",
            errorClass: "errormsg",
            errorPlacement: error_placement_handler
        });
    }




//======================= payment =========================
    zz.store.checkout.init_payment_screen = function(){
        $('form p.field label').inFieldLabels();

        $("input[name='order[creditcard_id]']").click(function(){
            $('#creditcard :input').attr('disabled', true);
            $('#creditcard').css('opacity',0.5);
        });

        $('#order_bill_address_id').change(function(){
            if( $(this).val() == '' ){
                $('#billing :input').attr('disabled', false);
                $('#billing').removeClass("lightgray");
            }else{
                $('#billing :input').attr('disabled', true);
                $('#billing').addClass("lightgray");
            }
        });

        var clear_wallet_radio = function(element){
            $('input[name*=creditcard_id]:checked').each(function(){
                $(this).attr('checked','');
            });
        };

        // ckear credit card fields when wallet is selected
        $('input[name*=creditcard_id]').click( function(){
            $("#card_number").val('').removeClass('errormsg').trigger('blur');
            $("#card_code").val('').removeClass('errormsg').trigger('blur');
        });

        // clear radio button when crdit card fields are used
        $("#card_number").keypress(clear_wallet_radio);
        $("#card_code").keypress(clear_wallet_radio);

        
        $('#checkout_form_payment').validate({
            //debug: true,
            rules: {
                'payment_source[1034433118][number]':{
                    required: function(element){
                        return $('input[name*=creditcard_id]:checked').length <=0;
                    },
                    creditcard: true
                },
                'payment_source[1034433118][verification_value]':{
                    required: function(element){
                        return $('input[name*=creditcard_id]:checked').length <=0;
                    },
                    number: true,
                    minlength: 3,
                    maxlength: 4
                },
                'order[bill_address_attributes][phone]':{
                    required:true,
                    phoneUS: true
                },
                'order[email]': {
                    required: true,
                    email: true
                },
                'order[bill_address_attributes][zipcode]':{
                    required:true,
                    postalcode: true
                }
            },
            messages: {
                'order[email]': {
                    required: 'promise we won&rsquo;t spam you',
                    email: 'valid email, please'
                },
                'payment_source[1034433118][verification_value]':{
                    required:'Need help?, click the question mark',
                    number: 'Need help?, click the question mark',
                    minlength: 'Need help?, click the question mark'
                },
                'order[bill_address_attributes][zipcode]':{
                                    required: ' your zip is really important!',
                                    postalcode: 'huh? is that a zip?'
                 }
            },
            submitHandler: function(form){
                form.submit();
            },
            errorElement: "div",
            errorClass: "errormsg",
            errorPlacement: error_placement_handler
        });
    };
    //======================= thankyou =========================
    zz.store.checkout.init_thankyou_screen = function(){
        $('form p.field label').inFieldLabels();

        $('form').bind('keypress', function(e){
            if ( e.keyCode == 13 ) {
                $("form").submit();
            }
        });
        $('#user_username').keyup(function(event){
            var username = $('#user_username').val();
            //set the value in the homepage url
            $('#blue_username').text(username);
            $('#username_display').fadeIn('fast');

        });

        $('#join_form').validate({
        rules: {
                'user[username]': {
                    required: true,
                    minlength: 1,
                    maxlength:25,
                    //regex: "(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",
                    remote: zz.routes.path_prefix + '/users/validate_username'
                },
                'user[password]': {
                    required: true,
                    minlength: 5
                }
            },
            messages: {
                'user[username]':{
                    required: 'please enter a username',
                    regex: 'only lower case letters and numbers',
                    remote: 'username already taken'
                },
                'user[password]': '6 characters or more, please'
            },
            submitHandler: function(form){
                form.submit();
            },
            errorElement: "div",
            errorClass: "errormsg",
            errorPlacement: error_placement_handler
        });

    };
})();