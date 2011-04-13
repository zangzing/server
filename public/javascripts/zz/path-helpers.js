var path_helpers = {
    image_url: function(path){
        if(zz.rails_asset_host){
            var host_num = path.length % 4;
            return 'http://' + zz.rails_asset_host.replace('%d', host_num) + path + '?' + zz.rails_asset_id;
        }
        else{
            return path + '?' + zz.rails_asset_id;
        }
    },


    rails_route: function(name, id){
        if(name == 'edit_user'){
            return '/' + id + '/settings';
        }
        else if(name == 'delete_identity'){
            return '/service/' + id + '/sessions/destroy'
        }
        else if(name == 'new_identity'){
            return '/service/' + id + '/sessions/new'
        }
        else if(name == 'signin'){
            return '/signin';
        }
        return null;
    }


};