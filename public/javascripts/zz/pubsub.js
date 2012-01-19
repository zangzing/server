var zz = zz || {};

(function(){

    zz.pubsub = zz.pubsub || {};


    // key is event name
    // value is array of subscription callback functions
    var subscriptions = {};

    zz.pubsub.subscribe = function(event, callback){
        subscriptions[event] = subscriptions[event] || [];
        subscriptions[event].push(callback);
    };

    zz.pubsub.unsubscribe = function(event, callback){
        if(subscriptions[event]){
            subscriptions[event] = _.without(subscriptions[event], [callback]);
        }
    };

    zz.pubsub.publish = function(event, data){
        if(subscriptions[event]){
            _.each(subscriptions[event], function(callback){
                callback(event, data || {});
            });
        }
    };

    zz.pubsub.subscriptions = function(){
        return subscriptions;
    };

})();