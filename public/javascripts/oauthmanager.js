//this is used in the main window
var oauthmanager = {


    callback : null,

    login : function(url, callback){
        oauthmanager.callback = callback;
        window.open(url, 'oauth-login', 'status=0,toolbar=0,width=500,height=500');
    },

    on_login : function(){
        oauthmanager.callback()
    }
}


//this is used in the popup window
var oauthmanager_popup = {

    close : function(){
        if(window.opener){
            window.opener.oauthmanager.on_login();
            window.close();
        }
    }



}