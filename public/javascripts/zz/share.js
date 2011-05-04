var share = {

    MENU_TEMPLATE: '<div class="share-menu">' +
                     '<div class="email menu-item">Email</div>' +
                     '<div class="twitter menu-item">Twitter</div>' +
                     '<div class="facebook menu-item">Facebook</div>' +
                   '</div>',


    show_share_menu: function(button, object_type, object_id, offset, zza_context, onclose){
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
            mouseOut();

            ZZAt.track(object_type + '.share.' + zza_context + '.email');
            ZZAt.track(object_type + '.share.email');

            share.share_to_email(object_type, object_id);
        });

        menu.find('.twitter').click(function(){
            mouseOut();

            ZZAt.track(object_type + '.share.' + zza_context + '.twitter');
            ZZAt.track(object_type + '.share.twitter');

            share.share_to_twitter(object_type, object_id);
        });

        menu.find('.facebook').click(function(){
            mouseOut();

            ZZAt.track(object_type + '.share.' + zza_context + '.facebook');
            ZZAt.track(object_type + '.share.facebook');

            share.share_to_facebook(object_type, object_id);
        });




    },


    share_to_email: function(object_type, object_id){
        if(!zz.current_user_id){
            var url = '/service/' + object_type + 's/' + object_id + '/new_mailto_share';
            $.get(url, {}, function(json){
                document.location.href = json.mailto;
            });
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



    share_to_twitter: function(object_type, object_id){
        var url = '/service/' + object_type + 's/' + object_id + '/new_twitter_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    },

    share_to_facebook: function(object_type, object_id){
        var url = '/service/' + object_type + 's/' + object_id + '/new_facebook_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    }

};
