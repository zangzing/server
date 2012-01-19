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

        $("#user-info-picture .defaultprofilepic").click(function(){
            $('#user-info').fadeOut(200);
            zz.routes.albums.add_profile_photo(zz.session.current_user_id);
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
            var user_name = '',
                user_email = '';
            if( typeof( zz.session.current_user_name) != 'undefined'){
                user_name  =  zz.session.current_user_name;
                user_email =  zz.session.current_user_email;
            }

            Zenbox.init({
                    dropboxID:   "14620",
                    url:         "https://zangzing.zendesk.com",
                    tabID:       "help",
                    tabColor:    "black",
                    requester_name: user_name,
                    requester_email: user_email,
                    tabPosition: "Left"
                  });


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
                    var sort = zz.local_storage.get_album_sort( zz.page.album_id );
                    document.location.href = zz.page.album_base_url + '/movie?sort='+sort+'&start=' + zz.page.current_photo_index + '&return_to=' + encodeURIComponent(document.location.href);
                });
        });
        zz.buy.toggle_visibility_with_buy_mode($('#footer #play-button'));




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
        zz.buy.toggle_visibility_with_buy_mode($('#footer #new-album-button'));



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
        zz.buy.toggle_visibility_with_buy_mode($('#inline-new-album-button'));


        $('#footer #import-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.import.click');

            zz.toolbars._disable_buttons();
            $('#footer #import-button').removeClass('disabled').addClass('selected');

            zz.import_albums.show_import_dialog();

        });
        zz.buy.toggle_visibility_with_buy_mode($('#footer #import-button'));




        // only album contributers can do this
        var add_photos_click_handler = function(){
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            zz.toolbars._add_photos();
        };

         // only album contributers can do this
        $('#header #top-add-photos-button').click(add_photos_click_handler);
        $('#footer #add-photos-button').click( add_photos_click_handler);
        zz.buy.toggle_visibility_with_buy_mode($('#header #top-add-photos-button'));
        zz.buy.toggle_visibility_with_buy_mode($('#footer #add-photos-button'));

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
        zz.buy.toggle_visibility_with_buy_mode($('#footer #share-button'));





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
        zz.buy.toggle_visibility_with_buy_mode($('#footer #edit-album-button'));


        // buy button is managed in buy.js

        // comments button is managed in comments.js


        zz.toolbars._init_account_badge();
        zz.toolbars._init_like_button();
        zz.toolbars._init_album_title();





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
        $('#acct-get-started-btn').click(function() {
            ZZAt.track('acctmenu.getstarted.click');
            window.open('/about/getting-started','GettingStarted','width=1000,height=1000,scrollbars=1');
        });

        $('#acct-invite-friends-btn').click(function() {
            ZZAt.track('acctmenu.invite-friends.click');
            zz.routes.users.goto_invite_friends_screen();
        });


        $('#acct-settings-btn').click(function() {
            zz.toolbars._disable_buttons();
            ZZAt.track('acctmenu.settings.click');
            $('#header #account-badge').removeClass('disabled').addClass('selected');
            document.location.href = zz.routes.edit_user_path(zz.session.current_user_name);
        });
        $('#acct-blog-btn').click(function() {
            ZZAt.track('acctmenu.blog.click');
            window.open('/blog','ZangZing','width=1100,height=1000,scrollbars=1');
        });
        $('#acct-signout-btn').click(function() {
            zz.local_storage.clear();
            ZZAt.track('acctmenu.signout.click');
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

        zz.buy.toggle_visibility_with_buy_mode($('#footer #like-button'));

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
        $('#header #top-add-photos-button').addClass('disabled');
        $('#header #view-buttons').children().addClass('disabled');
        $('#header #account-badge').addClass('disabled');
        $('#footer #play-button').addClass('disabled');
        $('#footer #next-button').addClass('disabled');
        $('#footer #prev-button').addClass('disabled');
        $('#footer #new-album-button').addClass('disabled');
        $('#footer #import-button').addClass('disabled');
        $('#footer #add-photos-button').addClass('disabled');
        $('#footer #share-button').addClass('disabled');
        $('#footer #edit-album-button').addClass('disabled');
        $('#footer #cart-button').addClass('disabled');
        $('#footer #buy-button').addClass('disabled');
        $('#footer #like-button').addClass('disabled');
        $('#footer #comments-button').addClass('disabled');
        $('#header #inline-new-album-button').addClass('disabled');
    },

    enable_buttons:function() {
        $('#header #back-button').removeClass('disabled');
        $('#header #view-buttons').children().removeClass('disabled');
        $('#header #account-badge').removeClass('disabled');
        $('#footer #play-button').removeClass('disabled');
        $('#footer #next-button').removeClass('disabled');
        $('#footer #prev-button').removeClass('disabled');
        $('#footer #new-album-button').removeClass('disabled');
        $('#footer #import-button').removeClass('disabled');
        $('#footer #add-photos-button').removeClass('disabled');
        $('#footer #share-button').removeClass('disabled');
        $('#footer #edit-album-button').removeClass('disabled');
        $('#footer #buy-button').removeClass('disabled');
        $('#footer #cart-button').removeClass('disabled');
        $('#footer #like-button').removeClass('disabled');
        $('#footer #import-button').removeClass('disabled').removeClass('selected');
        $('#header #inline-new-album-button').removeClass('disabled');
    },


    _init_album_title:function(){
        var title = $('#album-header-title');
        if(  zz.session.current_user_id && !zz.page.profile_album && zz.page.displayed_user_id == zz.session.current_user_id && title ){
            title.text(  zz.page.album_name  );
            title.ellipsis(300);
            title.click( function(){ title_edit( title ); } );


            var title_edit = function( title ){
                var max_title = 50;
                var edit = $('<div id="edit-album-title"><input id="album-title-input" class="album-title-input" type="text" name="album_title" ><div class="title-ok-button">OK</div>');
                var text_field = edit.find( '#album-title-input');
                var okButton =  edit.find('.title-ok-button');
                edit.width( title.width()+32);
                text_field.width( title.width() );
                $('#album-name-and-owner').append( edit );

                var commit_title_change = function(evt){
                    disarm_text_field();
                    ZZAt.track('topnavbar.albumtitle.click');

                    var new_title =  $.trim( text_field.val() );
                    if( zz.page.album_name != new_title && new_title.length <= max_title){
                        // send it to the back end
                        zz.routes.albums.update( zz.page.album_id,{'name': new_title },
                            function(data){
                                zz.page.album_name = new_title;
                                edit.remove();
                                title.text( new_title ).ellipsis(300);
                                title.unbind( 'click' ); //rebind click because ellipsis clears it in ie
                                title.click( function(){ title_edit( title ); } );
                            },
                            function(xhr){
                                zz.dialog.show_flash_dialog(JSON.parse(xhr.responseText).message, function(){arm_text_field();} );
                            });
                    }else{
                        edit.remove();
                    }
                };

                var arm_text_field = function(){
                    text_field.val( zz.page.album_name );
                    okButton.text('OK');

                    okButton.click(commit_title_change);
                    text_field.blur(commit_title_change);
                    text_field.keypress(function(event){
                        var text = $(this).val();
                        if(text.length > max_title ){
                            alert("album name cannot exceed "+max_title+" characters");
                            var new_text = text.substr(0, max_title);
                            $(this).val(new_text);
                            $(this).selectRange( max_title,max_title);
                        }else{
                            var keycode = (event.key_code ? event.key_code : event.which);
                            if(keycode == 13 || keycode == 9 ){ //enter or tab
                                commit_title_change( event );
                            }else if( keycode == 27 ){  //escape
                                edit.remove();
                            }
                        }
                    });

                    text_field.select();
                    text_field.focus();
                };

                var disarm_text_field = function(){
                    okButton.unbind('click');
                    text_field.unbind('blur')
                        .unbind('keypress')
                        .unbind('keyup');
                };

                arm_text_field();
            };
        }
    },

    _add_photos: function(){
            zz.toolbars._disable_buttons();
            $('#footer #comments-button').fadeOut(200);
            $('#album-info').fadeOut(200);
            $('#header #top-breadcrumb').fadeOut(200);
            $('#footer #add-photos-button').removeClass('disabled').addClass('selected');
            if( typeof( zz.session.current_user_id) != 'undefined' && typeof( zz.page.current_user_can_contribute) != 'undefined' && zz.page.current_user_can_contribute ){
                zz.photochooser.open_in_dialog(zz.page.album_id, function() {
                    window.location.reload(false);
                });
            } else {
                // The user is not allowed to download,
                // direct main window to server for user
                // validation and sigin/join request access etc...
                zz.routes.albums.add_photos(zz.page.album_id);
            }
    }
};
