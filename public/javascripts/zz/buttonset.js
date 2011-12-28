//
// buttonset.js
//
// The buttonset requires buttonset.css and pie.htc for IE

var zz = zz || {};
zz.buttonset = {};

(function($){
    zz.buttonset.init = function( default_action ){
        $('.zz-setbutton:not(.ui-state-disabled)')
            .hover(
            function(){
                $(this).addClass("hover-state");
            },
            function(){
                $(this).removeClass("hover-state");
            }
        ).mousedown( function(){
                var action = $(this).attr('data-action');
                if( $(this).hasClass('active-state') ){
                    if( $(this).find('div.arrow').length > 0 ){
                        if( $(this).hasClass('arrow-up') ){
                            action = action+'-down';
                            $(this).removeClass('arrow-up').addClass('arrow-down');
                        }else if( $(this).hasClass('arrow-down') ){
                            $(this).removeClass('arrow-down').addClass('arrow-up');
                            action = action+'-up';
                        }
                        $(this).trigger('buttonset-click', [action]);
                    }
                }else{
                    $(this).parents('.zz-buttonset:first').find(".zz-setbutton.active-state").removeClass("active-state");
                    $(this).addClass("active-state");
                    if( $(this).hasClass('arrow-up') ){
                        action = action+'-up'
                    }else if( $(this).hasClass('arrow-down') ){
                        action = action+'-down'
                    }
                    $(this).trigger('buttonset-click',[action]);
                }

            });
        if( typeof( default_action ) != 'undefined' && default_action.length > 0){
            zz.buttonset.activate( default_action );
        }
    }

    zz.buttonset.activate = function( action ){
        var action_parts = action.split('-');

        switch( action_parts[ action_parts.length -1 ] ){
            case 'up':
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action.substr(0, action.length-3)+']').trigger('mousedown');
                break;
            case 'down':
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action.substr(0, action.length-5)+']').trigger('mousedown');
                break;
            default:
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action+']').trigger('mousedown');
                break;
        }

    }
})(jQuery);