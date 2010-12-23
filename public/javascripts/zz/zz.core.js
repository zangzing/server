
var zz = {

    view: 'undefined',

    /* Drawer Animations
     ------------------------------------------------------------------------- */

    DRAWER_CLOSED: 0,
    DRAWER_OPEN: 1,
    DRAWER_PARTIAL: 2,


    drawer_state: 0,
    screen_gap: 150,

    open_drawer: function(time, percent){

        zz.screen_height = $(window).height(); // measure the screen height
        // adjust for out top and bottom bar, the gradient padding and a margin
        zz.drawer_height = zz.screen_height - zz.screen_gap;

        var opacity = 0;

        if (typeof percent == 'number') {
            opacity = percent;
        }

        // fade out the grid
        $('article').animate({ opacity: opacity }, time/2 ).html('');

        // pull out the drawer
        $('div#drawer').animate({ height: zz.drawer_height + 'px', top: '52px' }, time );
        //$('div#drawer').css( { height: zz.drawer_height + 'px', top: '50px' } );
        //$('div#drawer').slideDown( time );
        $('div#drawer-content').animate({ height: (zz.drawer_height - 14) + 'px'}, time );
        zz.wizard.resize_scroll_body();

        zz.drawer_state = zz.DRAWER_OPEN; // remember position of the drawer in

    },

    resize_drawer: function(time, size){

        zz.screen_height = $(window).height(); // measure the screen height
        // adjust for out top and bottom bar, the gradient padding and a margin
        zz.drawer_height = zz.screen_height - zz.screen_gap;

        if(typeof(size) != 'undefined' && size < zz.drawer_height )  zz.drawer_height = size;
        
        $('div#drawer').animate({ height: zz.drawer_height + 'px', top: '52px' }, time );
        $('div#drawer-content').animate({ height: (zz.drawer_height - 14) + 'px'}, time );
        zz.wizard.resize_scroll_body()

    },

    close_drawer_partially: function(time, size ){
        zz.resize_drawer( time, size );
        // fade in the grid
        $('article').animate({ opacity: 1 }, time * 1.1 );
        zz.drawer_state = zz.DRAWER_PARTIAL; // remember position of the drawer in
    },

    close_drawer: function(time){

        $('#indicator').fadeOut('fast');

        // close the drawer
        $('div#drawer').animate({ height: 0, top: '10px' }, time );
        $('div#drawer-content').animate({ height: 0, top: '10px' }, time );

        // fade in the grid
        $('article').animate({ opacity: 1 }, time * 1.1 );

        zz.drawer_state = zz.DRAWER_CLOSED; // remember position of the drawer in

    },

    easy_drawer: function(time, opacity, url, funct) {
        // time - how fast to animate the drawer
        // opacity - how much to fade out the article contents
        // url - partial to load into the drawer...
        // fn gets loaded on callback
        zz.open_drawer(time, opacity);

        $('#tab-content').load(url, function(){
            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 52) + 'px'});
            funct();
        });
    }




};
