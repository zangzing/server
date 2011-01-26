var beta_email = {

    register: function(email_address, referral_id, success, failure){
        var self = this;
        var post_data = {email_address: email_address, referal_id: referral_id};


//        $.ajax({
//          type: 'POST',
//          url: url,
//          data: post_data,
//          success: function(json){
//              self.on_success(json);
//              success(json);
//          },
//          failure: function(){
//              self.on_failure();
//              failure();
//          },
//          dataType: 'json'
//        });


        //for testing, use timeout rather than ajax call
        setTimeout(function(){
           //this is the response from the server
           var json = {referrer_id: 'asfasdfasdfasdf'}

           self.on_success(json);
           success();
        }, 100);


    },

    on_success: function(json){
        //set cookie to remember that use has signed up
        $.cookie('registered_for_beta', 'true');

        //show thank you dialog
        var scrim = $('<div></div>');

        //todo: move to css stylesheet
        scrim.css({
           position: 'absolute',
           top: 0,
           left: 0,
           bottom: 0,
           right: 0,
           'background-color':'#000000',
           opacity:0.5,
           'z-index':1000
        });


        var dialog = $('<div>Thank you; referral id:  <span id="referrer_id"></span></div>'); //should load this from template

        dialog.find('#referrer_id').html(json.referrer_id);

        //todo: move to css stylesheet
        dialog.css({
            position: 'absolute',
            top:100,
            left:100,
            width:300,
            height:300,
            'background-color': '#ffffff',
            'z-index':1000
        })

        scrim.append(dialog);

        $('body').append(scrim);

    },

    on_failure: function(){
        //show error dialog
    },

    already_registered: function(){
        return ($.cookie('registered_for_beta'));
    }

}