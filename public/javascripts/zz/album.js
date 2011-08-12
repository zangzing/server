var zz = zz || {};

zz.album = {

    init_picture_view: function(current_photo_id) {
        this._init_back_button(zz.page.album_name, zz.page.album_base_url + '/photos');

        $('#view-buttons').hide();

        $('#footer #comments-button').show();

        ZZAt.track('album.view', {id: zz.page.album_id});


        this._load_photos_json(function(json) {

            var renderPictureView = function() {


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
                }

                var gridElement = $('<div class="photogrid"></div>');

                $('#article').css('overflow', 'hidden');

                $('#article .photogrid').remove();
                $('#article').append(gridElement);

                if (zz.album._comments_open()){
                    gridElement.css({right: '500px'});
                }

                var grid = gridElement.zz_photogrid({
                    photos: json,
                    allowDelete: false,
                    allowEditCaption: false,
                    allowReorder: false,
                    cellWidth: gridElement.width(),
                    cellHeight: gridElement.height() - 20,
                    onClickPhoto: function(index, photo) {
                        grid.nextPicture();
                        ZZAt.track('button.next.click');
                    },
                    singlePictureMode: true,
                    currentPhotoId: current_photo_id,
                    onScrollToPhoto: function(photoId, index) {
                        window.location.hash = '#!' + photoId;
                        zz.page.current_photo_index = index; //this is used when we go to movie mode
                        current_photo_id = photoId;
                        if(zz.album._comments_open()){
                            zz.album._load_comments_for_photo(current_photo_id);
                        }
                        ZZAt.track('photo.view', {id: photoId});
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

            // setup comments drawer
            if(zz.album._comments_open()){
                $('#footer #comments-button').addClass('selected');
                zz.album._open_comments_drawer(false, current_photo_id, renderPictureView );
            }
            else{
                renderPictureView();
            }

            $('#footer #comments-button').click(function() {
                if ($(this).hasClass('disabled')) {
                    return;
                }

                $(this).toggleClass('selected');

                if ($(this).hasClass('selected')) {
                    zz.album._open_comments_drawer(true, current_photo_id, renderPictureView );
                }
                else{
                    zz.album._close_comments_drawer(true, renderPictureView );
                }



            });




            //handle resize
            var resizeTimer = null;
            $(window).resize(function(event) {
                if (resizeTimer) {
                    clearTimeout(resizeTimer);
                    resizeTimer = null;
                }

                resizeTimer = setTimeout(function() {
                    renderPictureView();
                }, 100);
            });
        });
    },


    init_grid_view: function() {

        this._init_back_button(zz.page.back_to_home_page_caption, zz.page.back_to_home_page_url);

        this._load_photos_json(function(json) {


            ZZAt.track('album.view', {id: zz.page.album_id});



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
            }


            var grid = gridElement.zz_photogrid({
                photos: json,
                allowDelete: false,
                allowEditCaption: false,
                allowReorder: false,
                cellWidth: 230,
                cellHeight: 230,
                showThumbscroller: false,
                onClickPhoto: function(index, photo) {

                    //get rid of scrollbars before animate transition
                    grid.hideThumbScroller();
                    gridElement.css({overflow: 'hidden'});

                    $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                    $('#header #back-button').fadeOut(200);

                    document.location.href = zz.page.album_base_url + '/photos/#!' + photo.id;
                },
                onDelete: function(index, photo) {
                    zz.routes.call_delete_photo(photo.id);
                    return true;
                },
                showButtonBar: true,
                infoMenuTemplateResolver: zz.album.info_menu_template_resolver
            }).data().zz_photogrid;
        });
    },

    _comments_open: function() {
        return jQuery.cookie('show_comments');
    },

    _open_comments_drawer: function(animate, photo_id, callback) {
        jQuery.cookie('show_comments', true);

        var comments_panel = $('<div class="comments-right-panel"></div>');
        var comments_widget = zz.comments.build_comments_widget(photo_id);
        comments_panel.html(comments_widget.element)

        zz.album._comments_widget = comments_widget;

        if(animate) {
            $('#article .photogrid').fadeOut('fast', function(){
                comments_panel.css({right: '-450px'});
                $('#article').append(comments_panel);
                comments_panel.animate({right:'0px'}, 300, function(){
                    callback();
                });
            });
        }
        else{
            $('#article').append(comments_panel);
            callback();
        }
    },

    _close_comments_drawer: function(animate, callback) {
        jQuery.cookie('show_comments', null);

        var comments_panel = $('#article .comments-right-panel');

        zz.album._comments_widget = null;

        if(animate){
            $('#article .photogrid').fadeOut('fast', function(){
                comments_panel.animate({right:'-450px'}, 300, function(){
                    comments_panel.remove();
                    callback();
                });
            });
        }
        else{
            $('#article .comments-right-panel').remove();
            callback();

        }
    },

    _load_comments_for_photo: function(photo_id) {
        zz.album._comments_widget.load_comments_for_photo(photo_id);
    },

    init_timeline_view: function() {
        this._init_timeline_or_people_view('timeline');
    },

    init_people_view: function() {
        this._init_timeline_or_people_view('people');
    },


    info_menu_template_resolver: function(photo_json) {
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
    },


    _load_photos_json: function(callback){
        $.ajax({
            dataType: 'json',
            url: zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/photos_json?' + zz.page.album_lastmod,

            error: function(xhr, message, exception) {
                zz.cache_helper.check_bad_album_json(xhr, message, zz.page.album_id, this.url);
            },

            success: function(json){
                json = zz.album._filterPhotosForUser(json);

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

            }
        });
    },

    _init_timeline_or_people_view: function(which) {

        this._init_back_button(zz.page.back_to_home_page_caption, zz.page.back_to_home_page_url);

        $('#article').touchScrollY();

        this._load_photos_json(function(json) {

            for (var i = 0; i < json.length; i++) {
                var photo = json[i];
                photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);
            }



            $('.timeline-grid').each(function(index, element) {

                $(element).empty();

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
                    onClickPhoto: function(index, photo) {
                        $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                        $('#header #back-button').fadeOut(200);
                        document.location.href = zz.page.album_base_url + '/photos/#!' + photo.id;
                    },
                    showThumbscroller: false,
                    showButtonBar: true,
                    onClickShare: function(photo_id) {
                        zz.pages.share.share_in_dialog('photo', photo_id);
                    },
                    onDelete: function(index, photo) {
                        zz.routes.call_delete_photo(photo.id);
                        return true;
                    },
                    infoMenuTemplateResolver: zz.album.info_menu_template_resolver
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
                            $(element).animate({height: $(element).children().last().position().top + 230}, 500, 'swing', function() {
                                $(element).trigger('scroll');  //hack: force the photos to load themselves now that they are visible
                            });
                            allShowing = true;

                        }
                    });
                }
            });
        });
    },

    _filterPhotosForUser: function(photos) {
        //filter photos that haven't finished uploading
        return $.map(photos, function(element, index) {
            if (element['state'] !== 'ready') {
                if (_.isUndefined(zz.session.current_user_id) || element['user_id'] != zz.session.current_user_id) {
                    return null;
                }
            }
            return element;
        });
    },

    _init_back_button: function(caption, url) {
        $('#header #back-button span').text(caption);

        $('#header #back-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            $('#article').animate({left: $('#article').width()}, 500, 'easeOutQuart');
            $('#album-info').fadeOut(200);
            $('#header #back-button').fadeOut(200);
            document.location.href = url;
        });
    }
};
