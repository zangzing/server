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

        // set up the wizard steps
        steps: {

            add: {
                next: 'name', // next in line
                title: 'Add Photos', // link text
                type: 'full', // drawer position - full(y open) or partial(ly open)
                url: '/albums/$$/add_photos', // url of the drawer template
                url_type: 'album', // replace $$ w/the id of the album or user

                init: function(){ // run when loading the drawer up
                    zz.wizard.init_add_tab('personal');
                },

                bounce: function(){ // run before you leave
                    $('#added-pictures-tray').fadeOut('fast');
                }

            }, //end zz.drawers.personal_album.steps.add

            name: {
                next: 'edit',
                title: 'Name',
                type: 'full',
                url: '/albums/$$/name_album',
                url_type: 'album',

                init: function(){
                    zz.wizard.init_name_tab();
                },

                bounce: function(){
                    zz.wizard.update_album();
                }

            }, //end zz.drawers.personal_album.steps.name

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',
                url: '/albums/$$/edit',
                url_type: 'album',

                init: function(){
                    zz.wizard.load_images();
                },

                bounce: function() {
                    zz.open_drawer();
                }

            }, //end zz.drawers.personal_album.steps.edit

            privacy: {
                next: 'share',
                title: 'Album Privacy',
                type: 'full',
                url: '/albums/$$/privacy',
                url_type: 'album',

                init: function(){
                    $('#privacy-public').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                            $('#privacy-public img.select-button').attr('src', '/images/btn-round-selected-on.png');
                        });
                    });
                    $('#privacy-hidden').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
                        $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                        $('#privacy-hidden img.select-button').attr('src', '/images/btn-round-selected-on.png');
                    });
                    $('#privacy-password').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
                        $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                        $('#privacy-password img.select-button').attr('src', '/images/btn-round-selected-on.png');
                    });
                },

                bounce: function(){
                }

            }, //end zz.drawers.personal_album.steps.privacy

            share: {
                next: 0,
                title: 'Share',
                type: 'full',
                url: '/albums/$$/shares/new',
                url_type: 'album',

                init: function(){
                    $('.social-share').click(function(){zz.wizard.social_share(zz.drawers.personal_album, 'share')});
                    $('.email-share').click(function(){zz.wizard.email_share(zz.drawers.personal_album, 'share')});
                },

                bounce: function(){
                }

            } //end zz.drawers.personal_album.steps.share

        } // end zz.drawers.personal_album.steps

    }, // end zz.drawers.personal_album


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

        // set up the wizard steps
        steps: {

            add: {
                next: 'name',
                title: 'Add Photos',
                type: 'full',
                url: '/albums/$$/add_photos',
                url_type: 'album',

                init: function(){
                    zz.wizard.init_add_tab('group');
                },
                bounce: function(){
                    $('#added-pictures-tray').fadeOut('fast');
                }
            },
            name: {  //group album
                id: 'name',
                next: 'edit',
                title: 'Name',
                type: 'full',
                url: '/albums/$$/name_album',
                url_type: 'album',
                init: function(){
                    zz.wizard.init_name_tab();
                },
                bounce: function(){
                    zz.wizard.update_album(); //post edit-album form
                }

            }, //end zz.drawers.group_album.steps.name

            edit: {
                next: 'privacy',
                title: 'Edit',
                type: 'partial',
                url: '/albums/$$/edit',
                url_type: 'album',

                init: function(){
                    zz.wizard.load_images();
                },

                bounce: function() {
                    zz.open_drawer();
                }

            }, //end zz.drawers.group_album.steps.edit

            privacy: {
                next: 'contributors',
                title: 'Privacy',
                type: 'full',
                url: '/albums/$$/privacy',
                url_type: 'album',

                init: function(){
                    $('#privacy-public').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                            $('#privacy-public img.select-button').attr('src', '/images/btn-round-selected-on.png');
                        });
                    });
                    $('#privacy-hidden').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
                        $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                        $('#privacy-hidden img.select-button').attr('src', '/images/btn-round-selected-on.png');
                    });
                    $('#privacy-password').click(function(){
                        $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
                        $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                        $('#privacy-password img.select-button').attr('src', '/images/btn-round-selected-on.png');
                    });
                },

                bounce: function(){
                }

            }, //end zz.drawers.group_album.steps.privacy

            contributors: {
                next: 'share',
                title: 'Contributors',
                type: 'full',
                url: '/albums/$$/contributors',
                url_type: 'album',

                init: function(){
//                    if( zz.wizard.contributor_count <= 0){
//                        zz.wizard.show_new_contributors();
//                    }else{
                        $('#add-contributors-btn').click(function(){zz.wizard.show_new_contributors();});
//                    }
                },

                bounce: function() {
                }

            }, //end zz.drawers.group_album.steps.contributors

            share: {
                next: 0,
                title: 'Share',
                type: 'full',
                url: '/albums/$$/shares/new',
                url_type: 'album',

                init: function(){
                    $('.social-share').click(function(){zz.wizard.social_share(zz.drawers.group_album, 'share')});
                    $('.email-share').click(function(){zz.wizard.email_share(zz.drawers.group_album, 'share')});
                },

                bounce: function(){
                }

            } //end zz.drawers.group_album.steps.share

        } // end zz.drawers.group_album.steps

    }, // end zz.drawers.group_album

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

         // set up the wizard steps
         steps: {

             profile: {
                 next: 'account',               // next in line
                 title: 'Profile',              // link text
                 type: 'full',                  // drawer position - full(y open) or partial(ly open)
                 url: '/users/$$/edit',         // url of the drawer template
                 url_type: 'user',              // replace $$ w/the id of the album or user

                 init: zz.init.profile_settings, // run when loading the drawer up
                 bounce: function(){ zz.wizard.update_user()} // run before you leave
             }, //end zz.drawers.account_settings.steps.profile

             account: {
                 next: 'notifications',
                 title: 'Account',
                 type: 'full',
                 url: '/albums/$$/name_album',
                 url_type: 'album',

                 init: function(){
                     zz.wizard.init_name_tab();
                 },

                 bounce: function(){
                     zz.wizard.update_album();
                 }

             }, //end zz.drawers.account_settings.steps.account

             notifications: {
                 next: 'linked-accts',
                 title: 'Notifications',
                 type: 'full',
                 url: '/albums/$$/name_album',
                 url_type: 'album',

                 init: function(){
                     zz.wizard.init_name_tab();
                 },

                 bounce: function(){
                    zz.wizard.update_album();
                 }

             }, //end zz.drawers.account_settings.steps.notifications

             linked_accts: {
                next: 0,
                title: 'Linked Accounts',
                type: 'full',
                url: '/users/$$/identities',
                url_type: 'user',
                init: function(){
                   zz.init.identities_settings();
                },
                bounce: function(){}
              } //end zz.drawers.account_settings.steps.linked_accts

         } // end zz.drawers.account_settings.steps

    } //end zz.drawers.account_settings

}; // end zz.drawers