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


    var EVENTS = {
        BEFORE_ACTIVATE: 'zz.buy.before_activate',
        ACTIVATE: 'zz.buy.activate',
        BEFORE_DEACTIVATE: 'zz.buy.BEFORE_deactivate',
        DEACTIVATE: 'zz.buy.deactivate'
    };

    zz.buy.init = function(){
        if(zz.buy.is_buy_mode_active()){
            $('#right-drawer').css('right', 0).show();
            $('#article').css('right', 445);
        }



        if(zz.buy.is_buy_mode_active()){
            $('#footer #buy-button').addClass('selected');
        }
        $('#footer #buy-button').click(function() {
            if (! $(this).hasClass('disabled')) {
                if(zz.buy.is_buy_mode_active()){
                    zz.buy.deactivate_buy_mode();
                    $(this).removeClass('selected');
                }
                else{
                    zz.buy.activate_buy_mode();
                    $(this).addClass('selected');
                }
            }
        });



    };


    zz.buy.toggle_visibility_with_buy_mode = function(element){
        if(zz.buy.is_buy_mode_active()){
            $(element).hide();
        }

        zz.buy.on_before_activate(function(){
            $(element).fadeOut('fast');

        });

        zz.buy.on_before_deactivate(function(){
            $(element).fadeIn('fast');

        });
    };

    zz.buy.is_buy_mode_active = function(){
        return jQuery.cookie('buy_mode') == 'true';
    };

    zz.buy.activate_buy_mode = function(){
        zz.pubsub.publish(EVENTS.BEFORE_ACTIVATE);
        jQuery.cookie('buy_mode', 'true', {path:'/'});
        open_drawer(function(){
            zz.pubsub.publish(EVENTS.ACTIVATE);
        });
    };

    zz.buy.deactivate_buy_mode = function(){
        zz.pubsub.publish(EVENTS.BEFORE_DEACTIVATE);
        jQuery.cookie('buy_mode', 'false', {path:'/'});
        close_drawer(function(){
            zz.pubsub.publish(EVENTS.DEACTIVATE);
        });
    };

    zz.buy.select_photo = function(photo_id, element, callback){

        if(zz.buy.is_photo_selected(photo_id)){
            // don't allow selecting the same photo more than once
            return; 
        }

        selected_photo_ids.push(photo_id);

        zz.routes.call_add_to_cart(photo_id);


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

    zz.buy.on_before_activate = function(callback){
        zz.pubsub.subscribe(EVENTS.BEFORE_ACTIVATE, callback)
    };

    zz.buy.on_activate = function(callback){
        zz.pubsub.subscribe(EVENTS.ACTIVATE, callback)
    };

    zz.buy.on_before_deactivate = function(callback){
        zz.pubsub.subscribe(EVENTS.BEFORE_DEACTIVATE, callback)
    };

    zz.buy.on_deactivate = function(callback){
        zz.pubsub.subscribe(EVENTS.DEACTIVATE, callback)
    };

    zz.buy.on_before_change_buy_mode = function(callback){
        zz.buy.on_before_activate(callback);
        zz.buy.on_before_deactivate(callback);
    };

    zz.buy.on_change_buy_mode = function(callback){
        zz.buy.on_activate(callback);
        zz.buy.on_deactivate(callback);
    };

    function render_select_product_screen(){

    }

    function render_configure_product_screen(){

    }

    function render_select_photos_screen(){

    }


    function open_drawer(callback){
        $('#article').fadeOut('fast', function(){
            $('#right-drawer').html('<a id="checkout-button" class="newgreen-button"><span>Checkout</span></a>');

            $('#right-drawer #checkout-button').click(function(){
                document.location.href = '/store/cart'
            });


            $('#right-drawer').show().animate({right:0},500, function(){
                $('#article').css({right:445});
                $('#article').show();
                callback();
            });
        });
    }

    function close_drawer(callback){
        $('#article').fadeOut('fast', function(){
            $('#right-drawer').animate({right:-450},500, function(){
                $('#article').css({right:0});
                $('#article').show();
                $('#right-drawer').hide();
                callback();
            });
        });
    }


})();