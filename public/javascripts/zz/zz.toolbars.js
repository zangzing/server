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
    }
}