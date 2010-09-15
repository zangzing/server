  /* INITs 
  --------------------------------------------------------------------------- */
  
zz.init = {
  
    template: function(){
    
      /* Click Handlers
      ----------------------------------------------------------------------- */
      
      // highlight a selected photo
      $('ul#grid-view li').click(function(){
        zz.zang.new_photo = $(this).attr('id');
        zz.zang.highlight_selected(zz.zang.new_photo);
      });
            
      // open drawer demo
      $('#nav-new-album').click(function(){
        if (zz.zang.drawer_open === 0) {
          zz.zang.choose_album_type();
        } else {
          //zz.zang.slam_drawer(880);
        }
      });
      
      $('#indicator li').click(function(){
        temp = $(this).attr('id');
        zz.zang.change_step(temp);
      });
                  
    },
    
    loaded: function(){
    
    },
    
    resized: function(){
      if (zz.zang.drawer_open == 1) {
        zz.zang.resize_drawer(250);
        //gow scroll body
      }
      // TODO: check for selected photo - move caption position
    },
    
    album: function(){
    
    
      $('#nav-new-photo').click(function(){
        if (typeof zz.zang.album_id == 'undefined') {
          
        } else if (zz.zang.drawer_open === 0) {
          zz.zang.open_drawer(500);
          zz.zang.add_photos();
          $('#indicator').fadeIn('slow');
        }
      });  
      
      $('#nav-share').click(function(){
        if (typeof zz.zang.album_id == 'undefined') {
          
        } else if (zz.zang.drawer_open === 0) {
          zz.zang.open_drawer(500);
          zz.zang.share_album();
          $('#indicator').removeClass('step-'+zz.zang.indicator_step).addClass('step-4').fadeIn('slow');
          $('#step-add').removeClass('on');
          zz.zang.indicator = 'step-share';
          zz.zang.indicator_step = 4;
          $('#step-share').addClass('on');
        }
      });    
      
    
    },
    
    
    tray: function(){
    
      
    
    },
    
    new_user: function(){
    
      $('#nav-new-album').click(function(){
        if (zz.zang.drawer_open === 0) {
          $('#sign-in').show();
          $('#sign-up').hide();        

          $('#small-drawer').animate({height: '460px', top: '53px'});
          zz.zang.drawer_open = 1;
          
        } else {
          //zz.zang.slam_drawer(880);
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
        if (zz.zang.drawer_open === 0) {
          $('#sign-in').show();
          $('#sign-up').hide();        

          $('#small-drawer').animate({height: '460px', top: '53px'});
          zz.zang.drawer_open = 1;
          
        } else {
          //zz.zang.slam_drawer(880);
        }
      });
      
      $('.cancel-mini').click(function(){
        $('#small-drawer').animate({height: '0px', top: '28px'});
        zz.zang.drawer_open = 0;
      });      
      
      $(zz.validation.sign_in.element).validate(zz.validation.sign_in);
      $(zz.validation.join.element).validate(zz.validation.join);

    
    }
  } // end zz.init
