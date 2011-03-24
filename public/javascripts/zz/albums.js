
function deleteAlbum(album_id, success, error){
    $.ajax({
        type: "DELETE",
        dataType: "json",
        url: zz.path_prefix + "/albums/" + album_id + ".json",
        error: function(){
            if(!_.isUndefined(error)){
                success();
            }
        },
        success:function(){
            agent.callAgent('/albums/' +  album_id + '/photos/*/cancel_upload');
            if(!_.isUndefined(success)){
                success();
            }
        }

    });
}