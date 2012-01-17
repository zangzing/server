var zz = zz || {};

zz.photochooser = {
    open_in_dialog: function(album_id, on_close) {

        var widget = null;

        var template = $('<div class="photochooser-container"></div>');
        $('<div id="add-photos-dialog"></div>').html(template).zz_dialog({
            height: $(document).height() - 70,
            width: 895,
            modal: true,
            autoOpen: true,
            open: function(event, ui) {
                widget = template.zz_photochooser({album_id: album_id}).data().zz_photochooser;
            },
            close: function(event, ui) {
                widget.destroy();

                $.ajax({
                    url: zz.routes.path_prefix + '/albums/' + album_id + '/close_batch',
                    complete: function(request, textStatus) {
                        zz.logger.debug('Batch closed because Add photos dialog was closed. Call to close_batch returned with status= ' + textStatus);
                    },
                    success: function() {
                        if (on_close) {
                            on_close();
                        }
                    }
                });
            }
        });
        template.height($(document).height() - 62);
    }
};


(function($, undefined) {

    $.widget('ui.zz_photochooser', {
        options: {
            album_id: null
        },

        stack: [],
        grid: null,
        destroyed: false,

        _create: function() {
            var self = this;


            var template = $('<div class="photochooser">' +
                    '   <div class="photochooser-body"></div>' +
                    '   <div class="photochooser-header">' +
                    '       <a class="back-button"><span>Back</span></a>' +
                    '       <h3>Folder Name</h3>' +
                    '       <h4>Choose pictures from folders on your computer or other photo sites</h4>' +
                    '   </div>' +
                    '   <div class="photochooser-footer">' +
                    '     <div class="added-pictures-tray"></div>' +
                    '     <div class="added-pictures-tab"></div>' +
                    '   </div>' +
                    '</div>');


            self.backButtonCaptionElement = template.find('.back-button span');
            self.backButtonElement = template.find('.back-button');
            self.folderNameElement = template.find('h3');
            self.bodyElement = template.find('.photochooser-body');


            self.element.html(template);


            self.backButtonElement.click(function() {
                //hack: in case these were hidden by the download agent dialog...
                $('.photochooser-header h3').show();
                $('.photochooser-header h4').show();

                self.goBack();
            });

            self.showRoots();

            self.init_tray();

        },


        destroy: function() {
            this.destroyed = true;
            $.Widget.prototype.destroy.apply(this, arguments);
        },


        callAgentOrServer: function(params) {
            var url = params['url'];
            var success_handler = params['success'];
            var error_handler = params['error'];

            if (zz.agent.isAgentUrl(url)) {
                url = zz.agent.checkAddCredentialsToUrl(url);
                $.jsonp({
                    url: url,
                    success: function(json) {
                        if (json.headers.status == 200) {
                            success_handler(json.body);
                        }
                        else {
                            error_handler(json);
                        }
                    },
                    error: error_handler
                });
            }
            else {
                zz.async_ajax.get(url, success_handler, error_handler);
            }
        },





        goBack: function() {
            var self = this;
            self.stack.pop(); //throw away current
            self.openFolder(self.stack.pop());
        },

        showRoots: function() {
            var self = this;

            self.openFolder({
                name: 'Home',
                children: self.roots()
            });
        },

        openFolder: function(folder) {
            var self = this;

            self.folderNameElement.text(folder.name);
            if (self.stack.length > 0) {
                self.backButtonCaptionElement.text(_.last(self.stack).name);
                self.backButtonElement.show();
            }
            else {
                self.backButtonElement.hide();
            }

            self.stack.push(folder);


            self.bodyElement.html('<img class="progress-indicator" src="' + zz.routes.image_url('/images/loading.gif') + '">');


            if (_.isArray(folder.children)) {
                self.showFolder(folder, folder.children);
            }
            else if (_.isFunction(folder.children)) {
                folder.children(function(children) {
                    self.showFolder(folder, children);
                });
            }
            else {
                self.callAgentOrServer({
                    url: folder.open_url,
                    success: function(children) {
                        folder.children = children; //store children for going 'back'
                        self.showFolder(folder, children);
                    },
                    error: function(error) {
                        if (!_.isUndefined(folder.on_error)) {
                            folder.on_error(error);
                        }
                        else {
                            alert('Sorry, there was a problem opening this folder. Please try again later.');
                        }
                    }
                });
            }
        },


        showFolder: function(folder, children) {
            var self = this;

            if (! children.length) {

                self.bodyElement.html('<div class="no-photos">There are no photos in this folder</div>');


            }
            else {

                //translate photos and folders from connector format to photo/photogrid format
                var hasPhotos = false;

                children = $.map(children, function(child, index) {
                    if (child.type === 'folder') {

                        //root level folders already have source set
                        if (typeof child.src === 'undefined') {
                            child.src = zz.routes.image_url('/images/folders/blank_off.jpg');
                            child.rolloverSrc = zz.routes.image_url('/images/folders/blank_on.jpg');
                        }
                    }
                    else {
                        child.src = zz.agent.checkAddCredentialsToUrl(child.thumb_url);
                        child.id = child.source_guid;
                        hasPhotos = true;
                    }

                    child.caption = child.name;

                    return child;
                });



                var gridElement = $('<div class="photogrid"></div>');
                self.bodyElement.html(gridElement);

                self.grid = gridElement.zz_photogrid({
                    photos: children,
                    showThumbscroller: false,
                    addAllButton: hasPhotos, //if the folder has photos, add an addAllButton
                    cellWidth: 190,
                    cellHeight: 190,
                    context: 'chooser-grid',
                    onClickPhoto: function(index, photo, element, action) {
                        if (photo.type === 'folder') {
                            self.openFolder(photo);
                        }
                        else {
                            if (action === 'main') {
                                if ($(element).data().zz_photo.isChecked()) {
                                    self.remove_photo_by_guid(photo.id); //chooser photos have source_guid as their id
                                }
                                else {
                                    self.add_photo_to_album(photo.add_url, element);
                                }
                            }
                            else if (action === 'magnify') {
                                if (hasPhotos) {
                                    children.shift(); //remove the 'add all photos' button
                                }
                                self.singlePictureView(folder, children, photo.id);
                            }
                        }
                    }

                }).data().zz_photogrid;

                if (hasPhotos) {
                    var addAllButton = $('<img class="add-all-button" src="' + zz.routes.image_url('/images/folders/add_all_photos.png') + '">');
                    addAllButton.click(function() {
                        self.add_folder_to_album(folder.add_url, addAllButton);
                    });

                    $('.photochooser .photochooser-body .photogrid').append(addAllButton);
                }

                self.updateCheckmarks();
            }

        },

        singlePictureView: function(folder, children, photoId) {
            var self = this;

            children = $.map(children, function(child, index) {
                child.previewSrc = zz.agent.checkAddCredentialsToUrl(child.thumb_url);
                child.src = zz.agent.checkAddCredentialsToUrl(child.screen_url);
                return child;
            });


            var template = $('<a class="prev-button"></a>' +
                    '<div class="singlepicture-wrapper">' +
                    '<div class="photogrid"></div>' +
                    '</div>' +
                    '<a class="next-button"></a>');


            var gridElement = template.find('.photogrid');
            self.bodyElement.html(template);


            template.filter('.next-button').css({
                top: (self.bodyElement.height() / 2) - 36
            });

            template.filter('.prev-button').css({
                top: (self.bodyElement.height() / 2) - 36
            });


            self.grid = gridElement.zz_photogrid({
                photos: children,
                showThumbscroller: false,
                hideNativeScroller: true,
                cellWidth: 720,
                cellHeight: self.element.parent().height() - 130,
                singlePictureMode: true,
                currentPhotoId: photoId,
                context: 'chooser-picture',
                lazyLoadThreshold: 0,
                onClickPhoto: function(index, photo, element, action) {
                    if (photo.type === 'folder') {
                        self.openFolder(photo);
                    }
                    else {
                        if (action === 'main') {
                            if ($(element).data().zz_photo.isChecked()) {
                                self.remove_photo_by_guid(photo.id); //chooser photos have source_guid as their id
                            }
                            else {
                                self.add_photo_to_album(photo.add_url, element);
                            }
                        }
                        else if (action === 'magnify') {
                            //reload current view to get back to grid
                            self.showFolder(folder, children);
                        }
                    }
                }

            }).data().zz_photogrid;

            self.updateCheckmarks();


            template.filter('.prev-button').click(function() {
                self.grid.previousPicture();
            });

            template.filter('.next-button').click(function() {
                self.grid.nextPicture();
            });


        },


        show_download_agent_or_simple_upload: function() {
            var self = this;

            ZZAt.track('simple_or_agent.view');

            $('.photochooser-header h3').hide();
            $('.photochooser-header h4').hide();

            var template = $('<div class="choose-simple-or-download">' +
                    '<h1>Use the simple uploader</h1>' +
                    '<div class="simple-uploader-button-wrapper">' +
                    '<a id="simple-uploader-button" class="black-button"><span>Simple Uploader</span></a>' +
                    '<div id="simple-uploader-flash-wrapper"></div>' +
                    '</div>' +
                    '<div class="or"></div>' +
                    '<h1>Download our free desktop uploader</h1>' +
                    '<div><a id="download-zangzing-button" class="green-download-button"><span>Download</span></a></div>' +
                    '<div class="learn-more"><a id="learn-more-link">Learn more about uploading your photos to ZangZing</a></div>' +
                    '</div>');

            template.find('#simple-uploader-button').click(function() {
                alert('The simple uploader requries the Flash.\n Please download and install from http://get.adobe.com/flashplayer.');
            });

            template.find('#download-zangzing-button').click(function() {
                zz.pages.download_agent.dialog(function() {
                    self.openFolder(self.stack.pop());
                    $('.photochooser-header h3').show();
                    $('.photochooser-header h4').show();
                }, true);
            });

            template.find('#learn-more-link').click(function() {
                ZZAt.track('simple_or_agent.learn_more.click');
                window.open('http://help.zangzing.com/entries/20144013-simple-photo-uploader-and-desktop-photo-uploader');
            });


            self.bodyElement.html(template);
            self.bodyElement.fadeIn('fast');


            zz.simple_uploader.instance($('#simple-uploader-flash-wrapper'), self.options.album_id, function(photos_uploaded) {
                var on_finished = function() {
                    self.reload_tray();
                    self.goBack();
                    $('.photochooser-header h3').show();
                    $('.photochooser-header h4').show();
                }


                if (photos_uploaded > 0) {
                    var dialog = self.show_processing_photos_dialog();
                    setTimeout(function() {
                        on_finished();
                        dialog.close();
                    }, 5000);
                }
                else {
                    on_finished();
                }

            });


        },

        open_login_window: function(folder, login_url) {
            var self = this;
            zz.oauthmanager.login(login_url, function() {
                self.openFolder(folder);
            });
        },



        roots: function() {
            var self = this;

            var roots = [];


            var file_system_on_error = function(error) {
                self.show_download_agent_or_simple_upload();
                self.bodyElement.fadeIn('fast');
            };

            var picasa_on_error = file_system_on_error;

            var iphoto_on_error = file_system_on_error;


            //My Computer for Win and Mac
            if (navigator.appVersion.indexOf('Mac') != -1 || navigator.appVersion.indexOf('Win') != -1 || navigator.platform.indexOf('Linux') != -1) {

                roots.push(
                {
                    type: 'folder',
                    name: 'My Computer',
                    on_error: file_system_on_error,
                    src: zz.routes.image_url('/images/folders/mycomputer_off.jpg'),
                    rolloverSrc: zz.routes.image_url('/images/folders/mycomputer_on.jpg'),
                    state: 'ready',

                    children: function(callback) {

                        var children = [];

                        if (navigator.appVersion.indexOf('Mac') != -1) {

                            children = [
                                //My Pictures
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders/fi9QaWN0dXJlcw=='),
                                    add_url: zz.agent.buildAgentUrl('/filesystem/folders/fi9QaWN0dXJlcw==/add_to_album'),
                                    type: 'folder',
                                    name: 'My Pictures',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/mypictures_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/mypictures_on.jpg'),
                                    state: 'ready'
                                },

                                //My Home
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders/fg=='),
                                    add_url: zz.agent.buildAgentUrl('/filesystem/folders/fg==/add_to_album'),
                                    type: 'folder',
                                    name: 'My Home',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/myhome_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/myhome_on.jpg'),
                                    state: 'ready'
                                },

                                //My Computer
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders/L1ZvbHVtZXM='),
                                    type: 'folder',
                                    name: 'My Computer',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/mycomputer_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/mycomputer_on.jpg'),
                                    state: 'ready'
                                }

                            ];
                        }

                        else {

                            children = [
                                //My Pictures
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM='),
                                    add_url: zz.agent.buildAgentUrl('/filesystem/folders/flxNeSBEb2N1bWVudHNcTXkgUGljdHVyZXM=/add_to_album'),
                                    type: 'folder',
                                    name: 'My Pictures',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/mypictures_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/mypictures_on.jpg'),
                                    state: 'ready'
                                },

                                //My Home
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders/fg=='),
                                    add_url: zz.agent.buildAgentUrl('/filesystem/folders/fg==/add_to_album'),
                                    type: 'folder',
                                    name: 'My Home',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/myhome_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/myhome_on.jpg'),
                                    state: 'ready'
                                },

                                //My Computer
                                {
                                    open_url: zz.agent.buildAgentUrl('/filesystem/folders'),
                                    type: 'folder',
                                    name: 'My Computer',
                                    on_error: file_system_on_error,
                                    src: zz.routes.image_url('/images/folders/mycomputer_off.jpg'),
                                    rolloverSrc: zz.routes.image_url('/images/folders/mycomputer_on.jpg'),
                                    state: 'ready'
                                }
                            ];

                        }

                        zz.agent.getStatus(function(status) {
                            if (status == zz.agent.STATUS.READY) {
                                callback(children);
                            }
                            else {
                                file_system_on_error();
                            }
                        });
                    }
                });

            }


            //mac
            if (navigator.appVersion.indexOf('Mac') != -1) {

                //iPhoto
                roots.push(
                {
                    open_url: zz.agent.buildAgentUrl('/iphoto/folders'),
                    type: 'folder',
                    name: 'iPhoto',
                    on_error: iphoto_on_error,
                    src: zz.routes.image_url('/images/folders/iphoto_off.jpg'),
                    rolloverSrc: zz.routes.image_url('/images/folders/iphoto_on.jpg'),
                    state: 'ready'
                });


                //Picasa
                roots.push(
                {
                    open_url: zz.agent.buildAgentUrl('/picasa/folders'),
                    type: 'folder',
                    name: 'Picasa',
                    on_error: picasa_on_error,
                    src: zz.routes.image_url('/images/folders/picasa_off.jpg'),
                    rolloverSrc: zz.routes.image_url('/images/folders/picasa_on.jpg'),
                    state: 'ready'
                });
            }


            //windows
            if (navigator.appVersion.indexOf('Win') != -1) {

                //Picassa
                roots.push(
                {
                    open_url: zz.agent.buildAgentUrl('/picasa/folders'),
                    type: 'folder',
                    name: 'Picasa',
                    on_error: picasa_on_error,
                    src: zz.routes.image_url('/images/folders/picasa_off.jpg'),
                    rolloverSrc: zz.routes.image_url('/images/folders/picasa_on.jpg'),
                    state: 'ready'
                });
            }


            //Facebook
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/facebook/folders.json',
                type: 'folder',
                name: 'Facebook',
                src: zz.routes.image_url('/images/folders/facebook_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/facebook_on.jpg'),
                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_facebook.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/facebook/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Flickr
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/flickr/folders.json',
                type: 'folder',
                name: 'Flickr',
                src: zz.routes.image_url('/images/folders/flickr_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/flickr_on.jpg'),
                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_flickr.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/flickr/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //Instagram
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/instagram/folders.json',
                type: 'folder',
                name: 'Instagram',
                src: zz.routes.image_url('/images/folders/instagram_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/instagram_on.jpg'),

                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_instagram.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/instagram/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //Picasa Web
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/google/folders.json',
                type: 'folder',
                name: 'Picasa Web',
                src: zz.routes.image_url('/images/folders/picasa_web_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/picasa_web_on.jpg'),
                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_picasa_web.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/google/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Shutterfly
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/shutterfly/folders.json',
                type: 'folder',
                name: 'Shutterfly',
                src: zz.routes.image_url('/images/folders/shutterfly_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/shutterfly_on.jpg'),

                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_shutterfly.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/shutterfly/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });

            //Kodak
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/kodak/folders.json',
                type: 'folder',
                name: 'Kodak',
                src: zz.routes.image_url('/images/folders/kodak_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/kodak_on.jpg'),
                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_kodak.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/kodak/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //SmugMug
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/smugmug/folders.json',
                type: 'folder',
                name: 'SmugMug',
                src: zz.routes.image_url('/images/folders/smugmug_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/smugmug_on.jpg'),
                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_smugmug.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/smugmug/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Photobucket
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/photobucket/folders', //No need for .json cause this connector has unusual structure
                type: 'folder',
                name: 'Photobucket',
                src: zz.routes.image_url('/images/folders/photobucket_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/photobucket_on.jpg'),
                add_url: zz.routes.path_prefix + '/photobucket/folders/import?album_path=/', //unlike other connectors, photobucket may have photos at the root level

                on_error: function() {
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_photobucket.html', function() {
                        self.bodyElement.find('#connect-button').click(function() {
                            self.open_login_window(folder, zz.routes.path_prefix + '/photobucket/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });



            //Dropbox
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/dropbox/folders', //No need for .json cause this connector has unusual structure
                type: 'folder',
                name: 'Dropbox',
                src: zz.routes.image_url('/images/folders/dropbox_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/dropbox_on.jpg'),
                add_url: zz.routes.path_prefix + "/dropbox/folders/import?path=/", //unlike other connectors, dropbox may have photos at the root level

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_dropbox.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.routes.path_prefix + '/dropbox/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });

            //Mobile.me
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/mobileme/folders.json',
                type: 'folder',
                name: 'MobileMe',
                src: zz.routes.image_url('/images/folders/mobileme_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/mobileme_on.jpg'),
                //add_url: zz.routes.path_prefix + "/mobileme/folders/import?path=/",

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_mobileme.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, zz.routes.path_prefix + '/mobileme/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //ZangZing
            roots.push(
            {
                open_url: zz.routes.path_prefix + '/zangzing/folders.json',
                type: 'folder',
                name: 'ZangZing',
                src: zz.routes.image_url('/images/folders/zangzing_off.jpg'),
                rolloverSrc: zz.routes.image_url('/images/folders/zangzing_on.jpg')
            });


            return roots;

        },

        updateCheckmarks: function() {
            var self = this;
            //remove all checkmarks
            $.each(self.grid.cells(), function(index, cell) {
                $(cell).data().zz_photo.setChecked(false);
            });


            //add back the ones we need
            $.each(self.tray_photos, function(index, photo) {
                var cell = self.grid.cellForId(photo.source_guid);
                if (cell) {
                    cell.data().zz_photo.setChecked(true);

                }
            });
        },


        tray_widget: null,
        tray_photos: [],
        tray_element: null,

        init_tray: function() {
            var self = this;
            self.tray_element = self.element.find('.added-pictures-tray');
            self.tray_widget = self.tray_element.zz_thumbtray({
                photos: [],
                allowDelete: true,
                allowSelect: false,

                onDeletePhoto: function(index, photo) {
                    self.remove_photo(photo.id);
                }
            }).data().zz_thumbtray;

            self.reload_tray();

        },

        remove_photo_by_guid: function(photo_guid) {
            var self = this;


            //since there is no animation to tell user that something is
            //happening, its important to remove check right away
            //var cell = self.grid.cellForId(photo_guid);
            //if(cell){
            //    cell.data().zz_photo.setChecked(false);
            //}


            var photo = _.detect(self.tray_photos, function(photo) {
                return photo.source_guid == photo_guid;
            });

            if (photo) {
                self.remove_photo(photo.id);
            }
        },

        remove_photo: function(photo_id) {
            var self = this;

            $.ajax({
                type: 'POST',
                dataType: 'json',
                data: {_method: 'delete'},
                url: zz.routes.path_prefix + '/photos/' + photo_id + '.json',
                success: function() {
                    zz.agent.callAgent('/albums/' + self.options.album_id + '/photos/' + photo_id + '/cancel_upload');
                    self.reload_tray();
                },

                error: function(error) {
                    zz.logger.debug(error);
                }
            });

        },

        reload_tray: function() {
            var self = this;
            zz.routes.photos.get_album_photos_json(self.options.album_id, 0, function(photos){
                self.tray_photos = _.filter(photos, function(photo) {
                     return zz.session.current_user_id == photo.user_id; //only show photos uploaded by this user
                 });

                 self.tray_widget.setPhotos(self.map_photos(self.tray_photos));
                 self.updateCheckmarks();
             });
        },

        add_photo_to_album: function(add_url, element) {
            var self = this;
            self.animate_to_tray(element, function() {
                self.add_to_album(add_url);
            });
            element.data().zz_photo.setChecked(true);

        },

        add_folder_to_album: function(add_url, element) {
            var self = this;


            self.animate_to_tray(element, function() {
                var dialog = self.show_processing_photos_dialog();

                var callback = function() {
                    dialog.close();
                };

                self.add_to_album(add_url, callback, callback);
            });


            $.each(self.grid.cells(), function(index, element) {
                $(element).data().zz_photo.setChecked(true);
            });

        },



        show_processing_photos_dialog: function() {
            var template = '<span class="processing-photos-dialog-content"><img src="{{src}}">Processing photos...</span>'.replace('{{src}}', zz.routes.image_url('/images/loading.gif'));

            var dialog = zz.dialog.show_dialog(template, { width: 300, height: 100, modal: true, autoOpen: true, cancelButton: false });
            return dialog;

        },


        animate_to_tray: function(element, callback) {
            var self = this;
            var imageElement;

            if (element.hasClass('add-all-button')) {
                imageElement = element;
            }
            else {
                imageElement = element.find('.photo-image');
            }


            var start_top = imageElement.offset().top;
            var start_left = imageElement.offset().left;

            var end_top = self.tray_element.offset().top;
            var end_left = self.tray_next_thumb_offset_x();


            var on_finish_animation = function() {
                callback();
                $(this).remove();
            }

            imageElement.clone()
                    .css({position: 'absolute', left: start_left, top: start_top, border: '1px solid #ffffff'})
                    .appendTo('body')
                    .addClass('animate-photo-to-tray')
                    .animate({
                                 width: '20px',
                                 height: '20px',
                                 top: (end_top) + 'px',
                                 left: (end_left) + 'px'
                             }, 1000, 'easeInOutCubic', on_finish_animation);


        },

        add_to_album: function(add_url, on_success, on_failure) {
            var self = this;

            add_url += (add_url.indexOf('?') == -1) ? '?' : '&';
            add_url += 'album_id=' + self.options.album_id;

            self.tray_widget.showLoadingIndicator();
            self.callAgentOrServer({
                url: add_url,
                success: function(photos) {
                    self.tray_photos = self.tray_photos.concat(photos);
                    self.tray_widget.setPhotos(self.map_photos(self.tray_photos));
                    self.tray_widget.hideLoadingIndicator();
                    if (on_success) {
                        on_success();
                    }
                },
                error: function(error) {
                    if (!self.destroyed) {
                        self.tray_widget.hideLoadingIndicator();
                        alert('Sorry, there was a problem adding photos to your album. Please try again.');
                        if (on_failure) {
                            on_failure(error);
                        }
                    }
                    else {
                        //this means that the user closed the chooser -- this is the likely cause of the error
                    }
                }
            });
        },



        get_photos: function() {
            return self.tray_photos;
        },

        map_photos: function(photos) {
            if (! $.isArray(photos)) {
                var photos = [photos];
            }

            photos = $.map(photos, function(photo, index) {
                var id = photo.id;
                var src = photo.thumb_url;

                src = zz.agent.checkAddCredentialsToUrl(src);

                return {id: id, src: src};
            });

            return photos;
        },

        tray_next_thumb_offset_x: function() {
            return this.tray_widget.nextThumbOffsetX();
        }


    });
})(jQuery);
