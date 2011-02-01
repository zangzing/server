/*!
 * zz.inits.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.init = {

    template: function(){
        /* Click Handlers
         ----------------------------------------------------------------------- */

        //top bar
        $('#header #home-button').click(function(){ document.location.href = '/' });

        $('#header #back-button').click(function(){ document.location.href = '/' });


        if(document.location.href.indexOf("/photos?view=slideshow") !== -1){
            $('#header #view-buttons #picture-view-button').addClass('selected');
        }
        else if(document.location.href.indexOf("/photos") !== -1){
            $('#header #view-buttons #grid-view-button').addClass('selected');
        }
        else if(document.location.href.indexOf("/people") !== -1){
            $('#header #view-buttons #people-view-button').addClass('selected');
        }
        else if(document.location.href.indexOf("/activities") !== -1){
            $('#header #view-buttons #activities-view-button').addClass('selected');
        }


        $('#header #view-buttons #grid-view-button').click(function(){
            document.location.href = '/albums/' + zz.album_id + "/photos";
        });

        $('#header #view-buttons #picture-view-button').click(function(){
            document.location.href = '/albums/' + zz.album_id + "/photos?view=slideshow";

        });

        $('#header #view-buttons #people-view-button').click(function(){
            document.location.href = '/albums/' + zz.album_id + "/people";

        });

        $('#header #view-buttons #activities-view-button').click(function(){
            document.location.href = '/albums/' + zz.album_id + "/activities";

        });

        $('#header #help-button').click(function(){
            feedback_widget.show();
        });


        $('#header #sign-in-button').click(function(){
            if (zz.drawer_state === zz.DRAWER_CLOSED) {
                $('#header #sign-in-button').addClass('selected');
                $('#sign-in').show();
                $('#sign-up').hide();

                $('#small-drawer').show().animate({height: '460px', top: '56px'},500, 'linear', function(){
                    $('#user_session_email').focus();
                });
                zz.drawer_state = zz.DRAWER_OPEN;
            }
        });



        $('#footer #play-button').click(function(){
            $('<div></div>').css({
                position: 'absolute',
                top:0,
                left:0,
                height:'100%',
                width:'100%',
                'z-index':3000,
                'background-color':'#000000',
                opacity: 0
            }).appendTo('body').animate({opacity:1},500, function(){
                document.location.href = '/albums/' + zz.album_id + '/photos?view=movie'; //global variable set in _bottom_nav
            });



        });

        $('#footer #new-album-button').click(function(){
            $('#footer #new-album-button').addClass('selected');


            zz.toolbars.init_new_album();
            zz.easy_drawer(600, 0.0, '/users/'+zz.current_user_id+'/albums/new', function(){
                $('#personal_album_link').click(zz.wizard.create_personal_album);
                $('#group_album_link').click(zz.wizard.create_group_album);
            });
        });



        //only album contributers can do this
        $('#footer #add-photo-button').click(function(){
            $('#footer #add-photo-button').addClass('selected');
            zz.wizard.open_edit_album_wizard('add')
        });

        //any signed in user can do this
        $('#footer #share-button').click(function(){
            $('#footer #share-button').addClass('selected');
            zz.wizard.open_edit_album_wizard('share')
        });

        //only album owner can do this
        $('#footer #edit-album-button').click(function(){
            $('#footer #edit-album-button').addClass('selected');
            zz.wizard.open_edit_album_wizard('add')
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
                $('#small-drawer').animate({height: '460px', top: '56px'}, 500, 'linear', function(){
                    $('#user_session_email').focus();
                });
            });


        });
        $('#step-join-off').click(function(){
            $('#small-drawer').animate({height: '0px', top: '28px'}, function(){
                $('#sign-up').show();
                $('#sign-in').hide();
                $('#small-drawer').animate({height: '460px', top: '56px'}, 500, 'linear', function(){
                    $('#user_name').focus();

                });
            });
        });

        $('#join_form_submit_button').click(function(){
            $('form#join-form').submit();
        });

        $('#join_form_cancel_button').click(function(){
            $('#small-drawer').animate({height: '0px', top: '28px'});
            zz.drawer_state = zz.DRAWER_CLOSED;
        });




        /* sign in   */
        /* ---------------------------------*/
        $('#signin-form-cancel-button').click(function(){
            $('#small-drawer').animate({height: '0px', top: '28px'});
            zz.drawer_state = zz.DRAWER_CLOSED;
        });


        $('#signin-form-submit-button').click(function(){
            $("form#new_user_session").submit();
        });

        //todo: why are these here
        $(zz.validate.sign_in.element).validate(zz.validate.sign_in);
        $(zz.validate.join.element).validate(zz.validate.join);


        zz.init.acct_badge();
        zz.init.like_menu();
        zz.init.buy_button();
        zz.init.preload_rollover_images();


    },


    loaded: function(){
        $('#drawer-content').ajaxError(function(event, request) {
            zz.wizard.display_errors( request, 50);
            zz.wizard.display_flashes(request, 50);
        });
        $('#drawer-content').ajaxSuccess(function(event, request) {
            zz.wizard.display_flashes(request, 50);
        });
    },

    resized: function(){
        if (zz.drawer_state == zz.DRAWER_OPEN) {
            zz.resize_drawer(50);
            //gow scroll body
        }
        // TODO: check for selected photo - move caption position
    },

    album: function(){
        //setup grid view

        var view = 'grid';

        if(document.location.href.indexOf('view=slideshow') !== -1){
            view = 'picture';
        }



        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json){


            var gridElement = $('<div class="photogrid-container"></div>');
            $('#article').html(gridElement);
            $('#article').css('overflow','hidden');

            if(view === 'grid'){
                for(var i =0;i<json.length;i++){
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src =       agent.checkAddCredentialsToUrl(photo.thumb_url);
                }

                var grid = gridElement.zz_photogrid({
                    photos:json,
                    allowDelete: false,
                    allowEditCaption: false,
                    allowReorder: false,
                    cellWidth: 200,
                    cellHeight: 200,
                    onClickPhoto: function(index, photo){
                        document.location.href = "/albums/" + zz.album_id +"/photos?view=slideshow#" + photo.id;
                    },
                    scrollToPhoto: $.param.fragment()

                }).data().zz_photogrid;



            }
            else{
                for(var i =0;i<json.length;i++){
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src =       agent.checkAddCredentialsToUrl(photo.screen_url);
                }

                var grid = gridElement.zz_photogrid({
                    photos:json,
                    allowDelete: false,
                    allowEditCaption: false,
                    allowReorder: false,
                    cellWidth: gridElement.width(),
                    cellHeight: gridElement.height(),
                    onClickPhoto: function(index, photo){
                        document.location.href = "/albums/" + zz.album_id +"/photos#" + photo.id;
                    },
                    singlePictureMode: true,
                    scrollToPhoto: $.param.fragment()

                }).data().zz_photogrid;


            }



                //setup upload progress smeter
                $('#progress-meter').hide();

                var updateProgressMeter = function(){

                    var photo_count = json.length; //todo: photos shouln't be a global variable

                    upload_stats.stats_for_album(zz.album_id,photo_count, function(time_remaining, percent_complete){
                        percent_complete = Math.round(percent_complete);

                        if(percent_complete < 100 ){
                            var minutes = Math.round(time_remaining / 60);
                            var step = 0;

                            if(percent_complete > 0){
                                step = Math.round(percent_complete / 6.25);
                            }


                            $('#progress-meter').css('background-image', 'url(/images/upload-'+ step +'.png)');


                            if(minutes === Infinity){
                                $('#nav-status').html("Calculating...");
                            }
                            else{
                                var minutes_text = "Minutes";
                                if(minutes === 1){
                                    minutes_text = "Minute"
                                }
                                $('#progress-meter-label').html(minutes + ' ' + minutes_text);
                            }

                            $('#progress-meter').show();
                        }
                        else{
                            $('#progress-meter').hide();
                        }
                    });
                }

                updateProgressMeter();

                //todo: need to shut this down if we leave album page ajax-ly
                //update album upload status every 10 seconds
                setInterval( updateProgressMeter ,10000);


            }
        });

    },


//    tray: function(){
//
//    },

    preload_rollover_images : function(){
        //todo: is there a way to query CSS to get all these?
        //wizard buttons/tabs
//        for(var i=1;i<=4; i++){
//            var src = "/images/bg-4step-strip-" + i + ".png"
//            image_preloader.load_image(src)
//
//            var src = "/images/bg-4step-edit-" + i + ".png"
//            image_preloader.load_image(src)
//        }
//
//        //wizard buttons/tabs
//        for(var i=1;i<=5; i++){
//            var src = "/images/bg-5step-strip-" + i + ".png"
//            image_preloader.load_image(src)
//
//            var src = "/images/bg-5step-edit-" + i + ".png"
//            image_preloader.load_image(src)
//        }
//
//        for(var i=1;i<=6; i++){
//            var src = "/images/bg-6step-strip-" + i + ".png"
//            image_preloader.load_image(src)
//
//            var src = "/images/bg-6step-edit-" + i + ".png"
//            image_preloader.load_image(src)
//        }
//
//
        for(var i=1;i<=6; i++){
            var src = "/images/wiz-num-" + i + "-on.png"
            image_preloader.load_image(src)

            var src = "/images/wiz-num-" + i + ".png"
            image_preloader.load_image(src)
        }




        //toolbar buttons
//        image_preloader.load_image("/images/btn-sign-in-on.png");

        //new album type rollover
        image_preloader.load_image("/images/bg-album-type-selected.png");

        //file chooser root folders rollover


        image_preloader.load_image("/images/folders/blank.png"); //for folder animate to tray

        image_preloader.load_image("/images/folders/blank_on.jpg");

        image_preloader.load_image("/images/folders/apple_on.jpg");
        image_preloader.load_image("/images/folders/facebook_on.jpg");
        image_preloader.load_image("/images/folders/flickr_on.jpg");
        image_preloader.load_image("/images/folders/myhome_on.jpg");
        image_preloader.load_image("/images/folders/kodak_on.jpg");
        image_preloader.load_image("/images/folders/mycomputer_on.jpg");
        image_preloader.load_image("/images/folders/mypictures_on.jpg");
        image_preloader.load_image("/images/folders/picasa_on.jpg");
        image_preloader.load_image("/images/folders/shutterfly_on.jpg");
        image_preloader.load_image("/images/folders/snapfish_on.jpg");
        image_preloader.load_image("/images/folders/smugmug_on.jpg");
        image_preloader.load_image("/images/folders/zangzing_on.jpg");

        image_preloader.load_image("/images/folders/blank_off.jpg");
        image_preloader.load_image("/images/folders/apple_off.jpg");
        image_preloader.load_image("/images/folders/facebook_off.jpg");
        image_preloader.load_image("/images/folders/flickr_off.jpg");
        image_preloader.load_image("/images/folders/myhome_off.jpg");
        image_preloader.load_image("/images/folders/kodak_off.jpg");
        image_preloader.load_image("/images/folders/mycomputer_off.jpg");
        image_preloader.load_image("/images/folders/mypictures_off.jpg");
        image_preloader.load_image("/images/folders/picasa_off.jpg");
        image_preloader.load_image("/images/folders/shutterfly_off.jpg");
        image_preloader.load_image("/images/folders/snapfish_off.jpg");
        image_preloader.load_image("/images/folders/smugmug_off.jpg");
        image_preloader.load_image("/images/folders/zangzing_off.jpg");
        image_preloader.load_image("/images/folders/photobucket_off.jpg");



        //album privacy
        image_preloader.load_image("/images/bg-privacy-public-off.png");
        image_preloader.load_image("/images/bg-privacy-private-off.png");
        image_preloader.load_image("/images/bg-privacy-password-off.png");
        image_preloader.load_image("/images/bg-privacy-public-on.png");
        image_preloader.load_image("/images/bg-privacy-private-on.png");
        image_preloader.load_image("/images/bg-privacy-password-on.png");



        //share album
        image_preloader.load_image("/images/btn-share-by-post.png");
        image_preloader.load_image("/images/btn-share-by-post-on.png");
        image_preloader.load_image("/images/btn-share-by-email.png");
        image_preloader.load_image("/images/btn-share-by-email-on.png");

        //drawer images types
        image_preloader.load_image("/images/bg-drawer-bottom-cap.png");
        image_preloader.load_image("/images/bg-bottom-repeat.png");

        //album types
        image_preloader.load_image("/images/bg-album-type.png");
        image_preloader.load_image("/images/stack-group.png");
        image_preloader.load_image("/images/btn-type-group.png");
        image_preloader.load_image("/images/stack-personal.png");
        image_preloader.load_image("/images/btn-type-personal.png");
        image_preloader.load_image("/images/stack-event.png");
        image_preloader.load_image("/images/btn-type-event.png");
        image_preloader.load_image("/images/stack-stream.png");
        image_preloader.load_image("/images/btn-type-streaming.png");

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

    album_people_view: function(){
        zz.init.album_timeline_or_people_view('people');
    },

    album_timeline_view: function(){
        zz.init.album_timeline_or_people_view('timeline');  

    },

    album_timeline_or_people_view: function(which){
        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json){

                for(var i =0;i<json.length;i++){
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src =       agent.checkAddCredentialsToUrl(photo.thumb_url);
                }

                
                $('.timeline-grid').each(function(index, element){

                    $(element).empty();

                    var filteredPhotos = null;


                    if(which === 'timeline'){
                        var batchId = parseInt($(element).attr('data-upload-batch-id'));

                        filteredPhotos = $(json).filter(function(index){
                            return (json[index].upload_batch_id === batchId)
                        });
                    }
                    else{
                        var userId = $(element).attr('data-user-id');

                        filteredPhotos = $(json).filter(function(index){
                            return (json[index].user_id === userId)
                        });
                    }





                    var grid = $(element).zz_photogrid({
                        photos:filteredPhotos,
                        allowDelete: false,
                        allowEditCaption: false,
                        allowReorder: false,
                        cellWidth: 180,
                        cellHeight: 180,
                        onClickPhoto: function(index, photo){
                            document.location.href = "/albums/" + zz.album_id +"/photos?view=slideshow#" + photo.id;
                        },
                        showThumbscroller: false
                    }).data().zz_photogrid;


                    var allShowing = false;
                    var moreLessbuttonElement = $(element).siblings('.more-less-btn');

                    moreLessbuttonElement.click(function(){
                        if(allShowing){
                            $(element).animate({height:180}, 500, 'swing', function(){
                                moreLessbuttonElement.html("more...");
                            });
                            allShowing = false;
                        }
                        else{
                            $(element).animate({height: $(element).children().last().position().top + 180}, 500, 'swing', function(){
                                $(element).trigger('scroll');  //hack: force the photos to load themselves now that they are visible
                                moreLessbuttonElement.html("less...");
                            });
                            allShowing = true;

                        }
                    });
                });
            }
        });
    },

//====================================== Account Badge  ===========================================
    acct_badge: function(){
        zz.toolbars.init_acct_badge_menu();
        $('#account-badge').click( zz.toolbars.show_acct_badge_menu );
    },

//======================================= Like Menu  ==============================================
    like_menu: function(){
        zz.toolbars.init_like_menu();
        $('#footer #like-button').click( zz.toolbars.show_like_menu );
    },
//======================================   ===============================================
    buy_button: function(){

    }

}; // end zz.init
