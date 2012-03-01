var zz = zz || {};


(function(){
	zz.message_banner = zz.message_banner || {};

    zz.message_banner.init = init;
    zz.message_banner.banner_refresh = banner_refresh;
    zz.message_banner.hide_banner = hide_banner;
    zz.message_banner.join_spacer = spacer_html;

    // Variables
    zz.message_banner.is_banner_visible = false;
    zz.message_banner.join_spacer_height = 75;

    // delegates
    var banner_delegates = [
        zz.joinbanner,
        zz.invitation_banner
    ];


    var current_banner_delegate = null;


    function init(){


        zz.buy.on_before_activate(function(){
        	hide_banner();
        });

        zz.buy.on_deactivate(function(){
        	banner_refresh();
        });

        zz.comments.on_open_comments(function(){
        	banner_refresh();
        });

        zz.comments.on_close_comments(function(){
        	banner_refresh();
        });



        current_banner_delegate = _.find(banner_delegates, function(delegate){
            return delegate.should_show_banner();
        });


        if(current_banner_delegate){
            var is_photos_page = (zz.page.album_id != null) && (zz.page.rails_controller_name == 'photos'); // Use this as a hack to determine whether there will be .photogrid

            $('#header').after('<div id="header-join-banner"></div>');

            if( !is_photos_page ){
                $("#article").prepend('<div class="join-banner-spacer"></div>');
            }


            $(window).resize(function(event) {
                banner_refresh();
            });

            $("#header-join-banner").html(current_banner_delegate.setup_banner());
            current_banner_delegate.on_show_banner();

            banner_refresh();
        }


    }

    function banner_refresh(){
    	if( !current_banner_delegate || !current_banner_delegate.should_show_banner() || zz.buy.is_buy_mode_active() || $('#checkout-banner .message').is(":visible") ){
    		hide_banner();
    	} else {
    		show_banner();
    		if($("#right-drawer").is(":visible")){
    			if(banner_fits()){
    				$("#right-drawer").css("top","56px");
    			} else {
    				$("#right-drawer").css("top","154px");
    			}

    		}
    	}
    }

    function hide_banner(animate){
        var hide = function(){
            $("#header-join-banner").addClass("none");
            $(".join-banner-spacer").addClass("none");
            $("#right-drawer").css("top","56px");
        };


        zz.message_banner.is_banner_visible = false;

    	if (animate){
            $("#header-join-banner").animate({top:-100}, 500, function(){
                hide();
            });
        }
        else{
            hide();
        }
    }

    function show_banner(){
		$("#header-join-banner").removeClass("none");
		$(".join-banner-spacer").removeClass("none");
		zz.message_banner.is_banner_visible = true;
    }


    function spacer_html(){
    	return '<div class="join-banner-spacer"></div>';
    }

        // Returns true/false for whether the large banner will fit current window width
    function banner_fits(){
    	var banner_width =  866; // 846px + 20px;
    	var usable_width = $(window).width();

    	// comments drawer
    	if($("#right-drawer").is(":visible")) {
    		usable_width -= $("#right-drawer").width() * 2; // double this because banner is centered
    	}

    	return usable_width > banner_width;
    }


}());