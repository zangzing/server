/*!
 * jquery-zz.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */


(function($) {


    $.fn.rowLeft = function() {
        var top = this.position().top;
        var sibling = this.prev();
        var list = [];
        while (sibling.length > 0 && sibling.position().top === top) {
            list.push(sibling[0]);
            sibling = sibling.prev();
        }
        return $(list);
    };

    $.fn.rowRight = function() {
        var top = this.position().top;
        var sibling = this.next();
        var list = [];

        while (sibling.length > 0 && sibling.position().top === top) {
            list.push(sibling[0]);
            sibling = sibling.next();
        }
        return $(list);
    };

    $.fn.animateRelative = function(x, y, duration, easing) {
        $.each(this, function(index, element) {
            var el = $(element);


            el.animate({
                left: parseInt(el.css('left')) + x,
                top: parseInt(el.css('top')) + y

            }, duration, easing);
        });
    };

    $.fn.rotate = function(angle) {
        zz.css_transform.rotate(this, angle);
        return this;
    };


    $.fn.center_x = function(container) {
        return this.center(container, true, false);
    };

    $.fn.center_y = function(container) {
        return this.center(container, false, true);
    };


    $.fn.center_xy = function(container) {
        return this.center(container, true, true);
    };

    $.fn.center = function(container, center_x, center_y) {
        _.each(this, function(el) {
            el = $(el);

            var my_container = container;
            if (! my_container) {
                my_container = $(el).parent();
            }

            if ($.isFunction(my_container.parent)) {
                //assume its an element
                var container_element = $(my_container);
                my_container = {
                    left: 0,
                    top: 0,
                    width: container_element.width(),
                    height: container_element.height()
                };
            }




            var left = Math.round((my_container.width - el.width()) / 2 + my_container.left);
            var top = Math.round((my_container.height - el.height()) / 2 + my_container.top);

            if (center_x && center_y) {
                el.css({
                    left: left,
                    top: top
                });
            }
            else if (center_y) {
                el.css({
                    top: top
                });
            }
            else if (center_x) {
                el.css({
                    left: left
                });
            }


        });


        return this;

    };


    $.fn.disableEnterKey = function(elements) {
        _.each(this, function(el) {
            $(el).bind('keypress', function(e) {
                if (e.keyCode == 13) {
                    return false;
                }
            });
        });
    };




})(jQuery);
