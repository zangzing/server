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
        
        _create: function() {
            var self = this;




            var template = $('<div class="photochooser">' +
                             '   <div class="header">' +
                             '       <a class="back-button"><span>Back</span></a>' +
                             '       <h2>Folder Name</h2>' +
                             '   </div>' +
                             '   <div class="body"></div>' +
                             '   <div class="footer"></div>' +
                             '</div>');



            self.backButtonCaptionElement = template.find('.back-button span');
            self.backButtonElement = template.find('.back-button');
            self.folderNameElement = template.find('h2');
            self.bodyElement = template.find('.body');


            self.element.html(template);


            self.backButtonElement.click(function(){
                self.goBack();
            });


            self.showRoots();

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



            self.bodyElement.html("loading...");


            if(!_.isUndefined(folder.children)){
                self.showFolder(folder.name, folder.children);
            }
            else{
                self.callAgentOrServer({
                   url: folder.open_url,
                   success:function(json){
                       self.showFolder(folder.name, json);
                   },
                   error: function(error){
                       if(!_.isUndefined(folder.on_error)){
                           folder.on_error();
                       }
                       else{
                            alert('error');
                       }
                   }
                });
            }
        },


        showFolder: function(name, children){
            var self = this;



            //translate photos and folders from connector format to photo/photogrid format
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
                }

                child.caption = child.name;

                return child;
            });


            var gridElement = $('<div class="photogrid"></div>');
            self.bodyElement.html(gridElement);

            var grid = gridElement.zz_photogrid({
                photos:children,
                showThumbscroller:false,
                cellWidth: 190,
                cellHeight: 190,
                onClickPhoto: function(index, photo){
                    if(photo.type === 'folder'){
                        self.openFolder(photo);
                    }
                    else{
                        //add photo to album
                        alert('add photo');
                    }
 
                }
                
            }).data().zz_photogrid;

        },



        open_login_window : function(folder, login_url) {
            var self = this;
            oauthmanager.login(login_url, function(){
                console.log('after login');
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
                    classy: 'filechooser folder f_pictures',
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
                    classy: 'filechooser folder f_iphoto',
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
                    classy: 'filechooser folder f_picasa',
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
                    classy: 'filechooser folder f_home',
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
                    classy: 'filechooser folder f_mycomputer',
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
                    classy: 'filechooser folder f_pictures',
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
                    classy: 'filechooser folder f_picasa',
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
                    classy: 'filechooser folder f_home',
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
                    classy: 'filechooser folder f_mycomputer',
                    on_error: file_system_on_error,
                    src: '/images/folders/mycomputer_off.jpg',
                    rolloverSrc: '/images/folders/mycomputer_on.jpg',
                    state: 'ready'

                });
            }


            //Shutterfly
            roots.push(
            {
                open_url: '/shutterfly/folders.json',
                type: 'folder',
                name: 'Shutterfly',
                src: '/images/folders/shutterfly_off.jpg',
                rolloverSrc: '/images/folders/shutterfly_on.jpg',

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_shutterfly.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/shutterfly/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });

            //Kodak
            roots.push(
            {
                open_url: '/kodak/folders.json',
                type: 'folder',
                name: 'Kodak',
                src: '/images/folders/kodak_off.jpg',
                rolloverSrc: '/images/folders/kodak_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_kodak.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/kodak/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //SmugMug
            roots.push(
            {
                open_url: '/smugmug/folders.json',
                type: 'folder',
                name: 'SmugMug',
                src: '/images/folders/smugmug_off.jpg',
                rolloverSrc: '/images/folders/smugmug_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_smugmug.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/smugmug/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Facebook
            roots.push(
            {
                open_url: '/facebook/folders.json',
                type: 'folder',
                name: 'Facebook',
                src: '/images/folders/facebook_off.jpg',
                rolloverSrc: '/images/folders/facebook_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_facebook.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/facebook/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });

            //Flickr
            roots.push(
            {
                open_url: '/flickr/folders.json',
                type: 'folder',
                name: 'Flickr',
                src: '/images/folders/flickr_off.jpg',
                rolloverSrc: '/images/folders/flickr_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_flickr.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/flickr/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //Picasa Web
            roots.push(
            {
                open_url: '/picasa/folders.json',
                type: 'folder',
                name: 'Picasa Web',
                src: '/images/folders/picasa_off.jpg',
                rolloverSrc: '/images/folders/picasa_on.jpg',
                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_picasa_web.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/picasa/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }
            });


            //Photobucket
            roots.push(
            {
                open_url: '/photobucket/folders', //No need for .json cause this connector has unusual structure
                type: 'folder',
                name: 'Photobucket',
                src: '/images/folders/photobucket_off.jpg',
                rolloverSrc: '/images/folders/photobucket_on.jpg',

                on_error: function(){
                    var folder = this;
                    self.bodyElement.hide().load('/static/connect_messages/connect_to_photobucket.html', function(){
                        self.bodyElement.find('#connect-button').click(function(){
                            self.open_login_window(folder, '/photobucket/sessions/new');
                        });
                        self.bodyElement.fadeIn('fast');
                    });
                }

            });


            //ZangZing
            roots.push(
            {
                open_url: '/zangzing/folders.json',
                type: 'folder',
                name: 'ZangZing',
                src: '/images/folders/zangzing_off.jpg',
                rolloverSrc: '/images/folders/zangzing_on.jpg'
            });

            return roots;

        }
        

    });
})( jQuery );