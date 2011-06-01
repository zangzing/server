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
        if( typeof( subject_id ) != 'undefined' && subject_id != 0 ){
            if( like.loaded && typeof( like.hash[subject_id]) == 'undefined' ){
                var wanted_subjects = {};
                wanted_subjects[ subject_id ] = subject_type;
                like.add_id_array( wanted_subjects );
            } else {
                like.refresh_tag( subject_id );
            }
        }
    },

    toggle: function(){
        var subject_id   = $(this).attr('data-zzid');
        var subject_type = $(this).attr('data-zztype');
        var url = zz.path_prefix + '/likes/'+subject_id;

        var zzae = 'like.' + subject_type + '.'
        //Decide the action before the value is toggled in the hash
        var type='post';
        if( like.hash[subject_id]['user'] == true ){
            type='delete';
            zzae += 'unlike';
        } else {
            zzae += 'like';
        }

        like.toggle_in_hash( subject_id );
        $.ajax({ type: 'POST',
            url:     url,
            data:    {  subject_type : subject_type, _method: type },
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
            like.draw_tag( zzliketag );
        });
    },

    draw_tag: function( tag){
        var id = $(tag).attr('data-zzid');
        if( typeof(like.hash[id])!= 'undefined' ){
            if( $(tag).attr('data-zzstyle') =="menu" ){
                $(tag).find("span.like-count").html( '('+like._count(id)+')' );
            }else{
                var button  = $( ' <div class="zzlike-button">'),
                    icon    = $( '<div class="zzlike-icon">' ),
                    counter = $( '<div class="zzlike-count">'+like._count(id)+'</div>');

                if( like.hash[id]['count'] <= 0){
                    counter.addClass('empty');
                }
                if( like.hash[id]['user'] ){
                    $(icon).addClass( 'thumbup' );
                } else {
                    $(icon).addClass( 'thumbdown' );
                }
                $(button).append( icon ).append(counter);
                $(tag).empty();
                $(tag).append( button );
            }
            $(tag).click( like.toggle );
        }
    },

    _count: function( id ){
        var count = like.hash[id]['count'];
        if( count <= 0 ){
           return '';
        }else if( count <= 1000 ){
           return count.toString();
        }else if( count <= 1000000){
           return Math.floor( count/1000 ).toString()+'K';
        }
    },

    refresh_tag: function(id){
        if( like.hash[id]){
            $('.zzlike[data-zzid="'+id+'"]').each( function(){
                if( $(this).attr('data-zzstyle') =="menu" ){
                    $(this).find('div.like-count').html( '('+like._count(id)+')' );
                } else {
                    if( like.hash[id]['user'] ){
                        $(this).find('.thumbdown').addClass('thumbup').removeClass( 'thumbdown' );
                    } else {
                        $(this).find('.thumbup').addClass('thumbdown').removeClass( 'thumbup' );
                    }

                    if( like.hash[id]['count'] <= 0){
                        $(this).find('.zzlike-count').addClass('empty');
                    }else{
                        $(this).find('.zzlike-count').html(like._count(id));
                    }
                }
                //logger.debug("refreshing and rebinding tags for "+id);
                $(this).unbind('click', like.toggle ).click( like.toggle );
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
