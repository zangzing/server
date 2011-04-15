/*!
 * zz.inits.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

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
    enable_buttons:function(){
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



        //tooltips
        $('<span class="tooltip">&nbsp;</span>').appendTo('body');
        $(".has-tooltip").each(function(index){


            $(this).tooltip({
                tip: '.tooltip',
                effect: 'fade',
                fadeOutSpeed: 100,
                predelay: 100,
//                position: "right",
                offset: [$(this).height() * .5, $(this).width() * .75]
            });


        });


        /* Click Handlers    ----------------------------------------------------------------------- */


        //top bar
        $('#header #home-button').click(function() {
            document.location.href = zz.path_prefix + '/';
            ZZAt.track('button.home.click');
        });


        if(zz.rails_controller_name == 'photos'){
            $('#header #view-buttons #grid-view-button').addClass('selected');
        }
        else if(zz.rails_controller_name == 'people'){
            $('#header #view-buttons #people-view-button').addClass('selected');
        }
        else if(zz.rails_controller_name == 'activities'){
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
            document.location.href = zz.album_base_url + "/photos";
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
            document.location.href = zz.album_base_url + "/people";
        });

        $('#header #view-buttons #activities-view-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.activitiesview.click');
            $('#header #view-buttons').children().removeClass('selected');
            $('#header #view-buttons #activities-view-button').addClass('selected');
            $('#article').fadeOut(200);
            document.location.href = zz.album_base_url + "/activities";
        });

        $('#header #help-button').click(function(event) {
            ZZAt.track('button.help.click');
            //feedback_widget.show();
            Zenbox.show(event);

            //hack: force zendesk dialog to show scrollbars if screen too small
            $('#zenbox_body').css({height:jQuery(window).height()-100})



        });

        $('#header #sign-in-button').click(function() {
            ZZAt.track('button.signin.click');
            document.location.href = "/signin";
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
                document.location.href = zz.album_base_url + '/movie';
            });

        });


        $('#footer #new-album-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }
            ZZAt.track('button.createalbum.click');

            zz.init.disable_buttons();
            $('#footer #new-album-button').removeClass('disabled').addClass('selected');

            zz.toolbars.init_new_album();
            zz.wizard.create_group_album();

//            zz.easy_drawer(600, 0.0, '/users/' + zz.current_user_id + '/albums/new', function() {
//                $('#personal_album_link').click(function() {
//                    zz.wizard.create_personal_album();
//                    ZZAt.track('button.createpersonalalbum.click');
//                });
//
//                $('#group_album_link').click(function() {
//                    zz.wizard.create_group_album();
//                    ZZAt.track('button.creategroupalbum.click');
//                });
//            });
        });


        //only album contributers can do this
        $('#footer #add-photos-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            zz.init.disable_buttons();
            $('#footer #add-photos-button').removeClass('disabled').addClass('selected');

            photochooser.open_in_dialog(zz.album_id, function(){
                 window.location.reload( false );
            });


//            var template = $('<div class="photochooser-container"></div>');
//            $('<div id="add-photos-dialog"></div>').html( template ).zz_dialog({
//                                   height: $(document).height() - 200,
//                                   width: 895,
//                                   modal: true,
//                                   autoOpen: true,
//                                   open : function(event, ui){ template.zz_photochooser({}) },
//                                   close: function(event, ui){
//                                       $.ajax({ url:      zz.path_prefix + '/albums/' +zz.album_id + '/close_batch',
//                                           complete: function(request, textStatus){
//                                               logger.debug('Batch closed because Add photos dialog was closed. Call to close_batch returned with status= '+textStatus);
//                                           },
//                                           success: function(){
//                                               window.location.reload( false );
//                                           }
//                                       });
//                                   }
//                               });
//            template.height( $(document).height() - 192 );


        });

        //any signed in user can do this
        $('#footer #share-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            ZZAt.track('button.share.click');

            zz.init.disable_buttons();
            $('#footer #share-button').removeClass('disabled').addClass('selected');


            //todo: need better generic way to determine current view and get photo id -- this is duplicated elsewhere
            if (document.location.href.indexOf('/photos/#!') !== -1 || document.location.href.indexOf('/photos#!') !== -1) {
                $('#footer #share-button').removeClass('selected');  
                zz.init.enable_buttons();
                alert("This feature is still under construction.");
//                //picture view -- share photo
//                var currentPhotoId = null;
//                var hash = jQuery.param.fragment();
//
//                if (hash !== '') {
//                    currentPhotoId = hash.slice(1); //remove the '!'
//                }
//                pages.share.share_in_dialog('photo', currentPhotoId, function(){
//                    zz.init.enable_buttons();
//                    $('#footer #share-button').removeClass('selected');  //todo: centralize this somewhere -- zz.toolbars
//                });
            }
            else{
                //album view -- share album
                pages.share.share_in_dialog('album', zz.album_id, function(){
                    zz.init.enable_buttons();
                    $('#footer #share-button').removeClass('selected');  //todo: centralize this somewhere -- zz.toolbars
                });

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


        $('#footer #buy-button').click(function(){
            alert("This feature is still under construction.")
        });


        /* new user stuff   */
        /* ---------------------------------*/

//        $('#user_username').keyup(function(event) {
//            var value = $('#user_username').val();
//            $('#update-username').empty().text(value);
//        });
//
//        $('#step-sign-in-off').click(function() {
//            $('#small-drawer').animate({height: '0px', top: '28px'}, function() {
//                $('#sign-in').show();
//                $('#sign-up').hide();
//                $('#small-drawer').animate({height: '480px', top: '56px'}, 500, 'linear', function() {
//                    $('#user_session_email').focus();
//                });
//            });
//
//
//        });
//        $('#step-join-off').click(function() {
//            $('#small-drawer').animate({height: '0px', top: '28px'}, function() {
//                $('#sign-up').show();
//                $('#sign-in').hide();
//                $('#small-drawer').animate({height: '480px', top: '56px'}, 500, 'linear', function() {
//                    $('#user_name').focus();
//
//                });
//            });
//        });
//
//        $('#join_form_submit_button').click(function() {
//            $('form#join-form').submit();
//        });
//
//        $('#join_form_cancel_button').click(function() {
//            //todo: move this to pages.signing
//            $('#small-drawer').animate({height: '0px', top: '28px'});
//            zz.drawer_state = zz.DRAWER_CLOSED;
//            $('#header #sign-in-button').removeClass('selected');
//
//        });
//
//        $('form#join-form').submit(function(){
//            ZZAt.track('button.join.click');
//        });
//
//
//        $('form#join-form').bind('keypress', function(e){
//              if ( e.keyCode == 13 ) {
//                  $("form#join-form").submit();
//              }
//        });



        /* sign in   */
        /* ---------------------------------*/
//        $('#signin-form-cancel-button').click(function() {
//            //todo: move this to pages.signing
//            $('#small-drawer').animate({height: '0px', top: '28px'});
//            zz.drawer_state = zz.DRAWER_CLOSED;
//            $('#header #sign-in-button').removeClass('selected');
//
//        });
//
//
//        $('#signin-form-submit-button').click(function() {
//            $("form#new_user_session").submit();
//        });
//
//
//         $('form#new_user_session').bind('keypress', function(e){
//               if ( e.keyCode == 13 ) {
//                   $("form#new_user_session").submit();
//               }
//         });
//
//        //todo: why are these here
//        $(zz.validate.sign_in.element).validate(zz.validate.sign_in);
//        $(zz.validate.join.element).validate(zz.validate.join);


        zz.init.acct_badge();
        zz.init.like_menu();

        setTimeout(function() {
            zz.init.preload_rollover_images();
        }, 500);


        profile_pictures.init_profile_pictures();


    },

    show_welcome_dialog: function(){
        $('<iframe frameborder="0" height="450" width="780" border="0" src="/static/welcome_dialog/index.html"></iframe>').zz_dialog({
            height: 420,
            width: 750,
            modal: true,
            autoOpen: true
        });
    },


    loaded: function() {
        $('#drawer-content').ajaxError(function(event, request) {
            zz.wizard.display_errors(request, 50);
            zz.wizard.display_flashes(request, 50);
        });
        $('#drawer-content').ajaxSuccess(function(event, request) {
            zz.wizard.display_flashes(request, 50);
        });
    },

    resized: function() {
        if (zz.drawer_state == zz.DRAWER_OPEN) {
            zz.resize_drawer(50);
            //gow scroll body
        }
        // TODO: check for selected photo - move caption position
    },

    init_back_button: function(caption, url){
        $('#header #back-button span').text(caption);

        $('#header #back-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            $('#article').animate({left: $('#article').width()}, 500, 'easeOutQuart');
            document.location.href = url;
        });
    },

    //todo: move this somewhere else
    filterPhotosForUser: function(photos){
        //filter photos that haven't finished uploading
        return $.map(photos, function(element, index){
            if (element['state'] !== 'ready'){
               if(_.isUndefined(zz.current_user_id) || element['user_id']!=zz.current_user_id){
                   return null;
               }
           }
           return element;
        });
   },

    album: function() {
        //setup grid view

        var view = 'grid';

        if (document.location.href.indexOf('#!')!== -1) { 
            view = 'picture';
        }

        if(view === 'grid'){
            this.init_back_button('All Albums', zz.back_to_home_page_url);
        }
        else{
            this.init_back_button(zz.album_name, zz.album_base_url + '/photos');
        }


        $.ajax({
            dataType: 'json',
            url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json) {


                ZZAt.track('album.view',{id:zz.album_id});

                json = zz.init.filterPhotosForUser(json);


                //no movie mode if no photos
                if(json.length == 0){
                    $('#footer #play-button').addClass('disabled');
                }


                if (view === 'grid') {   //grid view

                    var gridElement = $('<div class="photogrid"></div>');

                    $('#article').html(gridElement);
                    $('#article').css('overflow', 'hidden');


                    for (var i = 0; i < json.length; i++) {
                        var photo = json[i];
                        photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                        photo.src = agent.checkAddCredentialsToUrl(photo.thumb_url);
                    }




                    

                    var grid = gridElement.zz_photogrid({
                        photos:json,
                        allowDelete: false,
                        allowEditCaption: false,
                        allowReorder: false,
                        cellWidth: 230,
                        cellHeight: 230,
                        showThumbscroller: false,
                        onClickPhoto: function(index, photo) {

                            //get rid of scrollbars before animate transition
                            grid.hideThumbScroller();   
                            gridElement.css({overflow:'hidden'});

                            $('#article').css({overflow:'hidden'}).animate({left: -1 * $('#article').width()},500,'easeOutQuart');
                            document.location.href = zz.album_base_url + "/photos/#!" + photo.id;
                        },
                        currentPhotoId: $.param.fragment(),
                        showButtonBar:true,
                        onClickShare: function(photo_id){
                            alert("This feature is still under construction.");
//                            pages.share.share_in_dialog('photo', photo_id);
                        }

                    }).data().zz_photogrid;


                }
                else {    //single picture view
                    //hide view selectors
                    $('#view-buttons').hide();


                    var renderPictureView = function(){
                        var gridElement = $('<div class="photogrid"></div>');

                        $('#article').html(gridElement);
                        $('#article').css('overflow', 'hidden');




                        var bigScreen = ($(window).width() > 1200 && $(window).height() > 1000);

                        for (var i = 0; i < json.length; i++) {
                            var photo = json[i];
                            photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                            if(bigScreen){
                                photo.src = agent.checkAddCredentialsToUrl(photo.full_screen_url);
                            }
                            else{
                                photo.src = agent.checkAddCredentialsToUrl(photo.screen_url);
                            }
                        }

                        var currentPhotoId = null;
                        var hash = jQuery.param.fragment();

                        if (hash !== '') {
                            currentPhotoId = hash.slice(1); //remove the '!'
                        }



                        var grid = gridElement.zz_photogrid({
                            photos:json,
                            allowDelete: false,
                            allowEditCaption: false,
                            allowReorder: false,
                            cellWidth: gridElement.width(),
                            cellHeight: gridElement.height() - 20,
                            onClickPhoto: function(index, photo) {
                                grid.nextPicture();
                                ZZAt.track('button.next.click');//todo: phil, is this right?
                            },
                            singlePictureMode: true,
                            currentPhotoId: currentPhotoId,
                            onScrollToPhoto: function(photoId) {
                                window.location.hash = '#!' + photoId
                                ZZAt.track('photo.view',{id:photoId});

                            }


                        }).data().zz_photogrid;

                        $('#footer #next-button').unbind('click');
                        $('#footer #next-button').show().click(function() {
                            grid.nextPicture();
                            ZZAt.track('button.next.click');
                        });

                        $('#footer #prev-button').unbind('click');
                        $('#footer #prev-button').show().click(function() {
                            grid.previousPicture();
                            ZZAt.track('button.previous.click');
                        });

                    };

                    renderPictureView();


                    //handle resize
                    var resizeTimer = null;
                    $(window).resize(function(event){
                        if(resizeTimer){
                            clearTimeout(resizeTimer);
                            resizeTimer = null;
                        }

                        resizeTimer = setTimeout(function(){
                            renderPictureView();
                        },100);
                    });
                    







                }


//                //setup upload progress smeter
//                $('#progress-meter').hide();
//
//                var updateProgressMeter = function() {
//
//                    var photo_count = json.length; //todo: photos shouln't be a global variable
//
//                    upload_stats.stats_for_album(zz.album_id, photo_count, function(time_remaining, percent_complete) {
//                        percent_complete = Math.round(percent_complete);
//
//                        if (percent_complete < 100) {
//                            var minutes = Math.round(time_remaining / 60);
//                            var step = 0;
//
//                            if (percent_complete > 0) {
//                                step = Math.round(percent_complete / 6.25);
//                            }
//
//
//                            $('#progress-meter').css('background-image', 'url(/images/upload-' + step + '.png)');
//
//
//                            if (minutes === Infinity) {
//                                $('#nav-status').text("Calculating...");
//                            }
//                            else {
//                                var minutes_text = "Minutes";
//                                if (minutes === 1) {
//                                    minutes_text = "Minute"
//                                }
//                                $('#progress-meter-label').text(minutes + ' ' + minutes_text);
//                            }
//
//                            $('#progress-meter').show();
//                        }
//                        else {
//                            $('#progress-meter').hide();
//                        }
//                    });
//                }
//
//                updateProgressMeter();
//
//                //todo: need to shut this down if we leave album page ajax-ly
//                //update album upload status every 10 seconds
//                setInterval(updateProgressMeter, 10000);

                // Update the like array if it exists.
                if (typeof( like ) != 'undefined') {
                    var wanted_subjects = {};
                    for (key in json) {
                        id = json[key].id;
                        wanted_subjects[id] = 'photo';
                    }
                    like.add_id_array(wanted_subjects);
                }
            }
        });

    },




    preload_rollover_images : function() {


        //wizard buttons/tabs
        for (var i = 1; i <= 6; i++) {
            var src = "/images/wiz-num-" + i + "-on.png"
            image_utils.pre_load_image(path_helpers.image_url(src))

            var src = "/images/wiz-num-" + i + ".png"
            image_utils.pre_load_image(path_helpers.image_url(src))
        }
    },

    album_people_view: function() {
        zz.init.album_timeline_or_people_view('people');
    },

    album_timeline_view: function() {
        zz.init.album_timeline_or_people_view('timeline');

    },

    album_timeline_or_people_view: function(which) {

        this.init_back_button('All Albums', zz.back_to_home_page_url);


        $.ajax({
            dataType: 'json',
            url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json) {

                json = zz.init.filterPhotosForUser(json);


                //no movie mode if no photos
                if(json.length == 0){
                    $('#footer #play-button').addClass('disabled');
                }

                for (var i = 0; i < json.length; i++) {
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src = agent.checkAddCredentialsToUrl(photo.thumb_url);
                }


                $('.timeline-grid').each(function(index, element) {

                    $(element).empty();

                    var filteredPhotos = null;


                    if (which === 'timeline') {
                        var batchId = parseInt($(element).attr('data-upload-batch-id'));

                        filteredPhotos = $(json).filter(function(index) {
                            return (json[index].upload_batch_id === batchId)
                        });
                        var moreLessbuttonElement = $('.viewlist .more-less-btn[data-upload-batch-id="'+batchId.toString()+'"]');
                    }else{
                        var userId = parseInt($(element).attr('data-user-id'));

                        filteredPhotos = $(json).filter(function(index){
                            return (json[index].user_id === userId )
                        });
                        var moreLessbuttonElement = $('.viewlist .more-less-btn[data-user-id="'+userId.toString()+'"]');
                    }


                    var grid = $(element).zz_photogrid({
                        photos:filteredPhotos,
                        allowDelete: false,
                        allowEditCaption: false,
                        allowReorder: false,
                        cellWidth: 230,
                        cellHeight: 230,
                        onClickPhoto: function(index, photo) {
                            $('#article').css({overflow:'hidden'}).animate({left: -1 * $('#article').width()},500,'easeOutQuart');
                            document.location.href = zz.album_base_url + "/photos/#!" + photo.id;
                        },
                        showThumbscroller: false,
                        showButtonBar:true,
                        onClickShare: function(photo_id){
                            pages.share.share_in_dialog('photo', photo_id);
                        }


                    }).data().zz_photogrid;


                    //force this back because grid turns on scrolling
                    $(element).css({'overflow-x':'hidden', 'overflow-y':'hidden'});

                    var allShowing = false;


                    //var moreLessbuttonElement = $(element).siblings('.more-less-btn');
                    moreLessbuttonElement.click(function(){
                        if(allShowing){
                            moreLessbuttonElement.find("span").html("Show more photos");
                            moreLessbuttonElement.removeClass('open');
                            $(element).animate({height:230}, 500, 'swing', function(){
                            });
                            allShowing = false;
                        }
                        else {
                            moreLessbuttonElement.find("span").html("Show fewer photos");
                            moreLessbuttonElement.addClass('open');
                            $(element).animate({height: $(element).children().last().position().top + 180}, 500, 'swing', function() {
                                $(element).trigger('scroll');  //hack: force the photos to load themselves now that they are visible
                            });
                            allShowing = true;

                        }
                    });
                });
            }
        });
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

//======================================= Like Menu  ==============================================
    like_menu: function() {
        var menu = $(zz.toolbars.build_like_menu()).zzlike_menu();
        like.init();

        $('#footer #like-button').click(function(event) {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            ZZAt.track('button.like.click');

            $(menu).zzlike_menu('open', this);
            event.stopPropagation();
        });
    }

};
