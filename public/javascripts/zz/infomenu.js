var infomenu = {

    owner_template: '<ul>'+
            '<li class="download"><a href="#download">Download</a></li>'+
//           '<li class="privacy"><a href="#privacy">Privacy</a></li>'+
//           '<li class="rotater"><a href="#rotater">Right</a></li>'+
//           '<li class="rotatel"><a href="#rotatel">Left</a></li>'+
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>'+
            '<li class="rotater"><a href="#add_to_cart">Add To Cart</a></li>'+
            '<li class="delete"><a href="#deletephoto">Delete</a></li>'+
            '</ul>',

    download_template: '<ul>'+
                '<li class="download"><a href="#download">Download</a></li>'+
                '</ul>',

    click_handler: function(event,data){
        var action  = data.action,
                options = data.options,
                photo   = options.zz_photo,
                id      = options.subject_id,
                type    = options.subject_type;

        switch( action ){
            case 'download':
                var url = zz.path_prefix + "/photos/download/" + id;
                if($.client.os =="Mac"){
                    document.location.href = url;
                }else{
                    if(navigator.appVersion.indexOf("NT 5.1") !=  -1 && $.client.browser=='Explorer'){
                        window.open(url);
                    }else if($.client.browser == 'Chrome'){ //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                        window.open(url);
                    }else{
                        document.location.href = url;
                    }
                }
                break;
            case 'setcover':
                zzapi_album.set_cover( zz.album_id, id,
                        function(){ zz.toolbars.load_album_cover( photo.options.previewSrc); });
                break;
            case 'add_to_cart':
                zzapi_photo.add_to_cart( id, function(){
                    $("<div id='flash-dialog'><div><div id='flash'></div>><a id='checkout' class='newgreen-button'><span>Checkout</span></a><a id='ok' class='newgreen-button'><span>OK</span></a></div></div>").zz_dialog({ autoOpen: false });
                                         $('#flash-dialog #flash').text('Your photo has been added to the cart');
                                         $('#ok').click( function(){ $('#flash-dialog').zz_dialog('close').empty().remove(); });
                                         $('#checkout').css({ position: 'absolute', bottom: '30px', left: '40px', width: '80px' })
                                             .click( function(){ window.location = zz.path_prefix+'/store/cart'  });
                                         $('#flash-dialog').zz_dialog('open');
                });
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