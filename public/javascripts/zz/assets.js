var assets = {
    url_for: function(path){
        if(zz.rails_asset_host){
            var host_num = path.length % 4;
            return 'http://' + zz.rails_asset_host.replace('%d', host_num) + path + '?' + zz.rails_asset_id;
        }
        else{
            return path + '?' + zz.rails_asset_id;
        }
    }
};