//
// buttonset.js
//
// The buttonset requires buttonset.css and pie.htc for IE

(function($){
        $(document).ready( function(){
            $('.zz-setbutton:not(.ui-state-disabled)')
                .hover(
                function(){
                    $(this).addClass("hover-state");
                },
                function(){
                    $(this).removeClass("hover-state");
                }
            )
                .mousedown(function(){
                    $(this).parents('.zz-buttonset:first').find(".zz-setbutton.active-state").removeClass("active-state");
                    $(this).addClass("active-state");
                })
                .mouseup(function(){
                    if(! $(this).is('.zz-setbutton') ){
                        $(this).removClass("active-state");
                    }
                });
        });
})(jQuery);