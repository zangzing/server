var async_ajax = {
      MAX_CALLS: 350,
      DELAY: 1000,

      get: function(url, success_callback, failure_callback){
            var self = this;

            var makeCall;

            var calls = 0;



            var success = function(data, status, request){
                var pollUrl = request.getResponseHeader('x-poll-for-response');

                logger.debug(pollUrl);

                if(pollUrl){
                    setTimeout(function(){
                        makeCall(pollUrl);
                    }, self.DELAY);
                }
                else{
                    success_callback(data);
                }
            };


            makeCall = function(callUrl){
                calls ++;

                logger.debug('making call ' + calls);
                if(calls > self.MAX_CALLS){
                    failure_callback("timeout");
                }
                else{
                    $.ajax({
                        url: callUrl,
                        success: success,
                        error: function(request, error, errorThrown){
                            logger.debug(error);
                            failure_callback(request, error, errorThrown);
                        }
                    });
                }
            };

            makeCall(url);
      }
};