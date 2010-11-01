/* Filechooser
 ----------------------------------------------------------------------------- */
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
                $('#filechooser').hide().load('/static/connect_messages/no_agent.html', function(){
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
                classy: 'f_pictures',
                on_error: file_system_on_error
            });

            //iPhoto
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/iphoto/folders'),
                type: 'folder',
                name: 'iPhoto',
                classy: 'f_iphoto',
                on_error: iphoto_on_error
            });


            //Picasa
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/picasa/folders'),
                type: 'folder',
                name: 'Picasa',
                classy: 'f_picasa',
                on_error: picasa_on_error
            });


            //My Home
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                type: 'folder',
                name: 'My Home',
                classy: 'f_home',
                on_error: file_system_on_error
            });

            //My Computer
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/L1ZvbHVtZXM='),
                type: 'folder',
                name: 'My Computer',
                classy: 'f_mycomputer',
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
                classy: 'f_pictures',
                on_error: file_system_on_error
            });


            //Picassa
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/picasa/folders'),
                type: 'folder',
                name: 'Picasa',
                classy: 'f_picasa',
                on_error: picasa_on_error
            });

            //My Home
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                type: 'folder',
                name: 'My Home',
                classy: 'f_home',
                on_error: file_system_on_error
            });

            //My Computer
            filechooser.roots.push(
            {
                open_url: agent.buildAgentUrl('/filesystem/folders'),
                type: 'folder',
                name: 'My Computer',
                classy: 'f_mycomputer',
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
            classy: 'f_shutterfly',
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
            classy: 'f_kodak',
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
            classy: 'f_smugmug',
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
            classy: 'f_facebook',
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
            classy: 'f_flickr',
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
            classy: 'f_picasa',
            connect_message_url: '/static/connect_messages/connect_to_picasa_web.html',
            on_error: function(error){
                $('#filechooser').hide().load('/static/connect_messages/connect_to_picasa_web.html', function(){
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
            classy: 'f_zangzing',
            connect_message_url: ''
        });


        $('#filechooser-back-button').click(filechooser.open_parent_folder);
        filechooser.ancestors = [];
        filechooser.open_root();
        tray.reload();
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
            $('#filechooser-back-button').html(filechooser.ancestors[filechooser.ancestors.length - 2].name).show();
            $('#choose-header').removeClass('album-header').addClass('album-header-off');
        } else {
            $('#filechooser-back-button').html('').hide();
            $('#choose-header').removeClass('album-header-off').addClass('album-header');
        }

        $('#filechooser-title').html(name);

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
            //console.log('id: #'+id+', src: '+src+', width: '+width+', height: '+height);

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

                //wide
                //console.log('wide');

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


                html += '<li id="' + id + '" class="' + children[i].classy + '">';
                html += '<a href="" ' + theClick + '><img src="/images/blank-folder.png" /></a>';
                html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';

                if (children[i].add_url) {
                    html += '&nbsp;<a href="#" onclick="filechooser.add_folder(\'' + children[i].add_url + '\', \'' + id + '\'); return false;">(+)</a>';
                }

                html += '</li>';

            } else {
                //                var id = 'chooser-photo-' + children[i].source_guid;
                var img_id = 'chooser-photo-img-' + children[i].source_guid;
                var add_photo_handler = 'onclick="filechooser.add_photos(\'' + children[i].add_url + '\', \'' + img_id + '\'); return false;"';
                var picture_view_handler = 'onclick="filechooser.picture_view(' + i + ');return false;"';

                html += '<li id="photo-' + children[i].source_guid + '" class="photo" >';
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
        var add_photo_handler = 'onclick="filechooser.add_photos(\'' + children[i].add_url + '\', \'' + img_id + '\'); return false;"';

        html += '<a href="" ' + previous_image_handler + '><img src="/images/btn-prev-photo.png"></a>';
        html += '<a href="" ' + add_photo_handler + '>[add to album]</a>';
        html += '<a href="" ' + next_image_handler + '><img src="/images/btn-next-photo.png"></a>';

        if(children[i].type === 'folder'){
            var id = 'chooser-folder-' + i;

            var theClick = 'onclick="filechooser.open_folder(\'' + children[i].name + '\',\'' + children[i].open_url + '\',\'' + children[i].login_url + '\'); return false;"';
            html += '<a href="" ' + theClick + '><img src="/images/blank-folder.png" /></a>';
            html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';

            if (children[i].add_url) {
                html += '&nbsp;<a href="#" onclick="filechooser.add_folder(\'' + children[i].add_url + '\', \'' + id + '\'); return false;">(+)</a>';
            }
        }
        else{
            var grid_view_handler = 'onclick="filechooser.grid_view();return false;"';

            var image_url = children[i].screen_url;

            if (agent.isAgentUrl(image_url)) {
                image_url = agent.buildAgentUrl(image_url);
            }

            html += '<img id="' + img_id + '" src="'+ image_url +'" '+ grid_view_handler +'>';
            html += '<br>';
            html += children[i].name;

        }


        $('#filechooser').html(html);
    },

    grid_view :function(){
        filechooser.on_open_folder(filechooser.children)
    },


    update_checkmarks : function(){

        //uncheck all
        $('li').removeClass('in-tray');

        //check the ones in the tray
        for(var i in tray.album_photos){
            $("li#photo-" + tray.album_photos[i].source_guid).addClass('in-tray');
        }

    },

    add_photos : function(add_url, element_id) {

        if (add_url.indexOf('?x=') == -1)
            add_url += '?'
        else
            add_url += '&'
        add_url += 'album_id=' + zz.album_id;

        var after_animate = function(){

            filechooser.agent_or_server.call({
                url: add_url,
                success: function(json) {
                    filechooser.on_add_photos(json);
                },
                error: filechooser.on_error_adding_photos
            });
        }


        zz.image_pop(element_id, after_animate);

    },


    on_add_photos : function(json) {
        var photos = json;

        tray.add_photos(photos);

        filechooser.update_checkmarks();
    },


    add_folder : function(add_url, element_id) {
        //todo: need different implemenatation here
        filechooser.add_photos(add_url, element_id);
    },

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

    on_error_adding_photos :function() {
        alert('error adding photo');
    },

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


/* Added Photos Tray
 ----------------------------------------------------------------------------- */
var tray = {

    imageloader : null,
    album_photos : [],

    reload : function() {
        var get_album_photos_url = '/albums/' + zz.album_id + '/photos.json';
        $.ajax({
            dataType: 'json',
            url: get_album_photos_url,
            success: tray.on_reload,
            error: function() {
                alert('error reloading tray');
            }  //todo: remove alerty
        });
    },

    on_reload : function(photos) {
        tray.album_photos = photos;
        tray.repaint();
    },

    //add single or array of photos to tray
    add_photos : function(photos) {
        tray.album_photos = tray.album_photos.concat(photos);
        tray.repaint();
    },


    //redraws the contents of the tray; called after photos are added or removed
    repaint : function() {
        //setup the imageloader
        if (tray.imageloader) {
            tray.imageloader.stop();
        }
        var onStartLoadingImage = function(id, src) {
            $('#' + id).attr('src', '/images/loading.gif');
        };

        var onImageLoaded = function(id, src, width, height) {
            $('#' + id).attr('src', src);

            if (height > width) {
                var ratio = (width / height);
                $('#hover-' + id).attr('src', src).css({
                    height: '120px',
                    top: '-132px',
                    width: (ratio * 120) + 'px',
                    left: '-' + (((ratio * 120) / 2) - 15) + 'px'
                });

                $('#del-' + id).css({
                    //                top: '-152px',
                    //                left: ((ratio * 120) / 2) + 'px'
                    top: '-15px',
                    left: '-15px'
                });


            } else {

                var ratio = (height / width);
                //console.log(ratio);
                $('#hover-' + id).attr('src', src).css({
                    height: (ratio * 120) + 'px',
                    top: '-' + ((ratio * 120) + 12) + 'px',
                    width: '120px',
                    left: '-45px'

                });
                $('#del-' + id).css({
                    //                top: '-'+((ratio * 120) + 32) + 'px',
                    //                left: '60px'
                    top: '-15px',
                    left: '-15px'
                });


            }
        };

        tray.imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);

        //calculate margin-left of items so they all fit
        var TRAY_WIDTH = 878;
        var ITEM_WIDTH = 30;
        var count = tray.album_photos.length;
        var allocated_space = (TRAY_WIDTH / (count+1));

        if(allocated_space > ITEM_WIDTH){
            allocated_space = ITEM_WIDTH;
        }

        var overlap = ITEM_WIDTH - allocated_space;


        var html = '';

        for (var i =0;i<tray.album_photos.length; i++) {
            var photo = tray.album_photos[i];

            var id = 'tray-' + photo.id;

            /*

             from my firebug edits:
             <li>

             <div>

             <img width="20" height="20" src="http://farm1.static.flickr.com/28/63236798_316a95d732_m.jpg" id="tray-bbJRmOT4Kr35cyXcWddDor">

             <a href="" onclick="tray.delete_photo('bbJRmOT4Kr35cyXcWddDor'); return false;">(x)</a>


             </div>
             </li>

             */

            if(i===0){
                html+="<li>"
            }
            else{
                html += '<li style="margin-left:' + (-1 * overlap) + 'px">';
            }

            html += '<div>';
            html += '<img height="30" width="30" id="' + id + '" class="trayed-up" src="/images/loading.gif" style="z-index:5;">';
            html += '<a href="javascript:void(0);" onclick="tray.delete_photo(\'' + photo.id + '\'); return false;"><img src="/images/btn-delete.png" class="delete" id="del-'+ id +'" /></a>';
            html += '<img width="120" class="hover-thumbnail" src="" id="hover-'+ id +'">';
            html += '</div>';
            html += '</li>';

            if (photo.agent_id) {          //todo: need to check that agent id matches local agent
                //was uploaded from agent
                if (photo.state == 'ready') {
                    tray.imageloader.add(id, photo.thumb_url);
                } else {
                    tray.imageloader.add(id, agent.buildAgentUrl('/albums/' + zz.album_id + '/photos/' + photo.id + '.thumb'));

                }

            } else {

                //photo was side loaded or emailed
                if (photo.state == 'ready') {
                    tray.imageloader.add(id, photo.thumb_url);
                } else {
                    tray.imageloader.add(id, photo.source_thumb_url);
                }

            }

        }

        $('#added-pictures-tray').html(html);
        setTimeout(function(){$('#traversing').hide().remove();}, 500);
        zz.init.tray();
        tray.imageloader.start(5);

    },


    delete_photo : function(photo_id) {
        $.ajax({
            type: "DELETE",
            dataType: "json",
            url: "/photos/" + photo_id + ".json",
            success: function() {
                tray.on_delete_photo(photo_id);
            },
            error: function() {
            }
        });

        //todo: if local photo, need to cancel from agent upload -- http://localhost:9090/albums/:album_id/photos/:photo_id/cancel_upload
    },

    on_delete_photo :function(photo_id) {
        for (var i in tray.album_photos) {
            if (tray.album_photos[i].id === photo_id) {
                tray.album_photos.splice(i, 1); //remove from photos list
                tray.repaint();
                break;
            }
        }
        filechooser.update_checkmarks();
    }
};

