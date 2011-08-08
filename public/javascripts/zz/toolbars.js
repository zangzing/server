/*!
 * zz.toolbars.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};


zz.toolbars = {

    init_new_album: function() {
        $('#user-info').css('display', 'none');

        $('#album-info h2').text("New Album");
        $('#album-info h3').text("by " + zz.current_user_name);

        $('#header .album-cover').attr('src', zz.routes.image_url('/images/album-no-cover.png'));
        $('#header .album-cover').css({width: '60px'});

        $('#album-info').css('display', 'inline-block');
        zz.wizard.set_wizard_style('create');


        //tod: this should be in the wizard code
        $('div#cancel-drawer-btn').unbind('click').click(function() {
            if (confirm("Are you sure you want to cancel creating this album?")) {

                //reload after album is deleted to prevent race
                //condition in cache manager on server
                var afterdelete = function() {
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
    init_acct_badge_menu: function() {
        //Bind menu functionality
        $('ul.dropdown').hover(function() {
        }, function() {
            $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
        });
        $('ul.dropdown li a').click(function() {
            $(this).parent().parent().slideUp('fast');
        });

        //Bind Each Menu Item
        $('#acct-settings-btn').click(function() {
            zz.init.disable_buttons();
            $('#header #account-badge').removeClass('disabled').addClass('selected');
            document.location.href = zz.routes.edit_user_path(zz.current_user_name);
        });
        $('#acct-signout-btn').click(function() {
            window.location = zz.routes.path_prefix + '/signout'
        });
    },

    show_acct_badge_menu : function(event) {
        if ($('#acct-dropdown').is(":visible")) {
            $('#acct-dropdown').slideUp('fast');// Hide - slide up
        } else {
            $('#acct-dropdown').slideDown('fast');// Show - slide down.
        }
    },

    //==================================== LIKE BUTTON ==============================================
    build_like_button: function() {
        var tag = $('#footer #like-button');

        //decide what is on the screen to like and set their id and type
        if (location.hash && location.hash.length > 2) {
            //We are displaying a full size photo, add the photo menu element
            var hash = parseInt(location.hash.substr(2));
            if (isNaN(hash)) {
                hash = 0;
            }
            tag.attr('data-zzid', hash.toString()).attr('data-zztype', 'photo');
            //set a listener to keep the subject_id current with the selected photo. Selecting a photo sets its id as the hash
            $(window).bind('hashchange', function(event) {
                //zz.logger.debug('toolbar like for photo - hash changed to: location.hash ='+location.hash.substr(2));
                var hash = parseInt(location.hash.substr(2));
                if (!isNaN(hash)) {
                    tag.attr('data-zzid', hash.toString());
                    zz.like.add_id(hash.toString(), 'photo');
                }
            });
            //zz.logger.debug('toolbar like is for photo: '+hash.toString())
        } else if (typeof zz.album_id != 'undefined') {
            //we are displaying an album's photo grid/people/activity.
            tag.attr('data-zzid', zz.album_id).attr('data-zztype', 'album');
            //zz.logger.debug('toolbar like is for album: '+zz.album_id )
        } else if (typeof zz.displayed_user_id != 'undefined') {
            //we are displaying a user homepage
            tag.attr('data-zzid', zz.displayed_user_id).attr('data-zztype', 'user');
            //zz.logger.debug('toolbar like is for user: '+zz.displayed_user_id  )
        }
        return tag
    },

    load_album_cover: function(src) {
        var image = new Image();
        image.onload = function() {
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
        image.src = zz.agent.checkAddCredentialsToUrl(src);
    }

};