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
    
    
      $('#nav-new-album').click(function(){
        if (typeof zz.zang.album_id == 'undefined') {
          
        } else if (zz.zang.drawer_open === 0) {
          zz.zang.open_drawer(500);
          zz.zang.add_photos();
          
        }
      });  
      
      $('#nav-share').click(function(){
        if (typeof zz.zang.album_id == 'undefined') {
          
        } else if (zz.zang.drawer_open === 0) {
          zz.zang.open_drawer(500);
          zz.zang.share_album();
          
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

          $('#small-drawer').animate({height: '410px', top: '53px'});
          zz.zang.drawer_open = 1;
          
        } else {
          //zz.zang.slam_drawer(880);
        }
      });    
      
      $('#step-sign-in-off').click(function(){
        $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
          $('#sign-in').show();
          $('#sign-up').hide();  
          $('#small-drawer').animate({height: '410px', top: '53px'});
        });
        

      });
      $('#step-join-off').click(function(){
        $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
          $('#sign-up').show();
          $('#sign-in').hide();  
          $('#small-drawer').animate({height: '410px', top: '53px'});
        });      
      });
      
      $('#nav-sign-in').click(function(){
        if (zz.zang.drawer_open === 0) {
          $('#sign-in').show();
          $('#sign-up').hide();        

          $('#small-drawer').animate({height: '410px', top: '53px'});
          zz.zang.drawer_open = 1;
          
        } else {
          //zz.zang.slam_drawer(880);
        }
      });      
      
 
    
    }
  } // end zz.init
