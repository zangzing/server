var pages = {};

pages.album_add_photos_tab = {
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/add_photos';
        $('#tab-content').load(url, function(){
            filechooser.init();
            setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
            callback();
        });
    },

    bounce: function(){
        $('#added-pictures-tray').fadeOut('fast');
    }
};



pages.album_name_tab = {
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/name_album';

        $('#tab-content').load(url, function(){

            $('h2#album-header-title').html($('#album_name').val());

    //        $('#album_email').val( zz.wizard.dashify($('#album_name').val()));

            $('#album_name').keypress( function(){
                setTimeout(function(){
                    $('#album-header-title').html( $('#album_name').val() );
    //                $('#album_email').val( zz.wizard.dashify($('#album_name').val()) );
                }, 10);
            });
            setTimeout(function(){$('#album_name').select();},100);


            //setup album cover picker
            $.ajax({
                dataType: 'json',
                url: '/albums/' + zz.album_id + '/photos.json',
                success: function(json){
                    var selectedIndex=-1;
                    var currentId = $('#album_cover_photo').val();
                    var photos = $.map(json, function(element, index){
                        var id = element.id;

                        if(id == currentId){
                            selectedIndex = index;
                        }
                        var src;
                        if(element.state === 'ready'){
                            src = element.thumb_url;
                        }
                        else{
                            src = element.source_thumb_url;
                        }

                        if (agent.isAgentUrl(src)){
                            src = agent.buildAgentUrl(src);
                        }

                        return {id:id, src:src};
                    });

                    $("#album-cover-picker").zz_thumbtray({
                        photos:photos,
                        showSelection:true,
                        selectedIndex:selectedIndex,
                        onSelectPhoto: function(index, photo){
                            var photo_id = '';
                            if(index!==-1){
                                photo_id = photo.id
                            }
                            $('#album_cover_photo').val(photo_id);
                        }
                    });
                }
            });

            callback();  
        });


    },

    bounce: function(){
        zz.wizard.update_album();
    }
};


pages.edit_album_tab = {
    init: function(callback){
        var url =  '/albums/' + zz.album_id + '/edit';

        $('article').load(url, function(){

            var temp = jQuery.parseJSON(json).photos;

            var onStartLoadingImage = function(id, src) {
                $('#' + id).attr('src', '/images/loading.gif');
            };

            var onImageLoaded = function(id, src, width, height) {
                var new_size = 120;
                //console.log('id: #'+id+', src: '+src+', width: '+width+', height: '+height);

                if (height > width) {
                    //console.log('tall');
                    //tall
                    var ratio = width / height;
                    $('#' + id).attr('src', src).css({height: new_size+'px', width: (ratio * new_size) + 'px' });


                    var guuu = $('#'+id).attr('id').split('photo-')[1];
                    $('#' + id).parent('li').attr({id: 'photo-'+guuu});
                    $('li#photo-'+ guuu +'-li figure').css({bottom: '0px', width: (new_size * ratio) + 'px', left: $('#' + id).position()['left'] + 'px' });
                    $('li#photo-'+ guuu +'-li a.delete img').css({top: '-16px', right: (150 - $('#' + id).outerWidth() - 20) / 2  +'px'} );

                } else {
                    //wide
                    //console.log('wide');

                    var ratio = height / width;
                    $('#' + id).attr('src', src).css({height: (ratio * new_size) + 'px', width: new_size+'px', marginTop: ((new_size - (ratio * new_size)) / 2) + 'px' });

                    var guuu = $('#'+id).attr('id').split('photo-')[1];
                    //$('li#photo-'+ guuu +'-li a.delete img').css({top: ($('#' + id).position()['top'] - 26), right: '-26px'});
                    $('li#photo-'+ guuu +'-li figure').css({width: new_size + 'px', bottom:  0, left: (140 - new_size) / 2 +'px'});
                    //console.log(guuu);
                }

            };

            var imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);

            for(var i in temp){
                var id = 'photo-' + temp[i].id;
                var url = null
                if (temp[i].state == 'ready') {
                    url = temp[i].thumb_url;
                } else {
                    url = temp[i].source_thumb_url;
                }

                if (agent.isAgentUrl(url)) {
                    url = agent.buildAgentUrl(url);
                }

                imageloader.add(id, url);

            }

            imageloader.start(5);
        });
    },

    bounce: function(){
        zz.open_drawer();
    }

};

pages.album_privacy_tab = {
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/privacy';
        $('#tab-content').load(url, function(){

            $('#privacy-public').click(function(){
                $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                    $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                    $('#privacy-public img.select-button').attr('src', '/images/btn-round-selected-on.png');
                });
            });
            $('#privacy-hidden').click(function(){
                $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
                $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                $('#privacy-hidden img.select-button').attr('src', '/images/btn-round-selected-on.png');
            });
            $('#privacy-password').click(function(){
                $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
                $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                $('#privacy-password img.select-button').attr('src', '/images/btn-round-selected-on.png');
            });

            callback();
        });
    },

    bounce: function(){

    }
};



pages.album_share_tab = {
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/shares/new';
        var self = this;

        $('#tab-content').load(url, function(){
           zz.wizard.resize_scroll_body();

           $('.social-share').click(function(){
                if(zz.album_type === 'personal'){
                    self.show_social_share(zz.drawers.personal_album, 'share');
                }
                else{
                    self.show_social_share(zz.drawers.group_album, 'share');
                }
            });

            $('.email-share').click(function(){
                if(zz.album_type === 'personal'){
                    self.show_email_share(zz.drawers.personal_album, 'share');
                }
                else{
                    self.show_email_share(zz.drawers.group_album, 'share');

                }
            });

            callback();
        });
    },

    bounce: function(){

    },

    // loads the status message post form in place of the type switcher on the share step
    show_social_share: function(obj, id){
        var self = this;

        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load('/albums/'+zz.album_id+'/shares/newpost', function(){
                zz.wizard.resize_scroll_body()



                $("#facebook_box").click( function(){
                    if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login( '/facebook/sessions/new', function(){
                            $("#facebook_box").attr('checked', true);
                            $("#facebook_box").attr('authorized', 'yes');
                            $("#post_share_button").attr('src','/images/btn-post-on.png');
                        });
                    }
                });

                $("#twitter_box").click( function(){
                    if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login( '/twitter/sessions/new', function(){
                            $("#twitter_box").attr('checked', true);
                            $("#twitter_box").attr('authorized', 'yes');
                            $("#post_share_button").attr('src','/images/btn-post-on.png')
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
                        $.post('/albums/'+zz.album_id+'/shares.json', serialized, function(data,status,request){
                            pages.album_share_tab.reload_share(zz.drawers[zz.album_type+'_album'], 'share', function(){
                                zz.wizard.display_flashes(  request,200 )
                            });
                        });
                    }
                });

                $('#cancel-share').click(function(){
                    self.reload_share(obj, id);
                });

                $('#post_share_message').keypress( function(){
                    setTimeout(function(){
                        var text = 'characters';
                        var count = $('#post_share_message').val().length
                        if(count === 1){
                            text = 'character';
                        }
                        $('#character-count').html(count + ' ' + text);
                    }, 10);
                });

                $('div#share-body').fadeIn('fast');
            });
        });
    },


    // loads the email post form in place of the type switcher on the share step
    show_email_share: function(obj, id ){
        var self = this;
        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load('/albums/'+zz.album_id+'/shares/newemail', function(){
                zz.wizard.resize_scroll_body();
                zz.wizard.init_email_autocompleter();

                $('#new_email_share').validate({
                    rules: {
                        'email_share[to]': { required: true, minlength: 0 },
                        'email_share[message]': { required: true, minlength: 0 }
                    },
                    messages: {
                        'email_share[to]': 'At least one recipient is required',
                        'email_share[message]': ''
                    },

                    submitHandler: function() {
                        var serialized = $('#new_email_share').serialize();
                        $.post('/albums/'+zz.album_id+'/shares.json', serialized, function(data,status,request ){
                            self.reload_share(zz.drawers[zz.album_type+'_album'], 'share', function(){
                                zz.wizard.display_flashes(  request,200 )
                            });
                        },"json");
                    }

                });

                $('#cancel-share').click(function(){
                    self.reload_share(obj, id);
                });
                $('#the-list').click(function(){
                    $('#you-complete-me').focus();
                });

                //todo: move these into auto-complete widget
                $('#you-complete-me').focus(function(){
                    $('#the-list').addClass("focus");
                });
                $('#you-complete-me').blur(function(){
                    $('#the-list').removeClass("focus");
                });
                $('div#share-body').fadeIn('fast', function(){ $('#you-complete-me').focus();});
            });
        });
    },




    // reloads the main share part in place of the type switcher on the share step
    reload_share: function(obj, id, callback){
        var self = this;
        $('#tab-content').fadeOut('fast', function(){
            self.init(function(){
                $('#tab-content').fadeIn('fast');
                if( typeof(callback) != "undefined" ){
                    callback();
                }
                
            });

//            $('#tab-content').load('/albums/'+zz.album_id+'/shares/new', function(){
//                zz.wizard.build_nav(obj, id);
//                obj.steps[id].init();
//                $('#tab-content').fadeIn('fast');
//                if( typeof(callback) != "undefined" ){
//                    callback();
//                }
//            });
        })
    }


};

pages.album_contributors_tab = {
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/contributors';
        var self = this;

        $('#tab-content').load(url, function(){

            zz.wizard.resize_scroll_body();
            

            $('#add-contributors-btn').click(function(){
                self.show_new_contributors();
            });
            callback();
        });
    },

    bounce: function(){

    },


    show_new_contributors: function(){
        var self = this;

        $('div#contributors-body').fadeOut('fast', function(){
            $('div#contributors-body').load('/albums/'+zz.album_id+'/contributors/new', function(){
                zz.wizard.resize_scroll_body()
                zz.wizard.init_email_autocompleter();

                $('#new_contributors').validate({
                    rules: {
                        'email_share[to]': { required: true},
                        'email_share[message]': { required: true, minlength: 0}
                    },
                    messages: {
                        'email_share[message]': '',
                        'email_share[message]': ''
                    },

                    submitHandler: function() {
                        $.post('/albums/'+zz.album_id+'/contributors.json', $('#new_contributors').serialize(), function(data,status,request){
                            $('#tab-content').fadeOut('fast', function(){
                                $('#tab-content').load('/albums/'+zz.album_id+'/contributors', function(){
                                    zz.wizard.build_nav(zz.drawers.group_album, 'contributors');
                                    zz.drawers.group_album.steps['contributors'].init();
                                    zz.wizard.display_flashes(  request,200 );
                                    $('#tab-content').fadeIn('fast');
                                });
                            },"json");
                        });
                    }
                });


                $('#the-list').click(function(){
                    $('#you-complete-me').focus();
                });

                $('#cancel-new-contributors').click(function(){
                    $('#tab-content').fadeOut('fast', function(){
                        $('#tab-content').load('/albums/'+zz.album_id+'/contributors', function(){
                            zz.wizard.build_nav(zz.drawers.group_album, 'contributors'); //todo: should just reload the contributors like we do for the share screen. no need to use the wizard
                            zz.drawers.group_album.steps['contributors'].init();
                            $('#tab-content').fadeIn('fast');
                        });
                    })
                });


                //todo: move these into auto-complete widget
                $('#you-complete-me').focus(function(){
                    $('#the-list').addClass("focus");
                });
                $('#you-complete-me').blur(function(){
                    $('#the-list').removeClass("focus");
                });
                $('div#contributors-body').fadeIn('fast', function(){$('#you-complete-me').focus();});
            });
        })
    },


    insert_contributor_bubble: function(label,value){
        zz.wizard.email_id++;
        $('#m-clone-added').clone()
                .attr({id: 'm-'+zz.wizard.email_id})
                .insertAfter('#the-recipients li.rounded:last');
        $('#m-'+zz.wizard.email_id+' span').empty().html(label);
        $('#m-'+zz.wizard.email_id).fadeIn('fast');
        $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
        $('#m-'+zz.wizard.email_id+' input').attr({name: 'delete-url', checked: 'checked'}).val(value);
        $('#m-'+zz.wizard.email_id+' img').click(function(){
            $.post($(this).siblings('input').val(), {"_method": "delete"}, function(data){ });
            $(this).parent('li').fadeOut('fast', function(){
                $(this).remove();
            });
        });
    }

};


pages.account_settings_profile_tab = {
    init: function(){
        var self = this;
        zz.drawers.settings.redirect =  window.location;
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -140) + 'px'});
        $(this.validator.element).validate(this.validator);
        $('#user_username').keypress( function(){
            setTimeout(function(){
                $('#username_path').html( $('#user_username').val() );
            }, 10);
        });

          // unbind next tab button
//        var handler = $('#wizard-account').data('events')['click'][0];
//        $('#wizard-account').unbind('click');
//        $('#wizard-account').click( function(){
//            self.update_profile(function(){
//                zz.wizard.open_settings_drawer('account')
//            });
//        });

        //todo: i think this prevents the validator from running
        $('#ok_profile_button').click(function(){
            self.update_profile( function(){
                zz.wizard.close_settings_drawer();
            });
        });
        $('#cancel_profile_button').click(zz.wizard.close_settings_drawer)
    },

    bounce: function(){
        this.update_profile(function(){
//            zz.wizard.open_settings_drawer('account')
        });
    },

    update_profile: function(success) {
        if( $(this.validator.element).validate() ){
            var serialized = $(this.validator.element).serialize();
            $.ajax({
                type: 'POST',
                url: '/users/'+zz.current_user_id+'.json',
                data: serialized,
                success: function(){
                    $('#user_old_password').val('');
                    $('#user_password').val('');
                    if (typeof(success) !== 'undefined') success();
                },
                error: function(request){
                    $('#user_old_password').val('');
                    $('#user_password').val('');
                }
            });
        }
    },

    //todo: because we attach a click handler to the '#ok_profile_button', the validator is never run
    validator: {
        element: '#profile_form form',
        errorContainer: '#flashes-notice',
        rules: {
            'user[first_name]':     { required: true,
                minlength: 5 },
            'user[last_name]':     { required: true,
                minlength: 5 },
            'user[username]': { required: true,
                minlength: 5,
                regex: "^[a-z0-9]+$",
                remote: '/users/validate_username' },
            'user[email]':    { required: true,
                email: true,
                remote: '/users/validate_email' },
            'user[old_password]':{ minlength: 5,
                required:{ depends: function(element) {
                    logger.debug( "length is "+ $("#user_password").val().length);
                    return $("#user_password").val().length > 0;}
                }},
            'user[password]': { minlength: 5 }
        },
        messages: {
            'user[first_name]':{ required: 'Please enter your first name.',
                minlength: 'Please enter at least 5 letters'},
            'user[last_name]': { required: 'Please enter your last name.',
                minlength: 'Please enter at least 5 letters'},
            'user[username]': {  required: 'A username is required.',
                regex: 'Only lowercase alphanumeric characters allowed',
                remote: 'username not available'},
            'user[email]':   {   required: 'We promise we won&rsquo;t spam you.',
                email: 'Is that a valid email?',
                remote: 'Email already used'},
            'user[password]': 'Six characters or more please.'
        },

        //todo: i don't think this ever gets called
        submitHandler: function(form){
            pages.account_settings_profile_tab.update_profile(function(){
                zz.wizard.close_settings_drawer();
            })
        }
    }




};

pages.account_settings_linked_accounts = {
    init: function(){
        var self = this;
        zz.drawers.settings.redirect =  window.location;
        $('.delete-id-button').click(pages.account_settings_linked_accounts.delete_identity);

        $('.authorize-id-button').click(pages.account_settings_linked_accounts.authorize_identity);

        $('.id-status').each( function(){

            logger.debug("Binding id:"+this.id+" service:"+$(this).attr('service'));
        });
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -110) + 'px'});

        $('#ok_id_button').click(function(){
            zz.wizard.close_settings_drawer();
        });
    },

    bounce: function(){

    },

    delete_identity: function(){
        var self = this;
        logger.debug("Deleting ID with URL =  "+ $(this).attr('value'));
        $("#"+$(this).attr('service')+"-status").bind( 'identity_deleted' , pages.account_settings_linked_accounts.identity_deleted_handler);

        $.post($(this).attr('value'), {"_method": "delete"}, function(data){$('.id-status').trigger( 'identity_deleted' );});
//        $.post($(this).attr('value'), {"_method": "delete"}, function(data){$('.id-status').trigger( 'identity_deleted' );});
    },

    authorize_identity: function(){
        var self = this;
        logger.debug("Authorizing ID with URL =  "+ $(this).attr('value'));
        $("#"+$(this).attr('service')+"-status").bind( 'identity_linked' , pages.account_settings_linked_accounts.identity_linked_handler);
        oauthmanager.login( $(this).attr('value') , function(){ $('.id-status').trigger( 'identity_linked' );} );
    },

    identity_linked_handler: function(){
        logger.debug( "identity_linked event for service "+$(this).attr('service'));
        $(this).unbind( 'identity_linked' ); //remove the event handler
        $(this).fadeIn('slow'); //display the linked status
        $("#"+$(this).attr('service')+"-authorize").fadeOut( 'fast', function(){  //remove the link button
            $("#"+$(this).attr('service')+"-delete").fadeIn( 'fast', function(){
                if( $('#flashes-notice')){
                    var msg = "Your can now use "+ $(this).attr('service')+" features throughout ZangZing";
                    $('#flashes-notice').html(msg).fadeIn('fast', function(){
                        setTimeout(function(){$('#flashes-notice').fadeOut('fast', function(){$('#flashes-notice').html('    ');})}, 3000);
                    });
                }
            });//display the unlink button
        });
    },

    identity_deleted_handler: function(){
        logger.debug( "identity_deleted event for service "+$(this).attr('service'));
        $(this).unbind( 'identity_deleted' ); //remove the event handler
        $(this).fadeOut('slow'); //hide the linked status
        $("#"+$(this).attr('service')+"-delete").fadeOut( 'fast', function(){  //remove the unlink button
            $("#"+$(this).attr('service')+"-authorize").fadeIn( 'fast');//display the link button
        });
    }


};