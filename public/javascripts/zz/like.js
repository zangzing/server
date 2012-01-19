//
//  Copyright 2011. ZangZing LLC www.zangzing.com
//
var zz = zz || {};

zz.like = {

    hash: {},      // Hash keys are ids of liked subjects values are 'liked'
    loaded: false, // True when the hash is loaded for the logged in user

    init: function() {
        //obtain the array of wanted subjects from the divs of class zzlike  with data-zzid attributes
        var wanted_subjects = {};
        $('.zzlike').each(function(index, zzliketag) {
            wanted_subjects[$(zzliketag).attr('data-zzid')] = $(zzliketag).attr('data-zztype');
        });

        if (!$.isEmptyObject(wanted_subjects)) {
            zz.like.add_id_array(wanted_subjects);
        } else {
            zz.like.loaded = true;
        }
    },

    add_id_array: function(wanted_subjects) {
        if (!$.isEmptyObject(wanted_subjects)) {
            // get the wanted subjects. Use a POST because of GET query string size limitations
            $.ajax({ type: 'POST',
                url: zz.routes.path_prefix + '/likes.json',
                data: {'wanted_subjects' : wanted_subjects },
                success: function(data) {
                    if (zz.like.loaded) {
                        $.extend(zz.like.hash, data); // merge new data with existing hash
                        for (key in data)
                            zz.like.refresh_tag(key);
                    } else {
                        zz.like.hash = data;
                        zz.like.draw_tags();
                        zz.like.loaded = true;
                    }
                },
                dataType: 'json'});
        }
    },

    add_id: function(subject_id, subject_type) {
        if (typeof(subject_id) != 'undefined' && subject_id != 0) {
            if (zz.like.loaded && typeof(zz.like.hash[subject_id]) == 'undefined') {
                var wanted_subjects = {};
                wanted_subjects[subject_id] = subject_type;
                zz.like.add_id_array(wanted_subjects);
            } else {
                zz.like.refresh_tag(subject_id);
            }
        }
    },

    toggle: function() {
        if ($(this).hasClass('disabled')) {
            return;
        }
        var subject_id = $(this).attr('data-zzid');
        var subject_type = $(this).attr('data-zztype');
        var url = zz.routes.path_prefix + '/likes/' + subject_id;

        var zzae = 'like.' + subject_type + '.';
        //Decide the action before the value is toggled in the hash
        var type = 'post';
        if (zz.like.hash[subject_id]['user'] == true) {
            type = 'delete';
            zzae += 'unlike';
        } else {
            zzae += 'like';
        }

        zz.like.toggle_in_hash(subject_id);
        $.ajax({ type: 'POST',
            url: url,
            data: { subject_type: subject_type, _method: type },
            success: function(html) {
//                $('body').append(html);
//                zz.like.display_social_dialog(subject_id);
            },
            error: function(xhr) {
                if (xhr.status == 401) {
                    var returnUrl = 'https://' + document.location.hostname + zz.routes.path_prefix + '/' + subject_type + 's/' + subject_id + '/like';
                    document.location.href = zz.routes.signin_path() + '?return_to=' + returnUrl;
                } else {
                    // toggle in server failed, return hash and screen to previous state
                    zz.like.toggle_in_hash(subject_id);
                }
            }
        });

        ZZAt.track(zzae);
    },

    toggle_in_hash: function(subject_id) {
        if (zz.like.loaded && subject_id in zz.like.hash) {  //If the hash is loaded and  subject is in our hash
            if (zz.like.hash[subject_id]['user'] == true) {
                // The user likes the subject, toggle it off and decrease counter
                zz.like.hash[subject_id]['user'] = false;
                zz.like.hash[subject_id]['count'] -= 1;
            } else {
                // The user does not like the subject, toggle it on and increase counter
                zz.like.hash[subject_id]['user'] = true;
                zz.like.hash[subject_id]['count'] += 1;
            }
            zz.like.refresh_tag(subject_id);
        }
    },

    _count: function(id) {
        var count = zz.like.hash[id]['count'];
        if (count <= 0) {
            return '';
        } else if (count <= 1000) {
            return count.toString();
        } else if (count <= 1000000) {
            return Math.floor(count / 1000).toString() + 'K';
        }
    },

    draw_tags: function() {
        $('.zzlike').each(function(index, zzliketag) {
            zz.like.draw_tag(zzliketag);
        });
    },

    draw_tag: function(tag) {
        var button, icon, counter;
        var id = $(tag).attr('data-zzid');

        if ($(tag).attr('data-zzstyle') == 'toolbar') {
            icon = $(tag);
            counter = $(tag).find('.zzlike-count');
        } else {
            button = $('<div class="zzlike-button">'),
                    icon = $('<div class="zzlike-icon">'),
                    counter = $('<div class="zzlike-count empty">');
            $(button).append(icon).append(counter);
            $(tag).empty().append(button);
        }

        if (typeof(zz.like.hash[id]) != 'undefined') {
            // set the counter
            if (zz.like.hash[id]['count'] <= 0) {
                counter.addClass('empty').empty();
            } else {
                counter.removeClass('empty').text(zz.like._count(id));
            }

            // change the icon
            if (zz.like.hash[id]['user']) {
                icon.addClass('thumbup').removeClass('thumbdown');
            } else {
                icon.addClass('thumbdown');
            }

        }
        $(tag).click(zz.like.toggle);
    },

    refresh_tag: function(id) {
        if (zz.like.hash[id]) {
            $('.zzlike[data-zzid="' + id + '"]').each(function() {
                var icon;
                if ($(this).attr('data-zzstyle') == 'toolbar') {
                    icon = $(this);
                } else {
                    icon = $(this).find('.zzlike-icon');
                }
                //update icon
                if (zz.like.hash[id]['user']) {
                    icon.addClass('thumbup').removeClass('thumbdown');
                } else {
                    icon.addClass('thumbdown').removeClass('thumbup');
                }
                //update counter
                if (zz.like.hash[id]['count'] <= 0) {
                    $(this).find('.zzlike-count').addClass('empty');
                } else {
                    $(this).find('.zzlike-count').removeClass('empty').text(zz.like._count(id));
                }
                $(this).unbind('click', zz.like.toggle).click(zz.like.toggle);
            });
        }
    }

//    display_social_dialog: function(subject_id) {
//        $('#facebook_box').click(function() {
//            if ($(this).is(':checked') && !$('#facebook_box').attr('authorized')) {
//                $(this).attr('checked', false);
//                zz.oauthmanager.login(zz.routes.path_prefix + '/facebook/sessions/new', function() {
//                    $('#facebook_box').attr('checked', true);
//                    $('#facebook_box').attr('authorized', 'yes');
//                });
//            }
//        });
//
//        $('#twitter_box').click(function() {
//            if ($(this).is(':checked') && !$('#twitter_box').attr('authorized')) {
//                $(this).attr('checked', false);
//                zz.oauthmanager.login(zz.routes.path_prefix + '/twitter/sessions/new', function() {
//                    $('#twitter_box').attr('checked', true);
//                    $('#twitter_box').attr('authorized', 'yes');
//                });
//            }
//        });
//
//        $('#social-like-dialog').zz_dialog({ autoOpen: false });
//        $('#ld-cancel').click(function() {
//            $('#social-like-dialog').zz_dialog('close');
//            $('#social-like-dialog').zz_dialog().empty().remove();
//        });
//
//        $('#ld-ok').click(function() {
//            $.ajax({ type: 'POST',
//                url: zz.routes.path_prefix + '/likes/' + subject_id + '/post',
//                data: $('#social_like_form_' + subject_id).serialize()
//            });
//            $('#social-like-dialog').zz_dialog('close');
//            $('#social-like-dialog').zz_dialog().empty().remove();
//        });
//        $('#social-like-dialog').zz_dialog('open');
//    }
};
