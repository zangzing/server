

var zz = zz || {};


(function(){
	zz.invitation_banner = zz.invitation_banner || {};

	// Public functions
	zz.invitation_banner.should_show_banner = should_show_banner;
	zz.invitation_banner.setup_banner = setup_banner;
	zz.invitation_banner.on_show_banner = on_show_banner;


    function should_show_banner(){
        return zz.session.current_user_id != null &&
               zz.local_storage.get('invitation-banner.hide') != true &&
               (zz.page.rails_controller_name=="albums" ||
                   zz.page.rails_controller_name=="photos" ||
                   zz.page.rails_controller_name=="people" ||
                   zz.page.rails_controller_name=="activities"
               );
    }



    function setup_banner(){
        var html = '<div class="invitation-banner">' +
                    '<div class="message ">' +
                        '<span class="bold">Want extra free space?</span> Invite friends and you each get 250MB of extra space free.' +
                    '</div>' +
                    '<div class="buttons">' +
                        '<a class="green-button invite-button"><span>Invite Friends</span></a>' +
            '<a class="no-thanks-button"><span>No Thanks</span></a>' +

            '</div>' +
               '</div>';

        var element = $(html);

        element.find('.invite-button').click(function(){
            zz.routes.users.goto_invite_friends_screen();
            ZZAt.track('invitation-banner.invite-button.click');
        });

        element.find('.no-thanks-button').click(function(){
            zz.local_storage.set('invitation-banner.hide', true);


            element.find('.no-thanks-button').fadeOut('fast');
            element.find('.invite-button').fadeOut('fast');
            element.find('.message').fadeOut('fast', function(){
                element.find('.message').html('<span class="bold">No problem.</span><br>You can always Invite Friends later from the Account Menu.');
                element.find('.message').fadeIn('fast');

                setTimeout(function(){
                    zz.message_banner.hide_banner(true);
                    ZZAt.track('invitation-banner.no-thanks-button.click');
                }, 3000);


            });
        });


        return element;
    }

    function on_show_banner(){
        ZZAt.track("invitation-banner.show");
    }


})();