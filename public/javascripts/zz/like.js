//
//  Copyright 2011. ZangZing LLC www.zangzing.com
//



var like = {

    hash: {},      // Hash keys are ids of liked subjects values are 'liked'
    loaded: false, // True when the hash is loaded for the logged in user

    init: function(){
        //obtain the array of wanted subjects from the divs of class zzlike  with data-zzid attributes
        var wanted_subjects={};
        $('.zzlike').each( function(index, zzliketag){
            id = $(zzliketag).attr('data-zzid');
            type = $(zzliketag).attr('data-zztype');
            wanted_subjects[id]=type;
        });

        // get the wanted subjects. Use a POST because of GET query string size limitations
        $.ajax({ type:       'POST',
                 url:        '/likes.json',
                 data:       {'wanted_subjects' : wanted_subjects },
                 success:    function( data ){
                                like.hash = data;
                                like.loaded = true;
                                like.draw_tags();},
                 dataType: 'json'});
    },

    user: function(user_id){
        like.toggle_in_server( '/users/'+user_id+'/like', user_id);
    },

    album: function(album_id){
         like.toggle_in_server( '/albums/'+album_id+'/like', album_id);
    },

    photo: function(photo_id){
         like.toggle_in_server( '/photos/'+photo_id+'/like', photo_id);
    },

    toggle_in_server: function( url, subject_id ){
        like.toggle_in_hash( subject_id );
        $.ajax({ type:       'POST',
                 url:        url,
                 success:    function(){},
                 error:      function( xhr, textStatus, errorThrown){
                     like.toggle_in_hash( subject_id );
                     if( xhr.status == 401 ) alert('Must Be Logged In'); }
        });
    },

    toggle_in_hash: function(subject_id){
        if( like.loaded && subject_id  in like.hash){  //If the hash is loaded and  subject is in our hash
            if( like.hash[subject_id]['user'] == true ){
                // The user likes the subject, toggle it off and decrease counter
                like.hash[subject_id]['user'] = false;
                like.hash[subject_id]['count'] -= 1;
            }else{
                // The user does not like the subject, toggle it on and increase counter
                like.hash[subject_id]['user'] = true;
                like.hash[subject_id]['count'] += 1;
            }
            like.refresh_tag( subject_id );
        }
    },


    draw_tags: function(){
        $('.zzlike').each( function(index, zzliketag){
            var tag = $(zzliketag);
            var id = tag.attr('data-zzid');

            if( tag.attr('data-zzstyle') =="menu" ){
                tag.find("span.like-count").html( '('+like.hash[id]['count'].toString()+')' );
            }else{
                button  = $( ' <div class="zzlike-button">Like</div>');
                icon    = $( '<span></span>' )
                counter = $( '<div class="zzlike-count">'+like.hash[id]['count']+'</div>');
                if( like.hash[id]['user'] ){
                    $(icon).addClass( 'zzlike-thumbup' );
                } else {
                    $(icon).addClass( 'zzlike-vader' );
                }
                $(button).prepend( icon );
                tag.append( button ).append( counter );
            }

            switch(like.hash[id]['type']){
                case 'P': tag.click(function(){ like.photo(id)}); break;
                case 'A': tag.click(function(){ like.album(id)}); break;
                case 'U': tag.click(function(){ like.user(id)}); break;
            }
        });
    },

    refresh_tag: function(id){
        if( like.hash[id]){
            $('.zzlike[data-zzid="'+id+'"]').each( function(){
                if( $(this).attr('data-zzstyle') =="menu" ){
                    $(this).find('span.like-count').html( '('+like.hash[id]['count'].toString()+')' );
                } else {
                    if( like.hash[id]['user'] ){
                        $(this).find('span.zzlike-vader').addClass('zzlike-thumbup').removeClass( 'zzlike-vader' );
                    } else {
                        $(this).find('span.zzlike-thumbup').addClass('zzlike-vader').removeClass( 'zzlike-thumbup' );
                    }
                    $(this).find('div.zzlike-count').html(like.hash[id]['count']);
                }
            });

        }
    },

    display_login: function(){

    },

    is_it_liked: function( subject_id ){
        if( like.loaded ) return like.hash[subject_id]['user'];
        return false;
    }
};



(function( $, undefined ) {

$.widget("ui.zz_like_menu", {
        options: {
            anchor_id: 'red',
            open: 'false'
        },
        _create: function() {
            var self   = this;
            var menu   = $('#'+this.options.menu);
            var anchor =this.element;

            //set classes to hide it make it s like-menu
            menu.addClass( 'like-menu');
            menu.css('display','none');
            var items = $(menu).find('.zzlike');
            items.attr('data-zzstyle', 'menu');

            //Choose the class for the right size background
            switch (items.length ){
                case 1: menu.addClass('one-item'); break;
                case 2: menu.addClass('two-items'); break;
                case 3: menu.addClass('three-items'); break;
            }
            //Add the right title and space for the counter
            $.each(items, function(){
                switch( $(this).attr('data-zztype') ){
                    case 'user':    $(this).addClass( 'like-user').html('Person <span class="like-count"></span>'); break;
                    case 'album':   $(this).addClass( 'like-album').html('Album <span class="like-count"></span>'); break;
                    case 'photo':   $(this).addClass( 'like-photo').html('Photo <span class="like-count"></span>'); break;
                }
                //When an item is clicked, close the menu
                $(this).click( function(){ $(menu).slideUp('fast'); } );
            });

            //Close menu when mouse hovers out of menu
            $(menu).hover(function() {}, function(){
                $(this).slideUp('fast'); //When the mouse hovers out of the menu, roll it back up
            });

            //When anchor is clicked, display menu
            $(anchor).click(  function(e){
                //get the position of the clicked element and display popup above center of it
                var offset = $(anchor).offset();
                var x = ( $(anchor).outerWidth()/2 ) + offset.left - ($(menu).width()/2);
                var y = $(document).height() - offset.top;
                $(menu).css({ bottom: y, left: x }).slideToggle( 'fast' );// Show = slide down
            });

            //If the window resizes close menu (its bottom positioned so it will look out of place if not removed)
            $(window).resize(function() {
                $(menu).css('display','none');
            });
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
});

})( jQuery );