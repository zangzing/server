var zz = zz || {};

zz.sharemenu = {

    template: '<ul>' +
            '<li class="email"><a href="#email">Email</a></li>' +
            '<li class="twitter"><a href="#twitter">Twitter</a></li>' +
            '<li class="facebook"><a href="#facebook">Facebook</a></li>' +
            '</ul>',


    show: function(button, object_type, object_id, offset, zza_context, style, onclose) {
        $(button).zz_menu({
            subject_id: object_id,
            subject_type: object_type,
            zza_context: zza_context,
            menu_template: zz.sharemenu.template,
            click: zz.sharemenu.click_handler,
            style: style,
            open: $.noop,
            close: onclose,
            container: $('#article')

        });
        $(button).zz_menu('open');
    },

    show_in_picon: function(button, picon,  onopen, onclose) {
        button.zz_menu({
            picon:         picon,
            album:         picon.options.album,
            subject_id:    picon.options.album.id,
            subject_type:  'album',
            container:     $('#article'),
            zza_context:   'frame',
            style:         'auto',
            bind_click_open: false,
            append_to_element: false, //use the el zzindex so overflow goes under bottom toolbar
            menu_template: zz.sharemenu.template,
            click: zz.sharemenu.click_handler,
            open: onopen,
            close: onclose
        });
        $(button).zz_menu('open');
    },

    click_handler: function(event, data) {
        var action = data.action,
                options = data.options,
                context = options.zza_context,
                id = options.subject_id,
                type = options.subject_type;

        switch (action) {
            case 'email':
                zz.sharemenu.share_to_email(type, id, context);
                break;
            case 'twitter':
                zz.sharemenu.share_to_twitter(type, id, context);
                break;
            case 'facebook':
                zz.sharemenu.share_to_facebook(type, id, context);
                break;
        }
    },

    share_to_email: function(object_type, object_id, context) {
        ZZAt.track(object_type + '.share.' + context + '.email');
        if (!zz.session.current_user_id) {
            var url = '/service/' + object_type + 's/' + object_id + '/new_mailto_share';
            $.get(url, {}, function(json) {
                document.location.href = json.mailto;
            });
        }
        else {
            var url = zz.routes.path_prefix + '/shares/new';

            var container = $('<div id="share-dialog"></div>');


            container.load(zz.routes.path_prefix + '/shares/newemail', function() {

                var dialog = zz.dialog.show_dialog(container, {
                    height: 400,
                    width: 820,
                    modal: true
                });


                zz.contact_list.create(zz.session.current_user_id, $('#contact-list'), $('.contacts-btn'));

                zz.wizard.resize_scroll_body();

                $('#new_email_share').validate({
                    rules: {
                        'email_share[to]': { required: true, minlength: 0 },
                        'email_share[message]': { required: true, minlength: 0 }
                    },
                    messages: {
                        'email_share[to]': 'At least one recipient is required',
                        'email_share[message]': ''
                    },

                    submitHandler: function() {
                        var serialized = $('#new_email_share').serialize();
                        $.post(zz.routes.path_prefix + '/' + object_type + 's/' + object_id + '/shares.json', serialized, function(data, status, request) {
                            dialog.close();
                        }, 'json');
                    }
                });

                $('#mail-submit').click(function() {
                    if (zz.contact_list.has_errors()) {
                        alert('Please correct the highlighted addresses.');
                        return;
                    }
                    $('form#new_email_share').submit();
                });

                $('#cancel-share').click(function() {
                    dialog.close();
                });

            });
        }
    },

    share_to_twitter: function(object_type, object_id, context) {
        ZZAt.track(object_type + '.share.' + context + '.twitter');
        var url = '/service/' + object_type + 's/' + object_id + '/new_twitter_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    },

    share_to_facebook: function(object_type, object_id, context) {
        ZZAt.track(object_type + '.share.' + context + '.facebook');
        var url = '/service/' + object_type + 's/' + object_id + '/new_facebook_share';
        window.open(url, '', 'status=0,toolbar=0,width=700,height=450');
    }
};
