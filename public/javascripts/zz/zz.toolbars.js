zz.toolbars = {

    //    init_user : function(){
    //       $('#user-info').css('display', 'inline-block');
    //       $('#album-info').css('display', 'none');
    //
    //    },

    init_new_album : function(){
        $('#user-info').css('display', 'none');

        $('#album-info h2').html("New Album");
        $('#album-info h3').html("by " + zz.current_user_name);

        $('#album-info').css('display', 'inline-block');
    },

    show_acct_badge_dropdown : function(){
          //Following events are applied to the acct-dropdown itself (moving dropdown up and down)
          $('#acct-dropdown').slideDown('fast').show(); //Drop down the menu on click
          $('#acct-dropdown').hover(function() {}, function(){
              $("#acct-dropdown").slideUp('slow'); //When the mouse hovers out of the menu, roll it back up
            });
    }
}