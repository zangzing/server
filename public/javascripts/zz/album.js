var zz = zz || {};

zz.album = {};


(function(){


    var current_photo_id = null;
    var current_photo_json = null;

    var is_single_picture_view = false;

    zz.album.init_picture_view = function(photo_id) {

        current_photo_id = photo_id;

        init_back_button(zz.page.album_base_url + '/photos');

        $('#view-buttons').fadeOut('fast');

        zz.buy.toggle_visibility_with_buy_mode($('#footer #comments-button'));

        zz.buy.on_change_buy_mode(function(){
            render_picture_view();
        });

        zz.buy.on_change_selected_photos(function(){
            update_checkmarks_on_photos();
        });

        zz.buy.on_before_activate(function(){
            var photo = zz.routes.photos.get_photo_json(current_photo_id);
            if(!zz.buy.is_photo_selected(current_photo_id)){
                zz.buy.add_selected_photo(current_photo_json);
            }
            ZZAt.track('photo.buy.toolbar.click');
        });


        // setup comments drawer
        zz.comments.init_toolbar_button_and_drawer(current_photo_id, function(){
            render_picture_view();
        });


        is_single_picture_view = true;

    };

    zz.album.is_single_picture_view = function(){
        return is_single_picture_view;
    };

    zz.album.goto_single_picture = function(photo_id){
        //get rid of scrollbars before animate transition
        $('.photogrid').css({overflow: 'hidden'});
        $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
        $('#header #top-breadcrumb').fadeOut(200);
        document.location.href = zz.page.album_base_url + '/photos/#!' + photo_id;
    };

    zz.album.init_grid_view = function() {

        init_back_button(zz.page.back_to_home_page_url);

        zz.buy.on_before_change_buy_mode(function(){
            $('.photogrid').fadeOut('fast');
        });

        zz.buy.on_change_buy_mode(function(){
            render_grid_view();
        });

        zz.buy.on_change_selected_photos(function(){
            update_checkmarks_on_photos();
        });

        zz.buy.on_before_activate(function(){
            ZZAt.track('album.buy.toolbar.click');
        });


        render_grid_view();

    };

    zz.album.init_timeline_view = function() {
        init_timeline_or_people_view('timeline');
        zz.buy.on_before_activate(function(){
            ZZAt.track('album.buy.toolbar.click');
        });
    };


    zz.album.init_people_view = function() {
        init_timeline_or_people_view('people');
        zz.buy.on_before_activate(function(){
            ZZAt.track('album.buy.toolbar.click');
        });
    };





    /*           Private Stuff
     ***************************************************/

    function render_grid_view(){
        load_photos_json(function(json) {

            var buy_mode = zz.buy.is_buy_mode_active();

            //no movie mode if no photos
            if (json.length == 0) {
                $('#footer #play-button').addClass('disabled');
            }


            var gridElement = $('<div class="photogrid"></div>');

            $('#article').html(gridElement);
            $('#article').css('overflow', 'hidden');


            for (var i = 0; i < json.length; i++) {
                var photo = json[i];
                photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);

                if(buy_mode){
                    photo.checked = zz.buy.is_photo_selected(photo.id);
                }

            }


            // add placeholder for add-all button
            if(buy_mode){
                var addAllButton = {
                    id: 'add-all-photos',
                    src: zz.routes.image_url('/images/blank.png'),
                    caption: '',
                    type: 'blank'
                };

                json.unshift(addAllButton);
            }


            var grid = gridElement.zz_photogrid({
                photos: json,
                allowDelete: false,
                allowEditCaption: false,
                allowReorder: false,
                cellWidth: 230,
                cellHeight: 230,
                showThumbscroller: false,
                onClickPhoto: function(index, photo, element, action) {
                    if(!buy_mode){
                        zz.album.goto_single_picture(photo.id);
                    }
                    else{
                        if(action=='main'){
                            buy_photo(photo, element);
                        }
                        else if(action='magnify'){
                            zz.album.goto_single_picture(photo.id);
                        }
                    }
                },
                onDelete: function(index, photo) {
                    zz.routes.call_delete_photo(photo.id);
                    return true;
                },
                showButtonBar: !buy_mode,
                context: buy_mode ? 'chooser-grid' : 'album-grid',
                infoMenuTemplateResolver: info_menu_template_resolver,
                rolloverFrameContainer: gridElement
            }).data().zz_photogrid;



            if (buy_mode) {
                var addAllButton = $('<img class="add-all-button" src="' + zz.routes.image_url('/images/folders/add_all_photos.png') + '">');
                addAllButton.click(function() {
                    zz.buy.add_all_photos_from_current_album();
                });

                gridElement.find('.photogrid-cell:first').append(addAllButton);
            }



        });

    }


    function render_picture_view(){
        load_photos_json(function(json) {

            var render = function() {


                var buy_mode = zz.buy.is_buy_mode_active();
                

                // figure out which image size to use based
                // on screen size
                var bigScreen = ($(window).width() > 1200 && $(window).height() > 1000);
                for (var i = 0; i < json.length; i++) {
                    var photo = json[i];
                    photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                    if (bigScreen) {
                        photo.src = zz.agent.checkAddCredentialsToUrl(photo.full_screen_url);
                    }
                    else {
                        photo.src = zz.agent.checkAddCredentialsToUrl(photo.screen_url);
                    }

                    if(buy_mode){
                        photo.checked = zz.buy.is_photo_selected(photo.id);
                    }


                }

                var gridElement = $('<div class="photogrid"></div>');

                $('#article').css('overflow', 'hidden');

                $('#article .photogrid').remove();
                $('#article').append(gridElement);

//                if (comments_open()){
//                    gridElement.css({right: '450px'});
//                }


                var grid = gridElement.zz_photogrid({
                    photos: json,
                    allowDelete: false,
                    allowEditCaption: false,
                    allowReorder: false,
                    cellWidth: gridElement.width(),
                    cellHeight: gridElement.height() - 20,

                    onClickPhoto: function(index, photo, element, action) {
                        if(!buy_mode){
                            grid.nextPicture();
                            ZZAt.track('button.next.click');
                        }
                        else{
                            if(action=='main'){
                                buy_photo(photo, element);
                            }
                            else if(action='magnify'){
                                click_back_button();
                            }
                        }
                    },


                    singlePictureMode: true,
                    currentPhotoId: current_photo_id,
                    onScrollToPhoto: function(photoId, index) {
                        window.location.hash = '#!' + photoId;
                        zz.page.current_photo_index = index; //this is used when we go to movie mode
                        current_photo_id = photoId;
                        current_photo_json = json[index];

                        zz.comments.set_current_photo_id(photoId);

                       
                        ZZAt.track('photo.view', {id: photoId});
                    },
                    context: buy_mode ? 'chooser-picture' : 'album-grid'



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

            render();

            //handle resize
            var resizeTimer = null;
            $(window).resize(function(event) {
                if (resizeTimer) {
                    clearTimeout(resizeTimer);
                    resizeTimer = null;
                }

                resizeTimer = setTimeout(function() {
                    render();
                }, 100);
            });
        });

    }



    function buy_photo(photo_json, element){
        if(zz.buy.is_photo_selected(photo_json.id)){

        }
        else{
            zz.buy.add_selected_photo(photo_json, element);
        }
    }


    function info_menu_template_resolver(photo_json) {
        if (zz.page.displayed_user_id == zz.session.current_user_id) {
            if (photo_json.state == 'ready') {
                return zz.infomenu.album_owner_template;
            }
            else {
                return zz.infomenu.album_owner_template_photo_not_ready;
            }
        }
        else if (photo_json.user_id == zz.session.current_user_id) {
            if (photo_json.state == 'ready') {
                return zz.infomenu.photo_owner_template;
            }
            else {
                return zz.infomenu.photo_owner_template_photo_not_ready;
            }
        }
        else if (zz.page.current_user_can_download) {
            return zz.infomenu.download_template;
        }
        else {
            return false;
        }
    }


    function load_photos_json(callback){

        ZZAt.track('album.view', {id: zz.page.album_id});


        zz.routes.photos.get_album_photos_json(zz.page.album_id, zz.page.album_cache_version_key, function(json){
            json = filterPhotosForUser(json);

            callback(json);


            // setup like
            var wanted_subjects = {};
            for (var key in json) {
                var id = json[key].id;
                wanted_subjects[id] = 'photo';
            }
            zz.like.add_id_array(wanted_subjects);

            //no movie mode if no photos
            if (json.length == 0) {
                $('#footer #play-button').addClass('disabled');
            }
        });
    };

    function init_timeline_or_people_view(which) {

        init_back_button(zz.page.back_to_home_page_url);

        $('#article').touchScrollY();


        zz.buy.on_before_change_buy_mode(function(){
            $('.photogrid').fadeOut('fast');
        });

        zz.buy.on_change_buy_mode(function(){
            render_timeline_or_people_view(which);
        });

        zz.buy.on_change_selected_photos(function(){
            update_checkmarks_on_photos();
        });




        render_timeline_or_people_view(which);



    }


    function render_timeline_or_people_view(which){
        load_photos_json(function(json) {


            var buy_mode = zz.buy.is_buy_mode_active();


            for (var i = 0; i < json.length; i++) {
                var photo = json[i];
                photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);

                if(buy_mode){
                    photo.checked = zz.buy.is_photo_selected(photo.id);
                }

            }


            $('.timeline-grid').each(function(index, element) {

                $(element).empty();

                //in case this is a re-render
                if($(element).data().zz_photogrid){
                    $(element).data().zz_photogrid.destroy();
                }


                var filteredPhotos = null;

                if (which === 'timeline') {
                    if (!_.isUndefined($(element).attr('data-upload-batch-id'))) {
                        var batchId = parseInt($(element).attr('data-upload-batch-id'));
                        filteredPhotos = $(json).filter(function(index) {
                            return (json[index].upload_batch_id === batchId);
                        });
                        var moreLessbuttonElement = $('.viewlist .more-less-btn[data-upload-batch-id="' + batchId.toString() + '"]');
                    }
                    else if (!_.isUndefined($(element).attr('data-photo-id'))) {
                        var photoId = parseInt($(element).attr('data-photo-id'));
                        filteredPhotos = $(json).filter(function(index) {
                            return (json[index].id === photoId);
                        });
                    }
                }
                else {
                    var userId = parseInt($(element).attr('data-user-id'));

                    filteredPhotos = $(json).filter(function(index) {
                        return (json[index].user_id === userId);
                    });
                    var moreLessbuttonElement = $('.viewlist .more-less-btn[data-user-id="' + userId.toString() + '"]');
                }


                var grid = $(element).zz_photogrid({
                    photos: filteredPhotos,
                    allowDelete: false,
                    allowEditCaption: false,
                    allowReorder: false,
                    cellWidth: 230,
                    cellHeight: 230,
                    onClickPhoto: function(index, photo, element, action) {
                        if(!buy_mode){
                            $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                            $('#header #top-breadcrumb').fadeOut(200);
                            document.location.href = zz.page.album_base_url + '/photos/#!' + photo.id;
                        }
                        else{
                            if(action=='main'){
                                buy_photo(photo, element);
                            }
                            else if(action='magnify'){
                                zz.album.goto_single_picture(photo.id);
                            }
                        }
                    },

                    showThumbscroller: false,
                    onClickShare: function(photo_id) {
                        zz.pages.share.share_in_dialog('photo', photo_id);
                    },
                    onDelete: function(index, photo) {
                        zz.routes.call_delete_photo(photo.id);
                        return true;
                    },
                    infoMenuTemplateResolver: info_menu_template_resolver,
                    centerPhotos: false,
                    rolloverFrameContainer: $('#article'),
                    showButtonBar: !buy_mode,
                    context: buy_mode ? 'chooser-grid' : 'album-grid'


                }).data().zz_photogrid;



                //force this back because grid turns on scrolling
                $(element).css({'overflow-x': 'hidden', 'overflow-y': 'hidden'});


                var allShowing = false;


                //var moreLessbuttonElement = $(element).siblings('.more-less-btn');
                if (!_.isUndefined(moreLessbuttonElement)) {
                    moreLessbuttonElement.click(function() {
                        if (allShowing) {
                            moreLessbuttonElement.find('span').html('Show more photos');
                            moreLessbuttonElement.removeClass('open');
                            $(element).animate({height: 230}, 500, 'swing', function() {
                            });
                            allShowing = false;
                        }
                        else {
                            moreLessbuttonElement.find('span').html('Show fewer photos');
                            moreLessbuttonElement.addClass('open');
                            $(element).animate({height: $(element).find('.photogrid-cell').last().position().top + 230}, 500, 'swing', function() {
                                $(element).trigger('scroll');  //hack: force the photos to load themselves now that they are visible
                            });
                            allShowing = true;

                        }
                    });
                }
            });
        });

        if(which=='timeline'){
            $('.timeline-comment span').center_y();
            $('.timeline-comment span a').each(function(index, element){
                var photo_id = $(element).attr('data-photo-id');

                $(element).click(function(){
                    zz.comments.show_in_dialog(zz.page.album_id, zz.page.album_cache_version_key, photo_id);
                });
            });
        }
        
    }

    function filterPhotosForUser(photos) {
        //filter photos that haven't finished uploading
        return $.map(photos, function(element, index) {
            if (element['state'] !== 'ready') {
                if (_.isUndefined(zz.session.current_user_id) || element['user_id'] != zz.session.current_user_id) {
                    return null;
                }
            }
            return element;
        });
    }

     function init_back_button(url) {
        $('#header #back-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            $('#footer #comments-button').fadeOut(200);
            $('#article').animate({left: $('#article').width()}, 500, 'easeOutQuart');
            $('#album-info').fadeOut(200);
            $('#header #top-breadcrumb').fadeOut(200);
            document.location.href = url;
        });


    }


    function click_back_button(){
        //todo:hack
        $('#header #back-button').click();
    }


    function update_checkmarks_on_photos(){
         _.each($('.photogrid-cell'), function(element){
             var photo = $(element).data().zz_photo;
             if(photo){
                 photo.setChecked(zz.buy.is_photo_selected(photo.getPhotoId()));
             }
         });
    }

})();

