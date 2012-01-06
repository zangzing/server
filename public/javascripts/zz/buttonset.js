//
// buttonset.js
//
// The buttonset requires buttonset.css and pie.htc for IE

var zz = zz || {};
zz.buttonset = {};

(function($){
    zz.buttonset.init = function( default_action ){
        $('.zz-buttonset').attr('disabled','');
        $('#view-sort-bar div.set-title').attr('disabled','');
        $('.zz-setbutton')
            .unbind('click')
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
                        action = action+'-up';
                    }else if( $(this).hasClass('arrow-down') ){
                        action = action+'-down';
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
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action.substr(0, action.length-3)+']')
                    .addClass("active-state arrow-up").removeClass('arrow-down');
                break;
            case 'down':
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action.substr(0, action.length-5)+']')
                    .addClass("active-state arrow-down").removeClass('arrow-up');
                break;
            default:
                $('.zz-buttonset').find('.zz-setbutton[data-action='+action+']').addClass("active-state");
                break;
        }

    }

    zz.buttonset.disable = function(message){
        $('.zz-buttonset').attr('disabled','disabled');
        $('.zz-setbutton')
            .unbind('hover')
            .unbind('mousedown');
        if(!_.isUndefined(message)){
            $('.zz-setbutton').click( function(){ alert(message) });
        }
        $('#view-sort-bar div.set-title').attr('disabled','disabled');
    }

})(jQuery);