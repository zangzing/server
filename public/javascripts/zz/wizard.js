/*!
 * zz.wizard.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

zz.wizard = {

    INDICATOR_TEMPLATE: $('<ul id="clone-indicator" class="clearfix"><li></li></ul>'),

    group_album: {

        // set up the album variables
        first: 'add',
        last: 'group',
        show_next_button: true,
        numbers: 1,
        percent: 0.0,
        style: 'create',
        time: 600,

        init: function() {
        },

        on_close: function() {
            ZZAt.track('album.done.click');
            $.ajax({
                url: zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/close_batch',
                complete: function(request, textStatus) {
                    zz.logger.debug('Batch closed because drawer was closed. Call to close_batch returned with status= ' + textStatus);
                    window.location = zz.routes.path_prefix + '/albums/' + zz.page.album_id + '/photos';
                }
            });
        },


        // set up the wizard steps
        steps: {

            add: {
                next: 'name',
                title: 'Add Photos',
                type: 'full',
                url: zz.routes.path_prefix + '/albums/$$/add_photos',
                url_type: 'album',

                init: function(container, callback) { // run when loading the drawer up
                    zz.pages.album_add_photos_tab.init(container, callback, zz.wizard.group_album.style);
                },

                bounce: function(success, failure) { // run before you leave
                    zz.pages.album_add_photos_tab.bounce(success, failure);
                }

            },
            name: {  //group album
                id: 'name',
                next: 'group',
                title: 'Name Album',
                type: 'full',

                init: function(container, callback) {
                    zz.pages.album_name_tab.init(container, callback);
                },
                bounce: function(success, failure) {
                    zz.pages.album_name_tab.bounce(success, failure);
                }
            },

//            edit: {
//                next: 'group',
//                title: 'Edit Album',
//                type: 'partial',
//
//                init: function(container, callback) {
//                    zz.pages.edit_album_tab.init(container, callback);
//                },
//                bounce: function(success, failure) {
//                    zz.pages.edit_album_tab.bounce(success, failure);
//                }
//            },

            group: {
                next: 0,
                title: 'Create Group & Share',
                type: 'full',


                init: function(container, callback) {
                    zz.pages.group_tab.init(container, callback);
                },

                bounce: function(success, failure) {
                    zz.pages.group_tab.bounce(success, failure);
                }
            }
        }

    },





    open_drawer: function(obj, step) {

        obj.init();

        if (zz.drawers.drawer_state == zz.drawers.DRAWER_CLOSED) {
            zz.drawers.open_drawer(obj.time, obj.percent);
        }

        zz.wizard.build_nav(obj, step);

        var container = $('#tab-content');

        obj.steps[step].init(container, function() {
            zz.wizard.resize_scroll_body();
        });

        $('body').addClass('drawer');

    },

    change_step: function(id, obj) {


        var container = $('#tab-content');

        if (obj.steps[id].type == 'partial' && zz.drawers.drawer_state == zz.drawers.DRAWER_OPEN) {
            $('#tab-content').fadeOut('fast');
            if (obj.style == 'edit') {
                zz.drawers.close_drawer_partially(obj.time, 40);
            } else {
                zz.drawers.close_drawer_partially(obj.time, 40);
            }
            zz.wizard.build_nav(obj, id);
            obj.steps[id].init(container, function() {
                zz.wizard.resize_scroll_body();
            });


        } else if (obj.steps[id].type == 'partial' && zz.drawers.drawer_state == zz.drawers.DRAWER_PARTIAL) {
            zz.wizard.build_nav(obj, id);
            obj.steps[id].init(container, function() {
                zz.wizard.resize_scroll_body();
            });

        } else if (obj.steps[id].type == 'full' && zz.drawers.drawer_state == zz.drawers.DRAWER_PARTIAL) {
            zz.wizard.build_nav(obj, id);

            $('#tab-content').empty().show();

            zz.drawers.open_drawer(obj.time);

            //todo: should pass this as callback to zz.open_drawer
            setTimeout(function() {
                obj.steps[id].init(container, function() {
                    zz.wizard.resize_scroll_body();
                });
            }, obj.time);


        } else if (obj.steps[id].type == 'full' && zz.drawers.drawer_state == zz.drawers.DRAWER_OPEN) {
            zz.wizard.build_nav(obj, id);
            $('#tab-content').fadeOut(100, function() {
                $('#tab-content').empty();
                $('#tab-content').show();
//                $('#tab-content').css({opacity:0});
                obj.steps[id].init(container, function() {
                    zz.wizard.resize_scroll_body();
//                    $('#tab-content').fadeIn('fast');
                });

            });
        } else if (obj.steps[id].type == 'partial' && zz.drawers.drawer_state == zz.drawers.DRAWER_CLOSED) {
            zz.drawers.open_drawer(80, obj.percent);
            zz.drawers.close_drawer_partially(obj.time);
            zz.wizard.build_nav(obj, id);

            obj.steps[id].init(container, function() {
                zz.wizard.resize_scroll_body();
            });

        } else {
            console.warn('This should never happen. Context: zz.wizard.change_step, Type: ' + obj.steps[id].type + ', Drawer State: ' + zz.drawers.drawer_state);
        }


    },

    build_nav: function(obj, id, fade_in) {


        var temp_id = 1;
        var temp = '';
        $.each(obj.steps, function(i, item) {
            if (i == id && obj.numbers == 1) {
                value = temp_id;
                temp += '<li id="wizard-' + i + '" class="tab on">';
                temp += '<img src="' + zz.routes.image_url('/images/wiz-num-' + temp_id + '-on.png') + '" class="num"> ' + item.title + '</li>';
            } else if (i == id) {
                value = temp_id;
                temp += '<li id="wizard-' + i + '" class="tab on">' + item.title + '</li>';
            } else if (obj.numbers == 1) {
                temp += '<li id="wizard-' + i + '" class="tab">';
                temp += '<img src="' + zz.routes.image_url('/images/wiz-num-' + temp_id + '.png') + '" class="num"> ' + item.title + '</li>';
            } else {
                temp += '<li id="wizard-' + i + '" class="tab">' + item.title + '</li>';
            }
            temp_id++;

        });

        // the last time we incrimented it didn't load a step - we use this to know the length of the list below
        temp_id--;

        if (obj.show_next_button !== true) {
            // no next button neded
        } else if (obj.steps[id].next == 0 || obj.style == 'edit') {
//            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-wizard-done.png" /></li>';
            temp += '<li class="next-done">';
            temp += '<a id="next-step" class="green-button"><span>Done</span></a>';
            temp += '</li>';
        } else {
//            temp += '<li id="step-btn"><img id="next-step" src="/images/btn-steps-next.png" /></li>';
            temp += '<li class="next-done">';
            temp += '<a id="next-step" class="next-button"><span>Next</span></a>';
            temp += '</li>';
        }

        if (fade_in) {
            $('#drawer-tabs').hide();
        }
        if (obj.style == 'edit') {
            $('#drawer-tabs').html(this.INDICATOR_TEMPLATE.clone().attr('id', 'indicator' + '-' + temp_id).addClass('edit-' + value + '-' + temp_id).html(temp));
        } else {
            $('#drawer-tabs').html(this.INDICATOR_TEMPLATE.clone().attr('id', 'indicator' + '-' + temp_id).addClass('step-' + value + '-' + temp_id).html(temp));
        }
        if (fade_in) {
            $('#drawer-tabs').fadeIn('fast');
        }
        zz.wizard.resize_scroll_body();


        //bind the event handlers
        $.each(obj.steps, function(i, item) {
            $('li#wizard-' + i).click(function(e) {
                e.preventDefault();
                temp_id = $(this).attr('id').split('wizard-')[1];

                obj.steps[id].bounce(function() {
                    zz.wizard.change_step(temp_id, obj);
                });
            });


        });

        if (obj.show_next_button !== true) {
            // no next button neded
        } else if (obj.last == id || obj.style == 'edit') {
            $('#next-step').click(function(e) {
                obj.steps[id].bounce(function() {
                    $('#drawer .body').fadeOut('fast');
                    zz.drawers.close_drawer(400);
                    obj.on_close();
                });
            });
        } else {
            $('#next-step').click(function(e) {
                e.preventDefault();
                obj.steps[id].bounce(function() {
                    temp_id = obj.steps[id].next;


                    zz.wizard.change_step(temp_id, obj);
                });
            });
        }
    },

    //todo: why is this needed?
    resize_scroll_body: function() {
        $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 140) + 'px'});
    },


    set_wizard_style: function(style) {
        if (style == 'edit') {
            $('div#drawer').css('background-image', 'url(' + zz.routes.image_url('/images/bg-drawer-bottom-cap.png') + ')');
            $('div#cancel-drawer-btn').hide();
//            zz.screen_gap = 160;
        } else {
            $('div#drawer').css('background-image', 'url(' + zz.routes.image_url('/images/bg-drawer-bottom-cap-with-cancel.png') + ')');
            $('div#cancel-drawer-btn').show();
//            zz.screen_gap = 160;
        }
    },


    create_group_album: function() {
        $.post(zz.routes.path_prefix + '/users/' + zz.session.current_user_id + '/albums', { album_type: 'GroupAlbum' }, function(data) {
            zz.page.album_id = data.id;
            $('#album-info h2').text(data.name);
            zz.wizard.open_drawer(zz.wizard.group_album, 'add');
        });
    },

    open_edit_album_wizard: function(step) {
        zz.wizard.group_album.style = 'edit';
        zz.wizard.open_drawer(zz.wizard.group_album, step);
    },


    open_group_tab: function( email ){
         zz.toolbars._disable_buttons();
         $('#footer #edit-album-button').removeClass('disabled').addClass('selected');

         //This callback will be called when the init sequence for the tab is complete
         zz.pages.group_tab.init_callback = function(){
             //This callback will be called when the init sequence for the add people dialog is complete
            $('#article').empty().css({right:0});
             if( email && email.length > 0 ){
                 // we have an email. open add people type and type it
                 zz.pages.group_tab.init_callback = function(){
                     var type_email = function(){
                         $('ul.token-input-list-facebook').unbind( 'click',type_email );
                         if( email.length > 0 ){
                             $('li.token-input-input-token-facebook input').click().val(email).blur();
                         }
                         return false;
                     };
                     $('ul.token-input-list-facebook').click( type_email );
                     $('ul.token-input-list-facebook').click();
                 };
                 $('.group-editor div.add-people-button').click();
             } else {
                 // no email, no need to open add people tab
                 zz.pages.group_tab.init_callback = function(){};
             }

         };
         zz.wizard.open_edit_album_wizard('group');
        $('#article').css({opacity:0});
    },


    display_flashes: function(request, delay) {
        var data = request.getResponseHeader('X-Flash');
        if (data && data.length > 0 && $('#flashes-notice')) {
            var flash = $.parseJSON(data);
            if (flash.notice) {
                $('#flashes-notice').text(flash.notice).fadeIn('fast', function() {
                    setTimeout(function() {
                        $('#flashes-notice').fadeOut('fast', function() {
                            $('#flashes-notice').text('    ');
                        });
                    }, delay + 3000);
                });
            }
            if (flash.error) {
                $('#error-notice').text(flash.error).fadeIn('fast', function() {
                    setTimeout(function() {
                        $('#error-notice').fadeOut('fast', function() {
                            $('#error-notice').text('    ');
                        });
                    }, delay + 4000);
                });
            }
        }
    },

    display_errors: function(request, delay) {
        var data = request.getResponseHeader('X-Errors');
        if (data) {
            var errors = $.parseJSON(data);

            //extract the value of the first attribute
            var message = '';
            for (var i in errors) {
                if (typeof(i) !== 'undefined') {
                    message = errors[i];
                    break;
                }
            }

            $('#error-notice').text(message).fadeIn('fast', function() {
                if (delay > 0) {
                    setTimeout(function() {
                        $('#error-notice').fadeOut('fast', function() {
                            $('#error-notice').text('    ');
                        });
                    }, delay + 3000);

                }
            });
        }
    },

    loaded: function() {
        $('#drawer-content').ajaxError(function(event, request) {
            zz.wizard.display_errors(request, 50);
            zz.wizard.display_flashes(request, 50);
        });
        $('#drawer-content').ajaxSuccess(function(event, request) {
            zz.wizard.display_flashes(request, 50);
        });
    }
};


$(window).bind('load', function() {
    setTimeout('zz.wizard.loaded()', 64);
});
