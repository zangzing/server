var beta_email = {

    /*
     * called on load; captures referred_by param from query string and puts in cookie so we can retrieve later
     */
    init: function(){
        var get_param = function( name )
        {
          name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
          var regexS = "[\\?&]"+name+"=([^&#]*)";
          var regex = new RegExp( regexS );
          var results = regex.exec( window.location.href );
          if( results == null ){
              return "";
          }
          else{
            return results[1];
          }
        }

        var referred_by = get_param('referred_by');

        if(referred_by){
            $.cookie('referred_by', referred_by, { expires: 100000, path: '/' /*,domain: 'zangzing.com'*/});
        }
    },
    
    /*
     * check if user has already registered, based on cookie
     */
    already_registered: function(){
        return ($.cookie('registered_for_beta'));
    },


    /*
     * call to submit email address to server
     */
    register: function(email_address, success, failure){
        var self = this;
        var post_data = {email_address: email_address, referral_id: this.current_user_referred_by()};
        var url = 'register_email.json'

        
        $.ajax({
          type: 'GET',  //todo: change to POST
          url: url,
          data: post_data,
          success: function(json){
              self.show_thank_you_dialog(json.referrer_id);
              if(typeof success !== 'undefined') success(json);
          },
          failure: function(){
              self.show_error_dialog();
              if(typeof failure !== 'undefined') failure();
          },
          dataType: 'json'
        });
    },


    /* 
     * private: called after email address successfully saved to server
     */
    show_thank_you_dialog: function(referrer_id){
        //set cookie to remember that use has signed up
        $.cookie('registered_for_beta', 'true');

        var scrim = $('<div></div>');
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


        //todo: should load this from template
        var dialog = $('<div>Thank you<br>Please share this url: http://www.zangzing.com?referral id=<span id="referrer_id"></span><br>(click to close)</div>');
        dialog.find('#referrer_id').html(referrer_id);
        dialog.css({
            position: 'absolute',
            top:100,
            left:100,
            width:600,
            height:300,
            'background-color': '#ffffff',
            'z-index':1000
        })
        dialog.click(function(){
            scrim.remove();
        })

        scrim.append(dialog);

        $('body').append(scrim);

    },

    /*
     * private: called then bad email address submitted
     */
    show_error_dialog: function(){
        //todo: need nice HTML error dialog
        alert('there was an error');
    },



    /*
     * private: find who referred the current user
     */
    current_user_referred_by: function(){
        return ($.cookie('referred_by'));
    }





}

beta_email.init();