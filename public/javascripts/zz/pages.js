/*!
 * pages.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
var zz = zz || {};

zz.pages = {};

zz.pages.album_add_photos_tab = {
    chooserWidget: null,

    init: function(container, callback, drawer_style) {
        var template = $('<div class="photochooser-container"></div>');
        container.html(template);
        this.chooserWidget = template.zz_photochooser({album_id: zz.page.album_id}).data().zz_photochooser;

        ZZAt.track('album.add_photos_tab.view');


        callback();
    },

    bounce: function(success, failure) {
        this.chooserWidget.destroy();
        success();
    }
};

zz.pages.album_name_tab = {
    original_album_name: '',
    init: function(container, callback) {
        var url = zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/name_album';
        ZZAt.track('album.name_tab.view');

        var album_email_call_lock = 0;

        container.load(url, function() {
            //don't let <enter> submit the form
            $('form.edit_album input').disableEnterKey();


            //save album name and set header album name
            //zz.pages.album_name_tab.original_album_name = $('#album_name').val();
            //$('#album-header-title').text(zz.pages.album_name_tab.original_album_name);

            //change header album name as you type new album name
            $('#album_name').keypress(function() {
                setTimeout(function() {
                    $('#album-header-title').text($('#album_name').val());
                }, 10);
            });

            setTimeout(function() {
                $('#album_name').select();
            }, 100);

            //Get album email when 1.2 sec elapsed after user finishes typing
            $('#album_name').keyup(function() {
                album_email_call_lock++;
                setTimeout(function() {
                    album_email_call_lock--;
                    if (album_email_call_lock == 0) {
                        $.ajax({
                            url: zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/preview_album_email?' + $.param({'album[name]': $('#album_name').val()}),
                            success: function(json) {
                                $('#album_name').removeClass('error');
                                $('#album_email').text(json.email);
                                $('#album_url').text(json.url);
                            },
                            error: function() {
                                $('#album_name').addClass('error');
                                $('#album_name').val(zz.pages.album_name);
                                $('h2#album-header-title').text(zz.pages.album_name);
                            }
                        });
                    }
                }, 1200);

            });

            zz.routes.photos.get_album_photos_json(zz.page.album_id, 0, function(json){
                var selectedIndex = -1;
                var currentId = $('#album_cover_photo').val();
                var photos = $.map(json, function(element, index) {
                    var id = element.id;

                    if (id == currentId) {
                        selectedIndex = index;
                    }
                    var src = element.thumb_url;


                    src = zz.agent.checkAddCredentialsToUrl(src);

                    return {id: id, src: src};
                });

                $('#album-cover-picker').zz_thumbtray({
                    photos: photos,
//                        showSelection:true,
                    selectedIndex: selectedIndex,
                    onSelectPhoto: function(index, photo) {
                        var photo_id = '';
                        var photo_src = '/images/album-no-cover.png';
                        if (index !== -1) {
                            photo_id = photo.id;
                            photo_src = photo.src;

                            $('#album_cover_img').css({
                                height: 100,
                                width: null
                            });
                        }
                        else {
                            $('#album_cover_img').css({
                                height: 100,
                                width: 150
                            });
                        }

                        $('#album_cover_photo').val(photo_id);
                        $('#album_cover_img').attr('src', photo_src);

                    }
                });
            });
            //disable click-editing of album name when this tab is displayed
            $('h2#album-header-title').unbind('click');
            callback();
        });


    },

    bounce: function(success, failure) {
        $.ajax({ type: 'POST',
            url: zz.routes.path_prefix + '/albums/' + zz.page.album_id,
            data: $('.edit_album').serialize(),
            success: function(){
                zz.page.album_name = $('#album_name').val();
                $('h2#album-header-title').text(zz.pages.album_name);
                $('h2#album-header-title').ellipsis();
                 zz.toolbars._init_album_title();
                success();
            },
            error: function() {
                //restore name and header to valid value
                $('#album_name').val(zz.pages.album_name);
                $('h2#album-header-title').text(zz.pages.album_name);
                $('h2#album-header-title').ellipsis();
            }
        });
    }
};

zz.pages.edit_album_tab = {
    init: function(container, callback) {
        ZZAt.track('album.edit_tab.view');

        zz.routes.photos.get_album_photos_json(zz.page.album_id, 0, function(json){
            for (var i = 0; i < json.length; i++) {
                var photo = json[i];
                photo.previewSrc = zz.agent.checkAddCredentialsToUrl(photo.stamp_url);
                photo.src = zz.agent.checkAddCredentialsToUrl(photo.thumb_url);
            }

            //add empty cell a the end so that we have a place
            //to drop after the last photo
            json.push({
                id: null,
                type: 'blank',
                caption: ''
            });


            var gridElement = $('<div class="photogrid"></div>');

            $('#article').html(gridElement);
            $('#article').css('overflow', 'hidden');
            $('#article').css('top', '120px'); //make room for wizard tabs


            var grid = gridElement.zz_photogrid({
                photos: json,
                allowDelete: true,
                cellWidth: 230,
                cellHeight: 230,

                onDelete: function(index, photo) {
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        data: {_method: 'delete'},
                        url: zz.routes.path_prefix + '/photos/' + photo.id + '.json',
                        error: function(error) {
                        },
                        success: function() {
                            zz.agent.callAgent('/albums/' + zz.page.album_id + '/photos/' + photo.id + '/cancel_upload');
                        }

                    });
                    return true;
                },
                allowEditCaption: true,
                onChangeCaption: function(index, photo, caption) {
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        url: zz.routes.path_prefix + '/photos/' + photo.id + '.json',
                        data: {'photo[caption]': caption, _method: 'put'},
                        error: function(error) {
                        }

                    });
                    return true;

                },
                allowReorder: false, //disabled custom ordering when we added sort
                onChangeOrder: function(photo_id, before_id, after_id) {
                    var data = {};


                    if (before_id) {
                        data.before_id = before_id;
                    }

                    if (after_id) {
                        data.after_id = after_id;
                    }

                    data._method = 'put';

                    $.ajax({
                        type: 'POST',
                        data: data,
                        dataType: 'json',
                        url: zz.routes.path_prefix + '/photos/' + photo_id + '/position',
                        error: function(error) {
                        }

                    });
                    return true;

                },
                showThumbscroller: false
            }).data().zz_photogrid;

            $('#article').show();
        });
    },

    bounce: function(success, failure) {
        success();
    }

};


zz.pages.group_tab = {

    GROUP_EDITOR_TEMPLATE: function(){
        return '<div class="group-editor-container">' +
                    '<div class="group-editor">' +
                        '<div class="who-can-access-header">Privacy</div>' +
                        '<div class="privacy-buttons">' +
                            '<div data-privacy="public" class="public-button"></div>' +
                            '<div data-privacy="hidden" class="hidden-button"></div>' +
                            '<div data-privacy="password" class="password-button"></div>' +
                        '</div>' +
                        '<div class="divider-line"></div>' +
                        '<div class="create-group-header">Share</div>' +
                        '<div class="people-list"></div>' +
                        '<div class="share-button-section">' +
                            '<div class="add-people-button create-group"></div>' +
                            '<div class="stream-to-email"><input type="checkbox">Automatically email the group about new photos and comments</div>' +
                            '<div class="facebook-button"></div>' +
                            '<div class="stream-to-facebook"><input type="checkbox">Automatically share new photos on Facebook</div>' +
                            '<div class="twitter-button"></div>' +
                            '<div class="stream-to-twitter"><input type="checkbox">Automatically share new photos on Twitter</div>' +
                        '</div>' +
                        '<div class="divider-line"></div>' +
                        '<div class="settings-header">Settings</div>' +
                        '<div class="settings-section">' +
                            '<div class="who-can-upload">' +
                                '<select>' +
                                    '<option value="everyone">Everyone</option>' +
                                    '<option value="contributors">Contributors</option>' +
                                '</select>' +
                                '<span>can add photos</span>' +
                            '</div>' +
                            '<div class="who-can-download">' +
                                '<select>' +
                                    '<option value="everyone">Everyone</option>' +
                                    '<option value="viewers">Group</option>' +
                                    '<option value="owner">No one</option>' +
                                '</select>' +
                                '<span>can download full resolution photos</span>' +
                            '</div>' +
                            '<div class="who-can-buy">' +
                                '<select>' +
                                    '<option value="everyone">Everyone</option>' +
                                    '<option value="viewers">Group</option>' +
                                    '<option value="owner">No one</option>' +
                                '</select>' +
                                '<span>can purchase photos</span>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';
    },

    PERSON_TEMPLATE: function(){
       return '<div class="person">' +
                    '<div class="profile">' +
                        '<img data-src="/images/profile-default-55.png" src="/images/profile-default-55.png">' +
                    '</div>' +
                    '<div class="name"></div>' +
                    '<select class="permission" size="1">' +
                    '<option value="viewer">Viewer</option>' +
                    '<option value="contributor">Contributor</option>' +
                    '</select>' +
                    '<div class="delete-button"></div>' +
                '</div>';
    },


    FACEBOOK_DIALOG_TEMPLATE: function(){
        return '<div class="facebook-dialog">' +
                    '<div class="header"><div class="title">Share to Facebook</div></div>' +
                    '<textarea placeholder="Write something" class="message"></textarea>' +
                    '<div class="detail">' +
                        '<img class="photo" src="/images/album-no-cover.png">' +
                        '<div class="title"></div>' +
                        '<div class="url"></div>' +
                        '<div class="description"></div>' +
                    '</div>' +
                    '<div class="footer">' +
                        '<div class="submit-button"></div>' +
                        '<div class="cancel-button"></div>' +
                    '</div>' +
                '</div>';
    },

    TWITTER_DIALOG_TEMPLATE: function(){

        return  '<div class="twitter-dialog">' +
                    '<div class="header"></div>' +
                    '<div class="share-with-followers">Share with your followers</div>' +
                    '<textarea class="message"></textarea>' +
                    '<div class="chars-left">10</div>' +
                    '<div class="submit-button"></div>' +
                '</div>';
    },

    MESSAGE_PLACEHOLDER_TEXT: "Type a personal note",

    ADD_PEOPLE_DIALOG_TEMPLATE: function(){

        return '<div class="add-people-dialog">' +
                    '<div class="header">' +
                        '<div class="title">Add people to your group</div>' +
                        '<div class="import"><span>Import from </span>' +
                            '<a data-service="google" class="gray-square-button contacts-btn"><span><div class="off"></div>Google</span></a>' +
                            '<a data-service="local" class="gray-square-button contacts-btn"><span><div class="off"></div>Local</span></a>' +
                            '<a data-service="yahoo" class="gray-square-button contacts-btn"><span><div class="off"></div>Yahoo</span></a>' +
                            '<a data-service="mslive" class="gray-square-button contacts-btn"><span><div class="off"></div>Hotmail</span></a>' +
                        '</div>' +
                    '</div>' +
                    '<div class="to"><input class="contact-list"></div>' +
                    '<textarea placeholder="' + self.MESSAGE_PLACEHOLDER_TEXT + '" class="message"></textarea>' +
                    '<div class="permission">Add them as: <select size="1"><option value="viewer">Viewer</option><option selected="true" value="contributor">Contributor</option></select></div>' +
                    '<a class="cancel-button black-button"><span>Cancel</span></a>' +
                    '<a class="submit-button green-button"><span>OK</span></a>' +
                '</div>';
    },


    init: function(container, callback) {
        var self = this;
        ZZAt.track('album.group_tab.view');


        var check_empty_list = function() {
            if (container.find('.people-list .person').length == 0) {
                container.find('.add-people-button').addClass('create-group');
                container.find('.people-list').fadeOut('fast');
            }
            else {
                container.find('.add-people-button').removeClass('create-group');
                container.find('.people-list').fadeIn('fast');
            }

        };

        var refresh_person_list = function(people) {
            container.find('.people-list').empty();

            // populate the list
            _.each(people, function(person) {
                var element = $(self.PERSON_TEMPLATE());
                element.find('.name').text(person['name']);

                element.find('select.permission').val(person['permission']);
                element.find('select.permission').change(function() {
                    $.post('/zz_api/albums/' + zz.page.album_id + '/update_sharing_member', {_method: 'post', 'member[id]': person.id, 'member[permission]': $(this).val()});
                });

                element.find('.delete-button').click(function() {
                    if (confirm('Are you sure you want to remove ' + person.name + '?')) {
                        $.post('/zz_api/albums/' + zz.page.album_id + '/delete_sharing_member', {_method: 'post', 'member[id]': person.id});
                        element.remove();
                        check_empty_list();
                    }
                });

                // set the data-src attr which the
                // profile picture componet will pick up
                if (person['profile_photo_url']) {
                    element.find('.profile img').attr('data-src', person['profile_photo_url']);
                }

                container.find('.people-list').append(element);

            });

            zz.profile_pictures.init_profile_pictures(container.find('.profile'));

            $('.people-list').touchScrollY();

            check_empty_list();

        };


        $.ajax({
            dataType: 'json',
            url: '/zz_api/albums/' + zz.page.album_id + '/sharing_edit.json',
            success: function(json) {


                var has_facebook_token = json['user']['has_facebook_token'];
                var has_twitter_token = json['user']['has_twitter_token'];

                container.html(self.GROUP_EDITOR_TEMPLATE());


                //bind privacy buttons
                container.find('.privacy-buttons .' + json['album']['privacy'] + '-button').addClass('selected');
                container.find('.privacy-buttons').children().click(function() {
                    container.find('.privacy-buttons').children().removeClass('selected');
                    $(this).addClass('selected');
                    $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method: 'put', 'album[privacy]': $(this).attr('data-privacy')});
                });


                refresh_person_list(json['group']);


                //bind stream-to-email checkbox
                container.find('.stream-to-email input').attr('checked', json['album']['stream_to_email']);
                container.find('.stream-to-email input').change(function() {
                    $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method: 'put', 'album[stream_to_email]': $(this).attr('checked')});
                });


                //bind who-can-upload droppdown
                container.find('.who-can-upload select').val(json['album']['who_can_upload']);
                container.find('.who-can-upload select').change(function() {
                    $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method: 'put', 'album[who_can_upload]': $(this).val()});
                });


                //bind who-can-download droppdown
                container.find('.who-can-download select').val(json['album']['who_can_download']);
                container.find('.who-can-download select').change(function() {
                    $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method: 'put', 'album[who_can_download]': $(this).val()});
                });


                //bind who-can-buy droppdown
                container.find('.who-can-buy select').val(json['album']['who_can_buy']);
                container.find('.who-can-buy select').change(function() {
                    $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method: 'put', 'album[who_can_buy]': $(this).val()});
                });




                //bind stream-to-facebook checkbox
                var stream_to_facebook_checkbox_element = container.find('.stream-to-facebook input');
                var set_stream_to_facebook = function(b){
                    var set_value = function(value){
                        stream_to_facebook_checkbox_element.attr('checked', value);
                        $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method:'put', 'album[stream_to_facebook]': value});
                    };

                    if(b){
                        if(has_facebook_token){
                            set_value(true);
                        }
                        else {
                            zz.oauthmanager.login_facebook(function() {
                                has_facebook_token = true;
                                set_value(true);
                            });
                        }
                    }
                    else{
                        set_value(false);
                    }
                };
                stream_to_facebook_checkbox_element.attr('checked', json['album']['stream_to_facebook']);
                stream_to_facebook_checkbox_element.click(function(){
                    //undo the toggle and start over...
                    stream_to_facebook_checkbox_element.attr('checked', !stream_to_facebook_checkbox_element.attr('checked'));

                    set_stream_to_facebook(!stream_to_facebook_checkbox_element.attr('checked'));

               });



                //bind stream-to-twitter checkbox
                var stream_to_twitter_checkbox_element = container.find('.stream-to-twitter input');
                var set_stream_to_twitter = function(b){
                    var set_value = function(value){
                        stream_to_twitter_checkbox_element.attr('checked', value);
                        $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id, {_method:'put', 'album[stream_to_twitter]': value});
                    };


                    if(b){
                        if(has_twitter_token){
                            set_value(true);
                        }
                        else {
                            zz.oauthmanager.login_twitter(function() {
                                has_twitter_token = true;
                                set_value(true);
                            });
                        }
                    }
                    else{
                        set_value(false);
                    }

                };

                stream_to_twitter_checkbox_element.attr('checked', json['album']['stream_to_twitter']);
                stream_to_twitter_checkbox_element.change(function(){

                    //undo the toggle and start over...
                    stream_to_twitter_checkbox_element.attr('checked', !stream_to_twitter_checkbox_element.attr('checked'));

                    set_stream_to_twitter(!stream_to_twitter_checkbox_element.attr('checked'));

                });


                //set up event handlers
                container.find('.add-people-button').click(function() {
                    var content = $(self.ADD_PEOPLE_DIALOG_TEMPLATE());

                    var dialog = zz.dialog.show_dialog(content, {width: 750, height: 350});

                    content.find('textarea.message').placeholder();


                    zz.contact_list.create(zz.session.current_user_id, content.find('.contact-list'), content.find('.contacts-btn'));


                    content.find('.submit-button').click(function() {

                        if (zz.contact_list.has_errors()) {
                            alert('Please correct the highlighted addresses.');
                            return;
                        }


                        var emails = $('.contact-list').val().split(',');
                        var data = {
                            message: content.find('textarea.message').val(),
                            permission: content.find('.permission select').val(),
                            emails: emails
                        };

                        // in case user didn't change placeholder text...
                        if(data.message == self.MESSAGE_PLACEHOLDER_TEXT){
                            data.message = '';
                        }


                        $.post('/zz_api/albums/' + zz.page.album_id + '/add_sharing_members.json', data, function(json) {
                            refresh_person_list(json);
                            dialog.close();
                            ZZAt.track('album.share.group_tab.email');

                        });


                    });

                    content.find('.cancel-button').click(function() {
                        dialog.close();
                    });
                    if( typeof( zz.pages.group_tab.init_callback ) != 'undefined' ){
                        zz.pages.group_tab.init_callback();
                    }
                });

                container.find('.facebook-button').click(function() {

                    var show_facebook_dialog = function() {
                        var content = $(self.FACEBOOK_DIALOG_TEMPLATE());

                        content.find('.detail .title').text(json['share']['facebook']['title']);
                        content.find('.detail .url').text(json['share']['facebook']['url']);
                        content.find('.detail .description').text(json['share']['facebook']['description']);


                        //yuck! this is why we need a model!
                        if (container.find('.privacy-buttons .password-button').hasClass('selected')) {
                            content.find('.detail .photo').attr('src', '/images/private-album.png');
                        }
                        else {
                            if (json['share']['facebook']['photo']) {
                                content.find('.detail .photo').attr('src', json['share']['facebook']['photo']);
                            }
                        }

                        content.find('textarea.message').placeholder();

                        var dialog = zz.dialog.show_dialog(content, {width: 650, height: 285});

                        content.find('.submit-button').click(function() {
                            var data = {
                                message: content.find('textarea.message').val(),
                                recipients: ['facebook'],
                                service: 'social'
                            };

                            $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/shares.json', data);
                            dialog.close();
                            set_stream_to_facebook(true);

                            ZZAt.track('album.share.group_tab.facebook');

                        });

                        content.find('.cancel-button').click(function() {
                            dialog.close();
                        });
                    };


                    if (has_facebook_token) {
                        show_facebook_dialog();
                    }
                    else {
                        zz.oauthmanager.login_facebook(function() {
                            has_facebook_token = true;
                            show_facebook_dialog();
                        });
                    }
                });

                container.find('.twitter-button').click(function() {

                    var show_twitter_dialog = function() {
                        var content = $(self.TWITTER_DIALOG_TEMPLATE());


                        var update_char_left = function() {
                            var count = 124 - content.find('textarea.message').val().length;
                            content.find('.chars-left').text(count);
                        };


                        content.find('textarea.message').val(json['share']['twitter']['message']);
                        content.find('textarea.message').keypress(function() {
                            update_char_left();
                        });

                        update_char_left();


                        content.find('input.stream-to-twitter').val();


                        var dialog = zz.dialog.show_dialog(content, {width: 650, height: 250});


                        content.find('.submit-button').click(function() {
                            var data = {
                                message: content.find('textarea.message').val(),
                                recipients: ['twitter'],
                                service: 'social'
                            };

                            $.post(zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/shares.json', data);
                            dialog.close();
                            set_stream_to_twitter(true);
                            ZZAt.track('album.share.group_tab.twitter');
                        });
                    };

                    if (has_twitter_token) {
                        show_twitter_dialog();
                    }
                    else {
                        zz.oauthmanager.login_twitter(function() {
                            has_twitter_token = true;
                            show_twitter_dialog();
                        });
                    }
                });
              if( typeof( zz.pages.group_tab.init_callback ) != 'undefined' ){
                  zz.pages.group_tab.init_callback();
              }
            }
        });


        callback();
    },

    bounce: function(success, failure) {
        success();
    }


};



zz.pages.download_agent = {
    NO_AGENT_URL: '/static/templates/download_agent.html?v1',

    get_message_url: function() {
        ZZAt.track('agentdownload.requested');
        return this.NO_AGENT_URL;
    },

    keep_polling: function() {
        return $('.zangzing-downloader').length > 0;
    },


    dialog: function(onClose, startDownload) {

        $('<div></div>', { id: 'no-agent-dialog'}).load(zz.pages.download_agent.get_message_url(), function() {

            $(this).zz_dialog({
                modal: true,
                width: 910,
                height: 510,
                close: function() {
                    if (onClose) {
                        onClose();
                    }
                }
            });

            $('.zangzing-downloader #download-btn').click(function() {
                zz.pages.download_agent.download();
            });

            $('.zangzing-downloader #download-link').click(function() {
                zz.pages.download_agent.download();
            });


            zz.pages.download_agent.poll_agent(function() {
                $('#no-agent-dialog').zz_dialog('close');
            });


            //if this is IE and WinXp, don't auto-start download
            //because ie will pop up approval bar which forces
            //full page refresu
            if (navigator.appVersion.indexOf('NT 5.1') != -1 && $.client.browser == 'Explorer') {
                startDownload = false;
            }


            if (startDownload) {
                $(this).find('.manual-start').hide();

                setTimeout(function() {
                    zz.pages.download_agent.download();
                }, 1000);
            }
            else {
                $(this).find('.auto-start').hide();
            }
        });

    },

    poll_agent: function(when_ready) {
        zz.agent.getStatus(function(status) {
            if (status == zz.agent.STATUS.READY) {
                $('.zangzing-downloader #download-btn').attr('disabled', 'disabled');
                $('.zangzing-downloader .step.four .graphic').addClass('ready');
                if (when_ready) {
                    setTimeout(when_ready, 2000);
                }

            }
            else {
                if (zz.pages.download_agent.keep_polling()) {
                    setTimeout(function() {
                        zz.pages.download_agent.poll_agent(when_ready);
                    }, 1000);
                }
            }
        });
    },

    download: function() {
        if ($.client.os == 'Mac') {
            document.location.href = zz.config.mac_download_url; //'http://downloads.zangzing.com/agent/darwin/ZangZing-Setup.pkg'
        }
        else {
            if ($.client.browser == 'Chrome') {
                //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                window.open(zz.config.win_download_url);
            }
            else {
                document.location.href = zz.config.win_download_url;
            }

        }
        ZZAt.track('agentdownload.get');
    }
};


