var share = {

    share_menu_template: '<ul>'+
                                '<li class="email"><a href="#email">Email</a></li>' +
                                '<li class="twitter"><a href="#twitter">Twitter</a></li>' +
                                '<li class="facebook"><a href="#facebook">Facebook</a></li>' +
                        '</ul>',


    show_share_menu: function(button, object_type, object_id, offset, zza_context, onclose){
        $(button).zz_menu(
            { subject_id   : object_id,
              subject_type : object_type,
              zza_context  : zza_context,
              menu_template: this.share_menu_template,
              append_to_element: zza_context == 'frame',
              email_action : this.share_to_email,
              facebook_action : this.share_to_facebook,
              twitter_action : this.share_to_twitter
        });
        $(button).zz_menu('open');
    },


    share_to_email: function(object_type, object_id){
        ZZAt.track(object_type + '.share.' + this.zza_context + '.email');
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
        ZZAt.track(object_type + '.share.' + this.zza_context + '.twitter');
        var url = '/service/' + object_type + 's/' + object_id + '/new_twitter_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    },

    share_to_facebook: function(object_type, object_id){
        ZZAt.track(object_type + '.share.' + this.zza_context + '.facebook');
        var url = '/service/' + object_type + 's/' + object_id + '/new_facebook_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    }
};
