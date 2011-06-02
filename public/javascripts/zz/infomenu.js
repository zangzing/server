var infomenu = {

    template: '<ul>'+
            '<li class="download"><a href="#download">Download</a></li>'+
//           '<li class="privacy"><a href="#privacy">Privacy</a></li>'+
//           '<li class="rotater"><a href="#rotater">Right</a></li>'+
//           '<li class="rotatel"><a href="#rotatel">Left</a></li>'+
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>'+
            '<li class="delete"><a href="#deletephoto">Delete</a></li>'+
            '</ul>',

    click_handler: function(event,data){
        var action  = data.action,
                options = data.options,
                photo   = options.zz_photo,
                id      = options.subject_id,
                type    = options.subject_type;

        switch( action ){
            case 'download':
                var show_dialog = function( message ){
                    var template = '<div class="downloading-dialog-content">'+message+'</div>';
                    zz_dialog.show_dialog(template, { width:300, height: 100, modal: true, autoOpen: true });
                };
                var success = function( url ){
                    if($.client.os =="Mac"){
                        document.location.href = url;
                    }else{
                        if($.client.browser == 'Chrome'){ //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                            window.open(url);
                        }else{
                            document.location.href = url;
                        }
                    }
                };
                var error = function( request ){
                    var message = "of a strange circumstance";
                    if( request.status == 401 ){
                        message = "you are not authorized to download this photo";
                    } else {
                        var json = request.getResponseHeader("X-Flash");
                        var flash;
                        if( !_.isUndefined( json ) && (flash = $.parseJSON(json)) && flash.error ){
                            message = flash.error;
                        }
                    }
                    show_dialog( 'Unable to download because '+ message );
                };

                zzapi_photo.download( id, function(url){ success(url)}, function(request){error(request);} );
                break;
            case 'setcover':
                zzapi_album.set_cover( zz.album_id, id,
                        function(){ zz.toolbars.load_album_cover( photo.options.previewSrc); });
                break;
            case 'deletephoto':
                photo.delete_photo();
                break;
            default:
                alert( 'InfoMenu Click Handler\n\n' +
                        'Action: ' + action + '\n\n' +
                        'Subject Type: ' + type + '\n\n' +
                        'Subject ID: ' +  id + '\n\n');
                break;
        }
    }
};