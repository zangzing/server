var css_transform = {

    rotate : function(element, angle, left, top) {
        if ($.client.browser == "Explorer") {
            this._ie_rotate(element, angle, left, top);
        }
        else {
            var rotate = "rotate(" + angle + "deg)";

            $(element).css({
                '-moz-transform':    rotate,
                '-webkit-transform': rotate
            });
        }
    },

    _ie_rotate : function(element, angle, left, top) {

        //
        // copied from http://extremelysatisfactorytotalitarianism.com/projects/misc/2010/02/ie8_live/rotate_math_correction.html
        //

        angle = angle / 57;  //i have no idea why this correction works

        var target = element;

        // original layout



        var x = target.position().left;
        var y = target.position().top;
        var w = target.width();
        var h = target.height();

        if(left){
            x = left;
        }

        if(top){
            y = top;
        }


        // save some divisions
        var halfW = w / 2;
        var halfH = h / 2;

        var costheta = Math.cos(angle);
        var sintheta = Math.sin(angle);
        var a = costheta;
        var b = sintheta;
        var c = -sintheta;
        var d = costheta;
        var e = 0; // no translation in this example
        var f = 0;

        // set linear transformation via Matrix Filter
        var filter = 'progid:DXImageTransform.Microsoft.Matrix(';
        filter += 'M11=' + a;
        filter += ', M21=' + b;
        filter += ', M12=' + c;
        filter += ', M22=' + d;
        filter += ', SizingMethod="auto expand")';

        // horizontal shift
        a = Math.abs(a); // or go ternary
        c = Math.abs(c);
        var sx = (a - 1) * halfW + c * halfH;

        // vertical shift
        b = Math.abs(b);
        d = Math.abs(d);
        var sy = b * halfW + (d - 1) * halfH;


        target.css({
            filter: filter,

            // translation, corrected for origin shift
            // rounding helps--but doesn't eliminate--integer jittering
            left: Math.round(x + e - sx) + 'px',
            top: Math.round(y + f - sy) + 'px'
        })

    }
};

jQuery.fn.rotate = function(angle){
    css_transform.rotate(this, angle);
    return this;
};