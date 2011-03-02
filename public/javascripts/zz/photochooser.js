/*!
 * photochooser.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
(function( $, undefined ) {

    $.widget( "ui.zz_photochooser", {
        options: {
        },

        roots:null,

        _create: function() {
            var self = this;

            self.roots = self._getRoots();



            var template = $('<div class="photochooser">' +
                             '   <div class="header">' +
                             '       <a class="back-button"><span>Back</span></a>' +
                             '       <h2>Folder Name</h2>' +
                             '   </div>' +
                             '   <div class="body"></div>' +
                             '   <div class="footer"></div>' +
                             '</div>');



            self.backButtonElement = template.find('.back-button');
            self.folderNameElement = template.find('h2');
            self.bodyElement = template.find('.body');


            self.element.html(template);

            self.showRoots();

        },

        showRoots: function(){
            this.showFolder(this.roots);
        },

        showFolder: function(children){
            var self = this;

            var gridElement = $('<div class="photogrid"></div>');
            self.bodyElement.html(gridElement);

            var grid = gridElement.zz_photogrid({
                photos:children,
                showThumbscroller:false,
                cellWidth: 190,
                cellHeight: 190
            }).data().zz_photogrid;

        },


        _getRoots: function(){
            var roots = [];


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

            if(navigator.appVersion.indexOf("Mac")!=-1){

                //My Pictures
                roots.push(
                {
                    open_url: agent.buildAgentUrl('/filesystem/folders/fi9QaWN0dXJlcw=='),
                    type: 'folder',
                    caption: 'My Pictures',
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
                    caption: 'iPhoto',
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
                    caption: 'Picasa',
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
                    caption: 'My Home',
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
                    caption: 'My Computer',
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
                    caption: 'My Pictures',
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
                    caption: 'Picasa',
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
                    caption: 'My Home',
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
                    caption: 'My Computer',
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
                caption: 'Shutterfly',
                login_url: '/shutterfly/sessions/new',
                classy: 'filechooser folder f_shutterfly',
                connect_message_url: '/static/connect_messages/connect_to_shutterfly.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_shutterfly.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });

                },
                src: '/images/folders/shutterfly_off.jpg',
                rolloverSrc: '/images/folders/shutterfly_on.jpg',
                state: 'ready'
            });

            //Kodak
            roots.push(
            {
                open_url: '/kodak/folders.json',
                type: 'folder',
                caption: 'Kodak',
                login_url:'/kodak/sessions/new',
                classy: 'filechooser folder f_kodak',
                connect_message_url: '/static/connect_messages/connect_to_kodak.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_kodak.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });
                },
                src: '/images/folders/kodak_off.jpg',
                rolloverSrc: '/images/folders/kodak_on.jpg',
                state: 'ready'

            });


            //SmugMug
            roots.push(
            {
                open_url: '/smugmug/folders.json',
                type: 'folder',
                caption: 'SmugMug',
                login_url: '/smugmug/sessions/new',
                classy: 'filechooser folder f_smugmug',
                connect_message_url: '/static/connect_messages/connect_to_smugmug.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_smugmug.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });
                },
                src: '/images/folders/smugmug_off.jpg',
                rolloverSrc: '/images/folders/smugmug_on.jpg',
                state: 'ready'

            });


            //Facebook
            roots.push(
            {
                open_url: '/facebook/folders.json',
                type: 'folder',
                caption: 'Facebook',
                login_url: '/facebook/sessions/new',
                classy: 'filechooser folder f_facebook',
                connect_message_url: '/static/connect_messages/connect_to_facebook.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_facebook.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });

                },
                src: '/images/folders/facebook_off.jpg',
                rolloverSrc: '/images/folders/facebook_on.jpg',
                state: 'ready'


            });

            //Flickr
            roots.push(
            {
                open_url: '/flickr/folders.json',
                type: 'folder',
                caption: 'Flickr',
                login_url: '/flickr/sessions/new',
                classy: 'filechooser folder f_flickr',
                connect_message_url: '/static/connect_messages/connect_to_flickr.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_flickr.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });
                },
                src: '/images/folders/flickr_off.jpg',
                rolloverSrc: '/images/folders/flickr_on.jpg',
                state: 'ready'

            });


            //Picasa Web
            roots.push(
            {
                open_url: '/picasa/folders.json',
                type: 'folder',
                caption: 'Picasa Web',
                login_url: '/picasa/sessions/new',
                classy: 'filechooser folder f_picasa',
                connect_message_url: '/static/connect_messages/connect_to_picasa_web.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_picasa_web.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });

                },
                src: '/images/folders/picasa_off.jpg',
                rolloverSrc: '/images/folders/picasa_on.jpg',
                state: 'ready'

            });


            //Photobucket
            roots.push(
            {
                open_url: '/photobucket/folders', //No need for .json cause this connector has unusual structure
                type: 'folder',
                caption: 'Photobucket',
                login_url: '/photobucket/sessions/new',
                classy: 'filechooser folder f_photobucket',
                connect_message_url: '/static/connect_messages/connect_to_photobucket.html',
                on_error: function(error){
                    $('#filechooser').hide().load('/static/connect_messages/connect_to_photobucket.html', function(){
                        $('#filechooser').fadeIn('fast');
                    });

                },
                src: '/images/folders/photobucket_off.jpg',
                rolloverSrc: '/images/folders/photobucket_on.jpg',
                state: 'ready'

            });


            //ZangZing
            roots.push(
            {
                open_url: '/zangzing/folders.json',
                type: 'folder',
                caption: 'ZangZing',
                classy: 'filechooser folder f_zangzing',
                connect_message_url: '',
                src: '/images/folders/zangzing_off.jpg',
                rolloverSrc: '/images/folders/zangzing_on.jpg',
                state: 'ready'
                
            });

            return roots;

        }
        

    });
})( jQuery );