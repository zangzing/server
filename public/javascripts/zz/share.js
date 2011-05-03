var share = {

    MENU_TEMPLATE: '<div class="share-menu">' +
                     '<div class="facebook menu-item">Facebook</div>' +
                     '<div class="twitter menu-item">Twitter</div>' +
                     '<div class="email menu-item">Email</div>' +
                   '</div>',

    EMAIL_SHARE_TEMPLATE:    'mailto:?subject={{subject}}&body={{message}}',
    TWITTER_SHARE_TEMPLATE:  'http://twitter.com/share?text={{message}}&url={{url}}',
    FACEBOOK_SHARE_TEMPLATE: 'http://www.facebook.com/share.php?u={{url}}',



    share_to_email: function(object_type, object_url, object_id){
        if(!zz.current_user_id){
            var url = this.EMAIL_SHARE_TEMPLATE;
            url = url.replace('{{subject}}',encodeURIComponent('this is the email subject'));
            url = url.replace('{{message}}',encodeURIComponent('this is the email body ' + object_url));
            document.location.href = url;
        }
        else{
            pages.share.share_in_dialog(object_type, object_id);
        }
    },

    share_to_twitter: function(object_type, object_url, object_id){
        var url = this.TWITTER_SHARE_TEMPLATE;
        url = url.replace('{{message}}', encodeURIComponent('this is the message'));
        url = url.replace('{{url}}', encodeURIComponent(object_url));
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    },

    share_to_facebook: function(object_type, object_url, object_id){
        var url = this.FACEBOOK_SHARE_TEMPLATE;
        url = url.replace('{{url}}', encodeURIComponent(object_url));
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    },

    show_share_menu: function(button, object_type, object_url, object_id, offset, onclose){
        var menu = $(this.MENU_TEMPLATE);

        menu.appendTo('body').css({top:-1000, left:0});

        var x = button.offset().left + (button.width() / 2) - (menu.width() / 2);
        var y = button.offset().top - menu.height();

        if(offset){
           x = x + offset.x;
           y = y + offset.y;
        }

        menu.css({opacity:0,left:x,top:y+10});
        menu.animate({top:y,opacity:1},200);


        var hover = true;

        var mouseOver = function(){
            hover = true;
        };

        var mouseOut = function(){
            hover = false;
            setTimeout(function(){
                if(!hover){
                    menu.fadeOut('fast', function(){
                        menu.remove();
                        if(onclose){
                            onclose();
                        }
                    });

                    //cleanup
                    button.unbind('mouseover',mouseOver);
                    button.unbind('mouseout', mouseOut);
                }
            },100);
        };

        button.hover(mouseOver, mouseOut);
        menu.hover(mouseOver, mouseOut);


        menu.find('.email').click(function(){
            share.share_to_email(object_type, object_url, object_id);
            mouseOut();
        });

        menu.find('.twitter').click(function(){
            share.share_to_twitter(object_type, object_url, object_id);
            mouseOut();
        });

        menu.find('.facebook').click(function(){
            share.share_to_facebook(object_type, object_url, object_id);
            mouseOut();
        });




    }
};
