/*!
 * zz.toolbars.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.toolbars = {

    init_new_album: function(){
        $('#user-info').css('display', 'none');

        $('#album-info h2').text("New Album");
        $('#album-info h3').text("by " + zz.current_user_name);

        $('#header .album-cover').attr('src', path_helpers.image_url('/images/album-no-cover.png'));
        $('#header .album-cover').css({width: '60px'});

        $('#album-info').css('display', 'inline-block');
        zz.wizard.set_wizard_style( 'create');


        //tod: this should be in the wizard code
        $('div#cancel-drawer-btn').unbind('click').click( function(){
                if(confirm("Are you sure you want to cancel creating this album?")){

                    //reload after album is deleted to prevent race
                    //condition in cache manager on server
                    var afterdelete = function(){
                        window.location.reload();
                    };

                    zzapi_album.delete_album(zz.album_id, afterdelete, afterdelete);

                    $('#drawer .body').fadeOut('fast');
                    zz.close_drawer(400);
                    ZZAt.track('album.cancel.click');


                }
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

              document.location.href = path_helpers.rails_route('edit_user', zz.current_user_name);


//           zz.wizard.open_settings_drawer('profile')

       });
       $('#acct-signout-btn').click(function(){ window.location = zz.path_prefix + '/signout' });
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
            album = $('<li class="like-album">')
                    .append('<a href="#like_album" class="zzlike" data-zzid="'+zz.album_id+'" data-zztype="album" data-zzstyle="menu">Album <span class="like-count"></span></a>');
        }
        if( typeof zz.displayed_user_id != 'undefined' && zz.displayed_user_id != zz.current_user_id){
            //we are displaying an content from a user different than the logged in user
            user = $('<li class="like-user">')
                    .append('<a href="#like_user" class="zzlike" data-zzid="'+zz.displayed_user_id+'" data-zztype="user" data-zzstyle="menu">Person <span class="like-count"></span></a>');
        }
        if (location.hash && location.hash.length > 2) {
            //We are displaying a full size photo, add the photo menu element
            var hash = parseInt( location.hash.substr(2) );
            if( isNaN( hash ) ){
                hash = 0;
            }
            photo = $('<li class="like-photo" ></li>')
                    .append('<a href="#like_photo" id="like-menu-photo" class="zzlike" data-zzid="'+hash.toString()+'" data-zztype="photo" data-zzstyle="menu">Photo <span class="like-count"></span></a>');

            //set a listener to keep the subject_id current with the selected photo. Selecting a photo sets its id as the hash
            $(window).bind( 'hashchange', function( event ) {
                logger.debug('hash changed to: location.hash ='+location.hash.substr(2));
                var hash = parseInt( location.hash.substr(2) );
                if( !isNaN( hash ) ){
                    $('#like-menu-photo').attr('data-zzid', hash.toString() ).attr('data-zztype', 'photo' ).addClass('zzlike');
                    like.add_id( hash.toString(), 'photo' );
                }
            });
        }
        return $('<ul id="like-menu">').append( album ).append(user).append(photo);
    },

    load_album_cover: function( src ){
        var image = new Image();
        image.onload = function(){
            var height = 40;
            var width = Math.floor(image.width * (height / image.height));

            $('#album-cover-border img.album-cover').css({
                height: height,
                width:width
            });

            $('#album-cover-border .bottom-shadow').css({
                width:width + 4
            });

            $('img.album-cover').attr('src', image.src);
        };
        image.src = agent.checkAddCredentialsToUrl(src);
    }

};