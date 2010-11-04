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

    init_social: function(){
        $("#facebook_box").click( function(){
            if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
                $(this).attr('checked', false);
                oauthmanager.login( '/facebook/sessions/new', oauthmanager.facebook_login_success);
            }});
        $("#twitter_box").click( function(){
            if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
                $(this).attr('checked', false);
                oauthmanager.login( '/twitter/sessions/new', oauthmanager.twitter_login_success );
            }});
    },

    facebook_login_success: function(){
        $("#facebook_box").attr('checked', true);
        $("#facebook_box").attr('authorized', 'yes');
    },

    twitter_login_success: function(){
        $("#twitter_box").attr('checked', true);
        $("#twitter_box").attr('authorized', 'yes');
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