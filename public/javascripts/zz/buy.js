var zz = zz || {};

(function(){

    zz.buy = zz.buy || {};

    zz.buy.EVENTS = {
        BEFORE_ACTIVATE: 'zz.buy.before_activate',
        ACTIVATE: 'zz.buy.activate',
        BEFORE_DEACTIVATE: 'zz.buy.BEFORE_deactivate',
        DEACTIVATE: 'zz.buy.deactivate'
    };

    zz.buy.init = function(){
        if(zz.buy.is_buy_mode_active()){
            $('#buy-drawer').css('right', 0).show();
            $('#article').css('right', 445);
        }
    };

    zz.buy.is_buy_mode_active = function(){
        return jQuery.cookie('buy_mode') == 'true';
    };

    zz.buy.activate_buy_mode = function(){
        zz.pubsub.publish(zz.buy.EVENTS.BEFORE_ACTIVATE);
        jQuery.cookie('buy_mode', 'true', {path:'/'});
        open_drawer(function(){
            zz.pubsub.publish(zz.buy.EVENTS.ACTIVATE);
        });
    };

    zz.buy.deactivate_buy_mode = function(){
        zz.pubsub.publish(zz.buy.EVENTS.BEFORE_DEACTIVATE);
        jQuery.cookie('buy_mode', 'false', {path:'/'});
        close_drawer(function(){
            zz.pubsub.publish(zz.buy.EVENTS.DEACTIVATE);
        });
    };


    function open_drawer(callback){
        $('#article').fadeOut('fast', function(){
            $('#buy-drawer').show().animate({right:0},500, function(){
                $('#article').css({right:445});
                $('#article').fadeIn('fast');
                callback();
            });
        });
    }

    function close_drawer(callback){
        $('#article').fadeOut('fast', function(){
            $('#buy-drawer').show().animate({right:-450},500, function(){
                $('#article').css({right:0});
                $('#article').fadeIn('fast');
                $(this).hide();
                callback();
            });
        });
    }


})();