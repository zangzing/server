zz.wizard = {

    /* Wizard Functions
     ------------------------------------------------------------------------- */

    make_drawer: function(obj, step){
        /* obj contains: obj.next_element, obj.done_redirect, obj.steps.step.id,
         obj.steps.step.element, obj.steps.step.info,
         obj.steps.step.type, obj.steps.step.init,
         obj.steps.step.bounce */

        var temp; //todo: rename to somethign meaningful

        if (zz.drawer_open == 0) {
            zz.open_drawer(obj.time, obj.percent);
        }

        if (!step) {
            //console.log('set up the url');
            if (obj.steps[obj.first].url_type == 'album') {
                //console.log('album');
                temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.album_id + obj.steps[obj.first].url.split('$$')[1];
                //console.log(temp);
            } else if (obj.steps[obj.first].url_type == 'user') {
                //console.log('user');
                temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.current_user_id + obj.steps[obj.first].url.split('$$')[1];
                //console.log(temp);
            }


            zz.wizard.build_nav(obj, obj.first, true);
            $('#tab-content').fadeOut('fast', function(){
                $('#tab-content').load(temp, function(){
                    zz.wizard.resize_scroll_body()
                    obj.steps[obj.first].init();
                    $('#tab-content').fadeIn('fast');
                });
            });
        } else {

            if (obj.steps[step].url_type == 'album') {
                //console.log('album');
                temp = 'http://' + zz.base + obj.steps[step].url.split('$$')[0] + zz.album_id + obj.steps[step].url.split('$$')[1];
                //console.log(temp);
            } else if (obj.steps[step].url_type == 'user') {
                //console.log('user');
                temp = 'http://' + zz.base + obj.steps[step].url.split('$$')[0] + zz.current_user_id + obj.steps[step].url.split('$$')[1];
                //console.log(temp);
            }

            zz.wizard.build_nav(obj, step);
            $('#tab-content').load(temp, function(){
                zz.wizard.resize_scroll_body()
                obj.steps[step].init();
            });


        }

        $('body').addClass('drawer');

    },

    change_step: function(id, url, obj){

        logger.debug(obj.steps[id].type + "    " + zz.drawer_open);

        if (obj.steps[id].type == 'partial' && zz.drawer_open == 1) {

            //console.log('oh snap, were gonna have to ditch the drawer for this');
            $('#tab-content').fadeOut('fast');
            zz.close_drawer(obj.time);

            zz.wizard.build_nav(obj, id);
            $('article').load(url, function(data){
                zz.wizard.resize_scroll_body();
                obj.steps[id].init();
            });

        } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 2) {
            zz.wizard.build_nav(obj, id);
            $('article').load(url, function(data){
                zz.wizard.resize_scroll_body();
                obj.steps[id].init();
            });
        } else if (obj.steps[id].type == 'full' && zz.drawer_open != 1) {
            zz.wizard.build_nav(obj, id);
            $('#tab-content').load(url, function(data){
                zz.wizard.resize_scroll_body();
                obj.steps[id].init();
                zz.open_drawer(obj.time);
            });
        } else if (obj.steps[id].type == 'full' && zz.drawer_open == 1) {
            zz.wizard.build_nav(obj, id);
            $('#tab-content').fadeOut('fast', function(){
                $('#tab-content').load(url, function(data){
                    zz.wizard.resize_scroll_body();
                    obj.steps[id].init();
                    $('#tab-content').fadeIn('fast');
                });
            });
        } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 0) {
            zz.open_drawer(80, obj.percent);
            zz.close_drawer(obj.time);
            zz.wizard.build_nav(obj, id);
            $('article').load(url, function(data){
                zz.wizard.resize_scroll_body();
                obj.steps[id].init();
            });
        } else {
            console.warn('This should never happen. Context: zz.wizard.change_step, Type: '+obj.steps[id].type+', Drawer State: '+zz.drawer_open);
        }


    },

    build_nav: function(obj, id, fade_in){


        var temp_id = 1;
        var temp = '';
        $.each(obj.steps, function(i, item) {
            if (i == id && obj.numbers == 1) {
                value = temp_id;
                temp += '<li id="wizard-'+ i + '" class="on">';
                temp += '<img src="/images/wiz-num-'+temp_id+'-on.png" class="num"> '+ item.title +'</li>';
            } else if (i == id) {
                value = temp_id;
                temp += '<li id="wizard-'+ i + '" class="on">'+ item.title +'</li>';
            } else if (obj.numbers == 1) {
                temp += '<li id="wizard-'+ i + '">';
                temp += '<img src="/images/wiz-num-'+temp_id+'.png" class="num"> '+ item.title +'</li>';
            } else {
                temp += '<li id="wizard-'+ i + '">'+ item.title +'</li>';
            }
            temp_id++;

        });

        // the last time we incrimented it didn't load a step - we use this to know the length of the list below
        temp_id--;

        if (obj.next_element == 'none') {
            // no next button neded
        } else if (obj.steps[id].next == 0 || obj.style == 'edit') {
            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-wizard-done.png" /></li>';
        } else {
            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-steps-next.png" /></li>';
        }

        if(fade_in){
            $('#drawer-tabs').hide();
        }
        if (obj.style == 'edit') {
            //      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('edit-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');
            $('#drawer-tabs').html($('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('edit-'+value+'-'+temp_id).html(temp));
        } else {
            $('#drawer-tabs').html($('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('step-'+value+'-'+temp_id).html(temp));
            //      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('step-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');
        }
        if(fade_in){
            $('#drawer-tabs').fadeIn('fast');
        }


        zz.wizard.rebind(obj, id, temp_id); //now that we've built the nav let's bind all the nav events

    },

    resize_scroll_body: function(){
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 165) + 'px'});
    },

    rebind: function(obj, id, num_steps){

        zz.wizard.resize_scroll_body();


        $.each(obj.steps, function(i, item) {
            $('li#wizard-'+ i).click(function(e){
                e.preventDefault();
                obj.steps[id].bounce();
                temp_id = $(this).attr('id').split('wizard-')[1];

                //console.log('set up the url');
                if (obj.steps[id].url_type == 'album') {
                    //console.log('album');
                    temp_url = 'http://' + zz.base + obj.steps[i].url.split('$$')[0] + zz.album_id + obj.steps[i].url.split('$$')[1];
                    //console.log(temp);
                } else if (obj.steps[id].url_type == 'user') {
                    //console.log('user');
                    temp_url = 'http://' + zz.base + obj.steps[i].url.split('$$')[0] + zz.current_user_id + obj.steps[i].url.split('$$')[1];
                    //console.log(temp);
                }

                zz.wizard.change_step(temp_id, temp_url, obj);
            });



        });

        if (obj.next_element == 'none') {
            // no next button neded
        } else if (obj.last == id || obj.style == 'edit') {
            //console.log('last');
            $(obj.next_element).click(function(e){
                 obj.steps[id].bounce();
                $('#drawer .body').fadeOut('fast');
                zz.slam_drawer(400);
                if (obj.redirect_type == 'album') {
                    temp_url = 'http://' + zz.base + obj.redirect.split('$$')[0] + zz.album_id + obj.redirect.split('$$')[1];
                } else if (obj.redirect_type == 'user') {
                    temp_url = 'http://' + zz.base + obj.redirect.split('$$')[0] + zz.current_user_id + obj.redirect.split('$$')[1];
                }
                setTimeout('window.location = "'+temp_url+'"', 500);
            });
        } else {
            //console.log('NOT last');
            $(obj.next_element).click(function(e){
                e.preventDefault();
                obj.steps[id].bounce();
                temp_id = obj.steps[id].next;

                if (obj.steps[obj.steps[id].next].url_type == 'album') {
                    temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.album_id + obj.steps[obj.steps[id].next].url.split('$$')[1];
                } else if (obj.steps[obj.steps[id].next].url_type == 'user') {
                    temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.current_user_id + obj.steps[obj.steps[id].next].url.split('$$')[1];
                }

                zz.wizard.change_step(temp_id, temp_url, obj);

            });
        }
    },





    /* Wizard Object Functions - used to make special things happen
     ------------------------------------------------------------------------- */

    delete_btn: 1,
    email_id: 0,
    autocompleter: 0,
    contributor_count: 0,

    create_personal_album: function(){
        $.post('/users/'+zz.current_user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
            zz.album_id = data;
            zz.wizard.make_drawer(zz.drawers.personal_album);
        });
    },

    create_group_album: function(){
        $.post('/users/'+zz.current_user_id+'/albums', { album_type: "GroupAlbum" }, function(data){
            zz.album_id = data;
            zz.wizard.make_drawer(zz.drawers.group_album);
        });
    },

    open_edit_album_wizard: function( step ){
        switch(  zz.album_type ){
            case 'personal':
                if( typeof(zz.drawers.edit_personal_album) == "undefined" ){
                    zz.drawers.edit_personal_album = zz.drawers.personal_album;
                    zz.drawers.edit_personal_album.style='edit'
                }
                zz.wizard.make_drawer(zz.drawers.edit_personal_album, step);
                break;
            case 'group':
                if( typeof(zz.drawers.edit_group_album) == "undefined" ){
                    zz.drawers.edit_group_album = zz.drawers.group_album;
                    zz.drawers.edit_group_album.style='edit'
                }
                zz.wizard.make_drawer(zz.drawers.edit_group_album, step );
                break;
        }
    },

    // load_images is used to build the grid view of an album using json results
    load_images: function(){
        //console.log(json);
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

    // loads the status message post form in place of the type switcher on the share step
    social_share: function(obj, id){
        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load('/albums/'+zz.album_id+'/shares/newpost', function(){
                zz.wizard.resize_scroll_body()
                oauthmanager.init_social();
                $(zz.validate.new_post_share.element).validate(zz.validate.new_post_share);
                $('#cancel-share').click(function(){
                    zz.wizard.reload_share(obj, id);
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
    email_share: function(obj, id ){
        $('div#share-body').fadeOut('fast', function(){
            $('div#share-body').load('/albums/'+zz.album_id+'/shares/newemail', function(){
                zz.wizard.resize_scroll_body();
                zz.wizard.email_autocomplete();
                $(zz.validate.new_email_share.element).validate(zz.validate.new_email_share);

                $('#cancel-share').click(function(){
                    zz.wizard.reload_share(obj, id);
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
    },



    // adds a recipient to the autocomplete area on keypress
    add_recipient: function(comma){
        if (comma == 1) {
            value = $('#you-complete-me').val();
            value = value.split(',')[0];
            $('#you-complete-me').val('');
        } else {
            value = $('#you-complete-me').val();
            $('#you-complete-me').val('');

        }

        if (value.length < 6) {

        } else {


            zz.wizard.email_id++;
            //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
            $('#m-clone-added').clone()
                    .attr({id: 'm-'+zz.wizard.email_id})
                    .insertAfter('#the-recipients li.rounded:last');

            $('#m-'+zz.wizard.email_id+' span').empty().html(value);
            //$('#m-'+zz.wizard.email_id+' input').attr({name: 'i-' + zz.wizard.email_id, checked: 'checked'}).val(value);
            $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);
            $('#m-'+zz.wizard.email_id).fadeIn('fast');
            $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
            $('li.rounded img').click(function(){
                $(this).parent('li').fadeOut('fast', function(){
                    $(this).parent('li').remove();
                });
            });
            //console.log(value);
        }
    },

    // clones a recipient from the selection list
    clone_recipient: function(data){
        // data.selectValue is name|email
        var value = '\"'+data.selectValue+'\" \<'+data.extra[0]+'\>';
        var display_value = ( data.selectValue.length >0 ? data.selectValue : data.extra[0] );

        zz.wizard.email_id++;
        //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
        $('#you-complete-me').val('');
        $('#m-clone-added').clone()
                .attr({id: 'm-'+zz.wizard.email_id})
                .insertAfter('#the-recipients li.rounded:last');

        $('#m-'+zz.wizard.email_id+' span').empty().html(display_value);
        $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);
         $('#m-'+zz.wizard.email_id).fadeIn('fast');
        $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
        $('#img-'+zz.wizard.email_id).click(function(){
             $(this).parent('li').fadeOut('fast', function(){
                $(this).remove();
            });
        });
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

    // loads the form to add contibutors on the contributors drawer
    show_new_contributors: function(){
        //console.log("Loading new contributors...") ;
        $('div#contributors-body').fadeOut('fast', function(){
            $('div#contributors-body').load('/albums/'+zz.album_id+'/contributors/new', function(){
                //zz.wizard.build_nav(zz.drawers.group_album, 'contributors');
                //zz.drawers.group_album.steps['contributors'].init();
                //console.log("Initializing new contributors...") ;
                zz.wizard.resize_scroll_body()
                zz.wizard.email_autocomplete();
                $(zz.validate.new_contributors.element).validate(zz.validate.new_contributors);
                $('#the-list').click(function(){
                    $('#you-complete-me').focus();
                });
                $('#cancel-new-contributors').click(function(){
                    //console.log("Canceling new contributors...") ;
                    $('#tab-content').fadeOut('fast', function(){
                        $('#tab-content').load('/albums/'+zz.album_id+'/contributors', function(){
                            zz.wizard.build_nav(zz.drawers.group_album, 'contributors');
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

    format_autocomplete_row: function(row) {
        var formattedRow ='';
        var name         = row[0];
        var add          = row[1];
        var match_len    = row[2];
        if( row[3] == 1  ){
            //name match
            formattedRow+= '<span class="autocomplete-match">';
            formattedRow+= name.substr(0,match_len);
            formattedRow+= "</span>";
            formattedRow+= name.substr(match_len)+' ';
        } else {
          formattedRow+= ' '+name+' '; //push name
        }

        if( row[4] == 1){
            //address match
            formattedRow += '<<span class="autocomplete-match">';
            formattedRow+= add.substr(0,match_len);
            formattedRow+= "</span>";
            formattedRow+= add.substr(match_len)+'>';
        } else {
         formattedRow+= ' <'+add+'> '; //push add
        }
        return formattedRow;
    },
    //set up email autocomplete
    email_autocomplete: function(){

        logger.debug('start email_autocomplete');

        zz.autocompleter = $('#you-complete-me').autocompleteArray(
                google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ),
        {
            width: 700,
            position_element: 'dd#the-list',
            append: '#drawer div.body',
            onItemSelect: zz.wizard.clone_recipient,
            formatItem: zz.wizard.format_autocomplete_row
        }
        );
        //zz.address_list = '';
        logger.debug('end email_autocomplete');

    },

    // reloads the autocompletetion data
    email_autocompleter_reload: function(){
        logger.debug('start email_autocompleter_reload');
        zz.autocompleter[0].autocompleter.setData(google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ));
        logger.debug('end email_autocompleter_reload');

    },

//=========================================== SETTINGS DRAWER =====================================    
    update_profile: function(success,failure) {
        logger.debug('AJAX-posting profile_form');
        var serialized = $(zz.validate.profile_form.element).serialize();
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
                        if (typeof(failure) !== 'undefined') failure();
          }
        });
    },

    delete_identity: function(){
        logger.debug("Deleting ID with URL =  "+ $(this).attr('value'));
        $("#"+$(this).attr('service')+"-status").bind( 'identity_deleted' , zz.wizard.identity_deleted_handler );
        $.post($(this).attr('value'), {"_method": "delete"}, function(data){$('.id-status').trigger( 'identity_deleted' );});
    },

    authorize_identity: function(){
           logger.debug("Authorizing ID with URL =  "+ $(this).attr('value'));
           $("#"+$(this).attr('service')+"-status").bind( 'identity_linked' , zz.wizard.identity_linked_handler );
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
     },

    open_settings_drawer: function( step ){
           zz.wizard.make_drawer(zz.drawers.settings, step);
    },

    close_settings_drawer: function(){
        $('#drawer .body').fadeOut('fast');
        zz.slam_drawer(400);
        setTimeout('window.location = "'+zz.drawers.settings.redirect+'"', 500);
    },




    update_album: function(){
        $.post('/albums/'+zz.album_id,$(".edit_album").serialize() );
        return true;
    },


    dashify: function(s){
        return   s
                .toLowerCase() // change everything to lowercase
                .replace(/^\s+|\s+$/g, "") // trim leading and trailing spaces
                .replace(/[_|\s]+/g, "-") // change all spaces and underscores to a hyphen
                .replace(/[^a-z0-9-]+/g, "") // remove all non-alphanumeric characters except the hyphen
                .replace(/[-]+/g, "-") // replace multiple instances of the hyphen with a single instance
                .replace(/^-+|-+$/g, "") // trim leading and trailing hyphens
                ;
    },

    init_add_tab: function( album_type ){
        filechooser.init();
        setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);

        zz.album_type = album_type;
    },

    init_name_tab: function(){
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
    },


    display_flashes: function( request, delay ){
        var data = request.getResponseHeader('X-Flash');
        if( data && data.length>0 && $('#flashes-notice')){
            var flash = (new Function( "return( " + data + " );" ))();  //parse json using function contstructor
            if( flash.notice ){
                $('#flashes-notice').html(flash.notice).fadeIn('fast', function(){
                    setTimeout(function(){$('#flashes-notice').fadeOut('fast', function(){$('#flashes-notice').html('    ');})}, delay+3000);
                });
            }
        }
    },

    display_errors: function( request, delay ){
          var data = request.getResponseHeader('X-Errors');
            if( data ){
                var errors = (new Function( "return( " + data + " );" ))(); //parse json using function contstructor
                $('#error-notice').html(errors[0][1]).fadeIn('fast', function(){
                    if( delay >0 ){
                        setTimeout(function(){$('#error-notice').fadeOut('fast', function(){$('#error-notice').html('    ');})}, delay+3000);
                    }
                });
            }
    }
};