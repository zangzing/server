/* Wizard Drawer objects 
 --------------------------------------------------------------------------- */
zz.drawers = {
    /* Create ***PERSONAL*** Album
     ------------------------------------------------------------------------- */
    personal_album: {

        // set up the album variables
        first: 'add', // first item in the object
        last: 'share', // last item in the object
        list_element: 'indicator', // 'indicator' : #indicator-4, #indicator-5, etc
        next_element: '#next-step', // alternately, 'none' shows no next/done btn
        numbers: 1, // 1 = show the number images, 0 = don't
        percent: 0.0, // how far to fade the page contents when opening the drawer
        style: 'create', // create or edit
        time: 600, // how fast to open the drawer
        redirect: '/albums/$$/photos', // where do we go when we're done
        redirect_type: 'album', // replace $$ w/the id of the album or user

        init: function(){
            zz.album_type = 'personal';
        },

        // set up the wizard steps
        steps: {

            add: {
                next: 'name', // next in line
                title: 'Add Photos', // link text
                type: 'full', // drawer position - full(y open) or partial(ly open)
                url: '/albums/$$/add_photos', // url of the drawer template
                url_type: 'album', // replace $$ w/the id of the album or user

                init: function(){ // run when loading the drawer up
                    pages.album_add_photos_tab.init();
                },

                bounce: function(){ // run before you leave
                    pages.album_add_photos_tab.bounce();
                }

            },

            name: {
                next: 'edit',
                title: 'Name',
                type: 'full',
                url: '/albums/$$/name_album',
                url_type: 'album',
                init:   function(){
                    pages.album_name_tab.init();
                },
                bounce: function(){
                    pages.album_name_tab.bounce(); 
                }
            },

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',
                url: '/albums/$$/edit',
                url_type: 'album',
                init:   function(){
                    pages.edit_album_tab.init();
                },
                bounce: function(){
                    pages.edit_album_tab.bounce();
                }
            },

            privacy: {
                next: 'share',
                title: 'Album Privacy',
                type: 'full',
                url: '/albums/$$/privacy',
                url_type: 'album',

                init: function(){
                    pages.album_privacy_tab.init();
                },

                bounce: function(){
                    pages.album_privacy_tab.bounce();
                }
            },

            share: {
                next: 0,
                title: 'Share',
                type: 'full',
                url: '/albums/$$/shares/new',
                url_type: 'album',

                init: function(){
                    pages.album_share_tab.init();
                },

                bounce: function(){
                    pages.album_share_tab.bounce();
                }
            }

        }

    },


    /* Create ***GROUP*** Album
     ------------------------------------------------------------------------- */
    group_album: {

        // set up the album variables
        first: 'add',
        last: 'share',
        list_element: 'indicator',
        next_element: '#next-step',
        numbers: 1,
        percent: 0.0,
        style: 'create',
        time: 600,
        redirect: '/albums/$$/photos',
        redirect_type: 'album',

        init: function(){
            zz.album_type = 'group';
        },

        // set up the wizard steps
        steps: {

            add: {
                next: 'name',
                title: 'Add Photos',
                type: 'full',
                url: '/albums/$$/add_photos',
                url_type: 'album',

                init: function(){ // run when loading the drawer up
                    pages.album_add_photos_tab.init();
                },

                bounce: function(){ // run before you leave
                    pages.album_add_photos_tab.bounce();
                }

            },
            name: {  //group album
                id: 'name',
                next: 'edit',
                title: 'Name',
                type: 'full',
                url:  '/albums/$$/name_album',
                url_type: 'album',
                init:   function(){
                    pages.album_name_tab.init();
                },
                bounce: function(){
                    pages.album_name_tab.bounce();
                }
            },

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',
                url: '/albums/$$/edit',
                url_type: 'album',
                init:   function(){
                    pages.edit_album_tab.init();
                },
                bounce: function(){
                    pages.edit_album_tab.bounce();
                }
            },

            privacy: {
                next: 'contributors',
                title: 'Privacy',
                type: 'full',
                url: '/albums/$$/privacy',
                url_type: 'album',

                init: function(){
                    pages.album_privacy_tab.init();
                },

                bounce: function(){
                    pages.album_privacy_tab.bounce();
                }
            },

            contributors: {
                next: 'share',
                title: 'Contributors',
                type: 'full',
                url: '/albums/$$/contributors',
                url_type: 'album',

                init: function(){
                    pages.album_contributors_tab.init();
                },

                bounce: function(){
                    pages.album_contributors_tab.bounce();
                }
            },

            share: {
                next: 0,
                title: 'Share',
                type: 'full',
                url: '/albums/$$/shares/new',
                url_type: 'album',

                init: function(){
                    pages.album_share_tab.init();
//                    $('.social-share').click(function(){zz.wizard.social_share(zz.drawers.group_album, 'share')});
//                    $('.email-share').click(function(){zz.wizard.email_share(zz.drawers.group_album, 'share')});
                },

                bounce: function(){
                    pages.album_share_tab.bounce();
                }
            }

        }

    }, 

//====================================== SETTINGS WIZARD ================================================    
    settings: {

         // set up the album variables
         first: 'profile',              // first item in the object
         last: 'linked_accts',          // last item in the object
         list_element: 'indicator',     // 'indicator' : #indicator-4, #indicator-5, etc
         next_element: 'none',          // alternately, 'none' shows no next/done btn
         numbers: 0,                    // 1 = show the number images, 0 = don't
         percent: 0.0,                  // how far to fade the page contents when opening the drawer
         style: 'edit',               // create or edit
         time: 600,                     // how fast to open the drawer
         redirect: '/users/$$/albums', // where do we go when we're done
         redirect_type: 'user',        // replace $$ w/the id of the album or user

         init: function(){
             
         }, 

         // set up the wizard steps
         steps: {
             profile: {
                 next: 'account',               // next in line
                 title: 'Profile',              // link text
                 type: 'full',                  // drawer position - full(y open) or partial(ly open)
                 url: '/users/$$/edit',         // url of the drawer template
                 url_type: 'user',              // replace $$ w/the id of the album or user
                 init:   zz.init.profile_settings, // run when loading the drawer up
                 bounce: function(){ } // run before you leave
             }, //end zz.drawers.settings.steps.profile

             account: {
                 next: 'notifications',
                 title: 'Account',
                 type: 'full',
                 url: '/users/$$/account',
                 url_type: 'user',
                 init: function(){ },
                 bounce: function(){ }
             }, //end zz.drawers.settings.steps.account

             notifications: {
                 next: 'linked-accts',
                 title: 'Notifications',
                 type: 'full',
                 url: '/users/$$/notifications',
                 url_type: 'user',
                 init: function(){ },
                 bounce: function(){ }
             }, //end zz.drawers.settings.steps.notifications

             linked_accts: {
                next: 0,
                title: 'Linked Accounts',
                type: 'full',
                url: '/users/$$/identities',
                url_type: 'user',
                init: function(){ zz.init.id_settings(); },
                bounce: function(){ }
              } //end zz.drawers.settings.steps.linked_accts

         } // end zz.drawers.settings.steps

    } //end zz.drawers.settings

}; // end zz.drawers