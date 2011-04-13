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
            $('#album_name').keypress(function(){
                album_email_call_lock++;
                setTimeout(function(){
                    album_email_call_lock--;
                    if(album_email_call_lock==0){
                        $.ajax({
                            url: zz.path_prefix + '/albums/' + zz.album_id + '/preview_album_email?' + $.param({album_name: $('#album_name').val()}),
                            success: function(json){
                                $('#album_email').text(json.email);
                                $('#album_url').text(json.url);
                            },
                            error: function(){
                                $('#album_name').val(pages.album_name_tab.original_album_name);
                                $('h2#album-header-title').text(pages.album_name_tab.original_album_name);
                            }
                        });
                    }
                }, 1000);
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
                            type: "DELETE",
                            dataType: "json",
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
                            type: "PUT",
                            dataType: "json",
                            url: zz.path_prefix + "/photos/" + photo.id + ".json",
                            data: {'photo[caption]':caption},
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



                        $.ajax({
                            type: "PUT",
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

pages.album_privacy_tab = {
    init: function(container,callback){

        ZZAt.track('album.privacy_tab.view');


        var url = zz.path_prefix + '/albums/' + zz.album_id + '/privacy';
        container.load(url, function(){

            $('#privacy-public').click(function(){
                $.post(zz.path_prefix + '/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                    $('img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-off.png'));
                    $('#privacy-public img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-on.png'));
                });
            });
            $('#privacy-hidden').click(function(){
                $.post(zz.path_prefix + '/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
                $('img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-off.png'));
                $('#privacy-hidden img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-on.png'));
            });
            $('#privacy-password').click(function(){
                $.post(zz.path_prefix + '/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
                $('img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-off.png'));
                $('#privacy-password img.select-button').attr('src', path_helpers.image_url('/images/btn-round-selected-on.png'));
            });

            callback();
        });
    },

    bounce: function(success, failure){
        success();
    }
};

pages.share = {







    // optional params subject_tupe and subject_id paras are
    // used when not in the wizard. an 's' is added to
    // subject_type when constructing routes

    init: function(container, callback, subject_type, subject_id){

        ZZAt.track('album.share_tab.view');


        if(_.isUndefined(subject_type)){
            subject_type = 'album';
        }

        if(_.isUndefined(subject_id)){
            subject_id = zz.album_id;
        }

        var url = zz.path_prefix +'/shares/new';
        var self = this;



        container.load(url, function(){
           zz.wizard.resize_scroll_body();
           $('.social-share').click(function(){
                self.show_social(container, subject_type, subject_id);
            });

            $('.email-share').click(function(){
                self.show_email(container, subject_type, subject_id);
            });

            callback();
        });
    },


    share_in_dialog: function(subject_type, subject_id, on_close){
        var self = this;


        var template = $('<div id="share-dialog-content"></div>');
        $('<div id="share-dialog"></div>').html( template )
                                               .zz_dialog({
                                                         height: 450,
                                                         width: 895,
                                                         modal: true,
                                                         autoOpen: true,
                                                         open : function(event, ui){
                                                            self.init(template, function(){}, subject_type, subject_id);
                                                         },
                                                         close: function(event, ui){
                                                            if(!_.isUndefined(on_close)){
                                                                on_close();
                                                            }
                                                         }
        });

    },


    bounce: function(success, failure){
        success();
    },

    // loads the status message post form in place of the type switcher on the share step
    show_social: function(container, subject_type, subject_id){
        var self = this;

        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load(zz.path_prefix +'/shares/newpost', function(){
                zz.wizard.resize_scroll_body();



                $("#facebook_box").click( function(){
                    if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login(zz.path_prefix + '/facebook/sessions/new', function(){
                            $("#facebook_box").attr('checked', true);
                            $("#facebook_box").attr('authorized', 'yes');
                        });
                    }
                });

                $("#twitter_box").click( function(){
                    if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login(zz.path_prefix + '/twitter/sessions/new', function(){
                            $("#twitter_box").attr('checked', true);
                            $("#twitter_box").attr('authorized', 'yes');
                        });
                    }
                });


                $('#new_post_share').validate({
                    rules: {
                        'post_share[message]':  { required: true, minlength: 0, maxlength: 118 },
                        'post_share[facebook]': { required: "#twitter_box:unchecked" },
                        'post_share[twitter]':  { required:  "#facebook_box:unchecked"}
                    },
                    messages: {
                        'post_share[message]': '',
                        'post_share[facebook]': '',
                        'post_share[twitter]': ''
                    },
                    submitHandler: function() {
                        var serialized = $('#new_post_share').serialize();
                        $.post(zz.path_prefix + '/' + subject_type + 's/'+ subject_id +'/shares.json', serialized, function(data,status,request){
                            pages.share.reload_share(container, subject_type, subject_id, function(){
                                zz.wizard.display_flashes(  request,200 )
                            });
                        });
                    }
                });

                $('#cancel-share').click(function(){
                    self.reload_share(container, subject_type, subject_id);
                });

                $('#post_share_button').click(function(){
                    $('form#new_post_share').submit();
                });



                $('#post_share_message').keypress( function(){
                    setTimeout(function(){
                        var text = 'characters';
                        var count = $('#post_share_message').val().length
                        if(count === 1){
                            text = 'character';
                        }
                        $('#character-count').text(count + ' ' + text);
                    }, 10);
                });

                $('div#share-body').fadeIn('fast');
            });
        });
    },


    // loads the email post form in place of the type switcher on the share step
    show_email: function(container, subject_type, subject_id ){
        var self = this;
        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load(zz.path_prefix + '/shares/newemail', function(){

                $("#contact-list").tokenInput( zzcontacts.find, {
                    allowNewValues: true,
                    classes: {
                        tokenList: "token-input-list-facebook",
                        token: "token-input-token-facebook",
                        tokenDelete: "token-input-delete-token-facebook",
                        selectedToken: "token-input-selected-token-facebook",
                        highlightedToken: "token-input-highlighted-token-facebook",
                        dropdown: "token-input-dropdown-facebook",
                        dropdownItem: "token-input-dropdown-item-facebook",
                        dropdownItem2: "token-input-dropdown-item2-facebook",
                        selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                        inputToken: "token-input-input-token-facebook"
                    }
                });
                zzcontacts.init( zz.current_user_id );
                zz.wizard.resize_scroll_body();

                $('#new_email_share').validate({
                    rules: {
                        'email_share[to]':      { required: true, minlength: 0 },
                        'email_share[message]': { required: true, minlength: 0 }
                    },
                    messages: {
                        'email_share[to]': 'At least one recipient is required',
                        'email_share[message]': ''
                    },

                    submitHandler: function() {
                        var serialized = $('#new_email_share').serialize();
                        $.post(zz.path_prefix + '/'+ subject_type + 's/'+ subject_id +'/shares.json', serialized, function(data,status,request ){
                            self.reload_share(container, subject_type, subject_id, function(){
                                zz.wizard.display_flashes(  request,200 );
                            });
                        },"json");
                    }

                });

                $('#cancel-share').click(function(){
                    self.reload_share(container, subject_type, subject_id);
                });

                $('#mail-submit').click(function(){
                    $('form#new_email_share').submit();
                });
                $('div#share-body').fadeIn('fast');
            });
        });
    },




    // reloads the main share part in place of the type switcher on the share step
    reload_share: function(container, subject_type, subject_id, callback){
        var self = this;
        container.fadeOut('fast', function(){
            self.init(container, function(){
                container.fadeIn('fast');
                if( typeof(callback) != "undefined" ){
                    callback();
                }
            }, subject_type, subject_id);
        });
    }


};

pages.contributors = {

    present : false,
    url :'',

    init: function(container, callback){

        ZZAt.track('album.contributors_tab.view');

        this.url = zz.path_prefix + '/albums/'+zz.album_id+'/contributors';
        pages.contributors.show_list(container, callback);
    },

    bounce: function(success, failure){
        success();
    },

    show_list: function( container, callback, request ){
        container.load( pages.contributors.url , function(){
                //The contributors arrived in tmp_contact_list and declared when screen loaded
                if( tmp_contact_list.length <= 0 ){
                    pages.contributors.present = false;
                    pages.contributors.show_new(container, callback);
                } else {
                     pages.contributors.present = true;
                     // initialize the tokenized contact list widget
                     $('#contributors-list').tokenInput(  '' , {
                                allowNewValues: false,
                                displayOnly : true,
                                prePopulate: {
                                    data: tmp_contact_list,
                                    forceDataFill: true
                                },
                                classes: {
                                    tokenList: "token-input-list-facebook",
                                    token: "token-input-token-facebook",
                                    tokenDelete: "token-input-delete-token-facebook",
                                    selectedToken: "token-input-selected-token-facebook",
                                    highlightedToken: "token-input-highlighted-token-facebook",
                                    dropdown: "token-input-dropdown-facebook",
                                    dropdownItem: "token-input-dropdown-item-facebook",
                                    dropdownItem2: "token-input-dropdown-item2-facebook",
                                    selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                                    inputToken: "token-input-input-token-facebook"
                                }
                        });
                        //bind to the widget's object deleted event
                        $('#contributors-list').bind('tokenDeleted',function(e, id, name, count  ){
                                $.post(pages.contributors.url, { _method: 'delete', id: id}, function(data, status, request){
                                    zz.wizard.display_flashes(  request, 200 );
                                    if( count <= 0){ //the contributor list is empty
                                        pages.contributors.present = false;
                                        container.fadeOut('fast', function(){
                                            pages.contributors.show_new(container);
                                        } );
                                    }
                                });
                        });
                        zz.wizard.resize_scroll_body();
                        $('#add-contributors-btn').click(function(){
                            container.fadeOut('fast', function(){
                                pages.contributors.show_new(container);
                            });
                        });
                        container.fadeIn('fast', function( ){
                            if( typeof( request )!= 'undefined'){
                                zz.wizard.display_flashes(  request,200 );
                        }
                    });

                    if(! _.isUndefined(callback)){
                        callback();
                    }

                }
        });
    },

    show_new: function(container, callback){
        container.load(zz.path_prefix + '/albums/'+zz.album_id+'/contributors/new', function(){

            $("#contact-list").tokenInput( zzcontacts.find, {
                allowNewValues: true,
                classes: {
                    tokenList: "token-input-list-facebook",
                    token: "token-input-token-facebook",
                    tokenDelete: "token-input-delete-token-facebook",
                    selectedToken: "token-input-selected-token-facebook",
                    highlightedToken: "token-input-highlighted-token-facebook",
                    dropdown: "token-input-dropdown-facebook",
                    dropdownItem: "token-input-dropdown-item-facebook",
                    dropdownItem2: "token-input-dropdown-item2-facebook",
                    selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                    inputToken: "token-input-input-token-facebook"
                }
            });
            zzcontacts.init( zz.current_user_id );
            zz.wizard.resize_scroll_body();
            $('#new_contributors').validate({
                rules: {
                    'contact_list':    { required: true},
                    'contact_message': { required: true}
                },
                messages: {
                    'contact_list': 'Empty',
                    'contact_message': ''
                },

                //todo: submit errors are not being shown properly
                submitHandler: function() {
                    $.ajax({ type:     'POST',
                        url:      zz.path_prefix + '/albums/'+zz.album_id+'/contributors.json',
                        data:     $('#new_contributors').serialize(),
                        success:  function(data,status,request){
                            container.fadeOut('fast','swing', function(){
                                pages.contributors.show_list( container, callback,  request );
                            });
                        }
                    });
                }
            });

            if( pages.contributors.present){
                $('#cancel-new-contributors').click(function(){
                    container.fadeOut('fast', function(){
                        pages.contributors.show_list(container, callback);
                    } );
                });
            }else{
                $('#cancel-new-contributors').hide();
            }

            $('#submit-new-contributors').click(function(){
                $('form#new_contributors').submit();
            });

            container.fadeIn('fast');

            if(! _.isUndefined(callback)){
                callback();
            }
            
        });
    }
};

//pages.acct_profile = {
//
//    profile_photo_picker: 'undefined',
//
//    init: function(container, callback){
//        var url = zz.path_prefix + '/users/' + zz.current_user_id +'/edit';
//        var self = pages.acct_profile;
//
//        container.load(url, function(){
//
//            zz.drawers.settings.redirect =  window.location;
//            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -140) + 'px'});
//            $(self.validator.element).validate(self.validator);
//            $('#user_username').keypress( function(){
//                setTimeout(function(){
//                    $('#username-path').text( $('#user_username').val() );
//                }, 10);
//            });
//
//            self.init_profile_photo_picker();
//            self.init_add_photos_dialog();
//
//            $('#profile-photo-button').click( pages.acct_profile.show_add_photos_dialog );
//            $('#ok-profile-button').click(function(){
//                    self.update_profile( function(){
//                        zz.wizard.close_settings_drawer();
//                });
//            });
//            $('#cancel-profile-button').click(zz.wizard.close_settings_drawer)
//
//            callback();
//        });
//    },
//
//    bounce: function(success, failure){
//        this.update_profile( success );
//    },
//
//    load_profile_photos: function( success_callback ){
//            $.ajax({
//                dataType: 'json',
//                url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + (new Date()).getTime(),  //force browser cache miss
//                success: function(json){
//                    var selectedIndex=-1;
//                    var currentId = $('#profile-photo-id').val();
//                    var photos = $.map(json, function(element, index){
//                        var id = element.id;
//                        if(id == currentId){
//                            selectedIndex = index;
//                        }
//                        var src = element.thumb_url;
//                        src = agent.checkAddCredentialsToUrl(src);
//                        return {id:id, src:src};
//                    });
//                    success_callback(photos,selectedIndex);
//                }
//            });
//    },
//
//    init_profile_photo_picker: function(){
//        pages.acct_profile.load_profile_photos( function( photos, selectedIndex ){
//            pages.acct_profile.profile_photo_picker = $("#profile-photo-picker").zz_thumbtray({
//                photos:photos,
//                showSelection:true,
//                selectedIndex:selectedIndex,
//                onSelectPhoto: function(index, photo){
//                    var photo_id = '';
//                    if(index!==-1){
//                        photo_id = photo.id
//                    }
//                    $('#profile-photo-id').val(photo_id);
//                    $('div#profile-photo-picker div.thumbtray-wrapper div.thumbtray-selection').css('top', 0);
//                }
//            }).data().zz_thumbtray;
//            pages.acct_profile.profile_photo_picker.setPhotos( photos );
//            pages.acct_profile.profile_photo_picker.setSelectedIndex( selectedIndex );
//        });
//    },
//
//    refresh_profile_photo_picker: function(){
//        pages.acct_profile.load_profile_photos( function( photos, selectedIndex ){
//            pages.acct_profile.profile_photo_picker.setPhotos( photos );
//            pages.acct_profile.profile_photo_picker.setSelectedIndex( selectedIndex );
//        });
//    },
//
//    init_add_photos_dialog: function(){
//        //for the add_photos call, the id is irrelevant, it just delivers the filechooser DOM
//        var template = $('<div class="photochooser-container"></div>');
//        $('<div id="add-photos-dialog"></div>').html( template ).zz_dialog({
//            album_id: zz.album_id,
//            height: $(document).height() - 200,
//            width: 895,
//            modal: true,
//            autoOpen: false,
//            open : function(event, ui){ template.zz_photochooser({}) },
//            close: function(event, ui){
//                $.ajax({ url:      zz.path_prefix + '/albums/' +zz.album_id + '/close_batch',
//                    complete: function(request, textStatus){
//                        logger.debug('Batch closed because Add photos dialog was closed. Call to close_batch returned with status= '+textStatus);
//                    },
//                    success: function(){
//                        pages.acct_profile.refresh_profile_photo_picker()
//                    }
//                });
//            }
//        });
//        template.height( $(document).height() - 192 );
//    },
//
//    show_add_photos_dialog: function(event){
//        $('#add-photos-dialog').zz_dialog('open');
//    },
//
//
//    update_profile: function(success) {
//        if( $(this.validator.element).validate() ){
//            var serialized = $(this.validator.element).serialize();
//            $.ajax({
//                type: 'POST',
//                url: zz.path_prefix + '/users/'+zz.current_user_id+'.json',
//                data: serialized,
//                success: function(){
//                    $('#user_old_password').val('');
//                    $('#user_password').val('');
//                    if (typeof(success) !== 'undefined') success();
//                },
//                error: function(request){
//                    $('#user_old_password').val('');
//                    $('#user_password').val('');
//                }
//            });
//        }
//    },
//
//    //todo: because we attach a click handler to the '#ok_profile_button', the validator is never run
//    validator: {
//        element: '#profile-form form',
//        errorContainer: '#flashes-notice',
//        rules: {
//            'user[first_name]':     { required: true,
//                minlength: 5 },
//            'user[last_name]':     { required: true,
//                minlength: 5 },
//            'user[username]': { required: true,
//                minlength: 1,
//                maxlength: 25,
//                regex: "(^[a-z0-9]+$|^[a-z0-9]+:.{8}$)",
////                remote: zz.path_prefix + '/users/validate_username' },
//                remote: '/service/users/validate_username' },
//            'user[email]':    { required: true,
//                email: true,
////                remote: zz.path_prefix + '/users/validate_email' },
//                remote: '/service/users/validate_email' },
//            'user[old_password]':{ minlength: 5,
//                required:{ depends: function(element) {
//                    logger.debug( "length is "+ $("#user_password").val().length);
//                    return $("#user_password").val().length > 0;}
//                }},
//            'user[password]': { minlength: 5 }
//        },
//        messages: {
//            'user[first_name]':{ required: 'Please enter your first name.',
//                minlength: 'Please enter at least 5 letters'},
//            'user[last_name]': { required: 'Please enter your last name.',
//                minlength: 'Please enter at least 5 letters'},
//            'user[username]': {  required: 'A username is required.',
//                regex: 'Only lowercase alphanumeric characters allowed',
//                remote: 'username already taken'},
//            'user[email]':   {   required: 'We promise we won&rsquo;t spam you.',
//                email: 'Is that a valid email?',
//                remote: 'Email already used'},
//            'user[password]': 'Six characters or more please.'
//        },
//
//        //todo: i don't think this ever gets called
//        submitHandler: function(form){
//            pages.acct_profile.update_profile(function(){
//                zz.wizard.close_settings_drawer();
//            })
//        }
//    }
//
//
//
//
//};

//pages.account_setings_account_tab = {
//    init: function(container, callback){
//        container.empty();
//        callback();
//    },
//
//    bounce: function(success, failure){
//        success();
//    }
//
//};
//
//pages.account_setings_notifications_tab = {
//    init: function(container, callback){
//        container.empty();
//        callback();
//    },
//
//    bounce: function(success, failure){
//        success();
//    }
//
//};

//pages.linked_accounts = {
//    init: function(container, callback){
//        var url = zz.path_prefix + '/users/' + zz.current_user_id + '/identities';
//        container.load( url, function(){
//            zz.drawers.settings.redirect =  window.location;
//            $('.delete-id-button').click(pages.linked_accounts.delete_identity);
//            $('.authorize-id-button').click(pages.linked_accounts.authorize_identity);
//            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -110) + 'px'});
//            $('#ok_id_button').click(  zz.wizard.close_settings_drawer );
//            callback();
//        });
//    },

//    bounce: function(success, failure){
//         success();
//    },

//    delete_identity: function(){
//        logger.debug("Deleting ID with URL =  "+ $(this).attr('value'));
//        var service = $(this).attr('service');
//        $.post($(this).attr('value'), {"_method": "delete"},  function(){
//            logger.debug( "identity_deleted event for service "+service);
//            $('#'+service+'-status').fadeOut('slow'); //hide the linked status
//            $('#'+service+'-delete').fadeOut( 'fast', function(){  //remove the unlink button
//                $('#'+service+'-authorize').fadeIn('fast');//display the link button
//            });
//        });
//    },
//
//    authorize_identity: function(){
//        logger.debug("Authorizing ID with URL =  "+ $(this).attr('value'));
//        var service = $(this).attr('service');
//        oauthmanager.login( $(this).attr('value') , function(){
//            logger.debug( "identity_linked event for service "+service);
//            $('#'+service+'-status').fadeIn('slow'); //display the linked status
//            $('#'+service+'-authorize').fadeOut( 'fast', function(){  //remove the link button
//                $('#'+service+'-delete').fadeIn( 'fast', function(){
//                    if( $('#flashes-notice')){
//                        var msg = "Your can now use "+ service+" features throughout ZangZing";
//                        $('#flashes-notice').text(msg).fadeIn('fast', function(){
//                            setTimeout(function(){
//                                $('#flashes-notice').fadeOut('fast', function(){
//                                    $('#flashes-notice').text('    ');
//                                });
//                            }, 3000);
//                        });
//                    }
//                });//display the unlink button
//            });
//        });
//    }
//};

pages.no_agent = {
    NO_AGENT_URL: '/static/connect_messages/no_agent.html',
    OSX_10_5_URL: '/static/connect_messages/no_agent_unsupported_os.html',

    get_message_url: function(){
        if(navigator.appVersion.indexOf('Mac OS X 10_5') != -1){
            ZZAt.track('agentdownload.requested.osx10_5');
            return this.OSX_10_5_URL;
        }
        else{
            ZZAt.track('agentdownload.requested');
            return this.NO_AGENT_URL;
        }
    },

    keep_polling: function(){
        return $('.zangzing-downloader').length > 0;
    },

    filechooser: function(container, when_ready ){

        container.load(pages.no_agent.get_message_url(), function(){

            //hack: download screen is in the body, but we want
            //it to show up at the top of the chooser, under the hdeader
            //so, move it up 70px, the height of the header

            $('.zangzing-downloader').css({top:'-70px'});



            $('.zangzing-downloader #download-btn').click( function(){
               pages.no_agent.download();
            });

            pages.no_agent.keep_polling();
            pages.no_agent.poll_agent( function(){
                if( $.isFunction(  when_ready )) when_ready();
            });

        });
    },

    dialog: function( onClose ){

         $('<div></div>', { id: 'no-agent-dialog'}).load(pages.no_agent.get_message_url(), function(){
             $('.zangzing-downloader #download-btn').click( function(){
                 pages.no_agent.download();
             }) ;
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
               pages.no_agent.download();
            });


             pages.no_agent.poll_agent( function(){
                 $( '#no-agent-dialog' ).zz_dialog('close');
             });
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
				    ZZAt.track('agentdownload.ready');
              }
              else if( status == agent.STATUS.BAD_SESSION ){
                  alert("Sorry, your session has expired. Please sign in again.");
                  document.location.href = path_helpers.rails_route('signin');
              }
              else{
                  if( pages.no_agent.keep_polling() ){
                    setTimeout( function(){
                        pages.no_agent.poll_agent( when_ready )
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

pages.signin = {

    _show: function( message, signin ){
        if (zz.drawer_state === zz.DRAWER_CLOSED) {
                if( typeof( message ) != 'undefined' && typeof(message) == 'string'){
                   var msg = $('<p>'+message+'</p>');
                   msg.addClass("flash-notice");
                   $('#signin-flashbox').append( msg );
                   msg.show();
                   $('#signin-form-cancel-button').click( function(){msg.remove();});
                }

                if( signin ){ //for signun
                    $('#header #sign-in-button').addClass('selected');
                    $('#sign-in').show();
                    $('#sign-up').hide();
                } else { //for join
                    $('#header #sign-in-button').addClass('selected');
                    $('#sign-in').hide();
                    $('#sign-up').show();
                }
                $('#small-drawer').show().animate({height: '500px', top: '56px'}, 500, 'linear', function() {
                    $('#user_session_email').focus();
                });
                zz.drawer_state = zz.DRAWER_OPEN;
            }
    },

    join: function( message ){
        pages.signin._show(message, false);
    },

    signin: function(message){
        pages.signin._show(message, true);
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