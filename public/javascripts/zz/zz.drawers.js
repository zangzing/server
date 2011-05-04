/*!
 * zz.drawers.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.drawers = {
    group_album: {

        // set up the album variables
        first: 'add',
        last: 'share',
        show_next_button: true,
        numbers: 1,
        percent: 0.0,
        style: 'create',
        time: 600,

        init: function(){
            zz.album_type = 'group';
        },

        on_close: function(){
            ZZAt.track('album.done.click');
            $.ajax({
              url:      zz.path_prefix + '/albums/' +zz.album_id + '/close_batch',
              complete: function(request, textStatus){
                    logger.debug('Batch closed because drawer was closed. Call to close_batch returned with status= '+textStatus);
                    window.location = zz.path_prefix + '/albums/' +zz.album_id + '/photos';
              }
            });
        },


        // set up the wizard steps
        steps: {

            add: {
                next: 'name',
                title: 'Add Photos',
                type: 'full',
                url: zz.path_prefix + '/albums/$$/add_photos',
                url_type: 'album',

                init: function(container, callback){ // run when loading the drawer up
                    pages.album_add_photos_tab.init(container,  callback, zz.drawers.group_album.style);
                },

                bounce: function(success, failure){ // run before you leave
                    pages.album_add_photos_tab.bounce(success, failure);
                }

            },
            name: {  //group album
                id: 'name',
                next: 'edit',
                title: 'Name',
                type: 'full',

                init:   function(container, callback){
                    pages.album_name_tab.init(container,  callback);
                },
                bounce: function(success, failure){
                    pages.album_name_tab.bounce(success, failure);
                }
            },

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',

                init:   function(container, callback){
                    pages.edit_album_tab.init(container, callback);
                },
                bounce: function(success, failure){
                    pages.edit_album_tab.bounce(success, failure);
                }
            },

            privacy: {
                next: 'contributors',
                title: 'Privacy',
                type: 'full',


                init: function(container, callback){
                    pages.album_privacy_tab.init(container, callback);
                },

                bounce: function(success, failure){
                    pages.album_privacy_tab.bounce(success, failure);
                }
            },

            contributors: {
                next: 'share',
                title: 'Contributors',
                type: 'full',


                init: function(container, callback){
                    pages.contributors.init(container, callback);
                },

                bounce: function(success, failure){
                    pages.contributors.bounce(success, failure);
                }
            },

            share: {
                next: 0,
                title: 'Share',
                type: 'full',


                init: function(container, callback){
                    pages.share.init(container, callback);
                },

                bounce: function(success, failure){
                    pages.share.bounce(success, failure);
                }
            }

        }

    }
};