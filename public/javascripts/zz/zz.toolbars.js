/*!
 * zz.toolbars.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.toolbars = {

    init_new_album: function(){
        $('#user-info').css('display', 'none');

        $('#album-info h2').html("New Album");
        $('#album-info h3').html("by " + zz.current_user_name);

        $('#header .album-cover').attr('src', '/images/album-no-cover.png');
        $('#header .album-cover').css({width: '60px'});

        $('#album-info').css('display', 'inline-block');
        zz.wizard.set_wizard_style( 'create');
        $('div#cancel-drawer-btn').unbind('click').click( function(){
                $('#drawer .body').fadeOut('fast', function(){window.location.reload()});
                zz.close_drawer(400);
        });
    },

    //============================== ACCOUNT BADGE MENU ===========================================
    init_acct_badge_menu: function(){
       //Bind menu functionality 
       $('ul.dropdown').hover(function() {}, function(){
              $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
            });
       $('ul.dropdown li a').click(function(){  $(this).parent().parent().slideUp('fast');  });
        
       //Bind Each Menu Item
       $('#acct-settings-btn').click(function(){
           zz.init.disable_buttons();
           $('#header #account-badge').removeClass('disabled').addClass('selected');
       
           zz.wizard.open_settings_drawer('profile')

       });
       $('#acct-signout-btn').click(function(){ window.location = '/signout' }); 
    },

    show_acct_badge_menu : function(event){
//        event.preventDefault();
        // Toggle the slide based on the menu's current visibility.
        if( $('#acct-dropdown').is( ":visible" ) ){
               $('#acct-dropdown').slideUp( 'fast' );// Hide - slide up
        } else {
               $('#acct-dropdown').slideDown( 'fast' );// Show - slide down.
        }
    },

    //==================================== LIKE MENU ==============================================
    build_like_menu: function(){
        var menu='',user='',album='',photo='';
        //decide which menu items to show and set their subject_ids
        if( typeof zz.album_id != 'undefined' ){
              //we are displaying an album's photo grid.
            album = $('<li class="zzlike" data-zzid="'+zz.album_id+'" data-zztype="album"></li>');
        }
        if( typeof zz.displayed_user_id != 'undefined' && zz.displayed_user_id != zz.current_user_id){
            //we are displaying an content from a user different than the logged in user
            user = $('<li class="zzlike" data-zzid="'+zz.displayed_user_id+'" data-zztype="user"></li>');
        }
        if (location.hash && location.hash.length > 2) {
            //We are displaying a full size photo, add the photo menu element
            photo = $('<li id="like-menu-photo" class="zzlike" data-zzid="'+location.hash.substr(2)+'" data-zztype="photo"></li>');
            //set a listener to keep the subject_id current with the selected photo. Selecting a photo sets its id as the hash
            $(window).bind( 'hashchange', function( event ) {
              //logger.debug('hash changed to: location.hash ='+location.hash.substr(2));
              var id = location.hash.substr(2);
              $('#like-menu-photo').attr('data-zzid', id );
              like.add_id( id, 'photo' );
            });
        }
        menu=$('<ul id="like-menu"></ul>');
        menu.append( album );
        menu.append(user);
        menu.append(photo);
        return menu;
    }
};