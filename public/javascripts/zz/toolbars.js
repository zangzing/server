/*!
 * zz.toolbars.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};


zz.toolbars = {

    init: function() {
        //top bar
        $('#header #home-button').click(function() {
            document.location.href = zz.routes.path_prefix + '/';
            ZZAt.track('button.home.click');
        });
        if (zz.page.rails_controller_name == 'photos' || zz.page.rails_controller_name == 'albums') {
            $('#header #view-buttons #grid-view-button').addClass('selected');
        }
        else if (zz.page.rails_controller_name == 'people') {
            $('#header #view-buttons #people-view-button').addClass('selected');
        }
        else if (zz.page.rails_controller_name == 'activities') {
            $('#header #view-buttons #activities-view-button').addClass('selected');
        }
        $('#header #view-buttons #grid-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.gridview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #grid-view-button').addClass('selected');
            $('#article').fadeOut(200);
            if (typeof(zz.page.album_base_url) != 'undefined') {
                document.location.href = zz.page.album_base_url + '/photos';
            } else {
                document.location.href = zz.page.displayed_user_base_url;
            }

        });

        $('#header #view-buttons #picture-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.pictureview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #picture-view-button').addClass('selected');
            $('#article').fadeOut(200);
            document.location.href = zz.page.album_base_url + '/photos/#!';
        });

        $('#header #view-buttons #people-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.peopleview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #people-view-button').addClass('selected');
            $('#article').fadeOut(200);
            if (typeof(zz.page.album_base_url) != 'undefined') {
                document.location.href = zz.page.album_base_url + '/people';
            } else {
                document.location.href = zz.page.displayed_user_base_url + '/people';
            }

        });

        $('#header #view-buttons #activities-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.activitiesview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #activities-view-button').addClass('selected');
            $('#article').fadeOut(200);
            if (typeof(zz.page.album_base_url) != 'undefined') {
                document.location.href = zz.page.album_base_url + '/activities';
            } else {
                document.location.href = zz.page.displayed_user_base_url + '/activities';
            }
        });

        $('#header #help-button').click(function(event) {
            ZZAt.track('button.help.click');
            //feedback_widget.show();
            Zenbox.show(event);

            //hack: force zendesk dialog to show scrollbars if screen too small
            $('#zenbox_body').css({height: jQuery(window).height() - 100});
        });

        $('#header #sign-in-button').click(function() {
            ZZAt.track('button.signin.click');
            document.location.href = '/signin?return_to=' + encodeURIComponent(document.location.href);
        });

        $('#footer #play-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            ZZAt.track('button.play.click');

            $('<div></div>').css({
                position: 'absolute',
                top: 0,
                left: 0,
                height: '100%',
                width: '100%',
                'z-index': 3000,
                'background-color': '#000000',
                opacity: 0
            }).appendTo('body').animate({opacity: 1}, 500, function() {
                document.location.href = zz.page.album_base_url + '/movie?start=' + zz.page.current_photo_index + '&return_to=' + encodeURIComponent(document.location.href);
            });

        });


        // new album button -- buttom toolbar
        $('#footer #new-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.createalbum.click');

            zz.toolbars._disable_buttons();
            $('#footer #new-album-button').removeClass('disabled').addClass('selected');

            zz.toolbars._init_new_album();
            zz.wizard.create_group_album();
        });

        // new album buttons -- inline
        $('#inline-new-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.createalbum-top.click');

            zz.toolbars._disable_buttons();
            $('#footer #new-album-button').removeClass('disabled').addClass('selected');

            zz.toolbars._init_new_album();
            zz.wizard.create_group_album();
        });


        // only album contributers can do this
        $('#footer #add-photos-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            zz.toolbars._disable_buttons();
            $('#footer #add-photos-button').removeClass('disabled').addClass('selected');


            zz.photochooser.open_in_dialog(zz.page.album_id, function() {
                window.location.reload(false);
            });


        });




        //any signed in user can do this
        $('#footer #share-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            ZZAt.track('button.share.click');


            //todo: need better generic way to determine current view and get photo id -- this is duplicated elsewhere
            if (document.location.href.indexOf('/photos/#!') !== -1 || document.location.href.indexOf('/photos#!') !== -1) {
                var photoId = jQuery.param.fragment().slice(1);
                zz.sharemenu.show($(this), 'photo', photoId, {x: 0, y: 0}, 'toolbar', 'popup', $.noop);
            }
            else {
                zz.sharemenu.show($(this), 'album', zz.page.album_id, {x: 0, y: 0}, 'toolbar', 'popup', $.noop);
            }

        });

        //only album owner can do this
        $('#footer #edit-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;

            }
            ZZAt.track('button.editalbum.click');


            zz.toolbars._disable_buttons();
            $('#footer #edit-album-button').removeClass('disabled').addClass('selected');
            zz.wizard.open_edit_album_wizard('add');
        });


        if(zz.buy.is_buy_mode_active()){
            $('#footer #buy-button').addClass('selected');
        }
        $('#footer #buy-button').click(function() {
            if (! $(this).hasClass('disabled')) {
                if(zz.buy.is_buy_mode_active()){
                    zz.buy.deactivate_buy_mode();
                    $(this).removeClass('selected');
                }
                else{
                    zz.buy.activate_buy_mode();
                    $(this).addClass('selected');
                }
            }
        });

        zz.toolbars._init_account_badge();
        zz.toolbars._init_like_button();

    },


    _init_new_album: function() {
        $('#user-info').css('display', 'none');

        $('#album-info h2').text('New Album');
        $('#album-info h3').text('by ' + zz.session.current_user_name);

        $('#header .album-cover').attr('src', zz.routes.image_url('/images/album-no-cover.png'));
        $('#header .album-cover').css({width: '60px'});

        $('#album-info').css('display', 'inline-block');
        zz.wizard.set_wizard_style('create');


        //tod: this should be in the wizard code
        $('div#cancel-drawer-btn').unbind('click').click(function() {
            if (confirm('Are you sure you want to cancel creating this album?')) {

                //reload after album is deleted to prevent race
                //condition in cache manager on server
                var afterdelete = function() {
                    window.location.reload();
                };

                zz.routes.call_delete_album(zz.page.album_id, afterdelete, afterdelete);

                $('#drawer .body').fadeOut('fast');
                zz.drawers.close_drawer(400);
                ZZAt.track('album.cancel.click');


            }
        });
    },

    _init_account_badge: function() {
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
            zz.toolbars._disable_buttons();
            $('#header #account-badge').removeClass('disabled').addClass('selected');
            document.location.href = zz.routes.edit_user_path(zz.session.current_user_name);
        });
        $('#acct-signout-btn').click(function() {
            window.location = zz.routes.path_prefix + '/signout';
        });



        $('#account-badge').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            if ($('#acct-dropdown').is(':visible')) {
                $('#acct-dropdown').slideUp('fast');// Hide - slide up
            } else {
                $('#acct-dropdown').slideDown('fast');// Show - slide down.
            }
        });
    },



    _init_like_button: function() {
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
        } else if (typeof zz.page.album_id != 'undefined') {
            //we are displaying an album's photo grid/people/activity.
            tag.attr('data-zzid', zz.page.album_id).attr('data-zztype', 'album');
            //zz.logger.debug('toolbar like is for album: '+zz.page.album_id )
        } else if (typeof zz.page.displayed_user_id != 'undefined') {
            //we are displaying a user homepage
            tag.attr('data-zzid', zz.page.displayed_user_id).attr('data-zztype', 'user');
            //zz.logger.debug('toolbar like is for user: '+zz.page.displayed_user_id  )
        }

        zz.like.init();
    },

    load_album_cover: function(src) {
        var image = new Image();
        image.onload = function() {
            var height = 40;
            var width = Math.floor(image.width * (height / image.height));

            $('#album-cover-border img.album-cover').css({
                height: height,
                width: width
            });

            $('#album-cover-border .bottom-shadow').css({
                width: width + 4
            });

            $('img.album-cover').attr('src', image.src);
        };
        image.src = zz.agent.checkAddCredentialsToUrl(src);
    },

    _disable_buttons: function() {
        $('#header #back-button').addClass('disabled');
        $('#header #view-buttons').children().addClass('disabled');
        $('#header #account-badge').addClass('disabled');
        $('#footer #play-button').addClass('disabled');
        $('#footer #next-button').addClass('disabled');
        $('#footer #prev-button').addClass('disabled');
        $('#footer #new-album-button').addClass('disabled');
        $('#footer #add-photos-button').addClass('disabled');
        $('#footer #share-button').addClass('disabled');
        $('#footer #edit-album-button').addClass('disabled');
        $('#footer #buy-button').addClass('disabled');
        $('#footer #like-button').addClass('disabled');
        $('#footer #comments-button').addClass('disabled');
    }

//    enable_buttons:function() {
//        $('#header #back-button').removeClass('disabled');
//        $('#header #view-buttons').children().removeClass('disabled');
//        $('#header #account-badge').removeClass('disabled');
//        $('#footer #play-button').removeClass('disabled');
//        $('#footer #next-button').removeClass('disabled');
//        $('#footer #prev-button').removeClass('disabled');
//        $('#footer #new-album-button').removeClass('disabled');
//        $('#footer #add-photos-button').removeClass('disabled');
//        $('#footer #share-button').removeClass('disabled');
//        $('#footer #edit-album-button').removeClass('disabled');
//        $('#footer #buy-button').removeClass('disabled');
//        $('#footer #like-button').removeClass('disabled');
//    },






};
