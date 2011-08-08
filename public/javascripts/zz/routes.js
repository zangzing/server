var zz = zz || {};

zz.routes = {

    path_prefix: '/service',

    edit_user_path: function(username){
        return '/:username/settings'.replace(':username', username);
    },

    delete_identity_path: function(identity_name){
        return '/service/:identity_name/sessions/destroy'.replace(':identity_name', identity_name);
    },

    new_identity_path: function(identity_name){
        return '/service/:identity_name/sessions/new'.replace(':identity_name', identity_name);

    },

    signin_path: function(){
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
    }
    
};