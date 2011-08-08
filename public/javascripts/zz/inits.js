/*!
 * zz.inits.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};

zz.init = {

    //todo move to zz.toolbars
    disable_buttons: function() {
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
    },

    //todo move to zz.toolbars
    enable_buttons:function() {
        $('#header #back-button').removeClass('disabled');
        $('#header #view-buttons').children().removeClass('disabled');
        $('#header #account-badge').removeClass('disabled');
        $('#footer #play-button').removeClass('disabled');
        $('#footer #next-button').removeClass('disabled');
        $('#footer #prev-button').removeClass('disabled');
        $('#footer #new-album-button').removeClass('disabled');
        $('#footer #add-photos-button').removeClass('disabled');
        $('#footer #share-button').removeClass('disabled');
        $('#footer #edit-album-button').removeClass('disabled');
        $('#footer #buy-button').removeClass('disabled');
        $('#footer #like-button').removeClass('disabled');
    },

    template: function() {
        $(document).ajaxSend(function(event, request, settings) {
            settings.data = settings.data || "";
            settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(zz.rails_authenticity_token);
        });

        /* Click Handlers    ----------------------------------------------------------------------- */
        //join banner
        $('#join-banner #close-button').click(function() {
            $('#join-banner').fadeOut(200, function() {
                $('#page-wrapper').animate({top:0}, 200);
                $('body').removeClass('show-join-banner');

                //create cookie that expires in 1 hour or when user quits browser
                var expires = new Date();
                expires.setTime(expires.getTime() + 60 * 60 * 1000);
                jQuery.cookie('hide_join_banner', 'true', {expires: expires});
            });
        });

        $('#join-banner #join-button').click(function() {
            document.location.href = '/join';
        });

        $('#join-banner #signin-button').click(function() {
            document.location.href = '/signin?return_to=' + encodeURIComponent(document.location.href);
        });


        //system message banner
        $('#system-message-banner #close-button').click(function() {
            $('#system-message-banner').fadeOut(200, function() {
                $('#page-wrapper').animate({top:0}, 200);
                $('body').removeClass('show-join-banner');
                jQuery.cookie('hide_system_message_banner', 'true');
            });
        });
        //top bar
        $('#header #home-button').click(function() {
            document.location.href = zz.routes.path_prefix + '/';
            ZZAt.track('button.home.click');
        });
        if (zz.rails_controller_name == 'photos' || zz.rails_controller_name == 'albums') {
            $('#header #view-buttons #grid-view-button').addClass('selected');
        }
        else if (zz.rails_controller_name == 'people') {
            $('#header #view-buttons #people-view-button').addClass('selected');
        }
        else if (zz.rails_controller_name == 'activities') {
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
            if (typeof( zz.album_base_url ) != 'undefined') {
                document.location.href = zz.album_base_url + "/photos";
            } else {
                document.location.href = zz.displayed_user_base_url;
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
            document.location.href = zz.album_base_url + "/photos/#!";
        });

        $('#header #view-buttons #people-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.peopleview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #people-view-button').addClass('selected');
            $('#article').fadeOut(200);
            if (typeof( zz.album_base_url ) != 'undefined') {
                document.location.href = zz.album_base_url + "/people";
            } else {
                document.location.href = zz.displayed_user_base_url + "/people";
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
            if (typeof( zz.album_base_url ) != 'undefined') {
                document.location.href = zz.album_base_url + "/activities";
            } else {
                document.location.href = zz.displayed_user_base_url + "/activities";
            }
        });

        $('#header #help-button').click(function(event) {
            ZZAt.track('button.help.click');
            //feedback_widget.show();
            Zenbox.show(event);

            //hack: force zendesk dialog to show scrollbars if screen too small
            $('#zenbox_body').css({height:jQuery(window).height() - 100})
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
                top:0,
                left:0,
                height:'100%',
                width:'100%',
                'z-index':3000,
                'background-color':'#000000',
                opacity: 0
            }).appendTo('body').animate({opacity:1}, 500, function() {
                document.location.href = zz.album_base_url + '/movie?start=' + zz.current_photo_index + '&return_to=' + encodeURIComponent(document.location.href);
            });

        });


        // new album button -- buttom toolbar
        $('#footer #new-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.createalbum.click');

            zz.init.disable_buttons();
            $('#footer #new-album-button').removeClass('disabled').addClass('selected');

            zz.toolbars.init_new_album();
            zz.wizard.create_group_album();
        });

        // new album buttons -- inline
        $('#inline-new-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.createalbum-top.click');

            zz.init.disable_buttons();
            $('#footer #new-album-button').removeClass('disabled').addClass('selected');

            zz.toolbars.init_new_album();
            zz.wizard.create_group_album();
        });


        // only album contributers can do this
        $('#footer #add-photos-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            zz.init.disable_buttons();
            $('#footer #add-photos-button').removeClass('disabled').addClass('selected');


            zz.photochooser.open_in_dialog(zz.album_id, function() {
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
                zz.sharemenu.show($(this), 'photo', photoId, {x:0,y:0}, 'toolbar', $.noop, $.noop);
            }
            else {
                zz.sharemenu.show($(this), 'album', zz.album_id, {x:0,y:0}, 'toolbar', $.noop, $.noop);
            }

        });

        //only album owner can do this
        $('#footer #edit-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;

            }
            ZZAt.track('button.editalbum.click');


            zz.init.disable_buttons();
            $('#footer #edit-album-button').removeClass('disabled').addClass('selected');
            zz.wizard.open_edit_album_wizard('add')
        });


        $('#footer #buy-button').click(function() {
            if (! $(this).hasClass('disabled')) {
                alert("This feature is still under construction.")
            }
        });
        zz.init.acct_badge();
        zz.init.like_button();

        setTimeout(function() {
            zz.init.preload_rollover_images();
        }, 500);

        zz.profile_pictures.init_profile_pictures($('.profile-picture'));


        zz.mobile.lock_page_scroll();
    },










    preload_rollover_images : function() {


        //wizard buttons/tabs
        for (var i = 1; i <= 6; i++) {
            var src = "/images/wiz-num-" + i + "-on.png"
            zz.image_utils.pre_load_image(zz.routes.image_url(src))

            var src = "/images/wiz-num-" + i + ".png"
            zz.image_utils.pre_load_image(zz.routes.image_url(src))
        }
    },


//====================================== Account Badge  ===========================================
    acct_badge: function() {
        zz.toolbars.init_acct_badge_menu();
        $('#account-badge').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            zz.toolbars.show_acct_badge_menu()
        });
    },

//======================================= Like Button  ==============================================
    like_button: function() {
        zz.toolbars.build_like_button();
        zz.like.init();
    }

};

