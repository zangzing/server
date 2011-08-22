var zz = zz || {};

zz.routes = {

    path_prefix: '/service',

    edit_user_path: function(username) {
        return '/:username/settings'.replace(':username', username);
    },

    delete_identity_path: function(identity_name) {
        return '/service/:identity_name/sessions/destroy'.replace(':identity_name', identity_name);
    },

    new_identity_path: function(identity_name) {
        return '/service/:identity_name/sessions/new'.replace(':identity_name', identity_name);

    },

    signin_path: function() {
        return '/signin';
    },

    image_url: function(path) {
        if (zz.config.rails_asset_host) {
            var host_num = path.length % 4;
            return document.location.protocol + '//' + zz.config.rails_asset_host.replace('%d', host_num) + path + '?' + zz.config.rails_asset_id;
        }
        else {
            return path + '?' + zz.config.rails_asset_id;
        }
    },





    // todo: not sure these really belong here...
    //       but seems we do need central place to manage
    //       calls to server


    call_add_to_cart: function( photo_id, success, error ){
          $.ajax({
            type: "POST",
            dataType: "json",
            data:{photo_id:photo_id},
            url: "/store/orders/add_photo.json",
            error: function(){
                if(!_.isUndefined(error)){
                    error();
                }
            },
            success: function(){
                if( !_.isUndefined( success ) ){
                    success();
                }
            }
        });
    },

    call_delete_album: function(album_id, success, error) {
        $.ajax({
            type: 'POST',
            dataType: 'json',
            data: {_method: 'delete'},
            url: zz.routes.path_prefix + '/albums/' + album_id + '.json',
            error: function() {
                if (!_.isUndefined(error)) {
                    error();
                }
            },
            success: function() {
                zz.agent.callAgent('/albums/' + album_id + '/photos/*/cancel_upload');
                if (!_.isUndefined(success)) {
                    success();
                }
            }

        });
    },

    call_set_album_cover: function(album_id, photo_id, success, error) {
        $.ajax({ type: 'POST',
            url: zz.routes.path_prefix + '/albums/' + album_id,
            data: { '_method': 'put', 'album[cover_photo_id]': photo_id },
            error: function() {
                if (!_.isUndefined(error)) {
                    error();
                }
            },
            success: function() {
                if (!_.isUndefined(success)) {
                    success();
                }
            }
        });
    },

    call_delete_photo: function(photo_id, success, error) {
        $.ajax({
            type: 'POST',
            dataType: 'json',
            data: {_method: 'delete'},
            url: zz.routes.path_prefix + '/photos/' + photo_id + '.json',
            error: function() {
                if (!_.isUndefined(error)) {
                    error();
                }
            },
            success: function() {
                zz.agent.callAgent('/albums/' + zz.page.album_id + '/photos/' + photo_id + '/cancel_upload');
                if (!_.isUndefined(success)) {
                    success();
                }
            }
        });
    },

    call_rotate_photo_left: function(photo_id, success, failure) {
        this._call_rotate_photo(photo_id, 'left', success, failure);
    },

    call_rotate_photo_right: function(photo_id, success, failure) {
        this._call_rotate_photo(photo_id, 'right', success, failure);
    },

    // shows progress dialog and rotates photo on the server
    // success callback is passed the json of the rotated photo
    _call_rotate_photo: function(photo_id, direction, success, failure) {
        var dialog = zz.dialog.show_progress_dialog('Rotating photo...');

        var on_success = function(json) {
            dialog.close();
            if (_.isFunction(success)) {
                success(json);
            }
        };

        var on_failure = function(request, error, errorThrown) {
            dialog.close();
            if (_.isFunction(failure)) {
                failure(request, error, errorThrown);
            }
            alert(error);
        };

        zz.async_ajax.put('/service/photos/' + photo_id + '/async_rotate_' + direction, on_success, on_failure);
    }




};
