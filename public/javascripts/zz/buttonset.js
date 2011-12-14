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
                    if( $(this).hasClass('active-state') ){
                        if( $(this).find('div.arrow')){
                            if( $(this).hasClass('arrow-up') ){
                                $(this).removeClass('arrow-up').addClass('arrow-down');
                            }else if( $(this).hasClass('arrow-down') ){
                                $(this).removeClass('arrow-down').addClass('arrow-up');
                            }
                        }
                    } else {
                        $(this).parents('.zz-buttonset:first').find(".zz-setbutton.active-state").removeClass("active-state");
                        $(this).addClass("active-state");
                    }
                })
                .mouseup(function(){
                    if(! $(this).is('.zz-setbutton') ){
                        $(this).removeClass("active-state");
                    }
                });
        });
})(jQuery);