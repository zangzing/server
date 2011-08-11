var zz = zz || {};

zz.async_ajax = {
    MAX_CALLS: 35,
    DELAY: 1000,

    call: function(url, method, success_callback, failure_callback) {
        var self = this;

        var makeCall;

        var calls = 0;


        var success = function(data, status, request) {
            var pollUrl = request.getResponseHeader('x-poll-for-response');

            if (pollUrl) {
                webdriver.enter_async();  //allows webdriver to wait for ajax polling to complete
                setTimeout(function() {
                    webdriver.leave_async();
                    makeCall(pollUrl, 'get'); //polling call is always GET
                }, self.DELAY);
            }
            else {
                success_callback(data);
            }
        };


        makeCall = function(callUrl, method) {
            calls++;
            var data = {};

            if (calls > self.MAX_CALLS) {
                failure_callback('timeout');
            }
            else {
                if (method.toLowerCase() == 'put') {
                    method = 'post';
                    data = {_method: 'put'};
                }

                $.ajax({
                    url: callUrl,
                    type: method,
                    data: data,
                    success: success,
                    error: function(request, error, errorThrown) {
                        zz.logger.debug(error);
                        failure_callback(request, error, errorThrown);
                    }
                });
            }
        };

        makeCall(url, method);


    },

    get: function(url, success_callback, failure_callback) {
        this.call(url, 'get', success_callback, failure_callback);
    },

    put: function(url, success_callback, failure_callback) {
        this.call(url, 'put', success_callback, failure_callback);
    }


};
