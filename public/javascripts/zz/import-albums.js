var zz = zz || {};
zz.import_albums = zz.import_albums || {};

(function(){

    var BETA_LIST = [

    ];




    function SELECT_SERVICE_TEMPLATE(){
        return '<div class="import-all">' +
                    '<div class="select-service">' +
                        '<div class="header">Import All Your Photos</div>' +
                        '<div class="sub-header">Choose a service to import your photos</div>' +
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
                        '<div class="header service-name">Service Name Import</div>' +
                        '<div class="sub-header">Choose the default privacy setting for you imported albums.<br>You can always change it for each album.</div>' +
                        '<div class="privacy-buttons">' +
                            '<div class="public-button selected"></div>' +
                            '<div class="hidden-button"></div>' +
                            '<div class="password-button"></div>' +
                        '</div>' +
                        '<a class="green-button import-all-button"><span>Import My Albums</span></a>' +
                    '</div>' +
                    '<div class="import-progress">' +
                        '<img class="import-image">'+
                        '<div class="message">Importing albums from <span class="service-name"></span></div>'+
                        '<img class="spinner" src="/images/loading.gif">'+
                    '</div>' +
               '</div>';
    }



    zz.import_albums.init = function(){
        var show_import = (zz.config.rails_env!='photo_production' || _.find(BETA_LIST, function(id){
            return id == zz.session.current_user_id;
        }));

        if(show_import){
            $('#import-button').show();
        }
    };

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
                        show_confirm_screen(service_name);
                    }
                    else{
                        zz.oauthmanager.login(zz.routes.identities.login_url_for_service(service_name), function() {
                            show_confirm_screen(service_name);
                        });
                    }
                });
            });


            var show_confirm_screen = function(service_name){
                zz.routes.identities.get_identity_for_service(service_name, function(identity){
                    content.find('.select-service').hide();
                    content.find('.confirm-import').show();


                    content.find('.confirm-import .service-name').text(identity.name + ' Import');


                    content.find('.confirm-import .import-all-button').click(function(){
                        if(identity.last_import_all){
                            var d = new Date(identity.last_import_all);
                            var formatted_date = d.getMonth() + '-' + d.getDate() + '-' + d.getFullYear();
                            var message = 'You already imported ablums from ' + idenity.service_name + ' on ' + formatted_date +'. If you import again, you may end up with duplicate albums. Do you want to continue?';
                            if(!confirm(message)){
                                return;
                            }
                        }

                        show_progress_screen_and_start_import(service_name);
                    });


                });
            };


            var show_progress_screen_and_start_import = function(service_name){
                var on_finished = function(){
                    alert('done!');
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

            zz.dialog.show_dialog(content, {width:890, height:530, on_close: on_close});

        });
    };
}());