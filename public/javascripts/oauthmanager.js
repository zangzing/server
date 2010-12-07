//this is used in the main window
var oauthmanager = {
    callback : null,
    login: function(url, callback){
        oauthmanager.callback = callback;
        window.open(url, 'oauthlogin', 'status=0,toolbar=0,width=900,height=700');
    },

    on_login: function(){
        oauthmanager.callback()
    },

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