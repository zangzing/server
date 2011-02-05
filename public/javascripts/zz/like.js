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
        $.post( url, {}, function(){
             like.toggle_in_hash( subject_id );
             like.refresh_tag( subject_id );
        })
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
        $.post( '/likes.json',
                {'wanted_subjects' : wanted_subjects },
                function( data ){
                    like.hash = data;
                    like.loaded = true;
                    callback()},
                'json');

    },

    draw_tags: function(){
        $('zzlike').each( function(index, zzliketag){
            var id = $(zzliketag).attr('subj_id');
            $(zzliketag).attr('subj_type', like.hash[id]['type']);
            link = $('<a href=\"javascript:void(0)\"><H4>'+like.hash[id]['count']+'</h4></a>')
            switch(like.hash[id]['type']){
                case 'P': link.click(function(){ like.photo(id)}); break;
                case 'A': link.click(function(){ like.album(id)}); break;
                case 'U': link.click(function(){ like.user(id)}); break;
            }
            $(zzliketag).html(link)
        });
    },

    refresh_tag: function(id) {
        console.log ('refresh_tag id= '+id+' count='+like.hash[id]['count']);
        $('zzlike[subj_id="'+id+'"] a').html('<H2>'+like.hash[id]['count']+'</h2>')
    }
};
