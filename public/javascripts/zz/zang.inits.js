/* INITs 
  --------------------------------------------------------------------------- */

zz.init = {

  template: function(){
  
    /* Click Handlers
      ----------------------------------------------------------------------- */

    $('#nav-new-album').click(function(){
      var callback = function(){
        $('#personal_album_link').click(zz.wizard.create_personal_album);
        $('#group_album_link').click(zz.wizard.create_group_album);
      };
      zz.toolbars.init_new_album();
      zz.easy_drawer(600, 0.0, '/users/'+zz.current_user_id+'/albums/new', callback);
    });


      //only album contributers can do this
    $('#nav-home').click(function(){ document.location.href = '/' });


    //only album contributers can do this
    $('#nav-add-photo').click(function(){ zz.wizard.open_edit_album_wizard('add') });

    //any signed in user can do this
    $('#nav-share').click(function(){ zz.wizard.open_edit_album_wizard('share') });

    //only album owner can do this
    $('#nav-edit-album').click(function(){ zz.wizard.open_edit_album_wizard('add') });

    $('#nav-like').click(function(){
      var callback = function(){
        $('.delete-id-button').click(zz.wizard.delete_identity);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.current_user_id+'/identities', callback);
    });

    $('#nav-buy').click(function(){
      var callback = function(){
        $(zz.validate.user_update.element).validate(zz.validate.user_update);
        $('#update-user-button').click(zz.wizard.update_user);
      };
      zz.easy_drawer(600, 0.0, '/users/'+zz.current_user_id+'/edit', callback);
    });


    /* new user stuff   */
    /* ---------------------------------*/

    $('#user_username').keyup(function(event){
      var value = $('#user_username').val();
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
      }
    });

    $('.cancel-mini').click(function(){
      $('#small-drawer').animate({height: '0px', top: '28px'});
      zz.drawer_open = 0;
    });

    $(zz.validate.sign_in.element).validate(zz.validate.sign_in);
    $(zz.validate.join.element).validate(zz.validate.join);      


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
    $('#nav-status').hide();

    //update album upload status every 10 seconds
    var updateProgressMeter = function(){
        $.ajax({
            url: '/albums/' + zz.album_id + '/upload_stat',
            success: function(json){
                if(json['photos-pending'] > 0){
                    var percent_complete = Math.round(json['percent-complete']);

                    logger.debug('percent complete ' + percent_complete);
                    var step = 0;

                    if(percent_complete > 0){
                         step = Math.round(percent_complete / 6.25);
                    }
                    
                    logger.debug('step ' + step);

                    $('#nav-status').css('background-image', 'url(/images/upload-'+ step +'.png)');

                    if(percent_complete == 0){
                        $('#nav-status').html('Calculating...');
                    }
                    else{
                        $('#nav-status').html(Math.round(json['time-remaining']) + ' Minutes...');
                    }
                    $('#nav-status').show();
                }
                else{
                    $('#nav-status').hide();
                }
            }
        });
    }

    updateProgressMeter();  

    setInterval( updateProgressMeter ,10000);
  },
  
  
  tray: function(){

  },
  
//  new_user: function(){
//
//    $('#nav-new-album').click(function(){
//      if (zz.drawer_open === 0) {
//        $('#sign-in').show();
//        $('#sign-up').hide();
//
//        $('#small-drawer').animate({height: '460px', top: '53px'});
//        zz.drawer_open = 1;
//
//      } else {
//        //zz.slam_drawer(880);
//      }
//    });
//
//    $('#user_username').keyup(function(event){
//      value = $('#user_username').val();
//      $('#update-username').empty().html(value);
//    });
//
//    $('#step-sign-in-off').click(function(){
//      $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
//        $('#sign-in').show();
//        $('#sign-up').hide();
//        $('#small-drawer').animate({height: '460px', top: '53px'});
//      });
//
//
//    });
//    $('#step-join-off').click(function(){
//      $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
//        $('#sign-up').show();
//        $('#sign-in').hide();
//        $('#small-drawer').animate({height: '460px', top: '53px'});
//      });
//    });
//
//    $('#nav-sign-in').click(function(){
//        if (zz.drawer_open === 0) {
//            $('#sign-in').show();
//            $('#sign-up').hide();
//
//            $('#small-drawer').animate({height: '460px', top: '53px'});
//            zz.drawer_open = 1;
//      }
//    });
//
//    $('.cancel-mini').click(function(){
//      $('#small-drawer').animate({height: '0px', top: '28px'});
//      zz.drawer_open = 0;
//    });
//
//    $(zz.validate.sign_in.element).validate(zz.validate.sign_in);
//    $(zz.validate.join.element).validate(zz.validate.join);
//
//
//  },

  album_timeline_view: function(){
        // Bind more button for ALL upload Activities
        $('.lazy-thumb').lazyload({
            placeholder : '/images/grey.gif',
            event : 'more',
            effect : 'fadeIn'
        });
        var GRID_HEIGHT = 170;
        $('.timeline-action a.more-less-btn').click(function(){
            var photoGrid = $(this).siblings('.timeline-grid');
            if( photoGrid.height() <= GRID_HEIGHT ){
                photo_count = photoGrid.children('li').length;
                var rows = Math.ceil(  photo_count / 5 );
                $(this).siblings('ul.timeline-grid').children('li').children('a').children().trigger('more'); 
                photoGrid.animate({ height: (rows * GRID_HEIGHT) }, 500 );
                $(this).html('less');
            } else{
                photoGrid.animate({ height: GRID_HEIGHT }, 500 );
                $(this).html('more...');
            }
        })
    }
}; // end zz.init
