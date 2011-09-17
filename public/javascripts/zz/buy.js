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

    zz.buy.select_photo = function(photo_id, element, callback){
        zz.routes.call_add_to_cart( photo_id, function(){
            $("<div id='flash-dialog'><div><div id='flash'></div><a id='checkout' class='newgreen-button'><span>Checkout</span></a><a id='ok' class='newgreen-button'><span>OK</span></a></div></div>").zz_dialog({ autoOpen: false });
            $('#flash-dialog #flash').text('Your photo has been added to the cart');
            $('#ok').click( function(){ $('#flash-dialog').zz_dialog('close').empty().remove(); });
            $('#checkout').css({ position: 'absolute', bottom: '30px', left: '40px', width: '80px' })
             .click( function(){ window.location = '/store/cart'  });
            $('#flash-dialog').zz_dialog('open');
        });


        var imageElement;

        if (element.hasClass('add-all-button')) {
            imageElement = element;
        }
        else {
            imageElement = element.find('.photo-image');
        }


        var start_top = imageElement.offset().top;
        var start_left = imageElement.offset().left;

        var end_top = $('#footer #buy-button').offset().top;
        var end_left = $('#footer #buy-button').offset().left;


        var on_finish_animation = function() {
            if(callback){
                callback();
            }
            $(this).remove();
        }

        imageElement.clone()
                .css({position: 'absolute', left: start_left, top: start_top, border: '1px solid #ffffff'})
                .appendTo('body')
                .addClass('animate-photo-to-tray')
                .animate({
                             width: '20px',
                             height: '20px',
                             top: (end_top) + 'px',
                             left: (end_left) + 'px'
                         }, 1000, 'easeInOutCubic', on_finish_animation);









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