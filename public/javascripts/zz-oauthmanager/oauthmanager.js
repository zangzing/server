/**
 * @preserve
 * ---------
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var oauthmanager = {
    callback : null,
    
    login: function(url, callback){
        oauthmanager.callback = callback;
        window.open(url, 'oauthlogin', 'status=0,toolbar=0,width=900,height=700');
    },

    login_facebook: function(callback){
        this.login(zz.path_prefix + '/facebook/sessions/new', callback);
    },

    login_twitter: function(callback){
        this.login(zz.path_prefix + '/twitter/sessions/new', callback);
    },


    on_login: function(){
        oauthmanager.callback();
    }
};


//this is used in the popup window
var oauthmanager_popup = {
    close : function(){
        if(window.opener){
            window.opener.oauthmanager.on_login();
            window.close();
        }
    }
};

