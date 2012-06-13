var zz = zz || {};

zz.infomenu = {

    album_owner_template: '<ul>' +
            '<li class="download"><a href="#download">Download</a></li>' +
            '<li class="rotater"><a href="#rotater">Right</a></li>' +
            '<li class="rotatel"><a href="#rotatel">Left</a></li>' +
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    album_owner_template_photo_not_ready: '<ul>' +
            '<li class="setcover"><a href="#setcover">Set Cover</a></li>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    photo_owner_template: '<ul>' +
            '<li class="download"><a href="#download">Download</a></li>' +
            '<li class="rotater"><a href="#rotater">Right</a></li>' +
            '<li class="rotatel"><a href="#rotatel">Left</a></li>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    photo_owner_template_photo_not_ready: '<ul>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',


    download_template: '<ul>' +
            '<li class="download"><a href="#download">Download</a></li>' +
            '</ul>',

    delete_template: '<ul>' +
            '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
            '</ul>',

    download_delete_template: '<ul>' +
                '<li class="download"><a href="#download">Download</a></li>' +
                '<li class="delete"><a href="#deletephoto">Delete</a></li>' +
                '</ul>',


    show_in_photo: function(button, info_menu_template, zz_photo, photo_id, onclose) {
        button.zz_menu({
            zz_photo: zz_photo,
            container: $('#article'),
            subject_id: photo_id,
            subject_type: 'photo',
            style: 'auto',
            bind_click_open: false,
            append_to_element: false, //use the el zzindex so overflow goes under bottom toolbar
            menu_template: info_menu_template,
            click: zz.infomenu.photo_click_handler,
            close: onclose
        });
        $(button).zz_menu('open');

    },


    photo_click_handler: function(event, data) {
        var action = data.action,
            options = data.options,
            photo = options.zz_photo,
            id = options.subject_id,
            type = options.subject_type;

        switch (action) {
            case 'download':
                var url = zz.routes.path_prefix + '/photos/'+id+'/download';
                ZZAt.track('infomenu.photodownload.click');
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
                alert('this is an alert press ok');
                break;

            case 'rotatel':
                ZZAt.track('infomenu.rotatel.click');
                zz.routes.call_rotate_photo_left(options.subject_id, function(json) {
                    options.zz_photo.changeSrc( json );
                });
                break;

            case 'rotater':
                ZZAt.track('infomenu.rotater.click');
                zz.routes.call_rotate_photo_right(options.subject_id, function(json) {
                    options.zz_photo.changeSrc( json );
                });
                break;

            case 'setcover':
                ZZAt.track('infomenu.setcover.click');
                zz.routes.call_set_album_cover(zz.page.album_id, id, function() {
                    zz.toolbars.load_album_cover(photo.options.previewSrc);
                });
                break;

            case 'deletephoto':
                ZZAt.track('infomenu.photodelete.click');
                photo.delete_photo();
                break;

            default:
                alert('InfoMenu Click Handler\n\n' +
                        'Action: ' + action + '\n\n' +
                        'Subject Type: ' + type + '\n\n' +
                        'Subject ID: ' + id + '\n\n');
                break;

        }
    },

    show_in_picon: function(button, template, picon,  onopen, onclose) {
        button.zz_menu({
            picon:         picon,
            album:         picon.options.album,
            subject_id:    picon.options.album.id,
            subject_type:  'album',
            container:     $('#article'),
            style:         'auto',
            bind_click_open: false,
            append_to_element: false, //use the el zzindex so overflow goes under bottom toolbar
            menu_template: template,
            click: zz.infomenu.album_click_handler,
            open: onopen,
            close: onclose
        });
        $(button).zz_menu('open');
    },


    album_click_handler: function(event, data) {
        var action = data.action,
            options = data.options,
            id = options.subject_id,
            type = options.subject_type,
            album = options.album;

         switch (action) {
           case 'download':
               ZZAt.track('infomenu.albumdownload.click');
               var url = zz.routes.path_prefix + '/albums/' + id +'/download';
                 if ($.client.os == 'Mac') {
                    document.location.href = url;
                } else {
                    if (navigator.appVersion.indexOf('NT 5.1') != -1 && $.client.browser == 'Explorer'){
                        window.open(url);
                    } else if ($.client.browser == 'Chrome') { //on chrome on windows, using the same browser window to download causes js issues (stops pinging agent)
                        window.open(url);
                    } else {
                        document.location.href = url;
                    }
                }
                break;
             case 'deletephoto':
                 ZZAt.track('infomenu.albumdelete.click');
                 if (confirm('Are you sure you want to delete this album?')) {
                     $(options.picon.element).hide('scale', {}, 300, function() {
                         $(options.picon.element).remove();
                     });
                     zz.routes.call_delete_album(album.id);
                 }
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