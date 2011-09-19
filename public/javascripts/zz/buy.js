var zz = zz || {};
zz.buy = zz.buy || {};

(function(){

    var DRAWER_SCREENS = {
        SELECT_PRODUCT: 'select_product',
        CONFIGURE_PRODUCT: 'configure_product',
        SELECT_PHOTOS: 'select_photos'
    };

    var selected_photo_ids = [];

    var current_drawer_screen = DRAWER_SCREENS.SELECT_PHOTOS;


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

        $('#buy-drawer #checkout-button').click(function(){
            document.location.href = '/store/cart'
        });

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

        if(zz.buy.is_photo_selected(photo_id)){
            // don't allow selecting the same photo more than once
            return; 
        }

        selected_photo_ids.push(photo_id);

        zz.routes.call_add_to_cart( photo_id);


        var imageElement = element.find('.photo-image');

        var start_top = imageElement.offset().top;
        var start_left = imageElement.offset().left;

        var end_top = $('#footer #buy-button').offset().top;
        var end_left = $('#footer #buy-button').offset().left;


        var on_finish_animation = function() {
            if(callback){
                callback();
            }
            $(this).remove();


        };

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

    zz.buy.is_photo_selected = function(photo_id){
        return _.include(selected_photo_ids, photo_id);
    };





    function render_select_product_screen(){

    }

    function render_configure_product_screen(){

    }

    function render_select_photos_screen(){

    }


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