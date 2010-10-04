/* Form Validation objects 
  --------------------------------------------------------------------------- */
zang.validate = {

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
      'user[name]': { required: true, minlength: 5 },
      'user[username]': { required: true, minlength: 5 },
      'user[email]': { required: true, email: true },
      'user[password]': { required: true, minlength: 5 }
    },
    messages: {
      'user[name]': 'Please enter your name.',
      'user[username]': 'A username allows us to create personal links.',
      'user[email]': 'We promise we won&rsquo;t spam you.',
      'user[password]': 'Six characters or more please.'
    }
  },

  user_update: {
    element: '#user-update-form',
    rules: {
      'user[name]': { required: true, minlength: 5 },
      'user[email]': { required: true, email: true },
    },
    messages: {
      'user[name]': 'Please enter your name.',
      'user[email]': 'We promise we won&rsquo;t spam you.',
    }
  },



  new_post_share: {
    element: '#new_post_share',
    rules: {
      'post_share[message]': { required: true, minlength: 10, maxlength: 118 }
    },
    messages: {
      'post_share[message]': '' 
    },      
    submitHandler: function() {
      serialized = $('#new_post_share').serialize();
      $.post('/albums/'+zz.album_id+'/shares', serialized, function(data){
        zz.wizard.reload_share(zz.drawers[zz.album_type+'_album'], 'share');
      });
    }
    
  }, // end zang.validation.new_post_share
  
  new_email_share: {
    element: '#new_email_share',
    rules: {
      'email_share[to]': { required: true, minlength: 10 },    
      'email_share[message]': { required: true, minlength: 10 }
    },
    messages: {
      'email_share[to]': '',
      'email_share[message]': '' 
    },  
  
    submitHandler: function() {
      serialized = $('#new_email_share').serialize();
      $.post('/albums/'+zz.album_id+'/shares.json', serialized, function(data ){
       if( data.status == 200 ){
          zz.wizard.reload_share(zz.drawers[zz.album_type+'_album'], 'share');
        }else{
          alert( data.errors.length + " Errors "+data.errors[0]);  
        }
      },"json");
    }
    
  }, // end zang.validation.new_post_share    

  new_contributors: {
    element: '#new_contributors',
    rules: {
      'email_share[message]': { required: true, minlength: 10, maxlength: 118 }
    },
    messages: {
      'email_share[message]': ''
    },
    submitHandler: function() {
      serialized = $('#new_contributors').serialize();
      $.post('/albums/'+zz.album_id+'/contributors.json', serialized, function(data){
     /*
      if( data.flash != undefined ){
          if( data.flash.error !=undefined)
            alert( "Error Flash "+data.flash.error);
          if( data.flash.notice !=undefined)
            alert( "Notice Flash "+data.flash.notice);
      }
      */
      if( data.status == 200 ){
           $('#drawer-content').empty().load('/albums/'+zz.album_id+'/contributors', function(){  
                zz.wizard.build_nav(zz.drawers.group_album, 'contributors');
                zz.drawers.group_album.steps['contributors'].init();
            });
      }else{
        /*
          if( data.errors != undefined){
            alert( " Errors "+data.errors);
          }
         */
       }
      },"json");
    }

  }, // end zang.validation.new_post_share




  sample_sign_up: {
    element: '#sample-sign-up',
    rules: {
      first_name: { required: true, minlength: 2 },  
      last_name: { required: true, minlength: 3 },  
      email: { required: true, email: true }, 
      password: { required: true, minlength: 6 },
      terms: { required: true }
    },
    messages: {
      first_name: { 
        required: '', 
        minlength: '' 
      },  
      last_name: { 
        required: '', 
        minlength: '' 
      },  
      email: { 
        required: '', 
        email: '' 
      }, 
      password: { 
        required: '', 
        minlength: '' 
      },
      terms: { 
        required: '' 
      }  
    }
    
  } // end zang.validation.sample_sign_up
    
}; // end zang.validation