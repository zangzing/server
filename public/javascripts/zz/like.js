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
            wanted_subjects[ $(zzliketag).attr('data-zzid') ]= $(zzliketag).attr('data-zztype');
        });

        if( !$.isEmptyObject( wanted_subjects ) ){
            like.add_id_array( wanted_subjects );
        } else {
            like.loaded = true;
        }
    },

    add_id_array: function( wanted_subjects ){
        if( !$.isEmptyObject( wanted_subjects ) ){
             // get the wanted subjects. Use a POST because of GET query string size limitations
            $.ajax({ type:       'POST',
                url:        zz.path_prefix + '/likes.json',
                data:       {'wanted_subjects' : wanted_subjects },
                success:    function( data ){
                    if( like.loaded ){
                        $.extend( like.hash,  data); // merge new data with existing hash
                        for( key in data )
                                like.refresh_tag( key );
                    } else {
                        like.hash = data;
                        like.draw_tags();
                        like.loaded = true;
                    }},
                dataType: 'json'});
        }
    },

    add_id: function( subject_id, subject_type ){
        if( typeof( subject_id ) != 'undefined' && typeof( like.hash[subject_id]) == 'undefined' ){
             var wanted_subjects = {};
             wanted_subjects[ subject_id ] = subject_type;
             like.add_id_array( wanted_subjects );
        } else {
             like.refresh_tag( subject_id );
        }
    },

    toggle: function(){
        var subject_id   = $(this).attr('data-zzid');
        var subject_type = $(this).attr('data-zztype');
        var url = zz.path_prefix + '/likes/'+subject_id;

        var zzae = 'like.' + subject_type + '.'
        //Decide the action before the value is toggled in the hash
        var type='POST';
        if( like.hash[subject_id]['user'] == true ){
            type='DELETE';
            zzae += 'unlike';
        } else {
            zzae += 'like';
        }

        like.toggle_in_hash( subject_id );
        $.ajax({ type:    type,
            url:     url,
            data:    {  subject_type : subject_type },
            success: function(html){
                $('body').append(html);
                like.display_social_dialog( subject_id );
            },
            error: function( xhr ){
                // toggle in server failed, return hash and screen to previous state
                like.toggle_in_hash( subject_id );
                if( xhr.status == 401 ){
//                    if(confirm('You must be logged in to like this '+ subject_type + '. Would you like to sign in or join now?')){
                        var returnUrl = zz.path_prefix + '/' + subject_type + 's/' + subject_id + '/like';
                        document.location.href = path_helpers.rails_route('signin') + '?return_to=' + returnUrl;
//                    }
                }
            }
        });

        ZZAt.track(zzae);
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
                tag.empty();
                tag.append( button ).append( counter );
            }
            tag.click( like.toggle );
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

    display_social_dialog: function( subject_id ){
        $("#facebook_box").click( function(){
            if( $(this).is(':checked')  && !$("#facebook_box").attr('authorized')){
                $(this).attr('checked', false);
                oauthmanager.login( zz.path_prefix + '/facebook/sessions/new', function(){
                    $("#facebook_box").attr('checked', true);
                    $("#facebook_box").attr('authorized', 'yes');
                });
            }
        });

        $("#twitter_box").click( function(){
            if($(this).is(':checked') && !$("#twitter_box").attr('authorized')){
                $(this).attr('checked', false);
                oauthmanager.login( zz.path_prefix + '/twitter/sessions/new', function(){
                    $("#twitter_box").attr('checked', true);
                    $("#twitter_box").attr('authorized', 'yes');
                });
            }
        });

        $('#social-like-dialog').zz_dialog({ autoOpen: false });
        $('#ld-cancel').click( function(){
            $('#social-like-dialog').zz_dialog('close');
            $('#social-like-dialog').zz_dialog().empty().remove();
        });

        $('#ld-ok').click( function(){
            $.ajax({ type: 'POST',
                url:  zz.path_prefix + '/likes/'+subject_id+'/post',
                data:  $('#social_like_form_'+subject_id).serialize()
            });
            $('#social-like-dialog').zz_dialog('close');
            $('#social-like-dialog').zz_dialog().empty().remove();
        });
        $('#social-like-dialog').zz_dialog('open');
    }
};


(function( $, undefined ) {

$.widget("ui.zzlike_menu", {
        options: {
            anchor: false
        },
        _create: function() {
            var self   = this;
            var menu   = this.element;

            // make sure element is not visible



            //set classes to hide it make it s like-menu
            menu.css('display','none').addClass( 'like-menu');
            var items = $(menu).find('.zzlike').attr('data-zzstyle', 'menu');

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
            });

            //Check if element is already in DOM, if not, insert it at end of body.
            if( menu.parent().size() <= 0 ){
               $('body').append(menu);
            }

            // if there is an optional anchor. link it to it.               
            if( self.options.anchor ){
                //When anchor is clicked, display menu
                $(self.options.anchor).click(  function(){
                    self.open( this );
                });
            }
        },

    open: function(anchor){
        var self = this;
        var menu = self.element;

        if(menu.is(':hidden')){
            if(self._trigger('beforeopen') === false) return; //If any listeners return false, then do not open

            //get the position of the clicked element and display popup above center of it
            var offset = $(anchor).offset();
            var x = ( $(anchor).outerWidth()/2 ) + offset.left - (menu.width()/2);
            var y = $(document).height() - offset.top;
            menu.css({ left: x, bottom: y }).slideDown( 'fast' );// Show = slide down

            //Close menu when mouse hovers out of the menu or clicks
            $(menu).hover(  function(){}, function(){ $(this).slideUp('fast'); });
            setTimeout( function() { // Delay for Mozilla
                $(document).click( function() {
                    if(menu.is(':visible')){
                        $(document).unbind('click')
                        $(menu).slideUp('fast');
                    }
                    return false;
                });
            }, 0);

            //If the window resizes close menu (its bottom positioned so it will look out of place if not removed)
            $(window).one('resize',function() {  $(menu).css('display','none');  });
            self._trigger('open');
        }
    },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
});

})( jQuery );