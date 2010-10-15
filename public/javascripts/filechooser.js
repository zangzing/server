/* Filechooser
 ----------------------------------------------------------------------------- */
var filechooser = {

    imageloader: null,
    ancestors: [],
    roots: [],
    children: [],
    init: function() {

        filechooser.roots = [];


        //mac
        if(filechooser.is_mac()){

            //My Pictures
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders/fi9QaWN0dXJlcw==',
                    type: 'folder',
                    name: 'My Pictures',
                    classy: 'f_pictures'
                }
            );

            //iPhoto
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/iphoto/folders',
                    type: 'folder',
                    name: 'iPhoto',
                    classy: 'f_iphoto'
                }
            );


            //Picasa
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/picasa/folders',
                    type: 'folder',
                    name: 'Picasa',
                    classy: 'f_picasa'
                }
            );


            //My Home
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders/fg==',
                    type: 'folder',
                    name: 'My Home',
                    classy: 'f_home'
                }
            );

            //My Computer
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders/L1ZvbHVtZXM=',
                    type: 'folder',
                    name: 'My Computer',
                    classy: 'f_mycomputer'
                }
            );



        }






        //windows
        if(filechooser.is_windows()){

            //My Pictures
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM=',
                    type: 'folder',
                    name: 'My Pictures',
                    classy: 'f_pictures'
                }
            );


            //Picassa
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/picasa/folders',
                    type: 'folder',
                    name: 'iPicasa',
                    classy: 'f_picasa'
                }
            );

            //My Home
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders/fg==',
                    type: 'folder',
                    name: 'My Home',
                    classy: 'f_home'
                }
            );

            //My Computer
            filechooser.roots.push(
                {
                    open_url: 'http://localhost:9090/filesystem/folders',
                    type: 'folder',
                    name: 'My Computer',
                    classy: 'f_mycomputer'
                }
            );
        }


        //Shutterfly
        filechooser.roots.push(
            {
                open_url: '/shutterfly/folders.json',
                type: 'folder',
                name: 'Shutterfly',
                login_url: '/shutterfly/sessions/new',
                classy: 'f_shutterfly'
            }
        );

        //Kodak
        filechooser.roots.push(
            {
                open_url: '/kodak/folders.json',
                type: 'folder',
                name: 'Kodak',
                login_url:'/kodak/sessions/new',
                classy: 'f_kodak'
            }
        );        


        //SmugMug
        filechooser.roots.push(
            {
                open_url: '/smugmug/folders.json',
                type: 'folder',
                name: 'SmugMug',
                login_url: '/smugmug/sessions/new',
                classy: 'f_smugmug'
            }
        );


        //Facebook
        filechooser.roots.push(
            {
                open_url: '/facebook/folders.json',
                type: 'folder',
                name: 'Facebook',
                login_url: '/facebook/sessions/new',
                classy: 'f_facebook'
            }
        );

        //Flickr
        filechooser.roots.push(
            {
                open_url: '/flickr/folders.json',
                type: 'folder',
                name: 'Flickr',
                login_url: '/flickr/sessions/new',
                classy: 'f_flickr'
            }
        );


        //ZangZing
        filechooser.roots.push(
            {
                open_url: '/zangzing/folders.json',
                type: 'folder',
                name: 'ZangZing',
                classy: 'f_zangzing'
            }
        );


        $('#filechooser-back-button').click(filechooser.open_parent_folder);
        filechooser.ancestors = [],
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


    open_folder: function(name, url, login_url) {

        filechooser.ancestors.push({name:name, url:url, login_url:login_url});
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
        $('#filechooser').html('<img src="/images/loading.gif">');

        if (url == '') {

            filechooser.on_open_root();

        } else {

            if (url.indexOf('http://localhost:9090') === 0) {
                // if agent

                var user_session = $.cookie('user_credentials');
                url += '?session=' + user_session + '&callback=?';

                $.jsonp({
                    url: url,
                    success: function(json) {
                        filechooser.on_open_folder(json);
                    },
                    error: filechooser.on_error_opening_folder
                });

            } else {
                // on the server

                $.ajax({
                    dataType: 'json',
                    url: url,
                    success: function(json) {
                        filechooser.on_open_folder(json);
                    },
                    error: filechooser.on_error_opening_folder
                });
            }
        }
    },


    on_open_root : function(url) {
        filechooser.on_open_folder(filechooser.roots);
    },

    on_open_folder : function(children) {

        //unpack response
        if (children.body) {
            children = children.body;
        }

        filechooser.children = children

        //setup the imageloader -- if active, kill it
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        var onStartLoadingImage = function(id, src) {
            $('#' + id).attr('src', '/images/loading.gif');
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

        //unpack the jsonp resonse
        if (children.body) {
            children = children.body;
        }


        //build html for list of files/folders
        var html = '';
        for (var i in children) {

            if (children[i].type == 'folder') {

                var id = 'chooser-folder-' + i;
                var a_id = 'chooser-folder-a-' + i;

                var theClick = 'onclick="filechooser.open_folder(\'' + children[i].name + '\',\'' + children[i].open_url + '\',\'' + children[i].login_url + '\'); return false;"';
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
                html += '<img id="' + img_id + '" src="/images/loading.gif" '+ picture_view_handler +'>';
                html += '<figure ' + add_photo_handler + '>Add Photo</figure>';
                html += '<div class="checkmark"></div>';
                html += '</div>';
                html += children[i].name;
                html += '</li>';


                if (children[i].thumb_url.indexOf('http://localhost') === 0) {
                    filechooser.imageloader.add(img_id, children[i].thumb_url + '?session=' + $.cookie('user_credentials')); //extra business to auth with agent
                } else {
                    filechooser.imageloader.add(img_id, children[i].thumb_url);
                }
            }
        }

        $('#filechooser').html(html);

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
        var previous_image_handler = 'onclick="filechooser.picture_view(' + (i - 1) + ');return false;"';
        var next_image_handler = 'onclick="filechooser.picture_view(' + (i + 1) + ');return false;"';

        html += '<a href="" ' + previous_image_handler + '><img src="/images/btn-prev-photo.png"></a>';
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

            if (image_url.indexOf('http://localhost') === 0) {
                image_url += '?session=' + $.cookie('user_credentials'); //extra business to auth with agent
            }

            html += '<img src="'+ image_url +'" '+ grid_view_handler +'>';
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
        add_url += 'album_id=' + zang.zing.album_id;

        var after_animate = function(){
            if (add_url.indexOf('http://localhost:9090') === 0) {
				
                add_url += '&session=' + $.cookie('user_credentials') + '&callback=?';

                $.jsonp({
                    url: add_url,
                    success: function(json) {
                        filechooser.on_add_photos(json);
                    },
                    error: filechooser.on_error_adding_photos
                });
            } else {
                $.ajax({
                    dataType: 'json',
                    url: add_url,
                    success: function(json) {
                        filechooser.on_add_photos(json);
                    },
                    error: filechooser.on_error_adding_photos
                });
            }
        }


        zang.zing.image_pop(element_id, after_animate);

    },


    on_add_photos : function(json) {
        var photos;

        if (json.body) {
            //unpack response from agent
            photos = json.body
        }
        else {
            photos = json
        }

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
        filechooser.open_folder(parent.name, parent.url, parent.login_url);
    },


    on_error_opening_folder : function(error) {
        if (error.status === 401) {
            $('#filechooser').html('<h4>You need to log into your account before you can see this folder; click <a href="#" onClick="filechooser.open_login_window();return false;">here</a> to log in</h4>');
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
        filechooser.open_folder(current.name, current.url, current.login_url);
    }

};


/* Added Photos Tray
 ----------------------------------------------------------------------------- */
var tray = {

    imageloader : null,
    album_photos : [],

    reload : function() {
        var get_album_photos_url = '/albums/' + zang.zing.album_id + '/photos.json';
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
                    tray.imageloader.add(id, 'http://localhost:9090/albums/' +
                                             zang.zing.album_id + '/photos/' + photo.id + '.thumb' +
                                             '?session=' + $.cookie('user_credentials'));
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
        zang.init.tray();
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

