zz.wizard = {

    /* Wizard Functions
     ------------------------------------------------------------------------- */

    make_drawer: function(obj, step){
        /* obj contains: obj.next_element, obj.done_redirect, obj.steps.step.id,
         obj.steps.step.element, obj.steps.step.info,
         obj.steps.step.type, obj.steps.step.init,
         obj.steps.step.bounce */

        obj.init();

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




    //set up email autocomplete
    init_email_autocompleter: function(){

        logger.debug('start email_autocomplete');

        zz.autocompleter = $('#you-complete-me').autocompleteArray(
                google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ),
            {
                width: 700,
                position_element: 'dd#the-list',
                append: '#drawer div.body',
            }
        );
        //zz.address_list = '';
        logger.debug('end email_autocomplete');

    },

    // reloads the autocompletetion data
    reload_email_autocompleter: function(){
        logger.debug('start email_autocompleter_reload');
        zz.autocompleter[0].autocompleter.setData(google_contacts.concat( yahoo_contacts.concat( mslive_contacts.concat(local_contacts )) ));
        logger.debug('end email_autocompleter_reload');

    },

//=========================================== SETTINGS DRAWER =====================================    




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