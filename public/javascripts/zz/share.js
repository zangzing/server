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
            var url = zz.path_prefix +'/shares/new';

            var container = $('<div id="share-dialog"></div>');


            container.load(zz.path_prefix + '/shares/newemail', function(){

                var dialog = zz_dialog.show_dialog(container, {
                    height: 450,
                    width: 830,
                    modal: true
                });


                $("#contact-list").tokenInput( zzcontacts.find, {
                    allowNewValues: true,
                    hintText: '',
                    classes: {
                        tokenList: "token-input-list-facebook",
                        token: "token-input-token-facebook",
                        tokenDelete: "token-input-delete-token-facebook",
                        selectedToken: "token-input-selected-token-facebook",
                        highlightedToken: "token-input-highlighted-token-facebook",
                        dropdown: "token-input-dropdown-facebook",
                        dropdownItem: "token-input-dropdown-item-facebook",
                        dropdownItem2: "token-input-dropdown-item2-facebook",
                        selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                        inputToken: "token-input-input-token-facebook"
                    }
                });
                zzcontacts.init( zz.current_user_id );
                zz.wizard.resize_scroll_body();

                $('#new_email_share').validate({
                    rules: {
                        'email_share[to]':      { required: true, minlength: 0 },
                        'email_share[message]': { required: true, minlength: 0 }
                    },
                    messages: {
                        'email_share[to]': 'At least one recipient is required',
                        'email_share[message]': ''
                    },

                    submitHandler: function() {
                        var serialized = $('#new_email_share').serialize();
                        $.post(zz.path_prefix + '/'+ object_type + 's/'+ object_id +'/shares.json', serialized, function(data,status,request ){
                            alert('Your message has been sent.');
                            dialog.close();
                        },"json");
                    }
                });

                $('#mail-submit').click(function(){
                    $('form#new_email_share').submit();
                });

                $('#cancel-share').click(function(){
                   dialog.close();
                });

            });
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
