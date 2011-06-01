var zzapi_albums = {
    delete_album: function(album_id, success, error){
        $.ajax({
            type: "POST",
            dataType: "json",
            data:{_method:'delete'},
            url: zz.path_prefix + "/albums/" + album_id + ".json",
            error: function(){
                if(!_.isUndefined(error)){
                    error();
                }
            },
            success:function(){
                agent.callAgent('/albums/' +  album_id + '/photos/*/cancel_upload');
                if(!_.isUndefined(success)){
                    success();
                }
            }

        });
    },

    set_cover: function( album_id, photo_id, success, error){
        $.ajax({ type: 'POST',
            url: zz.path_prefix + '/albums/'+album_id,
            data:{ '_method': 'put','album[cover_photo_id]': photo_id },
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
    }
};

var zzapi_photos = {
    delete_photo: function(photo_id, success, error){
        $.ajax({
            type: "POST",
            dataType: "json",
            data:{_method:'delete'},
            url: zz.path_prefix + "/photos/" + photo_id + ".json",
            error: function(){
                if(!_.isUndefined(error)){
                    error();
                }
            },
            success: function(){
                agent.callAgent('/albums/' +  zz.album_id + '/photos/' + photo_id + '/cancel_upload');
                if( !_.isUndefined( success ) ){
                    success();
                }
            }
        });
    }
};

