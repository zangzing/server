var zz = zz || {};

zz.agent = {

    agentId: null,

    STATUS: {
        READY: true,
        NOT_RUNNING: false,
        NOT_READY: "not ready"
    },


    getStatus:function(callback) {
        var pingUrl = this.buildAgentUrl("/ping");


        $.jsonp({
            url: pingUrl,
            success: function(response) {
                if (response.headers.status == 200) {
                    callback(zz.agent.STATUS.READY);
                }
                else {
                    ZZAt.track('agent.ping.invalid', response);
                    callback(zz.agent.STATUS.NOT_READY);
                }
            },
            error: function() {
                callback(zz.agent.STATUS.NOT_RUNNING)
            }
        });
    },

    //todo: this needs to be cleaned up
    isAgentUrl: function(url) {
        if (url) {
            return url.indexOf('http://localhost:' + zz.agent_port) === 0;
        }
        else {
            return false;
        }
    },

    //if this is an agent url, add credentials
    checkAddCredentialsToUrl: function(url) {
        if (this.isAgentUrl(url)) {
            if (url.indexOf('session=') === -1 && typeof(zz.current_user_id) !== 'undefined') {
                if (url.indexOf('?') > -1) {
                    url += '&';
                }
                else {
                    url += '?';
                }

                //note: this is duplicated in application_helper.rb
                url += 'session=' + $.cookie('user_credentials') + '&user_id=' + zz.current_user_id + '&callback=?';
            }

            return url;
        }
        else {
            return url;
        }
    },

    /* path may be full url or just path portion */
    buildAgentUrl: function(path) {
        var url = '';

        if (! path) {
            return path;
        }

        if (! zz.agent.isAgentUrl(path)) {
            if ((path.indexOf('http://') !== -1) || (path.indexOf('https://') !== -1)) {
                return path;
            }
            else {
                url = 'http://localhost:' + zz.agent_port;
            }
        }

        url += path;


        //fix agent port
        url = url.replace(/http:\/\/localhost:[^\/]*/, "http://localhost:" + zz.agent_port);


        return this.checkAddCredentialsToUrl(url);
    },




    callAgent: function(path, onSuccess, onError) {
        var url;
        var user_session = $.cookie("user_credentials");
        if (path.indexOf('?') == -1) {
            url = "http://localhost:" + this.port + path + "?session=" + user_session + '&user_id=' + zz.current_user_id + "&callback=?";
        }
        else {
            url = "http://localhost:" + this.port + path + "&session=" + user_session + '&user_id=' + zz.current_user_id + "&callback=?";
        }


        //this is called when the http call succeeds
        var successHandler = function(response) {
            if (response.headers.status == 200) {
                onSuccess(response.body);
            }
            else {
                //this is an error wrapped in JSON
                errorHandler(response);
            }

        };

        //this is called when the http call fails
        var errorHandler = function(response) {
            if (response.headers) {
                //this error is wrapped in JSON
                zz.logger.debug("error calling agent: " + response.headers.status + ":" + response.headers.error_message + " url:  " + url);
            }
            else {
                zz.logger.debug("no response or invalid response from agent. url: " + url);
            }

            if (typeof(onError) != 'undefined') {
                onError();
            }
        };

        $.jsonp({
            url: url,
            success: successHandler,
            error: errorHandler
        });
    }
};