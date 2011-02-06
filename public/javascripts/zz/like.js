//
//  Copyright 2011. ZangZing LLC www.zangzing.com
//

//zz.current_user_id

var like = {

    hash: {},      // Hash keys are ids of liked subjects values are 'liked'
    loaded: false, // True when the hash is loaded for the logged in user

    init: function(){
        like.load_hash( like.draw_tags );
    },

    user: function(user_id){
        like.toggle_in_server( '/users/'+user_id+'/like', user_id);
    },

    album: function(album_id){
         like.toggle_in_server( '/albums/'+album_id+'/like', album_id);
    },

    photo: function(photo_id){
         like.toggle_in_server( '/photos/'+photo_id+'/like', photo_id)
    },

    toggle_in_server: function( url, subject_id ){
        like.toggle_in_hash( subject_id );
        like.refresh_tag( subject_id );
        $.ajax({ type:       'POST',
                 url:        url,
                 success:    function(){

                             },
                 error:      function( xhr, textStatus, errorThrown){
                     like.toggle_in_hash( subject_id );
                     like.refresh_tag( subject_id );
                     if( xhr.status == 401 ) alert('Must Be Logged In'); }
        });
    },

    toggle_in_hash: function(subject_id){
       if( !like.loaded ){
           like.load_hash();
       }
       if( subject_id  in like.hash){  //The subject is in our hash (like must be inited with all the wanted subjects)
         if( like.hash[subject_id]['user'] == true ){  // The user likes the subject, toggle it off and decrease counter
             like.hash[subject_id]['user'] = false
             like.hash[subject_id]['count'] -= 1;
         }else{  // The user does not like the subject, toggle it on and increase counter
             like.hash[subject_id]['user'] = true
             like.hash[subject_id]['count'] += 1;
         }
       }
    },

    load_hash: function( callback ){
        //obtain the array of wanted subjects from the zzlike tags with subj_id attributes
        var wanted_subjects={};
        $('zzlike').each( function(index, zzliketag){
            id = $(zzliketag).attr('subj_id');
            type = $(zzliketag).attr('subj_type');
            wanted_subjects[id]=type;
        });

        // get the wanted subjects. Use a POST because of GET query string size limitations
        $.ajax({ type:       'POST',
                 url:        '/likes.json',
                 data:       {'wanted_subjects' : wanted_subjects },
                 success:    function( data ){
                                like.hash = data;
                                like.loaded = true;
                                callback()},
                 dataType: 'json'});

    },

    draw_tags: function(){
        $('zzlike').each( function(index, zzliketag){
            var id = $(zzliketag).attr('subj_id');
            $(zzliketag).attr('subj_type', like.hash[id]['type']);
            counter = $('<span >'+like.hash[id]['count']+'</span>');
            if( like.hash[id]['user'] ){
                img = $( '<img   src="/images/icon-like-on.png">');
            } else {
                img = $('<img  src="/images/icon-like-off.png">');
            }
           div = $('<div ></div>').append( img ).append( counter );
           switch(like.hash[id]['type']){
                case 'P': div.click(function(){ like.photo(id)}); break;
                case 'A': div.click(function(){ like.album(id)}); break;
                case 'U': div.click(function(){ like.user(id)}); break;
            }

            $(zzliketag).html(div);
        });
    },

    refresh_tag: function(id){
        if( like.hash[id]){
            if( like.hash[id]['user'] ){
                $('zzlike[subj_id="'+id+'"] div img').attr('src','/images/icon-like-on.png' );
            } else {
                $('zzlike[subj_id="'+id+'"] div img').attr('src','/images/icon-like-off.png' );
            }
            $('zzlike[subj_id="'+id+'"] div span').html(like.hash[id]['count']);
        }
    },

    display_login: function(){

    },

    is_it_liked: function( subject_id ){
        if( like.loaded ) return like.hash[subject_id]['user'];
        return false;
    }
};
