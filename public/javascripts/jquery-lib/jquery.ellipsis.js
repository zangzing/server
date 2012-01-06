/**
 * from http://stackoverflow.com/questions/536814/insert-ellipsis-into-html-tag-if-content-too-wide
 */

(function($) {
    $.fn.ellipsis = function(maxWidth)
    {
        return this.each(function()
        {
            var el = $(this);

            if(el.css("overflow") == "hidden")
            {
                var text = el.html();
                var multiline = el.hasClass('multiline');
                var t = $(this.cloneNode(true))
                        .hide()
                        .css('position', 'absolute')
                        .css('overflow', 'visible')
                        .width(multiline ? el.width() : 'auto')
                        .height(multiline ? 'auto' : el.height())
                        ;

                el.after(t);

                var height = function(){ return t.height() > el.height(); };
                var width = function(){ return t.width() >  el.width(); };
                if( maxWidth ){
                    width = function(){ return t.width() > ( maxWidth-10); };
                }

                var func = multiline ? height : width;

                while (text.length > 0 && func())
                {
                    text = text.substr(0, text.length - 1);
                    t.html(text + "...");
                }

                el.html(t.html());
                t.remove();
            }
        });
    };
    $.fn.selectRange = function(start, end) {
        return this.each(function() {
//            if (this.setSelectionRange) {
//                this.focus();
//                this.setSelectionRange(start, end);
//            } else
            if (this.createTextRange) {
                var range = this.createTextRange();
                range.collapse(true);
                range.moveEnd('character', end);
                range.moveStart('character', start);
                range.select();
            }
        });
    };
})(jQuery);