/* INITs 
  --------------------------------------------------------------------------- */

zang.init = {

  template: function(){
  
    /* Click Handlers
      ----------------------------------------------------------------------- */
    //console.log('hello world?');
    // highlight a selected photo
    $('ul#grid-view li').click(function(){
      zang.zing.new_photo = $(this).attr('id');
      zang.zing.highlight_selected(zang.zing.new_photo);
    });
          
    // open drawer demo
    $('#nav-new-album').click(function(){
      if (zang.zing.drawer_open === 0) {
        zang.zing.choose_album_type();
      } else {
        //zang.zing.slam_drawer(880);
      }
    });
    
    $('#indicator li').click(function(){
      temp = $(this).attr('id');
      zang.zing.change_step(temp);
    });
                
  },
  
  loaded: function(){
  
  },
  
  resized: function(){
    if (zang.zing.drawer_open == 1) {
      zang.zing.resize_drawer(250);
      //gow scroll body
    }
    // TODO: check for selected photo - move caption position
  },
  
  album: function(){
  
  
    $('#nav-new-photo').click(function(){
      if (typeof zang.zing.album_id == 'undefined') {
        
      } else if (zang.zing.drawer_open === 0) {
        zang.zing.open_drawer(500);
        zang.zing.add_photos();
        $('#indicator').fadeIn('slow');
      }
    });  
    
    $('#nav-share').click(function(){
      if (typeof zang.zing.album_id == 'undefined') {
        
      } else if (zang.zing.drawer_open === 0) {
        zang.zing.open_drawer(500);
        zang.zing.share_album();
        $('#indicator').removeClass('step-'+zang.zing.indicator_step).addClass('step-4').fadeIn('slow');
        $('#step-add').removeClass('on');
        zang.zing.indicator = 'step-share';
        zang.zing.indicator_step = 4;
        $('#step-share').addClass('on');
      }
    });    
    
  
  },
  
  
  tray: function(){
  
    
  
  },
  
  new_user: function(){
  
    $('#nav-new-album').click(function(){
      if (zang.zing.drawer_open === 0) {
        $('#sign-in').show();
        $('#sign-up').hide();        

        $('#small-drawer').animate({height: '460px', top: '53px'});
        zang.zing.drawer_open = 1;
        
      } else {
        //zang.zing.slam_drawer(880);
      }
    });
    
    $('#user_username').keyup(function(event){
      value = $('#user_username').val();
      $('#update-username').empty().html(value);
    });

    $('#step-sign-in-off').click(function(){
      $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
        $('#sign-in').show();
        $('#sign-up').hide();  
        $('#small-drawer').animate({height: '460px', top: '53px'});
      });
      

    });
    $('#step-join-off').click(function(){
      $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
        $('#sign-up').show();
        $('#sign-in').hide();  
        $('#small-drawer').animate({height: '460px', top: '53px'});
      });      
    });
    
    $('#nav-sign-in').click(function(){
      if (zang.zing.drawer_open === 0) {
        $('#sign-in').show();
        $('#sign-up').hide();        

        $('#small-drawer').animate({height: '460px', top: '53px'});
        zang.zing.drawer_open = 1;
        
      } else {
        //zang.zing.slam_drawer(880);
      }
    });
    
    $('.cancel-mini').click(function(){
      $('#small-drawer').animate({height: '0px', top: '28px'});
      zang.zing.drawer_open = 0;
    });      
    
    $(zang.validation.sign_in.element).validate(zang.validation.sign_in);
    $(zang.validation.join.element).validate(zang.validation.join);

  
  }
}; // end zang.init
