var zz = zz || {};

zz.mobile = {
    lock_page_scroll: function() {
        $(document).bind('touchmove', function(event) {
            if (event.originalEvent.touches.length == 1) {
                event.preventDefault();
            }
        });
    }
};


(function($) {


    $.fn.touchScrollY = function() {
        var touch_start_y;
        var scroll_start_y;

        $(this).bind('touchstart', function(event) {
            var touch = event.originalEvent.touches[0];
            touch_start_y = touch.pageY;
            scroll_start_y = $(this).scrollTop();
        });


        $(this).bind('touchmove', function(event) {
            var touch = event.originalEvent.touches[0];
            var move_y = touch.pageY;

            $(this).scrollTop(scroll_start_y - (move_y - touch_start_y));


        });
    };

})(jQuery);
