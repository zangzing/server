/*!
 * pages.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var pages = {};

pages.album_add_photos_tab = {
    chooserWidget: null,

    init: function(container, callback, drawer_style){
        var template = $('<div class="photochooser-container"></div>');
        container.html(template);
        this.chooserWidget = template.zz_photochooser({album_id: zz.album_id}).data().zz_photochooser;

        ZZAt.track('album.add_photos_tab.view');


        callback();
    },

    bounce: function(success, failure){
        this.chooserWidget.destroy();
        success();
    }
};

pages.album_name_tab = {
    original_album_name: '',
    init: function(container, callback){
        var url = zz.path_prefix + '/albums/' + zz.album_id + '/name_album';

        ZZAt.track('album.name_tab.view');


        var album_email_call_lock = 0;

        container.load(url, function(){
            //don't let <enter> submit the form
            $('form.edit_album input').disableEnterKey();


            //save album name and set header album name
            pages.album_name_tab.original_album_name = $('#album_name').val();
            $('#album-header-title').text(pages.album_name_tab.original_album_name);

            //change header album name as you type new album name
            $('#album_name').keypress( function(){
                setTimeout(function(){
                    $('#album-header-title').text( $('#album_name').val() );
                }, 10);
            });

            setTimeout(function(){
                $('#album_name').select();
            },100);

            //Get album email when 1.2 sec elapsed after user finishes typing
            $('#album_name').keyup(function(){
                album_email_call_lock++;
                setTimeout(function(){
                    album_email_call_lock--;
                    if(album_email_call_lock==0){
                        $.ajax({
                            url: zz.path_prefix + '/albums/' + zz.album_id + '/preview_album_email?' + $.param({'album[name]': $('#album_name').val()}),
                            success: function(json){
                                $('#album_name').removeClass('error');
                                $('#album_email').text(json.email);
                                $('#album_url').text(json.url);
                            },
                            error: function(){
                                $('#album_name').addClass('error');
                                $('#album_name').val(pages.album_name_tab.original_album_name);
                                $('h2#album-header-title').text(pages.album_name_tab.original_album_name);
                            }
                        });
                    }
                }, 800);
            });

            //setup album cover picker
            $.ajax({
                dataType: 'json',
                url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + (new Date()).getTime(),  //force browser cache miss
                success: function(json){
                    var selectedIndex=-1;
                    var currentId = $('#album_cover_photo').val();
                    var photos = $.map(json, function(element, index){
                        var id = element.id;

                        if(id == currentId){
                            selectedIndex = index;
                        }
                        var src = element.thumb_url;


                        src = agent.checkAddCredentialsToUrl(src);

                        return {id:id, src:src};
                    });

                    $("#album-cover-picker").zz_thumbtray({
                        photos:photos,
//                        showSelection:true,
                        selectedIndex:selectedIndex,
                        onSelectPhoto: function(index, photo){
                            var photo_id = '';
                            var photo_src='/images/album-no-cover.png';
                            if(index!==-1){
                                photo_id = photo.id;
                                photo_src = photo.src;

                                $('#album_cover_img').css({
                                    height:100,
                                    width:null
                                });
                            }
                            else{
                                $('#album_cover_img').css({
                                    height:100,
                                    width:150
                                });
                            }

                            $('#album_cover_photo').val(photo_id);
                            $('#album_cover_img').attr('src', photo_src);

                        }
                    });
                }
            });

            callback();
        });


    },

    bounce: function(success, failure){
        $.ajax({ type: 'POST',
            url: zz.path_prefix + '/albums/'+zz.album_id,
            data:$(".edit_album").serialize(),
            success: success ,
            error:  function(){
                //restore name and header to valid value
                $('#album_name').val(pages.album_name_tab.original_album_name);
                $('h2#album-header-title').text(pages.album_name_tab.original_album_name);
                $('#album_name').keypress();
            }
        });
    }
};

pages.edit_album_tab = {
    init: function(container, callback){
        ZZAt.track('album.edit_tab.view');

        $.ajax({
            dataType: 'json',
            url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + (new Date()).getTime(),  //force browser cache miss,
            success: function(json){

                for(var i =0;i<json.length;i++){
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src =       agent.checkAddCredentialsToUrl(photo.thumb_url);
                }

                //add empty cell a the end so that we have a place
                //to drop after the last photo
                json.push({
                    id:null,
                    type:'blank',
                    caption:''
                });


                var gridElement = $('<div class="photogrid"></div>');

                $('#article').html(gridElement);
                $('#article').css('overflow','hidden');
                $('#article').css('top','120px'); //make room for wizard tabs


                var grid = gridElement.zz_photogrid({
                    photos:json,
                    allowDelete: true,
                    cellWidth: 230,
                    cellHeight: 230,

                    onDelete: function(index, photo){
                        $.ajax({
                            type: "POST",
                            dataType: "json",
                            data:{_method:'delete'},
                            url: zz.path_prefix + "/photos/" + photo.id + ".json",
                            error: function(error){
                            },
                            success: function(){
                                agent.callAgent('/albums/' +  zz.album_id + '/photos/' + photo.id + '/cancel_upload');
                            }

                        });
                        return true;
                    },
                    allowEditCaption: true,
                    onChangeCaption: function(index, photo, caption){
                        $.ajax({
                            type: "POST",
                            dataType: "json",
                            url: zz.path_prefix + "/photos/" + photo.id + ".json",
                            data: {'photo[caption]':caption, _method:'put'},
                            error: function(error){
                            }

                        });
                        return true;

                    },
                    allowReorder: true,
                    onChangeOrder: function(photo_id, before_id, after_id){
                        var data = {};


                        if(before_id){
                            data.before_id = before_id;
                        }

                        if(after_id){
                            data.after_id = after_id;
                        }

                        data._method = 'put';

                        $.ajax({
                            type: "POST",
                            data: data,
                            dataType: "json",
                            url: zz.path_prefix + "/photos/" + photo_id + "/position",
                            error: function(error){
                            }

                        });
                        return true;

                    },
                    showThumbscroller: false
                }).data().zz_photogrid;

                $('#article').show();
            }
        });
    },

    bounce: function(success, failure){
//        zz.open_drawer(); //todo: is this needed?
        success();
    }

};




pages.group_tab = {

    GROUP_EDITOR_TEMPLATE: '<div class="group-editor">' +
                 '<div class="who-can-access-header">Who can access this album?</div>' +
                 '<div class="privacy-buttons">' +
                    '<div data-privacy="public" class="public-button"></div>' +
                    '<div data-privacy="hidden" class="hidden-button"></div>' +
                    '<div data-privacy="password" class="password-button"></div>' +
                 '</div>' +
                 '<div class="divider-line"></div>' +
                 '<div class="create-group-header">Create a ZangZing Group and Share via email</div>' +
                 '<div class="people-list">' +
                 '</div>' +
                 '<div class="add-people-section">' +
                    '<div class="add-people-button create-group"></div>' +
                    '<div class="stream-to-email"><input type="checkbox">Automatically email the group about new photos</div>' +
                    '<div class="who-can-upload">' +
                        '<select>' +
                            '<option value="everyone">Everyone</option>' +
                            '<option value="contributors">Contributors</option>' +
                        '</select>' +
                        '<span>can upload photos</span>' +
                    '</div>' +
                    '<div class="who-can-download">' +
                        '<select>' +
                            '<option value="everyone">Everyone</option>' +
                            '<option value="viewers">Group</option>' +
                            '<option value="owner">No one</option>' +
                        '</select>' +
                        '<span>can download full resolution photos</span>' +
                    '</div>' +

                 '</div>' +
                 '<div class="divider-line"></div>' +
                 '<div class="share-header">Share</div>' +
                 '<div class="share-section">' +
                     '<div class="facebook-button"></div>' +
                     '<div class="stream-to-facebook"><input type="checkbox">Automatically post new photos to Facebook</div>' +
                     '<div class="twitter-button"></div>' +
                     '<div class="stream-to-twitter"><input type="checkbox">Automatically tweet new photos</div>' +
                 '</div>' +
             '</div>',

    PERSON_TEMPLATE:  '<div class="person">' +
                                '<img class="profile" src="/images/default_profile.png">' +
                                '<div class="name"></div>' +
                                '<select class="permission" size="1">' +
                                    '<option value="viewer">Viewer</option>' +
                                    '<option value="contributor">Contributor</option>' +
                                '</select>' +
                                '<div class="delete-button"></div>' +
                            '</div>',

    
    FACEBOOK_DIALOG_TEMPLATE: '<div class="facebook-dialog">' +
                                '<div class="header"><div class="title">Share to Facebook</div></div>' +
                                '<textarea placeholder="Write something" class="message"></textarea>' +
                                '<div class="detail">' +
                                    '<img class="photo" src="/images/album-no-cover.png">'+
                                    '<div class="title"></div>'+
                                    '<div class="url"></div>'+
                                    '<div class="description"></div>'+
                                '</div>' +
                                '<div class="footer">' +
//                                    '<div class="stream-to-facebook">' +
//                                        '<input type="checkbox">Automatically post new photos to Facebook' +
//                                    '</div>' +
                                    '<div class="submit-button"></div>' +
                                    '<div class="cancel-button"></div>' +
                                '</div>' +
                              '</div>',

    TWITTER_DIALOG_TEMPLATE : '<div class="twitter-dialog">' +
                                '<div class="header"></div>' +
                                '<div class="share-with-followers">Share with your followers</div>' +
                                '<textarea class="message"></textarea>' +
//                                '<div class="stream-to-twitter">' +
//                                    '<input type="checkbox">Automatically tweet new photos' +
//                                '</div>' +

                                '<div class="chars-left">10</div>' +
                                '<div class="submit-button"></div>' +
                              '</div>',

    ADD_PEOPLE_DIALOG_TEMPLATE:   '<div class="add-people-dialog">' +
                                    '<div class="header">' +
                                        '<div class="title">Add people to your group</div>' +
                                        '<div class="import"><span>Import from </span>' +
                                            '<a data-service="google" class="gray-button contacts-btn"><span><div class="off"></div>Google</span></a>' +
                                            '<a data-service="local" class="gray-button contacts-btn"><span><div class="off"></div>Local</span></a>' +
                                            '<a data-service="yahoo" class="gray-button contacts-btn"><span><div class="off"></div>Yahoo</span></a>' +
                                            '<a data-service="mslive" class="gray-button contacts-btn"><span><div class="off"></div>Hotmail</span></a>' +
                                        '</div>' +
                                    '</div>' +
                                    '<div class="to"><input class="contact-list"></div>' +
                                    '<textarea placeholder="Type a personal note" class="message"></textarea>' +
                                    '<div class="permission">Add them as: <select size="1"><option value="viewer">Viewer</option><option value="contributor">Contributor</option></select></div>' +
                                    '<a class="cancel-button black-button"><span>Cancel</span></a>' +
                                    '<a class="submit-button green-button"><span>OK</span></a>' +
                                  '</div>',


    init: function(container, callback){
        var self = this;


        var check_empty_list = function(){
            if(container.find('.people-list .person').length == 0){
                container.find('.add-people-button').addClass('create-group');
                container.find('.people-list').fadeOut('fast');
            }
            else{
                container.find('.add-people-button').removeClass('create-group');
                container.find('.people-list').fadeIn('fast');
            }

        };

        var refresh_person_list = function(people){
            container.find('.people-list').empty();

            // populate the list
            _.each(people, function(person){
                var element = $(self.PERSON_TEMPLATE);
                element.find('.name').text(person['name']);

                element.find('select.permission').val(person['permission']);
                element.find('select.permission').change(function(){
                    $.post(zz.path_prefix + '/albums/' + zz.album_id + '/update_group_member', {_method:'put', 'member[id]': person.id, 'member[permission]': $(this).val()});
                });

                element.find('.delete-button').click(function(){
                    if(confirm('Are you sure you want to remove ' + person.name + '?')){
                        $.post(zz.path_prefix + '/albums/' + zz.album_id + '/delete_group_member', {_method:'delete', 'member[id]': person.id});
                        element.remove();
                        check_empty_list();
                    }
                });

                container.find('.people-list').append(element);

            });

            check_empty_list();

        };


        $.ajax({
            dataType: 'json',
            url: zz.path_prefix + '/albums/' + zz.album_id + '/edit_group.json',
            error: function(){
                alert('error!');  
            },
            success: function(json){


                var has_facebook_token = json['user']['has_facebook_token'];
                var has_twitter_token = json['user']['has_twitter_token'];

                container.html(self.GROUP_EDITOR_TEMPLATE);

                

                //bind privacy buttons
                container.find('.privacy-buttons .' + json['album']['privacy'] + '-button').addClass('selected');
                container.find('.privacy-buttons').children().click(function(){
                    container.find('.privacy-buttons').children().removeClass('selected');
                    $(this).addClass('selected');
                    $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[privacy]': $(this).attr('data-privacy')});
                });


                refresh_person_list(json['group']);





                //bind stream-to-email checkbox
                container.find('.stream-to-email input').attr('checked', json['album']['stream_to_email']);
                container.find('.stream-to-email input').change(function(){
                    $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[stream_to_email]': $(this).attr('checked')});
                });


                //bind who-can-upload droppdown
                container.find('.who-can-upload select').val(json['album']['who_can_upload']);
                container.find('.who-can-upload select').change(function(){
                    $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[who_can_upload]': $(this).val()});
                });


                //bind who-can-download droppdown
                container.find('.who-can-download select').val(json['album']['who_can_download']);
                container.find('.who-can-download select').change(function(){
                    $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[who_can_download]': $(this).val()});
                });


                //bind stream-to-facebook checkbox
                container.find('.stream-to-facebook input').attr('checked', json['album']['stream_to_facebook']);
                container.find('.stream-to-facebook input').click(function(){
                    //todo: same as twitter code below
                    var element = $(this);

                    //undo the toggle and start over...
                    element.attr('checked', !element.attr('checked'));

                    var set_value = function(value){
                        element.attr('checked', value);
                        $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[stream_to_facebook]': value});
                    }

                    if(element.attr('checked')){
                        set_value(false);
                    }
                    else{
                        if(has_facebook_token){
                            set_value(true);
                        }
                        else{
                            oauthmanager.login_facebook(function(){
                                has_facebook_token = true;
                                set_value(true);
                            });
                        }
                    }
               });

                //bind stream-to-twitter checkbox
                container.find('.stream-to-twitter input').attr('checked', json['album']['stream_to_twitter']);
                container.find('.stream-to-twitter input').change(function(){
                    //todo: same as facebook code above
                    var element = $(this);

                    //undo the toggle and start over...
                    element.attr('checked', !element.attr('checked'));

                    var set_value = function(value){
                        element.attr('checked', value);
                        $.post(zz.path_prefix + '/albums/' + zz.album_id, {_method:'put', 'album[stream_to_twitter]': value});
                    };

                    if(element.attr('checked')){
                        set_value(false);
                    }
                    else{
                        if(has_twitter_token){
                            set_value(true);
                        }
                        else{
                            oauthmanager.login_twitter(function(){
                                has_twitter_token = true;
                                set_value(true);
                            });
                        }
                    }


                });




                //set up event handlers
                container.find('.add-people-button').click(function(){
                    var content = $(self.ADD_PEOPLE_DIALOG_TEMPLATE);

                    var dialog = zz_dialog.show_dialog(content, {width:750, height:320});

                    content.find('textarea.message').placeholder();


                    contact_list.create(zz.current_user_id, content.find('.contact-list'), content.find('.contacts-btn'));



                    content.find('.submit-button').click(function(){

                        var emails = $('.contact-list').val().split(',');
                        var data = {
                            message: content.find('textarea.message').val(),
                            permission: content.find('.permission select').val(),
                            emails: emails
                        };

                        $.post(zz.path_prefix + '/albums/' + zz.album_id + '/add_group_members.json', data, function(json){
                            refresh_person_list(json);
                            dialog.close();
                        });

                    });

                    content.find('.cancel-button').click(function(){
                        dialog.close();
                    });

                });

                container.find('.facebook-button').click(function(){

                    var show_facebook_dialog = function(){
                        var content = $(self.FACEBOOK_DIALOG_TEMPLATE);

                        content.find('.detail .title').text(json['share']['facebook']['title']);
                        content.find('.detail .url').text(json['share']['facebook']['url']);
                        content.find('.detail .description').text(json['share']['facebook']['description']);

                        if(json['share']['facebook']['photo']){
                            content.find('.detail .photo').attr('src', json['share']['facebook']['photo']);
                        }
                        
                        content.find('textarea.message').placeholder();

                        var dialog = zz_dialog.show_dialog(content, {width:650, height:285});

                        content.find('.submit-button').click(function(){
                            var data = {
                                message: content.find('textarea.message').val(),
                                recipients: ['facebook'],
                                service: 'social'
                            };

                            $.post(zz.path_prefix + '/albums/'+ zz.album_id +'/shares.json', data);
                            dialog.close();



                        });

                        content.find('.cancel-button').click(function(){
                            dialog.close();
                        });
                    };


                    if(has_facebook_token){
                       show_facebook_dialog();
                    }
                    else{
                        oauthmanager.login_facebook(function(){
                            has_facebook_token = true;
                            show_facebook_dialog();
                        });
                    }
                });

                container.find('.twitter-button').click(function(){

                    var show_twitter_dialog = function(){
                        var content = $(self.TWITTER_DIALOG_TEMPLATE);


                        var update_char_left = function(){
                            var count = 124 - content.find('textarea.message').val().length;
                            content.find('.chars-left').text(count);
                        };


                        content.find('textarea.message').val(json['share']['twitter']['message']);
                        content.find('textarea.message').keypress(function(){
                            update_char_left();
                        });
                        
                        update_char_left();


                        var dialog = zz_dialog.show_dialog(content, {width:650, height:250});



                        content.find('.submit-button').click(function(){
                            var data = {
                                message: content.find('textarea.message').val(),
                                recipients: ['twitter'],
                                service: 'social'
                            };

                            $.post(zz.path_prefix + '/albums/'+ zz.album_id +'/shares.json', data)
                            dialog.close();
                        });
                    };

                    if(has_twitter_token){
                       show_twitter_dialog();
                    }
                    else{
                        oauthmanager.login_twitter(function(){
                            has_twitter_token = true;
                            show_twitter_dialog();
                        });
                    }
                });
            }
        });


        callback();
    },

    bounce: function(success, failure){
        success();
    }


};









//pages.share = {
//
//    // optional params subject_tupe and subject_id paras are
//    // used when not in the wizard. an 's' is added to
//    // subject_type when constructing routes
//
//    init: function(container, callback, subject_type, subject_id){
//
//        ZZAt.track('album.share_tab.view' );
//
//
//        if(_.isUndefined(subject_type)){
//            subject_type = 'album';
//        }
//
//        if(_.isUndefined(subject_id)){
//            subject_id = zz.album_id;
//        }
//
//        var url = zz.path_prefix +'/shares/new';
//        var self = this;
//
//
//        container.load(url, function(){
//            zz.wizard.resize_scroll_body();
//            $('.social-share').click(function(){
//                self.show_social(container, subject_type, subject_id);
//            });
//
//            $('.email-share').click(function(){
//                self.show_email(container, subject_type, subject_id);
//            });
//
//            callback();
//        });
//    },
//
//
//    share_in_dialog: function(subject_type, subject_id, on_close){
//        var self = this;
//
//
//        var template = $('<div id="share-dialog-content"></div>');
//        $('<div id="share-dialog"></div>').html( template )
//                .zz_dialog({
//                               height: 450,
//                               width: 895,
//                               modal: true,
//                               autoOpen: true,
//                               open : function(event, ui){
//                                   self.init(template, function(){}, subject_type, subject_id);
//                               },
//                               close: function(event, ui){
//                                   if(!_.isUndefined(on_close)){
//                                       on_close();
//                                   }
//                               }
//                           });
//
//    },
//
//
//    bounce: function(success, failure){
//        success();
//    },
//
//    // loads the status message post form in place of the type switcher on the share step
//    show_social: function(container, subject_type, subject_id){
//        var self = this;
//
//        $('div#share-body').fadeOut('fast', function(){
//            $('div#share-body').load(zz.path_prefix +'/shares/newpost', function(){
//                zz.wizard.resize_scroll_body();
//
//
//
//                $("#facebook_box").click( function(){
//                    if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
//                        $(this).attr('checked', false);
//                        oauthmanager.login(zz.path_prefix + '/facebook/sessions/new', function(){
//                            $("#facebook_box").attr('checked', true);
//                            $("#facebook_box").attr('authorized', 'yes');
//                        });
//                    }
//                });
//
//                $("#twitter_box").click( function(){
//                    if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
//                        $(this).attr('checked', false);
//                        oauthmanager.login(zz.path_prefix + '/twitter/sessions/new', function(){
//                            $("#twitter_box").attr('checked', true);
//                            $("#twitter_box").attr('authorized', 'yes');
//                        });
//                    }
//                });
//
//
//                $('#new_post_share').validate({
//                    rules: {
//                        'post_share[message]':  { required: true, minlength: 0, maxlength: 118 },
//                        'post_share[facebook]': { required: "#twitter_box:unchecked" },
//                        'post_share[twitter]':  { required:  "#facebook_box:unchecked"}
//                    },
//                    messages: {
//                        'post_share[message]': '',
//                        'post_share[facebook]': '',
//                        'post_share[twitter]': ''
//                    },
//                    submitHandler: function() {
//                        var serialized = $('#new_post_share').serialize();
//                        $.post(zz.path_prefix + '/' + subject_type + 's/'+ subject_id +'/shares.json', serialized, function(data,status,request){
//                            pages.share.reload_share(container, subject_type, subject_id, function(){
//                                zz.wizard.display_flashes(  request,200 )
//                            });
//                        });
//                    }
//                });
//
//                $('#cancel-share').click(function(){
//                    self.reload_share(container, subject_type, subject_id);
//                });
//
//                $('#post_share_button').click(function(){
//                    $('form#new_post_share').submit();
//                });
//
//
//
//                $('#post_share_message').keypress( function(){
//                    setTimeout(function(){
//                        var text = 'characters';
//                        var count = $('#post_share_message').val().length
//                        if(count === 1){
//                            text = 'character';
//                        }
//                        $('#character-count').text(count + ' ' + text);
//                    }, 10);
//                });
//
//                $('div#share-body').fadeIn('fast');
//            });
//        });
//    },
//
//
//    // loads the email post form in place of the type switcher on the share step
//    show_email: function(container, subject_type, subject_id ){
//        var self = this;
//        $('div#share-body').fadeOut('fast', function(){
//            $('div#share-body').load(zz.path_prefix + '/shares/newemail', function(){
//
//                $("#contact-list").tokenInput( zzcontacts.find, {
//                    allowNewValues: true,
//                    classes: {
//                        tokenList: "token-input-list-facebook",
//                        token: "token-input-token-facebook",
//                        tokenDelete: "token-input-delete-token-facebook",
//                        selectedToken: "token-input-selected-token-facebook",
//                        highlightedToken: "token-input-highlighted-token-facebook",
//                        dropdown: "token-input-dropdown-facebook",
//                        dropdownItem: "token-input-dropdown-item-facebook",
//                        dropdownItem2: "token-input-dropdown-item2-facebook",
//                        selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
//                        inputToken: "token-input-input-token-facebook"
//                    }
//                });
//                zzcontacts.init( zz.current_user_id );
//                zz.wizard.resize_scroll_body();
//
//                $('#new_email_share').validate({
//                    rules: {
//                        'email_share[to]':      { required: true, minlength: 0 },
//                        'email_share[message]': { required: true, minlength: 0 }
//                    },
//                    messages: {
//                        'email_share[to]': 'At least one recipient is required',
//                        'email_share[message]': ''
//                    },
//
//                    submitHandler: function() {
//                        $.ajax({ type:     'POST',
//                            url:      zz.path_prefix + '/'+ subject_type + 's/'+ subject_id +'/shares.json',
//                            data:      $('#new_email_share').serialize(),
//                            dataType: 'json',
//                            success: function(errors,status,request ){
//                                if( errors && errors.length > 0 ){
//                                    $.each(errors, function( index, error ){
//                                        $('ul.token-input-list-facebook li:nth-child('+(error.index+1)+')').addClass('error')
//                                    });
//                                }else{
//                                    self.reload_share(container, subject_type, subject_id, function(){
//                                        zz.wizard.display_flashes(  request,200 );
//                                    });
//                                }
//                            }
//                        });
//                    }
//                });
//
//                $('#cancel-share').click(function(){
//                    self.reload_share(container, subject_type, subject_id);
//                });
//
//                $('#mail-submit').click(function(){
//                    $('form#new_email_share').submit();
//                });
//                $('div#share-body').fadeIn('fast');
//            });
//        });
//    },
//
//
//
//
//    // reloads the main share part in place of the type switcher on the share step
//    reload_share: function(container, subject_type, subject_id, callback){
//        var self = this;
//        container.fadeOut('fast', function(){
//            self.init(container, function(){
//                container.fadeIn('fast');
//                if( typeof(callback) != "undefined" ){
//                    callback();
//                }
//            }, subject_type, subject_id);
//        });
//    }
//
//
//};
//
//pages.contributors = {
//
//    present : false,
//    url :'',
//
//    init: function(container, callback){
//
//        ZZAt.track('album.contributors_tab.view');
//
//        this.url = zz.path_prefix + '/albums/'+zz.album_id+'/contributors';
//        pages.contributors.show_list(container, callback);
//    },
//
//    bounce: function(success, failure){
//        success();
//    },
//
//    show_list: function( container, callback, request ){
//        container.load( pages.contributors.url , function(){
//            //The contributors arrived in tmp_contact_list and declared when screen loaded
//            if( tmp_contact_list.length <= 0 ){
//                pages.contributors.present = false;
//                pages.contributors.show_new(container, callback);
//            } else {
//                pages.contributors.present = true;
//                // initialize the tokenized contact list widget
//                $('#contributors-list').tokenInput(  '' , {
//                    allowNewValues: false,
//                    displayOnly : true,
//                    prePopulate: {
//                        data: tmp_contact_list,
//                        forceDataFill: true
//                    },
//                    classes: {
//                        tokenList: "token-input-list-facebook",
//                        token: "token-input-token-facebook",
//                        tokenDelete: "token-input-delete-token-facebook",
//                        selectedToken: "token-input-selected-token-facebook",
//                        highlightedToken: "token-input-highlighted-token-facebook",
//                        dropdown: "token-input-dropdown-facebook",
//                        dropdownItem: "token-input-dropdown-item-facebook",
//                        dropdownItem2: "token-input-dropdown-item2-facebook",
//                        selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
//                        inputToken: "token-input-input-token-facebook"
//                    }
//                });
//                //bind to the widget's object deleted event
//                $('#contributors-list').bind('tokenDeleted',function(e, id, name, count  ){
//                    $.post(pages.contributors.url, { _method: 'delete', id: id}, function(data, status, request){
//                        zz.wizard.display_flashes(  request, 200 );
//                        if( count <= 0){ //the contributor list is empty
//                            pages.contributors.present = false;
//                            container.fadeOut('fast', function(){
//                                pages.contributors.show_new(container);
//                            } );
//                        }
//                    });
//                });
//                zz.wizard.resize_scroll_body();
//                $('#add-contributors-btn').click(function(){
//                    container.fadeOut('fast', function(){
//                        pages.contributors.show_new(container);
//                    });
//                });
//                container.fadeIn('fast', function( ){
//                    if( typeof( request )!= 'undefined'){
//                        zz.wizard.display_flashes(  request,200 );
//                    }
//                });
//
//                if(! _.isUndefined(callback)){
//                    callback();
//                }
//
//            }
//        });
//    },
//
//    show_new: function(container, callback){
//        container.load(zz.path_prefix + '/albums/'+zz.album_id+'/contributors/new', function(){
//
//            $("#contact-list").tokenInput( zzcontacts.find, {
//                allowNewValues: true,
//                hintText: '',
//                classes: {
//                    tokenList: "token-input-list-facebook",
//                    token: "token-input-token-facebook",
//                    tokenDelete: "token-input-delete-token-facebook",
//                    selectedToken: "token-input-selected-token-facebook",
//                    highlightedToken: "token-input-highlighted-token-facebook",
//                    dropdown: "token-input-dropdown-facebook",
//                    dropdownItem: "token-input-dropdown-item-facebook",
//                    dropdownItem2: "token-input-dropdown-item2-facebook",
//                    selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
//                    inputToken: "token-input-input-token-facebook"
//                }
//            });
//            zzcontacts.init( zz.current_user_id );
//            zz.wizard.resize_scroll_body();
//            $('#new_contributors').validate({
//                rules: {
//                    'contact_list':    { required: true},
//                    'contact_message': { required: true}
//                },
//                messages: {
//                    'contact_list': 'Empty',
//                    'contact_message': ''
//                },
//
//                //todo: submit errors are not being shown properly
//                submitHandler: function() {
//                    $.ajax({ type:     'POST',
//                        url:      zz.path_prefix + '/albums/'+zz.album_id+'/contributors.json',
//                        data:     $('#new_contributors').serialize(),
//                        dataType: 'json',
//                        success:  function(errors,status,request){
//                            if( errors && errors.length > 0 ){
//                                $.each(errors, function( index, error ){
//                                    $('ul.token-input-list-facebook li:nth-child('+(error.index+1)+')').addClass('error')
//                                });
//                            }else{
//                                container.fadeOut('fast','swing', function(){
//                                    pages.contributors.show_list( container, callback,  request );
//                                });
//                            }
//                        }
//                    });
//                }
//            });
//
//            if( pages.contributors.present){
//                $('#cancel-new-contributors').click(function(){
//                    container.fadeOut('fast', function(){
//                        pages.contributors.show_list(container, callback);
//                    } );
//                });
//            }else{
//                $('#cancel-new-contributors').hide();
//            }
//
//            $('#submit-new-contributors').click(function(){
//                $('form#new_contributors').submit();
//            });
//
//            container.fadeIn('fast');
//
//            if(! _.isUndefined(callback)){
//                callback();
//            }
//
//        });
//    }
//};






pages.download_agent = {
    NO_AGENT_URL: '/static/templates/download_agent.html?v1',

    get_message_url: function(){
        ZZAt.track('agentdownload.requested');
        return this.NO_AGENT_URL;
    },

    keep_polling: function(){
        return $('.zangzing-downloader').length > 0;
    },


    dialog: function( onClose, startDownload ){

        $('<div></div>', { id: 'no-agent-dialog'}).load(pages.download_agent.get_message_url(), function(){

            $( this ).zz_dialog({
                modal: true,
                width: 910,
                height: 510,
                close:  function(){
                    if(onClose){
                        onClose();
                    }
                }
            });

            $('.zangzing-downloader #download-btn').click( function(){
                pages.download_agent.download();
            });

            $('.zangzing-downloader #download-link').click( function(){
                pages.download_agent.download();
            });



            pages.download_agent.poll_agent( function(){
                $( '#no-agent-dialog' ).zz_dialog('close');
            });


            //if this is IE and WinXp, don't auto-start download
            //because ie will pop up approval bar which forces
            //full page refresu
            if(navigator.appVersion.indexOf("NT 5.1") !=  -1 && $.client.browser=='Explorer'){
                startDownload = false;
            }



            if(startDownload){
                $( this ).find('.manual-start').hide();

                setTimeout(function(){
                    pages.download_agent.download();
                }, 1000);
            }
            else{
                $( this ).find('.auto-start').hide();
            }
        });

    },

    poll_agent: function( when_ready ){
        agent.getStatus( function( status ){
            if( status == agent.STATUS.READY ){
                $('.zangzing-downloader #download-btn').attr('disabled', 'disabled');
                $('.zangzing-downloader .step.four .graphic').addClass('ready');
                if(  when_ready ){
                    setTimeout( when_ready, 2000 );
                }

            }
            else{
                if( pages.download_agent.keep_polling() ){
                    setTimeout( function(){
                        pages.download_agent.poll_agent( when_ready )
                    }, 1000);
                }
            }
        });
    },

    download: function(){
        ZZAt.track('agentdownload.get');

        if($.client.os =="Mac"){
            document.location.href = zz.mac_download_url; //'http://downloads.zangzing.com/agent/darwin/ZangZing-Setup.pkg'
        }
        else{
            if($.client.browser == 'Chrome'){
                //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                window.open(zz.win_download_url);
            }
            else{
                document.location.href = zz.win_download_url;
            }

        }

    }
};



pages.alert_dialog = {
    show: function(alert_dialog_url){
        if( typeof(alert_dialog_url) != 'undefined'){
            $.ajax({ type:    'GET',
                url:     alert_dialog_url,
                success: function(html){
                    $('body').append(html);
                }
            });

        }
    }
};