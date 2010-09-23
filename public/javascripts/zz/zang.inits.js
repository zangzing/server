/* INITs 
  --------------------------------------------------------------------------- */

zang.init = {

  template: function(){
  
    /* Click Handlers
      ----------------------------------------------------------------------- */
    //console.log('hello world?');
    // highlight a selected photo
    $('ul#grid-view li').click(function(){
      zz.new_photo = $(this).attr('id');
      zz.highlight_selected(zz.new_photo);
    });
    
    $('#nav-new-album').click(function(){
      temp = function(){
        $('#personal_album_link').click(zz.wizard.create_album);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.user_id+'/albums/new', temp);
    });
    
    /*  
    // open drawer demo
    $('#nav-new-album').click(function(){
      if (zz.drawer_open === 0) {
      
        $(element).drawer(obj);
        
        zz.choose_album_type();
      } else {
        //zz.slam_drawer(880);
      }
    });
    
    $('#indicator li').click(function(){
      temp = $(this).attr('id');
      zz.change_step(temp);
    });
    */
                
  },
  
  loaded: function(){
  
  },
  
  resized: function(){
    if (zz.drawer_open == 1) {
      zz.resize_drawer(250);
      //gow scroll body
    }
    // TODO: check for selected photo - move caption position
  },
  
  album: function(){
  
  
    $('#nav-new-photo').click(function(){
      if (typeof zz.album_id == 'undefined') {
        
      } else if (zz.drawer_open === 0) {
        zz.open_drawer(500);
        zz.add_photos();
        $('#indicator').fadeIn('slow');
      }
    });  
    
    $('#nav-share').click(function(){
      if (typeof zz.album_id == 'undefined') {
        
      } else if (zz.drawer_open === 0) {
        zz.open_drawer(500);
        zz.share_album();
        $('#indicator').removeClass('step-'+zz.indicator_step).addClass('step-4').fadeIn('slow');
        $('#step-add').removeClass('on');
        zz.indicator = 'step-share';
        zz.indicator_step = 4;
        $('#step-share').addClass('on');
      }
    });    
    
  
  },
  
  
  tray: function(){
  
    
  
  },
  
  new_user: function(){
  
    $('#nav-new-album').click(function(){
      if (zz.drawer_open === 0) {
        $('#sign-in').show();
        $('#sign-up').hide();        

        $('#small-drawer').animate({height: '460px', top: '53px'});
        zz.drawer_open = 1;
        
      } else {
        //zz.slam_drawer(880);
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
      if (zz.drawer_open === 0) {
        $('#sign-in').show();
        $('#sign-up').hide();        

        $('#small-drawer').animate({height: '460px', top: '53px'});
        zz.drawer_open = 1;
        
      } else {
        //zz.slam_drawer(880);
      }
    });
    
    $('.cancel-mini').click(function(){
      $('#small-drawer').animate({height: '0px', top: '28px'});
      zz.drawer_open = 0;
    });      
    
    $(zang.validate.sign_in.element).validate(zang.validate.sign_in);
    $(zang.validate.join.element).validate(zang.validate.join);

  
  }
}; // end zang.init
