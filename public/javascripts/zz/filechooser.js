/*!
 * filechooser.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */



var filechooser = {

    imageloader: null,
    ancestors: [],
    roots: [],
    children: [],

    agent_or_server : {      //wrap calls to agent vs server

        call : function(params){
            var url = params['url'];
            var success_handler = params['success'];
            var error_handler = params['error'];

            if (agent.isAgentUrl(url)) {
                url = agent.buildAgentUrl(url);
                $.jsonp({
                    url: url,
                    success: function(json) {
                        filechooser.agent_or_server.handle_agent_response(json, success_handler, error_handler)
                    },
                    error: error_handler
                });
            }
            else {
                $.ajax({
                    url: url,
                    success: success_handler,
                    error: error_handler
                });
            }
        },

        handle_agent_response: function(json, success_handler, error_handler){
            if(json.headers.status == 200){
                success_handler(json.body);
            }
            else{
                error_handler(json);
            }
        }
    },

    init: function() {

        filechooser.roots = [];


        var file_system_on_error = function(error){
            if(typeof(error.status) === 'undefined'){
                $('#filechooser').hide().load(pages.no_agent.url, function(){
                    pages.no_agent.init_from_filechooser(function(){});
                    $('#filechooser').fadeIn('fast');    
                });
            }
            else if(error.status === 401){
                $('#filechooser').hide().load('/static/connect_messages/wrong_agent_account.html', function(){
                    $('#filechooser').fadeIn('fast');
                });
            }
            else if(error.status === 500){
                $('#filechooser').hide().load('/static/connect_messages/general_agent_error.html', function(){
                    $('#filechooser').fadeIn('fast');
                });
            }
        }

        var picasa_on_error = file_system_on_error;

        var iphoto_on_error = file_system_on_error;


        //mac
        if(filechooser.is_mac()){

            //My Pictures
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/fi9QaWN0dXJlcw=='),
                type: 'folder',
                name: 'My Pictures',
                classy: 'filechooser folder f_pictures',
                on_error: file_system_on_error
            });

            //iPhoto
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/iphoto/folders'),
                type: 'folder',
                name: 'iPhoto',
                classy: 'filechooser folder f_iphoto',
                on_error: iphoto_on_error
            });


            //Picasa
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/picasa/folders'),
                type: 'folder',
                name: 'Picasa',
                classy: 'filechooser folder f_picasa',
                on_error: picasa_on_error
            });


            //My Home
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                type: 'folder',
                name: 'My Home',
                classy: 'filechooser folder f_home',
                on_error: file_system_on_error
            });

            //My Computer
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/L1ZvbHVtZXM='),
                type: 'folder',
                name: 'My Computer',
                classy: 'filechooser folder f_mycomputer',
                on_error: file_system_on_error
            });
        }






        //windows
        if(filechooser.is_windows()){

            //My Pictures
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM='),
                type: 'folder',
                name: 'My Pictures',
                classy: 'filechooser folder f_pictures',
                on_error: file_system_on_error
            });


            //Picassa
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/picasa/folders'),
                type: 'folder',
                name: 'Picasa',
                classy: 'filechooser folder f_picasa',
                on_error: picasa_on_error
            });

            //My Home
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                type: 'folder',
                name: 'My Home',
                classy: 'filechooser folder f_home',
                on_error: file_system_on_error
            });

            //My Computer
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders'),
                type: 'folder',
                name: 'My Computer',
                classy: 'filechooser folder f_mycomputer',
                on_error: file_system_on_error
            });
        }


        //Shutterfly
        filechooser.roots.push(
        {
            open_url: '/shutterfly/folders.json',
            type: 'folder',
            name: 'Shutterfly',
            login_url: '/shutterfly/sessions/new',
            classy: 'filechooser folder f_shutterfly',
            connect_message_url: '/static/connect_messages/connect_to_shutterfly.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_shutterfly.html', function(){
                    $('#filechooser').fadeIn('fast');
                });

            }
        });

        //Kodak
        filechooser.roots.push(
        {
            open_url: '/kodak/folders.json',
            type: 'folder',
            name: 'Kodak',
            login_url:'/kodak/sessions/new',
            classy: 'filechooser folder f_kodak',
            connect_message_url: '/static/connect_messages/connect_to_kodak.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_kodak.html', function(){
                    $('#filechooser').fadeIn('fast');
                });
            }
        });


        //SmugMug
        filechooser.roots.push(
        {
            open_url: '/smugmug/folders.json',
            type: 'folder',
            name: 'SmugMug',
            login_url: '/smugmug/sessions/new',
            classy: 'filechooser folder f_smugmug',
            connect_message_url: '/static/connect_messages/connect_to_smugmug.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_smugmug.html', function(){
                    $('#filechooser').fadeIn('fast');
                });
            }
        });


        //Facebook
        filechooser.roots.push(
        {
            open_url: '/facebook/folders.json',
            type: 'folder',
            name: 'Facebook',
            login_url: '/facebook/sessions/new',
            classy: 'filechooser folder f_facebook',
            connect_message_url: '/static/connect_messages/connect_to_facebook.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_facebook.html', function(){
                    $('#filechooser').fadeIn('fast');
                });

            }

        });

        //Flickr
        filechooser.roots.push(
        {
            open_url: '/flickr/folders.json',
            type: 'folder',
            name: 'Flickr',
            login_url: '/flickr/sessions/new',
            classy: 'filechooser folder f_flickr',
            connect_message_url: '/static/connect_messages/connect_to_flickr.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_flickr.html', function(){
                    $('#filechooser').fadeIn('fast');
                });
            }
        });


        //Picasa Web
        filechooser.roots.push(
        {
            open_url: '/picasa/folders.json',
            type: 'folder',
            name: 'Picasa Web',
            login_url: '/picasa/sessions/new',
            classy: 'filechooser folder f_picasa',
            connect_message_url: '/static/connect_messages/connect_to_picasa_web.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_picasa_web.html', function(){
                    $('#filechooser').fadeIn('fast');
                });

            }
        });


        //Photobucket
        filechooser.roots.push(
        {
            open_url: '/photobucket/folders', //No need for .json cause this connector has unusual structure
            type: 'folder',
            name: 'Photobucket',
            login_url: '/photobucket/sessions/new',
            classy: 'filechooser folder f_photobucket',
            connect_message_url: '/static/connect_messages/connect_to_photobucket.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_photobucket.html', function(){
                    $('#filechooser').fadeIn('fast');
                });

            }
        });


        //ZangZing
        filechooser.roots.push(
        {
            open_url: '/zangzing/folders.json',
            type: 'folder',
            name: 'ZangZing',
            classy: 'filechooser folder f_zangzing',
            connect_message_url: ''
        });


        $('#filechooser-back-button').click(filechooser.open_parent_folder);
        filechooser.ancestors = [];
        filechooser.open_root();

        tray.init(); 



    },


    open_root: function() {
        filechooser.open_folder('Home', '', '');
    },

    is_windows : function() {
        return (navigator.appVersion.indexOf("Win")!=-1);
    },

    is_mac : function() {
        return (navigator.appVersion.indexOf("Mac")!=-1);
    },


    open_folder: function(name, open_url, login_url) {


        filechooser.ancestors.push({name:name, open_url:open_url, login_url:login_url});
        //update title and back button
        if (filechooser.ancestors.length > 1) {
            $('#filechooser-back-button span').html(filechooser.ancestors[filechooser.ancestors.length - 2].name);
            $('#filechooser-back-button').show();
            $('#choose-header').removeClass('album-header').addClass('album-header-off');
        } else {
            $('#filechooser-back-button').hide();
            $('#filechooser-back-button span').html('');
            $('#choose-header').removeClass('album-header-off').addClass('album-header');
        }

        $('#filechooser-title').html(name);
        $('#filechooser-tagline').html('Choose pictures from folders on your computer or other photo sites');

        //update files
        $('#filechooser').fadeOut('fast', function(){
            $('#filechooser').html('<img src="/images/loading.gif">');
            $('#filechooser').show();


            if (open_url == '') {
                filechooser.on_open_root();
            }
            else {
                filechooser.agent_or_server.call({
                    url: open_url,
                    success: function(json) {
                        filechooser.on_open_folder(json);
                    },
                    error: filechooser.on_error_opening_folder
                });
            }
        });
    },


    on_open_root : function() {
        filechooser.on_open_folder(filechooser.roots);
    },

    on_open_folder : function(children) {

        filechooser.children = children

        //setup the imageloader -- if active, kill it
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        var onStartLoadingImage = function(id, src) {
            //            $('#' + id).attr('src', '/images/loading.gif');
        };

        var onImageLoaded = function(id, src, width, height) {
            var new_size = 115;

            if (height > width) {
                //tall
                var ratio = width / height;
                $('#' + id).attr('src', src).css({
                    height: new_size+'px',
                    width: (ratio * new_size) + 'px'
                });

                var guuu = $('#'+id).attr('id').split('-')[3];
                $('li#photo-'+ guuu +' figure').css({
                    bottom: '9px',
                    width: ((ratio * new_size) + 10)+'px',
                    marginLeft: (((new_size - (ratio * new_size)) / 2 ) + 2)+ 'px'
                });
                $('li#photo-'+ guuu +' .checkmark').css({bottom: '3px'});

            } else {



                var ratio = height / width;

                $('#' + id).attr('src', src).attr('src', src).css({
                    height: (ratio * new_size) + 'px',
                    width: new_size+'px',
                    marginTop: ((new_size - (ratio * new_size)) / 2) + 'px'
                });

                var guuu = $('#'+id).attr('id').split('-')[3];
                $('li#photo-'+ guuu +' figure').css({
                    bottom: ((new_size - (ratio * new_size)) / 2) + 9 +'px'
                });
                temp = $('li#photo-'+ guuu +' .checkmark').css('left');
                $('li#photo-'+ guuu +' .checkmark').css({
                    bottom: ((new_size - (ratio * new_size)) / 2) + 3 + 'px',
                    left: '-10px' });
            }
        };

        filechooser.imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);


        //build html for list of files/folders
        var html = '';
        for (var i in children) {

            if (children[i].type == 'folder') {

                var id = 'chooser-folder-' + i;
                var a_id = 'chooser-folder-a-' + i;

                var theClick = 'onclick="filechooser.open_folder(\'' + children[i].name + '\',\'' + children[i].open_url + '\',\'' + children[i].login_url + '\',\'' + children[i].connect_message_url + '\'); return false;"';

                var classy = children[i].classy;
                if(typeof (classy) === 'undefined'){
                    classy = 'filechooser folder f_blank';
                }


                html += '<li id="' + id + '" class="' + classy + '">';
                html += '<a href="" ' + theClick + '><img src="/images/blank-folder.png" /></a>';
                html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';

                if (children[i].add_url) {
                    html += '&nbsp;<a href="#" onclick="filechooser.add_folder_to_tray(\'' + children[i].add_url + '\', \'' + id + '\'); return false;">(+)</a>';
                }

                html += '</li>';

            } else {

                var img_id = 'chooser-photo-img-' + children[i].source_guid;
                var add_photo_handler = 'onclick="filechooser.add_photo_to_tray(\'' + children[i].add_url + '\', \'' + img_id + '\'); return false;"';
                var picture_view_handler = 'onclick="filechooser.picture_view(' + i + ');return false;"';

                html += '<li id="photo-' + children[i].source_guid + '" class="filechooser photo" >';
                html += '<div class="relative">'
                html += '<img id="' + img_id + '" src="/images/blank-image.png" '+ picture_view_handler +'>';
                html += '<figure ' + add_photo_handler + '>Add Photo</figure>';
                html += '<div class="checkmark"></div>';
                html += '</div>';
                html += children[i].name;
                html += '</li>';

                if (agent.isAgentUrl(children[i].thumb_url)) {
                    filechooser.imageloader.add(img_id, agent.buildAgentUrl(children[i].thumb_url));
                } else {
                    filechooser.imageloader.add(img_id, children[i].thumb_url);
                }
            }
        }


        $('#filechooser').hide();
        $('#filechooser').html(html);
        $('#filechooser').fadeIn('fast');

        filechooser.update_checkmarks();

        filechooser.imageloader.start(5);
    },

    picture_view : function(i){
        var children = filechooser.children

        if(i > children.length-1){
            i = children.length-1
        }

        if(i < 0){
            i = 0;
        }


        var html = '';
        var img_id = 'chooser-photo-img-' + children[i].source_guid;

        var previous_image_handler = 'onclick="filechooser.picture_view(' + (i - 1) + ');return false;"';
        var next_image_handler = 'onclick="filechooser.picture_view(' + (i + 1) + ');return false;"';
        var add_photo_handler = 'onclick="filechooser.add_photo_to_tray(\'' + children[i].add_url + '\', \'' + img_id + '\'); return false;"';


        if(children[i].type === 'folder'){
            var id = 'chooser-folder-' + i;

            var theClick = 'onclick="filechooser.open_folder(\'' + children[i].name + '\',\'' + children[i].open_url + '\',\'' + children[i].login_url + '\'); return false;"';
            html += '<a href="" ' + theClick + '><img src="/images/blank-folder.png" /></a>';
            html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';

//            if (children[i].add_url) {
//                html += '&nbsp;<a href="#" onclick="filechooser.add_folder(\'' + children[i].add_url + '\', \'' + id + '\'); return false;">(+)</a>';
//            }
        }
        else{
            var grid_view_handler = 'onclick="filechooser.grid_view();return false;"';

            var image_url = children[i].screen_url;

            if (agent.isAgentUrl(image_url)) {
                image_url = agent.buildAgentUrl(image_url);
            }

            html += '<img class="large-photo" id="' + img_id + '" src="'+ image_url +'" '+ grid_view_handler +'>';

        }

        html += '<br>';
        html += '<a href="" ' + previous_image_handler + '><img src="/images/btn-prev-photo.png"></a>';
        html += '<a href="" ' + add_photo_handler + '> ' + children[i].name +' [add to album]</a>';
        html += '<a href="" ' + next_image_handler + '><img src="/images/btn-next-photo.png"></a>';


        $('#filechooser').fadeOut('fast', function(){
            $('#filechooser').html(html);
            $('#filechooser').fadeIn('fast');
        });

    },

    grid_view :function(){
        filechooser.on_open_folder(filechooser.children)
    },


    update_checkmarks : function(){

        //uncheck all
        $('li').removeClass('in-tray');

        //check the ones in the tray
        var tray_photos = tray.get_photos();
        for(var i in tray_photos){
            $("li#photo-" + tray_photos[i].source_guid).addClass('in-tray');
        }

    },








    add_folder_to_tray : function(add_url, element_id) {
        var element = $('#'+element_id);
        var margin_top = element.css('margin-top').split('px')[0];
        var border_top = 5;
        var border_left = 5;
        var start_top = element.offset().top - margin_top + border_top;
        var start_left = element.offset().left + border_left;

        var end_top = tray.element.offset().top - margin_top;
        var end_left = tray.next_thumb_offset_x();


        var on_finish_animation = function(){
            tray.add_photos_to_album(add_url);
            $(this).remove();
        }


        var img = $('<img src="/images/folders/blank.png" style="display:none" width="135px" left="110px"/>');
        
        img.appendTo('body')
                .css({position: 'absolute', zIndex: 2000, left: start_left, top: start_top, border:'none'})
                .show()
                .addClass('animate-folder-to-tray')
                .animate({
                    width: '20px',
                    height: '20px',
                    top: (end_top) +'px',
                    left: (end_left) +'px'
                }, 1000, 'easeInOutCubic', on_finish_animation);

    },


    add_photo_to_tray: function(add_url, element_id){
        var element = $('#'+element_id);

        var margin_top = element.css('margin-top').split('px')[0];
        var border_top = 5;
        var border_left = 5;
        var start_top = element.offset().top - margin_top + border_top;
        var start_left = element.offset().left + border_left;

        var end_top = tray.element.offset().top - margin_top;
        var end_left = tray.next_thumb_offset_x();


        var on_finish_animation = function(){
            tray.add_photos_to_album(add_url);
            $(this).remove();
        }

        element.clone()
                .css({position: 'absolute', zIndex: 2000, left: start_left, top: start_top,border:'1px solid #ffffff'})
                .appendTo('body')
                .addClass('animate-photo-to-tray')
                .animate({
                    width: '20px',
                    height: '20px',
                    top: (end_top) +'px',
                    left: (end_left) +'px'
                }, 1000, 'easeInOutCubic', on_finish_animation);


        element.parents('li').addClass('in-tray');



    },



//    on_add_photos : function(json) {
//        var photos = json;
//
//        tray.add_photos(photos);
//
//        filechooser.update_checkmarks();
//    },




    open_parent_folder: function() {
        var current = filechooser.ancestors.pop(); //discard this
        var parent = filechooser.ancestors.pop();
        filechooser.open_folder(parent.name, parent.open_url, parent.login_url);
    },


    on_error_opening_folder : function(error) {
        var current = filechooser.ancestors[filechooser.ancestors.length - 1];
        for(var i in filechooser.roots){
            if(filechooser.roots[i].open_url === current.open_url){
                filechooser.roots[i].on_error(error);
                break;
            }
        }
    },

//    on_error_adding_photos :function() {
//        alert('error adding photo');
//    },

    // for oauth window
    open_login_window : function() {
        var current = filechooser.ancestors[filechooser.ancestors.length - 1];
        oauthmanager.login(current.login_url, filechooser.on_login);
    },

    // for oauth window - return
    on_login : function() {
        var current = filechooser.ancestors.pop(); //discard this
        filechooser.open_folder(current.name, current.open_url, current.login_url);
    }

};


var tray = {

    widget: null,
    photos: [],
    element: null,

    init: function(){
        tray.element = $("#added-pictures-tray")
        tray.widget =  tray.element.zz_thumbtray({
                photos:[],
                allowDelete:true,
                allowSelect:false,
                onDeletePhoto:function(index, photo){
                    tray.photos = tray.photos.splice(index,1);
                    filechooser.update_checkmarks();
                    tray.delete_photo(photo);
                }
             }).data().zz_thumbtray;

        tray.reload();
    },

    reload : function() {
        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos/json?' + (new Date()).getTime(),  //force cache miss
            success: function(photos){
                tray.photos = photos;
                tray.widget.setPhotos(tray.map_photos(tray.photos));
            }

        });
    },

    add_photos_to_album: function(add_url){

        add_url += (add_url.indexOf('?') == -1) ? '?' : '&'
        add_url += 'album_id=' + zz.album_id;

        tray.show_loading_indicator();
        filechooser.agent_or_server.call({
            url: add_url,
            success: function(photos) {
                tray.photos = tray.photos.concat(photos);
                tray.widget.setPhotos(tray.map_photos(tray.photos));
                tray.hide_loading_indicator();
                filechooser.update_checkmarks();                

            },
            error: function(error){
                logger.debug(error);
//                $.jGrowl("" + error);
            }
        });

    },



    get_photos: function(){
        return tray.photos;
    },

    map_photos:function(photos){
        if(! $.isArray(photos)){
            var photos = [photos];
        }

        photos = $.map(photos, function(photo, index){
            var id = photo.id;
            var src = photo.thumb_url;

            if(agent.isAgentUrl(src)){
               src = agent.buildAgentUrl(src); 
            }
            
            return {id:id, src:src};
        });

        return photos;
    },

    delete_photo: function(photo){
        $.ajax({
            type: "DELETE",
            dataType: "json",
            url: "/photos/" + photo.id + ".json",
            error: function(error){
                logger.debug(error);
//                $.jGrowl("" + error);
            }
        });
    },

    next_thumb_offset_x: function(){
        return this.widget.nextThumbOffsetX();
    },

    show_loading_indicator: function(){
        this.widget.showLoadingIndicator();
    },

    hide_loading_indicator: function(){
        this.widget.hideLoadingIndicator();
    }
};

