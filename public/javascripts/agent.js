//
// agent.js
//
// Copyright �2010, ZangZing LLC. All rights reserved.
//


var agent = {

    port : 9090,
    agentId: null,
    
    isAvailable: function(callback) {

        var onSuccess = function() {
            callback(true)
        }

        var onError = function() {
            callback(false)
        }


        this.callAgent("/ping", onSuccess, onError)

    },


    isAgentUrl: function(url){
        return url.indexOf('http://localhost:' + agent.port) === 0;
    },

    buildAgentUrl: function(path){
        var url = '';
        if(! agent.isAgentUrl(path)){
            url = 'http://localhost:' + agent.port;
        }

        url += path;

        if(url.indexOf('session=') === -1)
        {
            if(url.indexOf('?') > -1){
                url += '&';
            }
            else{
                url += '?';
            }

            url += 'session=' + $.cookie('user_credentials') + '&user_id=' + zz.user_id + '&callback=?';
//            url += 'session=' + $.cookie('user_credentials') + '&callback=?';
        }

        logger.debug(url);

        return url;
    },


//    getAgentId: function(onSuccess, onError){
//        if(this.agentId != null){
//            onSuccess(this.agentId);
//        }
//        else{
//            var me = this;  //so we can use in handler function
//
//
//            var successHandler = function(json){
//                me.agentId = json['agent_id']
//                onSuccess(me.agentId)
//            }
//
//            this.callAgent("/ping", successHandler, onError);
//        }
//    },
//
//    getFiles: function(virtualPath, onSuccess, onError) {
//        this.callAgent("/files/" + encodeURIComponent(virtualPath), onSuccess, onError)
//    },
//
//    getRoots: function(onSuccess, onError) {
//        this.callAgent("/roots", onSuccess, onError)
//    },
//
//
//    uploadPhoto: function(albumId, virtualPath, onSuccess, onError) {
//        this.callAgent("/albums/" + albumId + "/photos/upload?path=" + encodeURIComponent(virtualPath), onSuccess, onError)
//    },
//
//    cancelUpload : function(albumId, photoId, onSuccess, onError) {
//        this.callAgent("/albums/" + albumId + "/photos/" + photoId + "/cancel_upload", onSuccess, onError)
//    },
//
//
//    getThumbnailUrl: function(path, hint) {
//        var user_session = $.cookie("user_credentials");
//        var url = "http://localhost:" + this.port + "/files/" + encodeURIComponent(path) + "/thumbnail?session=" +user_session;
//        if (hint && hint.length > 0) {
//            url += "&hint=" + hint;
//        }
//        return url;
//    },


    callAgent: function(path, onSuccess, onError) {
        var url;
        var user_session = $.cookie("user_credentials");
        if (path.indexOf('?') == -1) {
            url = "http://localhost:" + this.port + path + "?session="+user_session+"&callback=?"
        }
        else {
            url = "http://localhost:" + this.port + path + "&session="+user_session+"&callback=?"
        }


        //this is called when the http call succeeds
        var successHandler = function(response){
            if(response.headers.status == 200){
                onSuccess(response.body)
            }
            else{
                //this is an error wrapped in JSON
                errorHandler(response)
            }

        }

        //this is called when the http call fails
        var errorHandler = function(response){
            if(response.headers){
                //this error is wrapped in JSON
                logger.debug("error calling agent: " + response.headers.status + ":" + response.headers.error_message + " url:  " + url )
            }
            else{
                logger.debug("no response or invalid response from agent. url: " + url )
            }
            
            if(typeof(onError) != 'undefined'){
                onError()  
            }
        }

        $.jsonp({
            url: url,
            success: successHandler,
            error: errorHandler
        });
    }
}