/**
 * @preserve
 * ---------
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};

zz.oauthmanager = {
    callback : null,
    
    login: function(url, callback){
        zz.oauthmanager.callback = callback;
        window.open(url, 'oauthlogin', 'status=0,toolbar=0,width=900,height=700');
    },

    login_facebook: function(callback){
        this.login(zz.routes.path_prefix + '/facebook/sessions/new', function(){
            zz.session.has_facebook_token = true;
            callback();
        });
    },

    login_twitter: function(callback){
        this.login(zz.routes.path_prefix + '/twitter/sessions/new', function(){
            zz.session.has_twitter_token = true;
            callback();
        });
    },


    on_login: function(){
        zz.oauthmanager.callback();
    }
};


//this is used in the popup window
zz.oauthmanager_popup = {
    close : function(){
        if(window.opener){
            window.opener.zz.oauthmanager.on_login();
            window.close();
        }
    }
};

