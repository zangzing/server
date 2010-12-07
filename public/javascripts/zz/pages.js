var pages = {}

pages.album_add_photos_tab = {
    init: function(){
        filechooser.init();
        setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
    },

    bounce: function(){
        $('#added-pictures-tray').fadeOut('fast');
    }
}



pages.album_name_tab = {
    init: function(){
        //Set The Album Name at the top of the screen
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

    },

    bounce: function(){
        zz.wizard.update_album();
    }
}


pages.edit_album_tab = {
    init: function(){
        temp = jQuery.parseJSON(json).photos;

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
    
    },

    bounce: function(){
        zz.open_drawer();
    }

}

pages.album_privacy_tab = {
    init: function(){
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
    },

    bounce: function(){

    }
}

pages.album_privacy_tab = {
    init: function(){
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
    },

    bounce: function(){

    }
}

pages.album_share_tab = {
    init: function(){
        var self = this;
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
                zz.wizard.email_autocomplete();

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
        $('#tab-content').fadeOut('fast', function(){
            $('#tab-content').load('/albums/'+zz.album_id+'/shares/new', function(){
                zz.wizard.build_nav(obj, id);
                obj.steps[id].init();
                $('#tab-content').fadeIn('fast');
                 if( typeof(callback) != "undefined" ){
                     callback();
                 }
            });
        })
    }


}

pages.album_contributors_tab = {
    init: function(){
        var self = this;
        $('#add-contributors-btn').click(function(){
            self.show_new_contributors();
        });
    },

    bounce: function(){

    },


    show_new_contributors: function(){
        var self = this;

        $('div#contributors-body').fadeOut('fast', function(){
            $('div#contributors-body').load('/albums/'+zz.album_id+'/contributors/new', function(){
                zz.wizard.resize_scroll_body()
                zz.wizard.email_autocomplete();

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
    },



}


pages.account_settings_profile_tab = {
    init: function(){
       zz.drawers.settings.redirect =  window.location;
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -140) + 'px'});
      $(zz.validate.profile_form.element).validate(zz.validate.profile_form);
      $('#user_username').keypress( function(){
            setTimeout(function(){
                $('#username_path').html( $('#user_username').val() );
            }, 10);
      });
      // unbind next tab button
      var handler = $('#wizard-account').data('events')['click'][0];
      $('#wizard-account').unbind('click');
      $('#wizard-account').click( function(){
          zz.wizard.update_profile(function(){zz.wizard.open_settings_drawer('account')})
      });

      $('#ok_profile_button').click(function(){
          zz.wizard.update_profile( zz.wizard.close_settings_drawer);
      });
      $('#cancel_profile_button').click(zz.wizard.close_settings_drawer)
    },

    bounce: function(){

    }


}

pages.account_settings_linked_accounts = {
    init: function(){
      zz.drawers.settings.redirect =  window.location;
      $('.delete-id-button').click(zz.wizard.delete_identity);
      $('.authorize-id-button').click(zz.wizard.authorize_identity);
      $('.id-status').each( function(){

             logger.debug("Binding id:"+this.id+" service:"+$(this).attr('service'));
      });
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height -110) + 'px'});
      $('#ok_id_button').click(zz.wizard.close_settings_drawer)
    },

    bounce: function(){
        
    }


}