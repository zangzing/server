/** Join Banner Dropdown Form **/
$(function(){
	$('.feature label').inFieldLabels();
});

// Set ZZA Tracking Variables
		zuserid = null;
		
		if (document.URL.toLowerCase().indexOf('http://www.zangzing.com') == 0) {
			
			// production
			var zza_config_GOOGLE_ANALYTICS_TOKEN = 'UA-18597985-5';
			var zza_config_MIXPANEL_TOKEN = 'c4d7b3457d0051550aad9a7a76ace17e';
			var zza_config_ZZA_ID = 'homepage/web';			
		} else {

			// staging
			var zza_config_GOOGLE_ANALYTICS_TOKEN = 'UA-18597985-4';
			var zza_config_MIXPANEL_TOKEN = '17540e499e4c7032071b48abcbfeb742';
			var zza_config_ZZA_ID = 'staging.homepage/web';			
		}


// Form submission, tracking, validation
var zz={};
zz.path_prefix = '/service';

$(document).ready(function(){

	var validator = zz.joinform.add_validation( $('#signup-form') );

	$('#signup').click(function(){
	    zz.joinform.submit_form($('#signup-form'), validator, "wordpress.banner.join");
	    return false;
	});

	$('form').bind('keypress', function(e){
	    if ( e.keyCode == 13 ) {
		    zz.joinform.submit_form($('#signup-form'), validator, "wordpress.banner.join");
		    return false;
		}
	});

	// ZZA Events Tracking
	ZZAt.track('wordpress.visit',{ua: navigator.userAgent});
	
	$("#user_name").focus(function () {
		ZZAt.track('wordpress.banner.name.focus');
	});		
	
	$("#user_username").focus(function () {
		ZZAt.track('wordpress.banner.username.focus');
	});
	
	$("#user_email").focus(function () {
		ZZAt.track('wordpress.banner.email.focus');
	});

	$("#user_password").focus(function () {
		ZZAt.track('wordpress.banner.password.focus');
	});

	$('.sign-in').click(function(){
		ZZAt.track('wordpress.signin.top.click');
	});

	$('.join').click(function(){
		ZZAt.track('wordpress.join.top.click');
	});
		

	// If visitor is logged in, don't show banner
	if($.cookie('user_credentials') != null){
		$(".head").hide();
		$("#service-buttons").css("margin-top","14px");
	} else {
		$('.fields-label').hide();
	
		var formTop = $('#signup-form').offset().top;
		
		$(window).scroll(function(){
						if( $(window).scrollTop() > formTop ) {
							$("#service-buttons").css("margin-top","330px");
							$('.head').css({position: 'fixed'});			
							$(".intro").hide();	
							$('.fields-label').fadeIn();					
						} else {
							$('.head').css({position: 'static'});
							$(".intro").fadeIn();
							$("#service-buttons").css("margin-top","22px");
							$('.fields-label').fadeOut();
						}
				});	
	}
});
/** END Join Banner **/

/** Slides **/
function highlightCurrentTab(num){
    $("ul#tab_menu li a.tab_"+num).closest('li').addClass('current');
	$("ul#tab_menu li a.tab_"+(parseInt(num) + 1)).closest('li').addClass('next');
	$("ul#tab_menu li a.tab_"+(parseInt(num) - 1)).closest('li').addClass('previous');
}

function deactivateAllTabs(){
    $("ul#tab_menu li").removeClass("current").removeClass("previous").removeClass("next");
    
}
function showSlide(num){
    deactivateAllTabs();
    var sid = "#slide_"+num;
    $(".slide:visible").hide();
    $(sid).fadeIn(400);
    highlightCurrentTab(num);
}

$(function(){
    function load(num){
        showSlide(num);
    }
    $(".tab").click(
        function(event){
            event.stopPropagation();
            var sid = $(this).attr('class').split("_")[1];
            $.history.load(sid);
            $(this).closest('li').addClass("current");
            return false;
        }
    );
    $(".btn_next").click(
        function(event){
            event.stopPropagation();
            var sid = $(this).attr('id').split("_")[1];
            $.history.load(sid);
            return false;
        }
    );

    var addr = $.address.value();
    if(addr === '/'){
        addr = "0"
    }

    $.history.init(
        function(url){
            load(url == "" ? '1' : url);
        }
    );
    
    // hook next and previous arrows
    $(document).keydown(function(){
    	if ( event.keyCode == 37 ) // left 
    		$("ul#tab_menu li.previous a.tab").click();
    	else if ( event.keyCode == 39) // right 
			$("ul#tab_menu li.next a.tab").click();    	
    });
});
