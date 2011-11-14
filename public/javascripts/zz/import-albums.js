var zz = zz || {};
zz.import_albums = zz.import_albums || {};

(function(){
    function SELECT_SERVICE_TEMPLATE(){
        return '<div class="import-all">' +
                    '<div class="select-service">' +
                        '<div class="header">Select a service below and import all your albums to ZangZing</div>' +
                        '<div class="services"></div>' +
                    '</div>' +
               '</div>';
    }


    zz.import_albums.show_import_dialog = function(){
        var content = SELECT_SERVICE_TEMPLATE();
        var on_close = function(){
            zz.toolbars.enable_buttons();
        };
        zz.dialog.show_square_dialog(content, {width:600, height:600, on_close: on_close});
    };





}())