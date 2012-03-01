/*!
 * zz.core.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
var zz = zz || {};


zz.drawers = {

//    view: 'undefined',

    /* Drawer Animations
     ------------------------------------------------------------------------- */

    DRAWER_CLOSED: 0,
    DRAWER_OPEN: 1,
    DRAWER_PARTIAL: 2,


    drawer_state: 0,
    SCREEN_GAP: 160,


    open_drawer: function(time, percent) {

        zz.buy.hide_checkout_banner();
        zz.message_banner.hide_banner();

        zz.screen_height = $('#page-wrapper').height(); // measure the screen height
        // adjust for out top and bottom bar, the gradient padding and a margin
        zz.drawer_height = zz.screen_height - zz.drawers.SCREEN_GAP;

        var opacity = 0;

        if (typeof percent == 'number') {
            opacity = percent;
        }

        // fade out the grid
        $('#article').empty().css({right:0}); //clear content and make it will width in case drawer was open
        $('#right-drawer').remove();

        // pull out the drawer
        $('div#drawer').show().animate({ height: zz.drawer_height + 'px', top: '51px' }, time);
        $('div#drawer-content').animate({ height: (zz.drawer_height - 18) + 'px'}, time);

        zz.wizard.resize_scroll_body();


        zz.drawers.drawer_state = zz.drawers.DRAWER_OPEN; // remember position of the drawer in

    },

    resize_drawer: function(time, size) {

        zz.screen_height = $('#page-wrapper').height(); // measure the screen height
        // adjust for out top and bottom bar, the gradient padding and a margin
        zz.drawer_height = zz.screen_height - zz.drawers.SCREEN_GAP;

        if (typeof(size) != 'undefined' && size < zz.drawer_height) zz.drawer_height = size;

        $('div#drawer').animate({ height: zz.drawer_height + 'px', top: '51px' }, time);
        $('div#drawer-content').animate({ height: (zz.drawer_height - 18) + 'px'}, time);

    },

    close_drawer_partially: function(time, size) {
        zz.drawers.resize_drawer(time, size);
        // fade in the grid
        $('#article').animate({ opacity: 1 }, time * 1.1);
        zz.drawers.drawer_state = zz.drawers.DRAWER_PARTIAL; // remember position of the drawer in
    },

    close_drawer: function(time) {

        $('#indicator').fadeOut('fast');

        // close the drawer
        $('div#drawer').animate({ height: 0, top: '10px' }, time);
        $('div#drawer-content').animate({ height: 0, top: '10px' }, time);

        // fade in the grid
        $('#article').animate({ opacity: 1 }, time * 1.1);

        zz.drawers.drawer_state = zz.drawers.DRAWER_CLOSED; // remember position of the drawer in

    },

    resized: function() {
        if (zz.drawers.drawer_state == zz.drawers.DRAWER_OPEN) {
            zz.drawers.resize_drawer(50);
        }
    }

};

$(window).bind('resize', function() {
    zz.drawers.resized();
});

