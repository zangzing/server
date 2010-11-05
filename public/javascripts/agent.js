//
// agent.js
//
// Copyright �2010, ZangZing LLC. All rights reserved.
//


var agent = {

    port : 30777,
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

            url += 'session=' + $.cookie('user_credentials') + '&user_id=' + user_id + '&callback=?';
        }

        return url;
    },




    callAgent: function(path, onSuccess, onError) {
        var url;
        var user_session = $.cookie("user_credentials");
        if (path.indexOf('?') == -1) {
            url = "http://localhost:" + this.port + path + "?session="+user_session + "&user_id=" + user_id + "&callback=?"
        }
        else {
            url = "http://localhost:" + this.port + path + "&session="+user_session + "&user_id=" + user_id + "&callback=?"
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