/*!
 * zz.wizard.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.wizard = {

    /* Wizard Functions
     ------------------------------------------------------------------------- */

    make_drawer: function(obj, step){

        obj.init();

        if (zz.drawer_state == zz.DRAWER_CLOSED) {
            zz.open_drawer(obj.time, obj.percent);
        }

        zz.wizard.build_nav(obj, step);

        var container = $('#tab-content');

        obj.steps[step].init(container, function(){
            zz.wizard.resize_scroll_body()
        });

        $('body').addClass('drawer');

    },

    change_step: function(id, obj){

//        logger.debug(obj.steps[id].type + "    " + zz.drawer_state);

        var container = $('#tab-content');

        if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_OPEN) {
            $('#tab-content').fadeOut('fast');
            if( obj.style == 'edit' ){
                zz.close_drawer_partially(obj.time, 40);
            }else{
                zz.close_drawer_partially(obj.time, 40);
            }
            zz.wizard.build_nav(obj, id);
            obj.steps[id].init(container, function(){
                zz.wizard.resize_scroll_body();
            });


        } else if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_PARTIAL) {
            zz.wizard.build_nav(obj, id);
            obj.steps[id].init(container, function(){
                zz.wizard.resize_scroll_body();
            });

        } else if (obj.steps[id].type == 'full' && zz.drawer_state == zz.DRAWER_PARTIAL) {
            zz.wizard.build_nav(obj, id);

            $('#tab-content').empty().show();

            zz.open_drawer(obj.time);

            //todo: should pass this as callback to zz.open_drawer
            setTimeout(function(){
                obj.steps[id].init(container, function(){
                    zz.wizard.resize_scroll_body();
                });
            }, obj.time);


        } else if (obj.steps[id].type == 'full' && zz.drawer_state == zz.DRAWER_OPEN) {
            zz.wizard.build_nav(obj, id);
            $('#tab-content').fadeOut(100, function(){
                $('#tab-content').empty();
                $('#tab-content').show();
//                $('#tab-content').css({opacity:0});
                obj.steps[id].init(container, function(){
                    zz.wizard.resize_scroll_body();
//                    $('#tab-content').fadeIn('fast');
                });

            });
        } else if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_CLOSED) {
            zz.open_drawer(80, obj.percent);
            zz.close_drawer_partially(obj.time);
            zz.wizard.build_nav(obj, id);

            obj.steps[id].init(container, function(){
                zz.wizard.resize_scroll_body();
            });

        } else {
            console.warn('This should never happen. Context: zz.wizard.change_step, Type: '+obj.steps[id].type+', Drawer State: '+zz.drawer_state);
        }


    },

    build_nav: function(obj, id, fade_in){


        var temp_id = 1;
        var temp = '';
        $.each(obj.steps, function(i, item) {
            if (i == id && obj.numbers == 1) {
                value = temp_id;
                temp += '<li id="wizard-'+ i + '" class="tab on">';
                temp += '<img src="' + path_helpers.image_url('/images/wiz-num-'+temp_id+'-on.png') +'" class="num"> '+ item.title +'</li>';
            } else if (i == id) {
                value = temp_id;
                temp += '<li id="wizard-'+ i + '" class="tab on">'+ item.title +'</li>';
            } else if (obj.numbers == 1) {
                temp += '<li id="wizard-'+ i + '" class="tab">';
                temp += '<img src="' + path_helpers.image_url('/images/wiz-num-'+temp_id+'.png') +'" class="num"> '+ item.title +'</li>';
            } else {
                temp += '<li id="wizard-'+ i + '" class="tab">'+ item.title +'</li>';
            }
            temp_id++;

        });

        // the last time we incrimented it didn't load a step - we use this to know the length of the list below
        temp_id--;

        if (obj.show_next_button !== true) {
            // no next button neded
        } else if (obj.steps[id].next == 0 || obj.style == 'edit') {
//            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-wizard-done.png" /></li>';
            temp += '<li class="next-done">';
            temp += '<a id="next-step" class="green-button"><span>Done</span></a>';
            temp += '</li>';
        } else {
//            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-steps-next.png" /></li>';
            temp += '<li class="next-done">';
            temp += '<a id="next-step" class="next-button"><span>Next</span></a>';
            temp += '</li>';
        }

        if(fade_in){
            $('#drawer-tabs').hide();
        }
        if (obj.style == 'edit') {
            //      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('edit-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');
            $('#drawer-tabs').html($('#clone-indicator').clone().attr('id', 'indicator' + '-' + temp_id).addClass('edit-'+value+'-'+temp_id).html(temp));
        } else {
            $('#drawer-tabs').html($('#clone-indicator').clone().attr('id', 'indicator' + '-' + temp_id).addClass('step-'+value+'-'+temp_id).html(temp));
            //      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('step-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');
        }
        if(fade_in){
            $('#drawer-tabs').fadeIn('fast');
        }
        zz.wizard.resize_scroll_body();


        //bind the event handlers
        $.each(obj.steps, function(i, item) {
            $('li#wizard-'+ i).click(function(e){
                e.preventDefault();
                temp_id = $(this).attr('id').split('wizard-')[1];
                
                obj.steps[id].bounce(function(){
                    zz.wizard.change_step(temp_id, obj);
                });
            });



        });

        if (obj.show_next_button !== true) {
            // no next button neded
        } else if (obj.last == id || obj.style == 'edit') {
            $('#next-step').click(function(e){
                 obj.steps[id].bounce(function(){
                     $('#drawer .body').fadeOut('fast');
                     zz.close_drawer(400);
                     obj.on_close();
                 });
            });
        } else {
            $('#next-step').click(function(e){
                e.preventDefault();
                obj.steps[id].bounce(function(){
                    temp_id = obj.steps[id].next;


                    zz.wizard.change_step(temp_id, obj);
                });
            });
        }
    },

    //todo: why is this needed?
    resize_scroll_body: function(){
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 140) + 'px'});
    },


    set_wizard_style: function(style){
      if( style == 'edit'){
            $('div#drawer').css('background-image','url(' + path_helpers.image_url('/images/bg-drawer-bottom-cap.png') + ')');
            $('div#cancel-drawer-btn').hide();
            zz.screen_gap =  160;
        } else {
            $('div#drawer').css('background-image','url(' + path_helpers.image_url('/images/bg-drawer-bottom-cap-with-cancel.png') + ')');
            $('div#cancel-drawer-btn').show();
            zz.screen_gap = 160;
        }
    },

    /* Wizard Object Functions - used to make special things happen
     ------------------------------------------------------------------------- */

    

//    create_personal_album: function(){
//        $.post('/users/'+zz.current_user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
//            zz.album_id = data;
//            zz.wizard.make_drawer(zz.drawers.personal_album, 'add');
//        });
//    },

    create_group_album: function(){
        $.post(zz.path_prefix + '/users/'+zz.current_user_id+'/albums', { album_type: "GroupAlbum" }, function(data){
            zz.album_id = data.id;
            $('#album-info h2').text(data.name);
            zz.wizard.make_drawer(zz.drawers.group_album, 'add');
        });
    },

    open_edit_album_wizard: function( step ){
        switch(  zz.album_type ){
            case 'profile':
//            case 'personal':
//                if( typeof(zz.drawers.edit_personal_album) == "undefined" ){
//                    zz.drawers.edit_personal_album = zz.drawers.personal_album;
//                    zz.drawers.edit_personal_album.style='edit'
//                }
//                zz.wizard.make_drawer(zz.drawers.edit_personal_album, step);
//                break;
            case 'group':
                if( typeof(zz.drawers.edit_group_album) == "undefined" ){
                    zz.drawers.edit_group_album = zz.drawers.group_album;
                    zz.drawers.edit_group_album.style='edit'
                }
                zz.wizard.make_drawer(zz.drawers.edit_group_album, step );
                break;
            default:
                logger.debug('zz.wizard.open_edit_album_wizard: Albums of type: '+zz.album_type+' are not supported yet.')    
                //alert('Albums of type: '+zz.album_type+' are not supported yet.')
                break
        }
    },




//    //set up email autocomplete
//    init_email_autocompleter: function(){
//
//        logger.debug('start email_autocomplete');
//
//        $('#you-complete-me').autocompleteArray(
//                google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ),
//            {
//                width: 700,
//                position_element: 'dd#the-list',
//                append: '#drawer div.body'
//            }
//        );
//        //zz.address_list = '';
//        logger.debug('end email_autocomplete');
//
//    },

//    // reloads the autocompletetion data
//    reload_email_autocompleter: function(){
//        logger.debug('start email_autocompleter_reload');
//
//        //todo: is there a better way to get a handle to the plugin?
//        $('#you-complete-me')[0].autocompleter.setData(google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ));
//
//        logger.debug('end email_autocompleter_reload');
//
//    },

//=========================================== SETTINGS DRAWER =====================================    




    open_settings_drawer: function( step ){
           zz.wizard.make_drawer(zz.drawers.settings, step);
    },

    close_settings_drawer: function(){
        $('#drawer .body').fadeOut('fast');
        zz.close_drawer(400);
        setTimeout(function(){
            window.location.reload( false );
        },1);
    },


    display_flashes: function( request, delay ){
        var data = request.getResponseHeader('X-Flash');
        if( data && data.length>0 && $('#flashes-notice')){
            var flash = $.parseJSON(data);
            if( flash.notice ){
                $('#flashes-notice').text(flash.notice).fadeIn('fast', function(){
                    setTimeout(function(){
                        $('#flashes-notice').fadeOut('fast', function(){
                            $('#flashes-notice').text('    ');
                        })
                    }, delay+3000);
                });
            }
            if( flash.error ){
                $('#error-notice').text(flash.error).fadeIn('fast', function(){
                    setTimeout(function(){
                        $('#error-notice').fadeOut('fast', function(){
                            $('#error-notice').text('    ');
                        })
                    }, delay+4000);
                });
            }
        }
    },

    display_errors: function( request, delay ){
          var data = request.getResponseHeader('X-Errors');
            if( data ){
                var errors = $.parseJSON(data);

                //extract the value of the first attribute
                var message = ""
                for(var i in errors){
                    if(typeof(i) !== 'undefined'){
                        message = errors[i];
                        break;
                    }
                }

                $('#error-notice').text(message).fadeIn('fast', function(){
                    if( delay >0 ){
                        setTimeout(function(){
                            $('#error-notice').fadeOut('fast', function(){
                                $('#error-notice').text('    ');
                            })
                        }, delay+3000);

                    }
                });
            }
    }
};