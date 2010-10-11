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

    //Bottom Menu
    $('h1#home-link').click(function(){
            window.location = "http://"+zz.base;
     });

    $('#nav-new-album').click(function(){
      callback = function(){
        $('#personal_album_link').click(zz.wizard.create_personal_album);
        $('#group_album_link').click(zz.wizard.create_group_album);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.user_id+'/albums/new', callback);
    });
    
    $('#nav-new-photo').click(function(){ zz.wizard.open_edit_album_wizard('add') });
    $('#nav-share').click(function(){ zz.wizard.open_edit_album_wizard('share') });

    $('#nav-like').click(function(){
      callback = function(){
        $('.delete-id-button').click(zz.wizard.delete_identity);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.user_id+'/identities', callback);
    });

    $('#nav-buy').click(function(){
      callback = function(){
        $(zang.validate.user_update.element).validate(zang.validate.user_update);  
        $('#update-user-button').click(zz.wizard.update_user);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.user_id+'/edit', callback);
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
     $('#drawer-content').ajaxError(function(event, request) {
         var data = request.getResponseHeader('X-Errors');
         if( data ){
            var errors = (new Function( "return( " + data + " );" ))(); //parse json using function contstructor
            $('#error-notice').html(errors[0][1]).show();
         }
         zz.wizard.display_flashes(request, 50);
     });
     $('#drawer-content').ajaxSuccess(function(event, request) {
         zz.wizard.display_flashes(request, 50);
     });

    
  },
  
  resized: function(){
    if (zz.drawer_open == 1) {
      zz.resize_drawer(250);
      //gow scroll body
    }
    // TODO: check for selected photo - move caption position
  },
  
  album: function(){ 
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

  
  },

  album_timeline_view: function(){
        // Bind more button for ALL upload Activities
        $(".thumbnail").lazyload({
            placeholder : "/images/grey.gif",
            event : "more",
            effect : "fadeIn"
        });
        var GRID_HEIGHT = 170;
        $('.timeline-action a.more-less-btn').click(function(){
            var photoGrid = $(this).siblings('.timeline-grid');
            if( photoGrid.height() <= GRID_HEIGHT ){
                photo_count = photoGrid.children().length;
                var rows = ( Math.floor(  photo_count / 5 ) );
                if( photo_count % 5 > 0 )  rows++;
                photoGrid.animate({ height: (rows * GRID_HEIGHT) }, 500 );
                $(".thumbnail").trigger("more");
                $(this).html('less');
            } else{
                photoGrid.animate({ height: GRID_HEIGHT }, 500 );
                $(this).html('more...');
            }
        })
    }
}; // end zang.init
