var cache_helper = {

    check_bad_album_json: function(xhr, message, album_id, url){
        if(xhr.status == 200 && message == 'parsererror'){
            $.post(zz.path_prefix + '/albums/' + album_id + '/photos_json_invalidate', {_method: 'put'});

            ZZAt.track('album.cache.corruption', {album_id: album_id, url: url || ""});
            return true;
        }
        else{
            return false;
        }
    },


    check_bad_homepage_json: function(xhr, message, user_id, url){
        if(xhr.status == 200 && message == 'parsererror'){
            $.post(zz.path_prefix + '/users/' + user_id + '/invalidate_cache', {_method: 'put'});

            ZZAt.track('homepage.cache.corruption', {user_id: user_id, url: url || ""});
            return true;
        }
        else{
            return false;
        }

    }
};