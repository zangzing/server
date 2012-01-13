var zz = zz || {};
zz.import_albums = zz.import_albums || {};

(function(){

    function get_service_pretty_name(service_name){
        var pretty_names = {
            'flickr': 'Flickr',
            'smugmug': 'SmugMug',
            'facebook': 'Facebook',
            'google': 'Picasa',
            'mobileme': 'MobileMe',
            'dropbox': 'Dropbox',
            'shutterfly': 'Shutterfly',
            'kodak': 'Kodak Gallery',
            'instagram': 'Instagram',
            'photobucket': 'Photobucket'
        };

        return pretty_names[service_name];
    }

    function get_notes_for_service(service_name){
        var notes = {
            'flickr': 'We can only import full resulution from Flickr Pro accounts. If you have a free account, we will import the highest resolution photos that they allow.',
            'shutterfly': 'Shutterfly does not allow us to import your full resolution photos. We will import the highest resolution that they allow.'
        };

        return notes[service_name];
    }


    function SELECT_SERVICE_TEMPLATE(){
        return '<div class="import-all">' +
                    '<div class="select-service">' +
                        '<div class="header">Import All Your Photos</div>' +
                        '<div class="sub-header">Choose a service to import your photos</div>' +
                        '<div class="services">' +
                            '<div class="service" data-name="flickr"><div class="service-logo flickr"/></div>' +
                            '<div class="service" data-name="facebook"><div class="service-logo facebook"/></div>' +
                            '<div class="service" data-name="mobileme"><div class="service-logo mobileme"/></div>' +
                            '<div class="service" data-name="google"><div class="service-logo google"/></div>' +
                            '<div class="service" data-name="dropbox"><div class="service-logo dropbox"/></div>' +
                            '<div class="service" data-name="shutterfly"><div class="service-logo shutterfly"/></div>' +
                            '<div class="service" data-name="kodak"><div class="service-logo kodak"/></div>' +
                            '<div class="service" data-name="instagram"><div class="service-logo instagram"/></div>' +
                            '<div class="service" data-name="smugmug"><div class="service-logo smugmug"/></div>' +
                            '<div class="service" data-name="photobucket"><div class="service-logo photobucket"/></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="confirm-import">' +
                        '<div class="header service-name">Service Name Import</div>' +
                        '<div class="sub-header">Choose the default privacy setting for you imported albums.<br>You can always change it for each album.</div>' +
                        '<div class="privacy-buttons">' +
                            '<div class="public-button"></div>' +
                            '<div class="hidden-button"></div>' +
                            '<div class="password-button"></div>' +
                        '</div>' +
                        '<div class="service-notes"></div>' +
                        '<a class="green-button import-all-button"><span>Import My Albums</span></a>' +
                    '</div>' +
                    '<div class="import-progress">' +
                        '<div class="header">Importing your <span class="service-name"></span> albums</div>' +
                        '<div class="sub-header">We are importing your albums from <span class="service-name"></span> to ZangZing</div>' +
                        '<div class="animation"><img/></div>' +
                        '<div class="import-from-service"><div class="service-logo"></div></div>' +
                        '<div class="import-to-zangzing"><div class="service-logo zangzing"/></div>' +
                    '</div>' +
                    '<div class="import-complete">' +
                        '<div class="header">Welcome to ZangZing!</div>' +
                        '<div class="success-message">' +
                            'We’ve started uploading photos from <span class="album-count"></span> albums.<br>' +
                            'It takes a few minutes to process all the photos.<br>' +
                            'We’ll send you an email when each album is ready.<br>' +
                        '</div>' +
                        '<a class="green-button done-button"><span>Back to my Homepage</span></a>' +
                    '</div>' +
               '</div>';
    }

    zz.import_albums.show_import_dialog = function(){
        zz.routes.identities.get_identities(function(identities){

            var content = $(SELECT_SERVICE_TEMPLATE());

            _.each(content.find('.service'), function(service_element){
                service_element = $(service_element);

                service_element.click(function(){
                    var service_name = $(this).attr('data-name');

                    var identity = _.detect(identities, function(identity){
                        return identity.identity_source == service_name;
                    });

                    if(identity && identity.credentials){
                        show_confirm_screen(service_name);
                    }
                    else{
                        zz.oauthmanager.login(zz.routes.identities.login_url_for_service(service_name), function() {
                            show_confirm_screen(service_name);
                        });
                    }
                });
            });


            var import_done = false;

            var show_confirm_screen = function(service_name){
                zz.routes.identities.get_identity_for_service(service_name, function(identity){
                    content.find('.select-service').hide();
                    content.find('.confirm-import').show();

                    var service_pretty_name =  get_service_pretty_name(service_name);
                    content.find('.confirm-import .service-name').text(service_pretty_name + ' Import');

                    var privacy = 'public';
                    var update_button_states = function(){
                        content.find('.privacy-buttons div').removeClass('selected');
                        content.find('.privacy-buttons .' + privacy + '-button').addClass('selected');
                    };
                    update_button_states();


                    content.find('.privacy-buttons .public-button').click(function(){
                        privacy = 'public';
                        update_button_states();
                    });

                    content.find('.privacy-buttons .hidden-button').click(function(){
                        privacy = 'hidden';
                        update_button_states();
                    });

                    content.find('.privacy-buttons .password-button').click(function(){
                        privacy = 'password';
                        update_button_states();
                    });


                    var notes = get_notes_for_service(service_name);
                    if(notes){
                        content.find('.confirm-import .service-notes').text(notes);
                    }


                    content.find('.confirm-import .import-all-button').click(function(){
                        if(identity.last_import_all){
                            var d = new Date(identity.last_import_all);
                            var formatted_date = (d.getMonth() + 1) + '-' + d.getDate() + '-' + d.getFullYear();
                            var message = 'You already imported ablums from ' + service_pretty_name + ' on ' + formatted_date +'. If you import again, you may end up with duplicate albums. Do you want to continue?';
                            if(!confirm(message)){
                                return;
                            }
                        }

                        show_progress_screen_and_start_import(service_name, privacy);
                    });


                });
            };


            var show_progress_screen_and_start_import = function(service_name, privacy){
                var success = function(json){
                    show_complete_screen(json);
                };

                var failure = function(){
                    alert('Oops. Something went wrong. Can you please try to import again?');
                    document.location.reload();
                };

                zz.routes.albums.import_all_from_service(service_name, privacy, success, failure);

                ZZAt.track('import_all.' + service_name);

                content.find('.confirm-import').hide();
                content.find('.import-progress').show();


                content.find('.import-from-service .service-logo').addClass(service_name);
                content.find('.animation img').attr('src', '/images/import/' + service_name + '-to-zangzing.gif');
                content.find('span.service-name').text(get_service_pretty_name(service_name));


            };

            var show_complete_screen = function(json){
                content.find('.import-progress').hide();
                content.find('.import-complete').show();
                content.find('.import-complete .done-button').click(function(){
                    document.location.reload();
                });
                content.find('.success-message .album-count').text(json.length);
                import_done = true;
            };




            var on_close = function(){
                if(!import_done){
                    zz.toolbars.enable_buttons();
                }
                else{
                    document.location.reload();
                }
            };

            zz.dialog.show_dialog(content, {width:890, height:450, on_close: on_close});

        });
    };
}());