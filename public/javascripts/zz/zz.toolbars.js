zz.toolbars = {

    init_new_album: function(){
        $('#user-info').css('display', 'none');

        $('#album-info h2').html("New Album");
        $('#album-info h3').html("by " + zz.current_user_name);

        $('#album-info').css('display', 'inline-block');
    },

    //============================== ACCOUNT BADGE MENU ===========================================
    init_acct_badge_menu: function(){
       //Bind menu functionality 
       $('ul.dropdown').hover(function() {}, function(){
              $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
            });
       $('ul.dropdown li a').click(function(){  $(this).parent().parent().slideUp('fast');  });
        
       //Bind Each Menu Item
       $('#acct-settings-btn').click(function(){ zz.wizard.open_settings_drawer('profile') });
    },

    show_acct_badge_menu : function(event){
        event.preventDefault();
        // Toggle the slide based on the menu's current visibility.
        if( $('#acct-dropdown').is( ":visible" ) ){
               $('#acct-dropdown').slideUp( 'fast' );// Hide - slide up
        } else {
               $('#acct-dropdown').slideDown( 'fast' );// Show - slide down.
        }
    },

    //==================================== LIKE MENU ==============================================
    init_like_menu: function(){
        $('ul.popup').hover(function() {}, function(){
                $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
              });
        $('ul.popup li a').click(function(){  $(this).parent().parent().slideUp('fast');  });

    },
    show_like_menu: function(event){
        //toggle visibility
        if( $('#like-popup').is( ":visible" ) ){
               $('#like-popup').slideUp( 'fast' );// Hide - slide up
        }else{
          //get the position of the clicked element and display popup above center of it  
          var pos =  $(this).offset();
          var width =  $(this).width();
          var height=  $(this).width();
          $("#like-popup").css( { "left":  pos.left - (width/2)+"px", "bottom": height+ "px" } );  
          $('#like-popup').slideDown( 'fast' );// Show - slide down
        }
    }
}