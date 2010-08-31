/* Filechooser
 ----------------------------------------------------------------------------- */


var filechooser = {

    imageloader: null,
    ancestors: [],
    roots: [
        {
            open_url: 'http://localhost:9090/iphoto/folders',
            type: 'folder',
            name: 'iPhoto',
            class: 'f_iphoto'
        },
        {
            open_url: 'http://localhost:9090/filesystem/folders',
            type: 'folder',
            name: 'My Computer',
            class: 'f_mycomputer'
        },
        {
            open_url: 'http://localhost:9090/filesystem/folders/fg==',
            type: 'folder',
            name: 'My Home',
            class: 'f_home'
        },
        {
            open_url: '/facebook/folders.json',
            type: 'folder',
            name: 'Facebook',
            login_url: '/facebook/sessions/new',
            class: 'f_facebook'
        },
        {
            open_url: '/flickr/folders.json',
            type: 'folder',
            name: 'Flickr',
            login_url: '/flickr/sessions/new',
            class: 'f_flickr'
        },
        {
            open_url: '/kodak/folders.json',
            type: 'folder',
            name: 'Kodak',
            login_url:'/kodak/sessions/new',
            class: 'f_kodak'
        },
        {
            open_url: '/smugmug/folders.json',
            type: 'folder',
            name: 'SmugMug',
            login_url: '/smugmug/sessions/new',
            class: 'f_smugmug'
        },
        {
            open_url: '/shutterfly/folders.json',
            type: 'folder',
            name: 'Shutterfly',
            login_url: '/shutterfly/sessions/new',
            class: 'f_shutterfly'
        }
    ],

    init: function() {
        $('#filechooser-back-button').click(filechooser.open_parent_folder);
        filechooser.open_root();
        tray.reload();
    },


    open_root: function() {
        filechooser.open_folder('Home', '', '');
    },

    open_folder: function(name, url, login_url) {

        filechooser.ancestors.push({name:name, url:url, login_url:login_url});
        //update title and back button
        if (filechooser.ancestors.length > 1) {
            $('#filechooser-back-button').html(filechooser.ancestors[filechooser.ancestors.length - 2].name);
        } else {
            $('#filechooser-back-button').html('');
        }

        $('#filechooser-title').html(name);

        //update files
        $('#filechooser').html('<img src="/images/loading.gif"> Loading ...');

        if (url == '') {

            filechooser.on_open_root(name, url);

        } else {

            if (url.indexOf('http://localhost:9090') === 0) {
                // if agent

                var user_session = $.cookie('user_credentials');
                url += '?session=' + user_session + '&callback=?';

                $.jsonp({
                    url: url,
                    success: function(json) {
                        filechooser.on_open_folder(name, url, json);
                    },
                    error: filechooser.on_error_opening_folder
                });

            } else {
                // on the server

                $.ajax({
                    dataType: 'json',
                    url: url,
                    success: function(json) {
                        filechooser.on_open_folder(name, url, json);
                    },
                    error: filechooser.on_error_opening_folder
                });
            }
        }
    },


    on_open_root : function(name, url) {
        filechooser.on_open_folder(name, url, filechooser.roots);
    },

    on_open_folder : function(name, url, children) {

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
              //console.log('tall');
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
              //console.log(guuu);
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
                html += '<li id="' + id + '" class="' + children[i].class + '">';

                html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';

                if (children[i].add_url) {
                    html += '&nbsp;<a href="#" onclick="filechooser.add_folder(\'' + children[i].add_url + '\', \'' + id + '\'); return false;">(+)</a>';
                }

                html += '</li>';

            } else {
//                var id = 'chooser-photo-' + children[i].source_guid;
                var img_id = 'chooser-photo-img-' + children[i].source_guid;
                var theClick = 'onclick="filechooser.add_photos(\'' + children[i].add_url + '\', \'' + img_id + '\'); return false;"';                
                html += '<li id="photo-' + children[i].source_guid + '" class="photo" ' + theClick + '>';
                html += '<div class="relative">'
                html += '<img id="' + img_id + '" src="">';
                html += '<figure>Add Photo</figure>';
                html += '<div class="checkmark"></div>';
                html += '</div>';
                html += '<a href="" ' + theClick + '>' + children[i].name + '</a>';
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


    update_checkmarks : function(){

        //uncheck all
        $('li').removeClass('in-tray');

        //check the ones in the tray
        for(var i in tray.album_photos){
            $("li#photo-" + tray.album_photos[i].source_guid).addClass('in-tray');
        }

    },

    add_photos : function(add_url, element_id) {

        add_url += '?album_id=' + zz.zang.album_id;

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


        zz.zang.image_pop(element_id);

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
            $('#filechooser').html('you need to log into your account before you can see this folder; click <a href="#" onClick="filechooser.open_login_window();return false;">here</a> to log in');
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
        var get_album_photos_url = '/albums/' + zz.zang.album_id + '/photos.json';
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
        };

        tray.imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);

        var html = '';
        for (var i in tray.album_photos) {
            var photo = tray.album_photos[i];
            
            var id = 'tray-' + photo.id;

            html += '<li>';
            html += '<div><img height="30" width="30" id="' + id + '" src=""></div>';
            html += '<a href="" onclick="tray.delete_photo(\'' + photo.id + '\'); return false;">(x)</a>';
            html += '</li>';

            if (photo.agent_id) {          //todo: need to check that agent id matches local agent
                //was uploaded from agent
                if (photo.state == 'ready') {
                    tray.imageloader.add(id, photo.thumb_url);
                } else {
                    tray.imageloader.add(id, 'http://localhost:9090/albums/' +
                                             zz.zang.album_id + '/photos/' + photo.id + '.thumb' +
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

