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
    init_like_menu: function(){
        $('ul.popup').hover(function() {}, function(){
                $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
              });
        $('ul.popup li').click( zz.toolbars.like_menu_clicked );

        //decide which menu items to show and set their subject_ids
        if( typeof zz.album_id != 'undefined' ){
            //we are displaying an album photos
            $('#like-album').attr('subject_id', zz.album_id);
            $('#like-album').css('display', 'block');
        }
        if( typeof zz.displayed_user_id != 'undefined' && zz.displayed_user_id != zz.current_user_id){
            //we are displaying an content from a user different than the logged in user
            $('#like-user').attr('subject_id', zz.displayed_user_id );
            $('#like-user').css('display', 'block');
        }
        if (location.hash && location.hash.length > 2) {
            //We are displaying a full size photo, add the photo menu element
             logger.debug('hash set to: location.hash ='+location.hash.substr(2));
            $('#like-photo').attr('subject_id', location.hash.substr(2) );
            $('#like-photo').css('display', 'block');
            //set a listener to keep the subject_id current with the selected photo. Selecting a photo sets its id as the hash
            $(window).bind( 'hashchange', function( event ) {
                logger.debug('hash changed to: location.hash ='+location.hash.substr(2));
              $('#like-photo').attr('subject_id', location.hash.substr(2) );
            });
        }
    },
    show_like_menu: function(){
        //toggle visibility
        if( $('#like-popup').is( ":visible" ) ){
               $('#like-popup').slideUp( 'fast' );// Hide - slide up
        }else{
          //get the position of the clicked element and display popup above center of it  
          var pos =  $('#footer #like-button').offset();
          var width =  $('#footer #like-button').width();
          var height=  $('#footer #like-button').width();
          $("#like-popup").css( { "left":  pos.left - (width/2)+"px", "bottom": height+ "px" } );
          $('#like-popup').slideToggle( 'fast' );// Show = slide down
        }
    },

    like_menu_clicked: function(){
            $(this).parent().slideUp('fast');
            console.log(this.id);
            switch(this.id){
               case 'like-photo': like.photo($(this).attr('subject_id')); break;
               case 'like-album': like.album($(this).attr('subject_id')); break;
               case 'like-user' : like.user($(this).attr('subject_id'));  break;
            }
    }
};