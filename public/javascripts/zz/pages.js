/*!
 * pages.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var pages = {};

pages.album_add_photos_tab = {
    init: function(callback, drawer_style){
        var url = '/albums/' + zz.album_id + '/add_photos';
        $('#tab-content').load(url, function(){
            if( drawer_style == 'edit'){
                $('#added-pictures-tray-container').css('bottom','5px')
            } else {
                $('#added-pictures-tray-container').css('bottom','24px')
            }
            filechooser.init();
            callback();
        });
    },

    bounce: function(success, failure){
        success();
    }
};

pages.album_name_tab = {
    original_album_name: '',
    init: function(callback){
        var url = '/albums/' + zz.album_id + '/name_album';

        $('#tab-content').load(url, function(){
            //save album name and set header album name
            pages.album_name_tab.original_album_name = $('#album_name').val();
            $('h2#album-header-title').html(pages.album_name_tab.original_album_name);

            //change header album name as you type new album name
            $('#album_name').keypress( function(){
                setTimeout(function(){
                    $('#album-header-title').html( $('#album_name').val() );
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
                            url: '/albums/' + zz.album_id + '/preview_album_email?' + $.param({album_name: $('#album_name').val()}),
                            success: function(new_mail){
                                $('#album_email').val(new_mail);
                            },
                            error: function(){
                                $('#album_name').val(pages.album_name_tab.original_album_name);
                                $('h2#album-header-title').html(pages.album_name_tab.original_album_name);
                            }
                        });
                    }
                }, 1000);
            });

            //setup album cover picker
            $.ajax({
                dataType: 'json',
                url: '/albums/' + zz.album_id + '/photos_json?' + (new Date()).getTime(),  //force browser cache miss
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

    bounce: function(success, failure){
            $.ajax({ type: 'POST',
                     url:'/albums/'+zz.album_id,
                     data:$(".edit_album").serialize(),
                     success: success ,
                     error:  function(){
                                 //restore name and header to valid value
                                 $('#album_name').val(pages.album_name_tab.original_album_name);
                                 $('h2#album-header-title').html(pages.album_name_tab.original_album_name);
                                 $('#album_name').keypress();
                     }
            });
    }
};

pages.edit_album_tab = {
    init: function(callback){
        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json){

                for(var i =0;i<json.length;i++){
                    var photo = json[i];
                    photo.previewSrc = agent.checkAddCredentialsToUrl(photo.stamp_url);
                    photo.src =       agent.checkAddCredentialsToUrl(photo.thumb_url);
                }


                var gridElement = $('<div class="photogrid-container"></div>');

                $('#article').html(gridElement);
                $('#article').css('overflow','hidden');
    

                var grid = gridElement.zz_photogrid({
                    photos:json,
                    allowDelete: true,
                    onDelete: function(index, photo){
                        $.ajax({
                            type: "DELETE",
                            dataType: "json",
                            url: "/photos/" + photo.id + ".json",
                            error: function(error){
                                logger.debug(error);
//                                $.jGrowl("" + error);
                            }
                            
                        });
                        return true;                          
                    },
                    allowEditCaption: true,
                    onChangeCaption: function(index, photo, caption){
                        $.ajax({
                            type: "PUT",
                            dataType: "json",
                            url: "/photos/" + photo.id + ".json",
                            data: {'photo[caption]':caption},
                            error: function(error){
                                logger.debug(error);
//                                $.jGrowl("" + error);
                            }

                        });
                        return true;

                    },
                    allowReorder: true,
//                    cellHeight: 150,
//                    cellWidth: 150,
                    showThumbscroller: true
                }).data().zz_photogrid;

                $('#article').show();
            }
        });
    },

    bounce: function(success, failure){
        zz.open_drawer(); //todo: is this needed?
        success();
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

    bounce: function(success, failure){
        success();
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

    bounce: function(success, failure){
        success();
    },

    // loads the status message post form in place of the type switcher on the share step
    show_social_share: function(obj, id){
        var self = this;

        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load('/albums/'+zz.album_id+'/shares/newpost', function(){
                zz.wizard.resize_scroll_body();



                $("#facebook_box").click( function(){
                    if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login( '/facebook/sessions/new', function(){
                            $("#facebook_box").attr('checked', true);
                            $("#facebook_box").attr('authorized', 'yes');
//                            $("#post_share_button").attr('src','/images/btn-post-on.png');
                        });
                    }
                });

                $("#twitter_box").click( function(){
                    if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
                        $(this).attr('checked', false);
                        oauthmanager.login( '/twitter/sessions/new', function(){
                            $("#twitter_box").attr('checked', true);
                            $("#twitter_box").attr('authorized', 'yes');
//                            $("#post_share_button").attr('src','/images/btn-post-on.png')
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

                $('#mail-submit').click(function(){
                   $('form#new_email_share').submit(); 
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
        });
    }


};

pages.album_contributors_tab = {
    contributor_count:0,
    
    init: function(){
        pages.album_contributors_tab.show_contributor_list();
    },

    bounce: function(success, failure){
        success();
    },

    show_contributor_list: function( request ){
        $('#tab-content').load( '/albums/' + zz.album_id + '/contributors' , function(){
                if( pages.album_contributors_tab.contributor_count <= 0){
                    pages.album_contributors_tab.show_new_contributors();
                } else {
                    zz.wizard.resize_scroll_body();
                    $('#add-contributors-btn').click(function(){
                         $('#tab-content').fadeOut('fast', pages.album_contributors_tab.show_new_contributors );
                     });
                    $('#tab-content').fadeIn('fast', function( ){
                        if( typeof( request )!= 'undefined'){
                            zz.wizard.display_flashes(  request,200 );
                        }
                    });
                }
        });
    },

    show_new_contributors: function(){
        $('#tab-content').load('/albums/'+zz.album_id+'/contributors/new', function(){
            zz.wizard.resize_scroll_body()
            zz.wizard.init_email_autocompleter();

            $('#new_contributors').validate({
                rules: {
                    'email_share[to]': { email:true, required: true, minlength: 1},
                    'email_share[message]': { required: true}
                },
                messages: {
                    'email_share[to]': 'Empty',
                    'email_share[message]': ''
                },

                //todo: submit errors are not being shown properly
                submitHandler: function() {
                    $.ajax({ type:     'POST',
                             url:      '/albums/'+zz.album_id+'/contributors.json',
                             data:     $('#new_contributors').serialize(),
                             success:  function(data,status,request){
                                              $('#tab-content').fadeOut('fast','swing', function(){
                                                  pages.album_contributors_tab.show_contributor_list( request );
                                              });
                                       },
                             error:    function(){}
                    });
                } //submit handler
            }); //new_contributors,validate

            $('#the-list').click(function(){
                $('#you-complete-me').focus();
            });

            if( pages.album_contributors_tab.contributor_count > 0){
                $('#cancel-new-contributors').click(function(){
                    $('#tab-content').fadeOut('fast', pages.album_contributors_tab.show_contributor_list );
                });
            } else {
                $('#cancel-new-contributors').hide();
            }

            $('#submit-new-contributors').click(function(){
                $('form#new_contributors').submit();
            });

            //todo: move these into auto-complete widget
            $('#you-complete-me').focus(function(){
                $('#the-list').addClass("focus");
            });
            $('#you-complete-me').blur(function(){
                $('#the-list').removeClass("focus");
            });
            $('#tab-content').fadeIn('fast', function(){$('#you-complete-me').focus();});
        });
    },


    insert_contributor_bubble: function(label,value){
        var bubble = $('#m-clone-added').clone().insertAfter('#the-recipients li.rounded:last');
        bubble.find('span').empty().html(label);
        bubble.fadeIn('fast');
        bubble.find('input').attr({name: 'delete-url', checked: 'checked'}).val(value);
        bubble.find('img').click(function(){
            $.post($(this).siblings('input').val(), {"_method": "delete"}, function(data){ });
            $(this).parent('li').fadeOut('fast', function(){
                $(this).parent('li').remove();
            });
        });
    }

};

pages.account_settings_profile_tab = {

    profile_photo_picker: 'undefined',

    init: function(callback){
        var url = '/users/' + zz.current_user_id +'/edit';
        var self = pages.account_settings_profile_tab;

        $('#tab-content').load(url, function(){

            zz.drawers.settings.redirect =  window.location;
            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -140) + 'px'});
            $(self.validator.element).validate(self.validator);
            $('#user_username').keypress( function(){
                setTimeout(function(){
                    $('#username-path').html( $('#user_username').val() );
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

            self.init_profile_photo_picker();
            self.refresh_profile_photo_picker();
            self.init_add_photos_dialog();

            $('#profile-photo-button').click( pages.account_settings_profile_tab.show_add_photos_dialog );
            $('#ok-profile-button').click(function(){
                    self.update_profile( function(){
                        zz.wizard.close_settings_drawer();
                });
            });
            $('#cancel-profile-button').click(zz.wizard.close_settings_drawer)

            callback();
        });
    },

    bounce: function(success, failure){
        this.update_profile( success );
    },

    init_profile_photo_picker: function(){
        var self = this;

        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json){
                var selectedIndex=-1;
                var currentId = $('#profile-photo-id').val();
                var photos = $.map(json, function(element, index){
                    var id = element.id;

                    if(id == currentId){
                        selectedIndex = index;
                    }
                    var src = element.thumb_url;

                    
                    src = agent.checkAddCredentialsToUrl(src);

                    return {id:id, src:src};
                });


                self.profile_photo_picker = $("#profile-photo-picker").zz_thumbtray({
                    photos:photos,
                    showSelection:true,
                    selectedIndex:selectedIndex,
                    onSelectPhoto: function(index, photo){
                        var photo_id = '';
                        if(index!==-1){
                            photo_id = photo.id
                        }
                        $('#profile-photo-id').val(photo_id);
                        $('div#profile-photo-picker div.thumbtray-wrapper div.thumbtray-selection').css('top', 0);
                    }
                }).data().zz_thumbtray;    
            }
        });

    },

    refresh_profile_photo_picker: function(){
        //refresh album cover picker
        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos_json?' + zz.album_lastmod,
            success: function(json){
                var selectedIndex=-1;
                var currentId = $('#profile-photo-id').val();
                var photos = $.map(json, function(element, index){
                    var id = element.id;

                    if(id == currentId){
                        selectedIndex = index;
                    }
                    var src = element.thumb_url;

                    
                    src = agent.checkAddCredentialsToUrl(src);

                    return {id:id, src:src};
                });
                pages.account_settings_profile_tab.profile_photo_picker.addPhotos( photos );
            }
        });
    },  

    init_add_photos_dialog: function(){
        //for the add_photos call, the id is irrelevant, it just delivers the filechooser DOM
        $('<div id="add-photos-dialog"></div>').load( '/albums/lkj789074XsSXkd/add_photos' )
                                               .dialog({ title: 'Load Profile Pictures',
                                                         width: 920,
                                                         minHeight: 350,
                                                         position: [130,40],
                                                         modal: true,
                                                         autoOpen: false,
                                                         open:   function(event, ui){ filechooser.init(); },
                                                         close:  function(event, ui){
                                                             $.get( '/albums/' +zz.album_id + '/close_batch', function(){
                                                                pages.account_settings_profile_tab.refresh_profile_photo_picker()
                                                             });
                                                         }
                 });
    },

    show_add_photos_dialog: function(event){
        $('#add-photos-dialog').dialog('open');
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
        element: '#profile-form form',
        errorContainer: '#flashes-notice',
        rules: {
            'user[first_name]':     { required: true,
                minlength: 5 },
            'user[last_name]':     { required: true,
                minlength: 5 },
            'user[username]': { required: true,
                minlength: 1,
                maxlength: 25,
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
                remote: 'username already taken'},
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

pages.account_setings_account_tab = {
    init: function(callback){
        $('#tab-content').empty();
        callback();
    },

    bounce: function(success, failure){
        success();
    }

};

pages.account_setings_notifications_tab = {
    init: function(callback){
        $('#tab-content').empty();
        callback();
    },

    bounce: function(success, failure){
        success();
    }

};

pages.linked_accounts = {
    init: function(callback){
        var url = '/users/' + zz.current_user_id + '/identities';
        $('#tab-content').load( url, function(){
            zz.drawers.settings.redirect =  window.location;
            $('.delete-id-button').click(pages.linked_accounts.delete_identity);
            $('.authorize-id-button').click(pages.linked_accounts.authorize_identity);
            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -110) + 'px'});
            $('#ok_id_button').click(  zz.wizard.close_settings_drawer );
            callback();
        });
    },

    bounce: function(success, failure){
         success();
    },

    delete_identity: function(){
        logger.debug("Deleting ID with URL =  "+ $(this).attr('value'));
        var service = $(this).attr('service');
        $.post($(this).attr('value'), {"_method": "delete"},  function(){
            logger.debug( "identity_deleted event for service "+service);
            $('#'+service+'-status').fadeOut('slow'); //hide the linked status
            $('#'+service+'-delete').fadeOut( 'fast', function(){  //remove the unlink button
                $('#'+service+'-authorize').fadeIn('fast');//display the link button
            });
        });  
    },

    authorize_identity: function(){
        logger.debug("Authorizing ID with URL =  "+ $(this).attr('value'));
        var service = $(this).attr('service');
        oauthmanager.login( $(this).attr('value') , function(){
            logger.debug( "identity_linked event for service "+service);
            $('#'+service+'-status').fadeIn('slow'); //display the linked status
            $('#'+service+'-authorize').fadeOut( 'fast', function(){  //remove the link button
                $('#'+service+'-delete').fadeIn( 'fast', function(){
                    if( $('#flashes-notice')){
                        var msg = "Your can now use "+ service+" features throughout ZangZing";
                        $('#flashes-notice').html(msg).fadeIn('fast', function(){
                            setTimeout(function(){
                                $('#flashes-notice').fadeOut('fast', function(){
                                    $('#flashes-notice').html('    ');
                                });
                            }, 3000);
                        });
                    }
                });//display the unlink button
            });
        });
    }
};

pages.no_agent = {
    url: '/static/connect_messages/no_agent.html',
    init_from_filechooser: function( callback ){             
        $('#filechooser-title').html($('#downloadzz-title').html());
        $('#choose-header h4').html($('#downloadzz-tagline').html());
        $('#downloadzz-title').html('');
        $('#downloadzz-tagline').html( '');
        $('#downloadzz-btn').click(function(){
            alert("Agent should be downloading now (TODO: Set URL for download in pages.js)");
        });
        pages.no_agent.poll_agent_from_filechooser( ); //Download begun , start polling for agent
        callback();
    },


    poll_agent_from_filechooser: function( ){
      agent.isAvailable( function( agentAvailable ){
          if( agentAvailable ){
                 pages.no_agent.agent_ready_from_filechooser();
          }else{
                setTimeout( 'pages.no_agent.poll_agent_from_filechooser()', 1000);
          }
      });  
    },

    agent_ready_from_filechooser: function( ){
        $('#downloadzz-btn').attr('disabled', 'disabled');
        $('#downloadzz-developed').fadeIn(4000, function(){
                $('#downloadzz-developed').parent().siblings('.downloadzz-text').fadeOut( 'fast')
                $('#downloadzz-developed').parent().siblings('.downloadzz-headline').fadeOut( 'fast', function(){
                        $(this).html('ZangZing is Ready!');
                        $(this).fadeIn( 'fast');
                        setTimeout( 'filechooser.on_login()', 1000 );
                });            
        });
    },


    dialog: function( ){
         $('<div></div>', { id: 'no-agent-dialog'}).load(pages.no_agent.url, function(){
                    $( this ).dialog({
                           title: 'Download ZangZing',
                           width: 910,
                           minHeight: 550,
                           position: [170,65],
                           modal: true,
                           close:  function(){
                               $('#no-agent-dialog').remove();
                               sharecontacts.call_local_import();
                           }
                    });
                    $('#downloadzz-btn').click(function(){
                        alert("Agent should be downloading now (TODO: Set URL for download in pages.js)");
                    });
                    pages.no_agent.poll_agent_from_dialog( ); //Download begun , start polling for agent
        });
    },

    poll_agent_from_dialog: function( ){
          agent.isAvailable( function( agentAvailable ){
              if( agentAvailable ){
                     pages.no_agent.agent_ready_from_dialog();
              }else{
                    setTimeout( 'pages.no_agent.poll_agent_from_dialog()', 1000);
              }
          });
    },

    agent_ready_from_dialog: function( ){
        $('#downloadzz-btn').attr('disabled', 'disabled');
        $('#downloadzz-developed').fadeIn(4000, function(){
                $('#downloadzz-developed').parent().siblings('.downloadzz-text').fadeOut( 'fast')
                $('#downloadzz-developed').parent().siblings('.downloadzz-headline').fadeOut( 'slow', function(){
                        $(this).html('ZangZing is Ready!');
                        $(this).fadeIn( 'fast');
                        setTimeout( function(){  $( '#no-agent-dialog' ).dialog('close'); }, 1000 );
                });
        });
    }
};