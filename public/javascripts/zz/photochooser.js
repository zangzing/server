/*!
 * photochooser.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
(function( $, undefined ) {

    $.widget( "ui.zz_photochooser", {
        options: {
        },

        stack:[],
        grid:null,
        
        _create: function() {
            var self = this;




            var template = $('<div class="photochooser">' +
                             '   <div class="photochooser-header">' +
                             '       <a class="back-button"><span>Back</span></a>' +
                             '       <h3>Folder Name</h3>' +
                             '       <h4>Choose pictures from folders on your computer or other photo sites</h4>' +
                             '   </div>' +
                             '   <div class="photochooser-body"></div>' +
                             '   <div class="photochooser-footer">' +
                             '     <div class="added-pictures-tray"></div>' +
                             '   </div>' +
                             '</div>');



            self.backButtonCaptionElement = template.find('.back-button span');
            self.backButtonElement = template.find('.back-button');
            self.folderNameElement = template.find('h3');
            self.bodyElement = template.find('.photochooser-body');


            self.element.html(template);


            self.backButtonElement.click(function(){
                self.goBack();
            });

            self.showRoots();

            self.init_tray();

        },


        callAgentOrServer : function(params){
            var url = params['url'];
            var success_handler = params['success'];
            var error_handler = params['error'];

            if (agent.isAgentUrl(url)) {
                url = agent.checkAddCredentialsToUrl(url);
                $.jsonp({
                    url: url,
                    success: function(json) {
                        if(json.headers.status == 200){
                            success_handler(json.body);
                        }
                        else{
                            error_handler(json);
                        }
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

        goBack: function(){
            var self = this;
            self.stack.pop(); //throw away current
            self.openFolder(self.stack.pop());
        },

        showRoots: function(){
            var self = this;

            self.openFolder({
                name: "Home",
                children: self.roots()
            });
        },

        openFolder: function(folder){
            var self = this;

            self.folderNameElement.html(folder.name);
            if(self.stack.length > 0){
                self.backButtonCaptionElement.html(_.last(self.stack).name);
                self.backButtonElement.show();
            }
            else{
                self.backButtonElement.hide();
            }

            self.stack.push(folder);



            self.bodyElement.html('<img class="progress-indicator" src="/images/loading.gif">');


            if(!_.isUndefined(folder.children)){
                self.showFolder(folder, folder.children);
            }
            else{
                self.callAgentOrServer({
                   url: folder.open_url,
                   success:function(json){
                       self.showFolder(folder, json);
                   },
                   error: function(error){
                       if(!_.isUndefined(folder.on_error)){
                           folder.on_error(error);
                       }
                       else{
                           alert('Sorry, there was a problem opening this folder. Please try again later.');
                       }
                   }
                });
            }
        },


        showFolder: function(folder, children){
            var self = this;



            //translate photos and folders from connector format to photo/photogrid format
            var hasPhotos = false;

            children = $.map(children, function(child, index){
                if(child.type === 'folder'){

                    //root level folders already have source set
                    if(typeof child.src === 'undefined'){
                        child.src = '/images/folders/blank_off.jpg';
                        child.rolloverSrc = '/images/folders/blank_on.jpg';
                    }
                }
                else{
                    child.src = agent.checkAddCredentialsToUrl(child.thumb_url);
                    child.id = child.source_guid;
                    hasPhotos = true;
                }

                child.caption = child.name;

                return child;
            });


            if(hasPhotos){
                var addAllButton = {
                    id: 'add-all-photos',
                    src: '/images/folders/add_all_photos.png',
                    caption: '',
                    type: 'folder', //todo: need new type for button..
                    add_url: folder.add_url
                };

                children.unshift(addAllButton);
            }


            var gridElement = $('<div class="photogrid"></div>');
            self.bodyElement.html(gridElement);

            self.grid = gridElement.zz_photogrid({
                photos:children,
                showThumbscroller:false,
                cellWidth: 190,
                cellHeight: 190,
                context: 'chooser-grid',
                onClickPhoto: function(index, photo, element, action){
                    if(photo.type === 'folder'){
                        if(photo.id === 'add-all-photos'){
                            self.add_folder_to_album(photo.add_url, element);
                        }
                        else{
                             self.openFolder(photo);
                        }
                    }
                    else{
                        if(action === 'main'){
                            if($(element).data().zz_photo.isChecked()){
                                self.remove_photo_by_guid(photo.id); //chooser photos have source_guid as their id
                            }
                            else{
                                self.add_photo_to_album(photo.add_url, element);
                            }
                        }
                        else if(action === 'magnify'){
                            if(hasPhotos){
                                children.shift(); //remove the 'add all photos' button
                            }
                            self.singlePictureView(folder, children, photo.id);
                        }
                    }
                }

            }).data().zz_photogrid;

            self.updateCheckmarks();

        },

        singlePictureView:function(folder, children, photoId){
            var self = this;

            children = $.map(children, function(child, index){
                child.previewSrc = agent.checkAddCredentialsToUrl(child.thumb_url);
                child.src = agent.checkAddCredentialsToUrl(child.screen_url);
                return child;
            });


            var template = $('<a class="prev-button"></a>' +
                             '<div class="singlepicture-wrapper">' +
                             '<div class="photogrid"></div>' +
                             '</div>' +
                             '<a class="next-button"></a>');
            
            var gridElement = template.find('.photogrid');
            self.bodyElement.html(template);

            self.grid = gridElement.zz_photogrid({
                photos:children,
                showThumbscroller:false,
                hideNativeScroller: true,
                cellWidth: 720,
                cellHeight: 500,
                singlePictureMode: true,
                currentPhotoId: photoId,
                context: 'chooser-picture',
                onClickPhoto: function(index, photo, element, action){
                    if(photo.type === 'folder'){
                        if(photo.id === 'add-all-photos'){
                            self.add_folder_to_album(photo.add_url, element);
                        }
                        else{
                             self.openFolder(photo);
                        }
                    }
                    else{
                        if(action === 'main'){
                            if($(element).data().zz_photo.isChecked()){
                                self.remove_photo_by_guid(photo.id); //chooser photos have source_guid as their id
                            }
                            else{
                                self.add_photo_to_album(photo.add_url, element);
                            }
                        }
                        else if(action === 'magnify'){
                            //reload current view to get back to grid
                            self.showFolder(folder, children);
                        }
                    }
                }

            }).data().zz_photogrid;

            self.updateCheckmarks();
            

            template.filter('.prev-button').click(function(){
                self.grid.previousPicture();
            });

            template.filter('.next-button').click(function(){
                self.grid.nextPicture();
            });


        },


        open_login_window : function(folder, login_url) {
            var self = this;
            oauthmanager.login(login_url, function(){
                self.openFolder(folder);
            });
        },



        roots: function(){
            var self = this;

            var roots = [];


            var file_system_on_error = function(error){
                if(typeof(error.status) === 'undefined'){
                    self.bodyElement.hide().load(pages.no_agent.url, function(){
                        pages.no_agent.init_from_filechooser(function(){});
                        self.bodyElement.fadeIn('fast');
                    });
                }
                else if(error.status === 401){
                    self.bodyElement.hide().load('/static/connect_messages/wrong_agent_account.html', function(){
                        self.bodyElement.fadeIn('fast');
                    });
                }
                else if(error.status === 500){
                    self.bodyElement.hide().load('/static/connect_messages/general_agent_error.html', function(){
                        self.bodyElement.fadeIn('fast');
                    });
                }
            }

            var picasa_on_error = file_system_on_error;

            var iphoto_on_error = file_system_on_error;


            //mac

            if(navigator.appVersion.indexOf("Mac")!=-1){

                //My Pictures
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/fi9QaWN0dXJlcw=='),
                    type: 'folder',
                    name: 'My Pictures',
                    on_error: file_system_on_error,
                    src: '/images/folders/mypictures_off.jpg',
                    rolloverSrc: '/images/folders/mypictures_on.jpg',
                    state: 'ready'
                });

                //iPhoto
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/iphoto/folders'),
                    type: 'folder',
                    name: 'iPhoto',
                    on_error: iphoto_on_error,
                    src: '/images/folders/iphoto_off.jpg',
                    rolloverSrc: '/images/folders/iphoto_on.jpg',
                    state: 'ready'
                });


                //Picasa
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/picasa/folders'),
                    type: 'folder',
                    name: 'Picasa',
                    on_error: picasa_on_error,
                    src: '/images/folders/picasa_off.jpg',
                    rolloverSrc: '/images/folders/picasa_on.jpg',
                    state: 'ready'
                });


                //My Home
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                    type: 'folder',
                    name: 'My Home',
                    on_error: file_system_on_error,
                    src: '/images/folders/myhome_off.jpg',
                    rolloverSrc: '/images/folders/myhome_on.jpg',
                    state: 'ready'
                });

                //My Computer
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/L1ZvbHVtZXM='),
                    type: 'folder',
                    name: 'My Computer',
                    on_error: file_system_on_error,
                    src: '/images/folders/mycomputer_off.jpg',
                    rolloverSrc: '/images/folders/mycomputer_on.jpg',
                    state: 'ready'
                });
            }






            //windows
            if(navigator.appVersion.indexOf("Win")!=-1){

                //My Pictures
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM='),
                    type: 'folder',
                    name: 'My Pictures',
                    on_error: file_system_on_error,
                    src: '/images/folders/mypictures_off.jpg',
                    rolloverSrc: '/images/folders/mypictures_on.jpg',
                    state: 'ready'
                });


                //Picassa
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/picasa/folders'),
                    type: 'folder',
                    name: 'Picasa',
                    on_error: picasa_on_error,
                    src: '/images/folders/picasa_off.jpg',
                    rolloverSrc: '/images/folders/picasa_on.jpg',
                    state: 'ready'
                });

                //My Home
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/fg=='),
                    type: 'folder',
                    name: 'My Home',
                    on_error: file_system_on_error,
                    src: '/images/folders/myhome_off.jpg',
                    rolloverSrc: '/images/folders/myhome_on.jpg',
                    state: 'ready'
                });

                //My Computer
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders'),
                    type: 'folder',
                    name: 'My Computer',
                    on_error: file_system_on_error,
                    src: '/images/folders/mycomputer_off.jpg',
                    rolloverSrc: '/images/folders/mycomputer_on.jpg',
                    state: 'ready'

                });
            }


            //Facebook
            roots.push(
            {
                open_url: zz.path_prefix + '/facebook/folders.json',
                type: 'folder',
                name: 'Facebook',
                src: '/images/folders/facebook_off.jpg',
                rolloverSrc: '/images/folders/facebook_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_facebook.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/facebook/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });

            //Shutterfly
            roots.push(
            {
                open_url: zz.path_prefix + '/shutterfly/folders.json',
                type: 'folder',
                name: 'Shutterfly',
                src: '/images/folders/shutterfly_off.jpg',
                rolloverSrc: '/images/folders/shutterfly_on.jpg',

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_shutterfly.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/shutterfly/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });

            //Kodak
            roots.push(
            {
                open_url: zz.path_prefix + '/kodak/folders.json',
                type: 'folder',
                name: 'Kodak',
                src: '/images/folders/kodak_off.jpg',
                rolloverSrc: '/images/folders/kodak_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_kodak.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/kodak/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //SmugMug
            roots.push(
            {
                open_url: zz.path_prefix + '/smugmug/folders.json',
                type: 'folder',
                name: 'SmugMug',
                src: '/images/folders/smugmug_off.jpg',
                rolloverSrc: '/images/folders/smugmug_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_smugmug.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/smugmug/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });



            //Flickr
            roots.push(
            {
                open_url: zz.path_prefix + '/flickr/folders.json',
                type: 'folder',
                name: 'Flickr',
                src: '/images/folders/flickr_off.jpg',
                rolloverSrc: '/images/folders/flickr_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_flickr.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/flickr/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //Picasa Web
            roots.push(
            {
                open_url: zz.path_prefix + '/picasa/folders.json',
                type: 'folder',
                name: 'Picasa Web',
                src: '/images/folders/picasa_off.jpg',
                rolloverSrc: '/images/folders/picasa_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_picasa_web.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/picasa/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Photobucket
            roots.push(
            {
                open_url: zz.path_prefix + '/photobucket/folders', //No need for .json cause this connector has unusual structure
                type: 'folder',
                name: 'Photobucket',
                src: '/images/folders/photobucket_off.jpg',
                rolloverSrc: '/images/folders/photobucket_on.jpg',

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_photobucket.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.path_prefix + '/photobucket/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //ZangZing
            roots.push(
            {
                open_url: zz.path_prefix + '/zangzing/folders.json',
                type: 'folder',
                name: 'ZangZing',
                src: '/images/folders/zangzing_off.jpg',
                rolloverSrc: '/images/folders/zangzing_on.jpg'
            });

            return roots;

        },

        updateCheckmarks: function(){
            var self = this;
            //remove all checkmarks
            $.each(self.grid.cells(),function(index, cell){
                $(cell).data().zz_photo.setChecked(false);
            });
            

            //add back the ones we need
            $.each(self.tray_photos, function(index, photo){
                logger.debug(photo.source_guid);
                var cell = self.grid.cellForId(photo.source_guid);
                if(cell){
                    cell.data().zz_photo.setChecked(true);

                }
            });
        },


        tray_widget: null,
        tray_photos: [],
        tray_element: null,

        init_tray: function(){
            var self = this;
            self.tray_element = self.element.find(".added-pictures-tray")
            self.tray_widget =  self.tray_element.zz_thumbtray({
                    photos:[],
                    allowDelete:true,
                    allowSelect:false,

                    onDeletePhoto:function(index, photo){
                        self.remove_photo(photo.id);
                    }
            }).data().zz_thumbtray;

            self.reload_tray();

        },

        remove_photo_by_guid: function(photo_guid){
            var self = this;

            var photo = _.detect(self.tray_photos, function(photo){
                return photo.source_guid == photo_guid;
            });

            if(photo){
                self.remove_photo(photo.id);
            }
        },

        remove_photo:function(photo_id){
            var self = this;

            $.ajax({
                type: "DELETE",
                dataType: "json",
                url: zz.path_prefix + "/photos/" + photo_id + ".json",
                success:function(){
                    self.reload_tray();
                },

                error: function(error){
                    logger.debug(error);
                }
            });

        },

        reload_tray : function() {
            var self = this;
            $.ajax({
                dataType: 'json',
                url: zz.path_prefix + '/albums/' + zz.album_id + '/photos_json?' + (new Date()).getTime(),  //force browser cache miss
                success: function(photos){
                    
                    self.tray_photos = _.filter(photos, function(photo){
                        return zz.current_user_id == photo.user_id; //only show photos uploaded by this user
                    });
                    
                    self.tray_widget.setPhotos(self.map_photos(self.tray_photos));
                    self.updateCheckmarks();
                }

            });
        },

        add_photo_to_album: function(add_url, element){
            var self = this;
            self.animate_to_tray(element, function(){
                self.add_to_album(add_url);
            });
            element.data().zz_photo.setChecked(true);

        },

        add_folder_to_album: function(add_url, element){
            var self = this;
            self.animate_to_tray(element, function(){
                self.add_to_album(add_url);
            });

            $.each(self.grid.cells(), function(index, element){
                $(element).data().zz_photo.setChecked(true);
            });
            
        },

        animate_to_tray: function(element, callback){
            var self = this;

            var imageElement = element.find('.photo-image');


            var start_top = imageElement.offset().top;
            var start_left = imageElement.offset().left;

            var end_top = self.tray_element.offset().top;
            var end_left = self.tray_next_thumb_offset_x();


            var on_finish_animation = function(){
                callback();
                $(this).remove();
            }

            imageElement.clone()
                    .css({position: 'absolute', zIndex: 2000, left: start_left, top: start_top,border:'1px solid #ffffff'})
                    .appendTo('body')
                    .addClass('animate-photo-to-tray')
                    .animate({
                        width: '20px',
                        height: '20px',
                        top: (end_top) +'px',
                        left: (end_left) +'px'
                    }, 1000, 'easeInOutCubic', on_finish_animation);



        },

        add_to_album: function(add_url){
            var self = this;

            add_url += (add_url.indexOf('?') == -1) ? '?' : '&'
            add_url += 'album_id=' + zz.album_id;

            self.tray_widget.showLoadingIndicator();
            self.callAgentOrServer({
                url: add_url,
                success: function(photos) {
                    self.tray_photos = self.tray_photos.concat(photos);
                    self.tray_widget.setPhotos(self.map_photos(self.tray_photos));
                    self.tray_widget.hideLoadingIndicator();
                },
                error: function(error){
                    self.tray_widget.hideLoadingIndicator();
                    alert('Sorry, there was a problem adding photos to your album. Please try again.');
                    logger.debug(error);

    //                $.jGrowl("" + error);
                }
            });

        },



        get_photos: function(){
            return self.tray_photos;
        },

        map_photos:function(photos){
            if(! $.isArray(photos)){
                var photos = [photos];
            }

            photos = $.map(photos, function(photo, index){
                var id = photo.id;
                var src = photo.thumb_url;

                src = agent.checkAddCredentialsToUrl(src);

                return {id:id, src:src};
            });

            return photos;
        },

        tray_next_thumb_offset_x: function(){
            return this.tray_widget.nextThumbOffsetX();
        }


    });
})( jQuery );