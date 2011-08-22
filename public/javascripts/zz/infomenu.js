var infomenu = {

    album_owner_template: '<ul>'+
            '<li class="download"><a href="#download">Download</a></li>'+
            '<li class="rotater"><a href="#rotater">Right</a></li>'+
            '<li class="rotatel"><a href="#rotatel">Left</a></li>'+
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>'+
            '<li class="rotater"><a href="#add_to_cart">Add To Cart</a></li>'+
            '<li class="delete"><a href="#deletephoto">Delete</a></li>'+
            '</ul>',

    album_owner_template_photo_not_ready: '<ul>' +
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    photo_owner_template: '<ul>' +
            '<li class="download"><a href="#download">Download</a></li>' +
            '<li class="rotater"><a href="#rotater">Right</a></li>' +
            '<li class"rotatel"><a href="#rotatel">Left</a></li>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    photo_owner_template_photo_not_ready: '<ul>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',


    download_template: '<ul>' +
            '<li class="download"><a href="#download">Download</a></li>' +
            '</ul>',



    

    show: function(button, info_menu_template, zz_photo, photo_id, onclose) {
        button.zz_menu({
            zz_photo: zz_photo,
            container: $('#article'),
            subject_id: photo_id,
            subject_type: 'photo',
            style: 'auto',
            bind_click_open: false,
            append_to_element: false, //use the el zzindex so overflow goes under bottom toolbar
            menu_template: info_menu_template,
            click: zz.infomenu.click_handler,
            close: onclose
        });
        $(button).zz_menu('open');

    },





    click_handler: function(event, data) {
        var action = data.action,
            options = data.options,
            photo = options.zz_photo,
            id = options.subject_id,
            type = options.subject_type;

        switch (action) {
            case 'download':
                var url = zz.routes.path_prefix + '/photos/download/' + id;
                if ($.client.os == 'Mac') {
                    document.location.href = url;
                } else {
                    if (navigator.appVersion.indexOf('NT 5.1') != -1 && $.client.browser == 'Explorer') {
                        window.open(url);
                    } else if ($.client.browser == 'Chrome') { //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                        window.open(url);
                    } else {
                        document.location.href = url;
                    }
                }
                break;

            case 'rotatel':
                zz.routes.call_rotate_photo_left(options.subject_id, function(json) {
                    options.zz_photo.changeSrc(json.thumb_url, json.stamp_url);
                });
                break;

            case 'rotater':
                zz.routes.call_rotate_photo_right(options.subject_id, function(json) {
                    options.zz_photo.changeSrc(json.thumb_url, json.stamp_url);
                });
                break;

            case 'setcover':
                zz.routes.call_set_album_cover(zz.page.album_id, id, function() {
                    zz.toolbars.load_album_cover(photo.options.previewSrc);
                });
                break;
            
            case 'add_to_cart':
                zz.routes.call_add_to_cart( id, function(){
                    $("<div id='flash-dialog'><div><div id='flash'></div>><a id='checkout' class='newgreen-button'><span>Checkout</span></a><a id='ok' class='newgreen-button'><span>OK</span></a></div></div>").zz_dialog({ autoOpen: false });
                                         $('#flash-dialog #flash').text('Your photo has been added to the cart');
                                         $('#ok').click( function(){ $('#flash-dialog').zz_dialog('close').empty().remove(); });
                                         $('#checkout').css({ position: 'absolute', bottom: '30px', left: '40px', width: '80px' })
                                             .click( function(){ window.location = '/store/cart'  });
                                         $('#flash-dialog').zz_dialog('open');
                });
                break;

            case 'deletephoto':
                photo.delete_photo();
                break;

            default:
                alert('InfoMenu Click Handler\n\n' +
                        'Action: ' + action + '\n\n' +
                        'Subject Type: ' + type + '\n\n' +
                        'Subject ID: ' + id + '\n\n');
                break;

        }
    }
};
