/*!
 * zz.drawers.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.drawers = {
    /* Create ***PERSONAL*** Album
     ------------------------------------------------------------------------- */
//    personal_album: {
//
//        // set up the album variables
//        first: 'add', // first item in the object
//        last: 'share', // last item in the object
//        show_next_button: true,
//        numbers: 1, // 1 = show the number images, 0 = don't
//        percent: 0.0, // how far to fade the page contents when opening the drawer
//        style: 'create', // create or edit
//        time: 600, // how fast to open the drawer
//
//        init: function(){
//            zz.album_type = 'personal';
//        },
//
//        on_close: function(){
//            $.get( '/albums/' +zz.album_id + '/close_batch' );
//            var url = '/albums/' +zz.album_id + '/photos';
//            setTimeout('window.location = "' + url + '"', 1);
//        },
//
//        // set up the wizard steps
//        steps: {
//
//            add: {
//                next: 'name', // next in line
//                title: 'Add Photos', // link text
//                type: 'full', // drawer position - full(y open) or partial(ly open)
//
//
//                init: function(callback){ // run when loading the drawer up
//                    pages.album_add_photos_tab.init(callback, zz.drawers.personal_album.style);
//                },
//
//                bounce: function(success, failure){ // run before you leave
//                    pages.album_add_photos_tab.bounce(success, failure);
//                }
//
//            },
//
//            name: {
//                next: 'edit',
//                title: 'Name',
//                type: 'full',
//                init:   function(callback){
//                    pages.album_name_tab.init(callback);
//                },
//                bounce: function(success, failure){
//                    pages.album_name_tab.bounce(success, failure);
//                }
//            },
//
//            edit: {
//                next: 'privacy',
//                title: 'Edit',
//                type: 'partial',
//                init:   function(callback){
//                    pages.edit_album_tab.init(callback);
//                },
//                bounce: function(success, failure){
//                    pages.edit_album_tab.bounce(success, failure);
//                }
//            },
//
//            privacy: {
//                next: 'share',
//                title: 'Album Privacy',
//                type: 'full',
//
//                init: function(callback){
//                    pages.album_privacy_tab.init(callback);
//                },
//
//                bounce: function(success, failure){
//                    pages.album_privacy_tab.bounce(success, failure);
//                }
//            },
//
//            share: {
//                next: 0,
//                title: 'Share',
//                type: 'full',
//
//                init: function(callback){
//                    pages.share.init(callback);
//                },
//
//                bounce: function(success, failure){
//                    pages.share.bounce(success, failure);
//                }
//            }
//
//        }
//
//    },


    /* Create ***GROUP*** Album
     ------------------------------------------------------------------------- */
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
            $.get( zz.path_prefix + '/albums/' +zz.album_id + '/close_batch' );
            var url = zz.path_prefix + '/albums/' +zz.album_id + '/photos';
            setTimeout('window.location = "' + url + '"', 1);
        },


        // set up the wizard steps
        steps: {

            add: {
                next: 'name',
                title: 'Add Photos',
                type: 'full',
                url: zz.path_prefix + '/albums/$$/add_photos',
                url_type: 'album',

                init: function(callback){ // run when loading the drawer up
                    pages.album_add_photos_tab.init(callback, zz.drawers.group_album.style);
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

                init:   function(callback){
                    pages.album_name_tab.init(callback);
                },
                bounce: function(success, failure){
                    pages.album_name_tab.bounce(success, failure);
                }
            },

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',

                init:   function(callback){
                    pages.edit_album_tab.init(callback);
                },
                bounce: function(success, failure){
                    pages.edit_album_tab.bounce(success, failure);
                }
            },

            privacy: {
                next: 'contributors',
                title: 'Privacy',
                type: 'full',


                init: function(callback){
                    pages.album_privacy_tab.init(callback);
                },

                bounce: function(success, failure){
                    pages.album_privacy_tab.bounce(success, failure);
                }
            },

            contributors: {
                next: 'share',
                title: 'Contributors',
                type: 'full',


                init: function(callback){
                    pages.contributors.init(callback);
                },

                bounce: function(success, failure){
                    pages.contributors.bounce(success, failure);
                }
            },

            share: {
                next: 0,
                title: 'Share',
                type: 'full',


                init: function(callback){
                    pages.share.init(callback);
                },

                bounce: function(success, failure){
                    pages.share.bounce(success, failure);
                }
            }

        }

    }, 

//====================================== SETTINGS WIZARD ================================================
    settings: {

         // set up the album variables
         first: 'profile',              // first item in the object
         last: 'linked_accts',          // last item in the object
         show_next_button: false,          // alternately, 'none' shows no next/done btn
         numbers: 0,                    // 1 = show the number images, 0 = don't
         percent: 0.0,                  // how far to fade the page contents when opening the drawer
         style: 'edit',               // create or edit
         time: 600,                     // how fast to open the drawer
//         redirect: '/users/$$/albums', // where do we go when we're done
//         redirect_type: 'user',        // replace $$ w/the id of the album or user

         init: function(){
             
         }, 

        //todo: for some reason this isn't being called
        on_close: function(){
            var url = zz.path_prefix + '/users/' +zz.current_user_id + '/albums';
            setTimeout('window.location = "' + url + '"', 1);
        },


         // set up the wizard steps
         steps: {
             profile: {
                 next: 'account',               // next in line
                 title: 'Profile',              // link text
                 type: 'full',                  // drawer position - full(y open) or partial(ly open)
//                 url: '/users/$$/edit',         // url of the drawer template
//                 url_type: 'user',              // replace $$ w/the id of the album or user
                 init:   function(callback){
                    pages.acct_profile.init(callback);
                 },
                 bounce: function(success, failure){
                     pages.acct_profile.bounce(success, failure);
                 }

             },

             account: {
                 next: 'notifications',
                 title: 'Account',
                 type: 'full',
//                 url: '/users/$$/account',
//                 url_type: 'user',
                 init: function(callback){
                    pages.account_setings_account_tab.init(callback);
                 },
                 bounce: function(success, failure){
                     pages.account_setings_account_tab.bounce(success, failure);
                 }
             },

             notifications: {
                 next: 'linked-accts',
                 title: 'Notifications',
                 type: 'full',
//                 url: '/users/$$/notifications',
//                 url_type: 'user',
                 init: function(callback){
                    pages.account_setings_notifications_tab.init(callback);
                 },
                 bounce: function(success, failure){
                     pages.account_setings_notifications_tab.bounce(success, failure);
                 }
             },

             linked_accts: {
                next: 0,
                title: 'Linked Accounts',
                type: 'full',
//                url: '/users/$$/identities',
//                url_type: 'user',
                init: function(callback){
                    pages.linked_accounts.init(callback);
                },

                 bounce: function(success, failure){
                     pages.linked_accounts.bounce(success, failure);
                 }
              }

         }

    }

};