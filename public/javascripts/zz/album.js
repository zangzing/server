var zz = zz || {};

zz.album = {
    init_grid_view: function() {
        //
        //  GRID VIEW
        //

        var view = 'grid';

        if (document.location.href.indexOf('#!') !== -1) {
            view = 'picture';
        }

        if (view === 'grid') {
            this._init_back_button(zz.back_to_home_page_caption, zz.back_to_home_page_url);
        }
        else {
            this._init_back_button(zz.album_name, zz.album_base_url + '/photos');
        }


        $.ajax({
            dataType: 'json',
            url: zz.routes.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            error: function(xhr, message, exception) {
                zz.cache_helper.check_bad_album_json(xhr, message, zz.album_id, this.url);
            },
            success: function(json) {


                ZZAt.track('album.view', {id:zz.album_id});

                json = zz.album._filterPhotosForUser(json);


                //no movie mode if no photos
                if (json.length == 0) {
                    $('#footer #play-button').addClass('disabled');
                }


                if (view === 'grid') {
                    //
                    // GRID VIEW
                    //

                    var gridElement = $('<div class="photogrid"></div>');

                    $('#article').html(gridElement);
                    $('#article').css('overflow', 'hidden');


                    for (var i = 0; i < json.length; i++) {
                        var photo = json[i];
                        photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                        photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);
                    }

                    var infoMenuTemplateResolver = function(photo_json) {
                        if (zz.displayed_user_id == zz.current_user_id) {
                            if (photo_json.state == 'ready') {
                                return zz.infomenu.album_owner_template;
                            }
                            else {
                                return zz.infomenu.album_owner_template_photo_not_ready;
                            }
                        }
                        else if (photo_json.user_id == zz.current_user_id) {
                            if (photo_json.state == 'ready') {
                                return zz.infomenu.photo_owner_template;
                            }
                            else {
                                return zz.infomenu.photo_owner_template_photo_not_ready;
                            }
                        }
                        else if (zz.current_user_can_download) {
                            return zz.infomenu.download_template;
                        }
                        else {
                            return false
                        }
                    };


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

                            $('#article').css({overflow:'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                            $('#header #back-button').fadeOut(200);

                            document.location.href = zz.album_base_url + "/photos/#!" + photo.id;
                        },
                        onDelete: function(index, photo) {
                            zzapi_photo.delete_photo(photo.id);
                            return true;
                        },
                        currentPhotoId: $.param.fragment(),
                        showButtonBar:true,
                        infoMenuTemplateResolver: infoMenuTemplateResolver
                    }).data().zz_photogrid;


                } else {
                    //
                    // SINGLE PICTURE VIEW
                    //
                    //hide view selectors
                    $('#view-buttons').hide();


                    var renderPictureView = function() {
                        var gridElement = $('<div class="photogrid"></div>');

                        $('#article').html(gridElement);
                        $('#article').css('overflow', 'hidden');


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
                            onScrollToPhoto: function(photoId, index) {
                                window.location.hash = '#!' + photoId
                                zz.current_photo_index = index;
                                ZZAt.track('photo.view', {id:photoId});
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
                    $(window).resize(function(event) {
                        if (resizeTimer) {
                            clearTimeout(resizeTimer);
                            resizeTimer = null;
                        }

                        resizeTimer = setTimeout(function() {
                            renderPictureView();
                        }, 100);
                    });


                }


                // Update the like array if it exists.
                // todo: why wouldn't it exist? (jeremy 8/7)
                if (typeof( zz.like ) != 'undefined') {
                    var wanted_subjects = {};
                    for (var key in json) {
                        var id = json[key].id;
                        wanted_subjects[id] = 'photo';
                    }
                    zz.like.add_id_array(wanted_subjects);
                }
            }
        });

    },

    init_timeline_view: function(){
        this._init_timeline_or_people_view('activities');
    },

    init_people_view: function(){
        this._init_timeline_or_people_view('people');
    },

    _init_timeline_or_people_view: function(which) {

        this._init_back_button(zz.back_to_home_page_caption, zz.back_to_home_page_url);

        $('#article').touchScrollY();

        $.ajax({
            dataType: 'json',
            url: zz.routes.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            error: function(xhr, message, exception) {
                zz.cache_helper.check_bad_album_json(xhr, message, zz.album_id, this.url);
            },
            success: function(json) {

                json = zz.album._filterPhotosForUser(json);


                //no movie mode if no photos
                if (json.length == 0) {
                    $('#footer #play-button').addClass('disabled');
                }

                var wanted_subjects = {};
                for (var i = 0; i < json.length; i++) {
                    var photo = json[i];
                    photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);
                    wanted_subjects[ photo.id ] = 'photo';
                }
                zz.like.add_id_array(wanted_subjects);


                $('.timeline-grid').each(function(index, element) {

                    $(element).empty();

                    var filteredPhotos = null;

                    if (which === 'timeline') {
                        if (!_.isUndefined($(element).attr('data-upload-batch-id'))) {
                            var batchId = parseInt($(element).attr('data-upload-batch-id'));
                            filteredPhotos = $(json).filter(function(index) {
                                return (json[index].upload_batch_id === batchId)
                            });
                            var moreLessbuttonElement = $('.viewlist .more-less-btn[data-upload-batch-id="' + batchId.toString() + '"]');
                        }
                        else if (!_.isUndefined($(element).attr('data-photo-id'))) {
                            var photoId = parseInt($(element).attr('data-photo-id'));
                            filteredPhotos = $(json).filter(function(index) {
                                return (json[index].id === photoId)
                            });
                        }
                    }
                    else {
                        var userId = parseInt($(element).attr('data-user-id'));

                        filteredPhotos = $(json).filter(function(index) {
                            return (json[index].user_id === userId )
                        });
                        var moreLessbuttonElement = $('.viewlist .more-less-btn[data-user-id="' + userId.toString() + '"]');
                    }

                    var infoMenuTemplateResolver = function(photo_json) {
                        if (zz.displayed_user_id == zz.current_user_id) {
                            if (photo_json.state == 'ready') {
                                return zz.infomenu.album_owner_template;
                            }
                            else {
                                return zz.infomenu.album_owner_template_photo_not_ready;
                            }
                        }
                        else if (photo_json.user_id == zz.current_user_id) {
                            if (photo_json.state == 'ready') {
                                return zz.infomenu.photo_owner_template;
                            }
                            else {
                                return zz.infomenu.photo_owner_template_photo_not_ready;
                            }
                        }
                        else if (zz.current_user_can_download) {
                            return zz.infomenu.download_template;
                        }
                        else {
                            return false
                        }
                    };

                    var grid = $(element).zz_photogrid({
                        photos:filteredPhotos,
                        allowDelete: false,
                        allowEditCaption: false,
                        allowReorder: false,
                        cellWidth: 230,
                        cellHeight: 230,
                        onClickPhoto: function(index, photo) {
                            $('#article').css({overflow:'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                            $('#header #back-button').fadeOut(200);
                            document.location.href = zz.album_base_url + "/photos/#!" + photo.id;
                        },
                        showThumbscroller: false,
                        showButtonBar:true,
                        allowDownload: zz.current_user_can_download,
                        showInfoMenu: zz.displayed_user_id == zz.current_user_id, //The owner of the album being displayed ios zz.displayed_user_id
                        onClickShare: function(photo_id) {
                            zz.pages.share.share_in_dialog('photo', photo_id);
                        },
                        onDelete: function(index, photo) {
                            zzapi_photo.delete_photo(photo.id);
                            return true;
                        },
                        infoMenuTemplateResolver: infoMenuTemplateResolver
                    }).data().zz_photogrid;


                    //force this back because grid turns on scrolling
                    $(element).css({'overflow-x':'hidden', 'overflow-y':'hidden'});

                    var allShowing = false;


                    //var moreLessbuttonElement = $(element).siblings('.more-less-btn');
                    if (!_.isUndefined(moreLessbuttonElement)) {
                        moreLessbuttonElement.click(function() {
                            if (allShowing) {
                                moreLessbuttonElement.find("span").html("Show more photos");
                                moreLessbuttonElement.removeClass('open');
                                $(element).animate({height:230}, 500, 'swing', function() {
                                });
                                allShowing = false;
                            }
                            else {
                                moreLessbuttonElement.find("span").html("Show fewer photos");
                                moreLessbuttonElement.addClass('open');
                                $(element).animate({height: $(element).children().last().position().top + 230}, 500, 'swing', function() {
                                    $(element).trigger('scroll');  //hack: force the photos to load themselves now that they are visible
                                });
                                allShowing = true;

                            }
                        });
                    }
                });
            }
        });
    },

    _filterPhotosForUser: function(photos) {
        //filter photos that haven't finished uploading
        return $.map(photos, function(element, index) {
            if (element['state'] !== 'ready') {
                if (_.isUndefined(zz.current_user_id) || element['user_id'] != zz.current_user_id) {
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