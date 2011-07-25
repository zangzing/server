var photo_manipulation = {

    rotate_left: function(photo_id, success, failure){
        this._rotate(photo_id, 'left', success, failure)
    },

    rotate_right: function(photo_id, success, failure){
        this._rotate(photo_id, 'right', success, failure)
    },

    // shows progress dialog and rotates photo on the server
    // success callback is passed the json of the rotated photo
    _rotate: function(photo_id, direction, success, failure){
        var dialog = zz_dialog.show_progress_dialog("Rotating photo...");

        var on_success = function(json){
            dialog.close();
            if(_.isFunction(success)){
                success(json);
            }
        };

        var on_failure = function(request, error, errorThrown){
            dialog.close();
            if(_.isFunction(failure)){
                failure(request, error, errorThrown);
            }
            alert(error );
        };

        async_ajax.put('/service/photos/' + photo_id + '/async_rotate_' + direction, on_success, on_failure);
    }

};