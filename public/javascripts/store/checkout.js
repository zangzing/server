var zz = zz || {};
zz.store = zz.store || {};

zz.store.checkout = {};

(function(){

    //add phone validator to jquery validate
    jQuery.validator.addMethod("phoneUS", function(phone_number, element) {
        phone_number = phone_number.replace(/\s+/g, "");
        return this.optional(element) || phone_number.length > 9 &&
            phone_number.match(/^(1-?)?(\([2-9]\d{2}\)|[2-9]\d{2})-?[2-9]\d{2}-?\d{4}$/);
    }, "Please specify a valid phone number");

    // add zip code validatore
    jQuery.validator.addMethod("postalcode", function(postalcode, element) {
	    return this.optional(element) || postalcode
                .match(/(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXYabceghjklmnpstvxy]{1}\d{1}[A-Za-z]{1} ?\d{1}[A-Za-z]{1}\d{1})$/);
        }, "Please specify a valid postal/zip code");

    // add regex validator
    jQuery.validator.addMethod(
        'regex',
        function(value, element, regexp) {
            var check = false;
            var re = new RegExp(regexp);
            return this.optional(element) || re.test(value);
        }, 'Please check your input.'  );

    //used to send focus to first errored-out field
    var invalid_handler = function(form, validator) {
        var errors = validator.numberOfInvalids();
        if (errors) {
            validator.errorList[0].element.focus(); //Set Focus
        }
    }


    //used to place and display form errors as you tab around
    var error_placement_handler = function(error, element) {
        $(element).data('error', $(error).text() );
         if( typeof( $('element').data('popover') ) == 'undefined' ){
            $(element).popover({
                trigger: 'focus',
                placement: 'above',
                offset: 5,
                animate:false,
                content: function(){ return $(element).data('error'); }
            });
        } else {
            $(element).popover('enable')
                 .popover('hide')
                .popover('setContent')
                .popover('show');
        }
    };
    var highlighter = function(element, errorClass){
         $(element).addClass( errorClass );
         $(element).popover('setContent')
             .popover('enable');

    };
    var unhighlighter = function( element, errorClass, validClass ){
        $(element).removeClass(errorClass);//.popover('disable');
    };
    var success_handler = function( label ){
                var input_id = $(label).attr('for');
                $('#'+input_id).popover('hide').
                    popover('disable');
    };
//======================= ship_address =========================
    zz.store.checkout.init_ship_address_screen = function(){
         $('form p.field label').inFieldLabels();

         // need to expose this so that we can clear after address is picked from dropdown.
         // todo: this should be refactored. dependend code is all over the place. it should all be here
         //       in this init function
         zz.store.checkout.validator = $('#checkout_form_ship_address').validate({
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
                    required: 'A phone number is required by most shippers',
                    phoneUS: 'Is that a US/Canada phone?'
                },
                'order[ship_address_attributes][zipcode]':{
                    required: 'Your zip code is really important!',
                    postalcode: 'huh? is that a zip?'
                }
            },
            submitHandler: function(form){
                form.submit();
                ZZAt.track('buy.checkout.shipping.submit');
            },
            errorElement: "div",
            errorClass: "errormsg",
            invalidHandler: invalid_handler,
            focusCleanup: true,
            errorPlacement: error_placement_handler,
            success: success_handler,
            highlight: highlighter,
            unhighlight: unhighlighter
        });
        ZZAt.track('buy.checkout.shipping.open');
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


        // need to expose this so that we can clear after address is picked from dropdown.
        // todo: this should be refactored. dependend code is all over the place. it should all be here
        //       in this init function
        zz.store.checkout.validator = $('#checkout_form_payment').validate({
            //debug: true,
            rules: {
                'card_number':{
                    required: function(element){
                        return $('input[name*=creditcard_id]:checked').length <=0;
                    },
                    creditcard: true
                },
                'card_code':{
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
                    required: 'We promise we won&rsquo;t spam you',
                    email: 'Valid email, pretty pleahse :)'
                },
                'card_code':{
                    required:'Need help?, click the question mark',
                    number: 'Need help?, click the question mark',
                    minlength: 'Need help?, click the question mark'
                },
                'order[bill_address_attributes][zipcode]':{
                                    required: ' Your zip is really important!',
                                    postalcode: 'Huh? is that a zip?'
                 }
            },
            submitHandler: function(form){
                if ($('#order_bill_address_attributes_firstname').length > 0){
                    $('#cc_firstname').val($('#order_bill_address_attributes_firstname').val());
                    $('#cc_lastname').val($('#order_bill_address_attributes_lastname').val());
                    $('#cc_zipcode').val($('#order_bill_address_attributes_zipcode').val());
                }
                $('#cc_number').val($('#card_number').val());
                $('#cc_code').val($('#card_code').val());

                zz.dialog.show_spinner_progress_dialog("Verifying payment information...");
                // need to defer the submit otherwise progress dialog spinner doesn't load
                
                _.defer(function(){
                    form.submit();
                    ZZAt.track('buy.checkout.payment.submit');
                });
            },
            errorElement: "div",
            errorClass: "errormsg",
            invalidHandler: invalid_handler,
            focusCleanup: true,
            errorPlacement: error_placement_handler,
            success: success_handler,
            highlight: highlighter,
            unhighlight: unhighlighter
        });
        ZZAt.track('buy.checkout.payment.open');
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
                ZZAt.track('buy.checkout.thankyou.join.submit');
            },
             errorElement: "div",
            errorClass: "errormsg",
            invalidHandler: invalid_handler,
            focusCleanup: true,
            errorPlacement: error_placement_handler,
            success: success_handler,
            highlight: highlighter,
            unhighlight: unhighlighter
        });
         ZZAt.track('buy.checkout.thankyou.open');
    };
      //======================= thankyou =========================
    zz.store.checkout.init_cart_screen = function(){};
})();