//var temp;var temp_width;var temp_height;var temp_top;var temp_left;
//var temp_id;var temp_url;var content_url;var serialized;var temp_top_new;
//var temp_left_new;var value;var callback;


var zz = {

    view: 'undefined',


    /* Drawer Animations
     ------------------------------------------------------------------------- */

    drawer_open: 0,
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
        $('div#drawer').animate({ height: zz.drawer_height + 'px', top: '50px' }, time );
        $('div#drawer-content').animate({ height: (zz.drawer_height - 14) + 'px'}, time );
        zz.wizard.resize_scroll_body()

        zz.drawer_open = 1; // remember position of the drawer in

    }, // end zz.open_drawer()

    resize_drawer: function(time){

        zz.screen_height = $(window).height(); // measure the screen height
        // adjust for out top and bottom bar, the gradient padding and a margin
        zz.drawer_height = zz.screen_height - zz.screen_gap;

        $('div#drawer').animate({ height: zz.drawer_height + 'px', top: '50px' }, time );
        $('div#drawer-content').animate({ height: (zz.drawer_height - 14) + 'px'}, time );
        zz.wizard.resize_scroll_body()

    }, // end zz.resize_drawer()

    close_drawer: function(time){

        // close the drawer
        $('div#drawer').animate({ height: '24px'}, time );
        $('div#drawer-content').animate({ height: '24px'}, time );

        // fade in the grid
        $('article').animate({ opacity: 1 }, time * 1.1 );

        zz.drawer_open = 2; // remember position of the drawer in

    }, // end zz.close_drawer()

    slam_drawer: function(time){

        $('#indicator').fadeOut('fast');

        // close the drawer
        $('div#drawer').animate({ height: 0, top: '10px' }, time );
        $('div#drawer-content').animate({ height: 0, top: '10px' }, time );

        // fade in the grid
        $('article').animate({ opacity: 1 }, time * 1.1 );

        zz.drawer_open = 0; // remember position of the drawer in

    }, // end zz.slam_drawer()

    easy_drawer: function(time, opacity, url, funct) {
        // time - how fast to animate the drawer
        // opacity - how much to fade out the article contents
        // url - partial to load into the drawer...
        // fn gets loaded on callback
        zz.open_drawer(time, opacity);

        $('#tab-content').load(url, function(){
            $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 50) + 'px'});
            funct();
        });
    },

    /* Tray Animation
     ------------------------------------------------------------------------- */

    image_pop: function(element, callback){
        var temp = $('#'+element).css('margin-top').split('px')[0];
        $('#traversing').remove();
        var temp_top = $('#'+element).offset().top - temp;
        var temp_left = $('#'+element).offset().left;
        var temp_top_new;
        var temp_left_new;

        if($('#added-pictures-tray li:last').offset() !== null){
            temp_top_new = $('#added-pictures-tray li:last').offset().top - temp;
            temp_left_new = $('#added-pictures-tray li:last').offset().left + 20;
        }
        else{
            temp_top_new = $('#added-pictures-tray').offset().top - temp;
            temp_left_new = $('#added-pictures-tray').offset().left;

        }

        $('#'+element).clone()
                .attr({id: 'traversing'})
                .css({position: 'absolute', zIndex: 2000, left: temp_left, top: temp_top})
                .appendTo('body');

        $('#traversing').animate({
            width: '30px',
            height: '30px',
            top: (temp_top_new + 2) +'px',
            left: (temp_left_new + 13) +'px'
        }, 500, 'swing', callback);



    } // end zZ.image_pop


};
