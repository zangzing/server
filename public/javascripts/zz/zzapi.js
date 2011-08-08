var zzapi_album = {
    delete_album: function(album_id, success, error) {
        $.ajax({
            type: "POST",
            dataType: "json",
            data:{_method:'delete'},
            url: zz.routes.path_prefix + "/albums/" + album_id + ".json",
            error: function() {
                if (!_.isUndefined(error)) {
                    error();
                }
            },
            success:function() {
                zz.agent.callAgent('/albums/' + album_id + '/photos/*/cancel_upload');
                if (!_.isUndefined(success)) {
                    success();
                }
            }

        });
    },

    set_cover: function(album_id, photo_id, success, error) {
        $.ajax({ type: 'POST',
            url: zz.routes.path_prefix + '/albums/' + album_id,
            data:{ '_method': 'put','album[cover_photo_id]': photo_id },
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
    }
};

var zzapi_photo = {
    delete_photo: function(photo_id, success, error) {
        $.ajax({
            type: "POST",
            dataType: "json",
            data:{_method:'delete'},
            url: zz.routes.path_prefix + "/photos/" + photo_id + ".json",
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

    download: function(photo_id, success, error) {
        var url = zz.routes.path_prefix + "/photos/download/" + photo_id;
        $.ajax({
            type: "GET",
            dataType: "text",
            url: url + ".json",
            error:   function(request) {
                error(request);
            },
            success: function(data) {
                success(url + ".html");
            }
        });
    },


    rotate_left: function(photo_id, success, failure) {
        this._rotate(photo_id, 'left', success, failure)
    },

    rotate_right: function(photo_id, success, failure) {
        this._rotate(photo_id, 'right', success, failure)
    },

    // shows progress dialog and rotates photo on the server
    // success callback is passed the json of the rotated photo
    _rotate: function(photo_id, direction, success, failure) {
        var dialog = zz.dialog.show_progress_dialog("Rotating photo...");

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


