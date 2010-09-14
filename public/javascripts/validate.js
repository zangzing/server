  /* Form Validation objects 
  --------------------------------------------------------------------------- */
zz.validation = {
  
  sign_in: {
    element: '#new_user_session',
    rules: {
      'user_session[email]': { required: true, minlength: 5 },
      'user_session[password]': { required: true, minlength: 5 }
    },
    messages: {
      'user_session[email]': '',
      'user_session[password]': '' 
    },
    errorPlacement: function(message) {
      $('div#sign-in p.error-notice').fadeIn('fast');
    }      
  
  },

  join: {
    element: '#join-form',
    rules: {
      'user[name]': { required: true, minlength: 5 },
      'user[username]': { required: true, minlength: 5 },
      'user[email]': { required: true, email: true },
      'user[password]': { required: true, minlength: 5 }
    },
    messages: {
      'user[name]': '',
      'user[username]': '',
      'user[email]': '',
      'user[password]': ''
    },
    errorPlacement: function(message) {
      $('div#sign-up p.error-notice').fadeIn('fast');
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
      $.post('/albums/'+zz.zang.album_id+'/shares', serialized, function(data){
        zz.zang.reload_share();
      });
    }
    
  }, // end zz.validation.new_post_share
  
  new_email_share: {
    element: '#new_email_share',
    rules: {
      'email_share[to]': { required: true, minlength: 10 },
      'email_share[subject]': { required: true, minlength: 10 },
      'email_share[message]': { required: true, minlength: 10 }
    },
    messages: {
      'email_share[to]': '',  
      'email_share[subject]': '',  
      'email_share[message]': '' 
    },  

    submitHandler: function() {
      serialized = $('#new_email_share').serialize();
      $.post('/albums/'+zz.zang.album_id+'/shares', serialized, function(data){
        zz.zang.reload_share();
      });
    }
    
  }, // end zz.validation.new_post_share    
  
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
    
  } // end zz.validation.sample_sign_up
      
}; // end zz.validation