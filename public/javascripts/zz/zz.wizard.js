zz.wizard = {

    /* Wizard Functions
     ------------------------------------------------------------------------- */

    make_drawer: function(obj, step){


        obj.init();


        if (zz.drawer_state == zz.DRAWER_CLOSED) {
            zz.open_drawer(obj.time, obj.percent);
        }



        zz.wizard.build_nav(obj, step);

        obj.steps[step].init(function(){
            zz.wizard.resize_scroll_body()
        });



        $('body').addClass('drawer');

    },

    change_step: function(id, obj){

        logger.debug(obj.steps[id].type + "    " + zz.drawer_state);

        if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_OPEN) {
            $('#tab-content').fadeOut('fast');
            zz.close_drawer_partially(obj.time);

            zz.wizard.build_nav(obj, id);

            obj.steps[id].init(function(){
                zz.wizard.resize_scroll_body();
            });


        } else if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_PARTIAL) {
            zz.wizard.build_nav(obj, id);
            obj.steps[id].init(function(){
                zz.wizard.resize_scroll_body();
            });

        } else if (obj.steps[id].type == 'full' && zz.drawer_state != zz.DRAWER_OPEN) {
            zz.wizard.build_nav(obj, id);

            obj.steps[id].init(function(){
                zz.wizard.resize_scroll_body();
                zz.open_drawer(obj.time);
            });

        } else if (obj.steps[id].type == 'full' && zz.drawer_state == zz.DRAWER_OPEN) {
            zz.wizard.build_nav(obj, id);
            $('#tab-content').fadeOut('fast', function(){
                obj.steps[id].init(function(){
                    zz.wizard.resize_scroll_body();
                    $('#tab-content').fadeIn('fast');
                });

            });
        } else if (obj.steps[id].type == 'partial' && zz.drawer_state == zz.DRAWER_CLOSED) {
            zz.open_drawer(80, obj.percent);
            zz.close_drawer_partially(obj.time);
            zz.wizard.build_nav(obj, id);

            obj.steps[id].init(function(){
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

        if (obj.show_next_button !== true) {
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
                obj.steps[id].bounce();
                temp_id = $(this).attr('id').split('wizard-')[1];

                zz.wizard.change_step(temp_id, obj);
            });



        });

        if (obj.show_next_button !== true) {
            // no next button neded
        } else if (obj.last == id || obj.style == 'edit') {
            $('#next-step').click(function(e){
                 obj.steps[id].bounce();
                $('#drawer .body').fadeOut('fast');
                zz.close_drawer(400);

                obj.on_close();

            });
        } else {
            $('#next-step').click(function(e){
                e.preventDefault();
                obj.steps[id].bounce();
                temp_id = obj.steps[id].next;

                if (obj.steps[obj.steps[id].next].url_type == 'album') {
                    temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.album_id + obj.steps[obj.steps[id].next].url.split('$$')[1];
                } else if (obj.steps[obj.steps[id].next].url_type == 'user') {
                    temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.current_user_id + obj.steps[obj.steps[id].next].url.split('$$')[1];
                }

                zz.wizard.change_step(temp_id, obj);

            });
        }
    },

    //todo: why is this needed?
    resize_scroll_body: function(){
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 165) + 'px'});
    },





    /* Wizard Object Functions - used to make special things happen
     ------------------------------------------------------------------------- */

    
    email_id: 0,
    autocompleter: 0,
//    contributor_count: 0,

    create_personal_album: function(){
        $.post('/users/'+zz.current_user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
            zz.album_id = data;
            zz.wizard.make_drawer(zz.drawers.personal_album, 'add');
        });
    },

    create_group_album: function(){
        $.post('/users/'+zz.current_user_id+'/albums', { album_type: "GroupAlbum" }, function(data){
            zz.album_id = data;
            zz.wizard.make_drawer(zz.drawers.group_album, 'add');
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
                append: '#drawer div.body'
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
        zz.close_drawer(400);
        setTimeout('window.location = "'+zz.drawers.settings.redirect+'"', 1);
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