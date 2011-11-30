var zz = zz || {};
zz.import_albums = zz.import_albums || {};

(function(){
    function SELECT_SERVICE_TEMPLATE(){
        return '<div class="import-all">' +
                    '<div class="select-service">' +
                        '<div class="header">Select a service below and import all your albums to ZangZing</div>' +
                        '<div class="services">' +
                            '<div class="service flickr" data-name="flickr"><div/></div>' +
                            '<div class="service facebook" data-name="facebook"><div/></div>' +
                            '<div class="service mobileme" data-name="mobileme"><div/></div>' +
                            '<div class="service google" data-name="google"><div/></div>' +
                            '<div class="service dropbox" data-name="dropbox"><div/></div>' +
                            '<div class="service shutterfly" data-name="shutterfly"><div/></div>' +
                            '<div class="service kodak" data-name="kodak"><div/></div>' +
                            '<div class="service instagram" data-name="instagram"><div/></div>' +
                            '<div class="service smugmug" data-name="smugmug"><div/></div>' +
                            '<div class="service photobucket" data-name="photobucket"><div/></div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="confirm-import">' +
                        '<div class="header">Import all your albums from <span class="service-name"></span>. You will see the new ZangZing albums immediately and the photos will continue to load in the background.</div>' +
                        '<img class="import-image">'+
                        '<div class="warning-message">Warning: you already imported albums from <span class="service-name"></span> on <span class="date"></span>. If you import again, you may end up with duplicate albums in ZangZing</div>'+
                        '<a class="green-button import-all-button"><span>Import All Albums</span></a>' +
                    '</div>' +
                    '<div class="import-progress">' +
                        '<img class="import-image">'+
                        '<div class="message">Importing albums from <span class="service-name"></span></div>'+
                        '<img class="spinner" src="/images/loading.gif">'+
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

                    if(identity && identity.credentials && identity.identity_source != 'mobileme'){ // since we have issues with mobile me sessions, we want to always create a new one before starting an import
                        show_service_screen(service_name);
                    }
                    else{
                        zz.oauthmanager.login(zz.routes.identities.login_url_for_service(service_name), function() {
                            show_service_screen(service_name);
                        });
                    }
                });
            });


            var show_service_screen = function(service_name){
                zz.routes.identities.get_identity_for_service(service_name, function(identity){
                    content.find('.select-service').hide();
                    content.find('.confirm-import').show();
                    content.find('.confirm-import .service-name').text(service_name);
                    content.find('.confirm-import img.import-image').attr('src', '/images/connect-to-' + service_name + '.jpg');

                    content.find('.confirm-import .import-all-button').click(function(){
                        show_progress_screen(service_name);
                    });


                    if(identity.last_import_all){
                        var d = new Date(identity.last_import_all);
                        var formatted_date = d.getMonth() + '-' + d.getDate() + '-' + d.getFullYear();
                        content.find('.confirm-import .warning-message .service-name').text(service_name);
                        content.find('.confirm-import .warning-message .date').text(formatted_date);
                        content.find('.confirm-import .warning-message').show();
                    }
                });
            };


            var show_progress_screen = function(service_name){
                var on_finished = function(){
                    document.location.reload();
                };

                zz.routes.albums.import_all_from_service(service_name, on_finished);


                content.find('.confirm-import').hide();
                content.find('.import-progress').show();
                content.find('.import-progress img.import-image').attr('src', '/images/connect-to-' + service_name + '.jpg');
                content.find('.import-progress .message .service-name').text(service_name);
                content.find('.import-progress .message').center_x();
            };


            var on_close = function(){
                zz.toolbars.enable_buttons();
            };

            zz.dialog.show_square_dialog(content, {width:800, height:600, on_close: on_close});

        });
    };
}());