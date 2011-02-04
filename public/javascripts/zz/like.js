//
//  Copyright 2011. ZangZing LLC www.zangzing.com
//

//zz.current_user_id

var likes = {

    hash: {},      // Hash keys are ids of liked subjects values are 'liked'
    loaded: false, // True when the hash is loaded for the logged in user

    init: function(){
        likes.load_hash();
    },

    user: function(user_id){
        likes.toggle_in_server( '/users/'+user_id+'/like', user_id);
    },

    album: function(album_id){
         likes.toggle_in_server( '/albums/'+album_id+'/like', album_id);
    },

    photo: function(photo_id){
         likes.toggle_in_server( '/photos/'+photo_id+'/like', photo_id)
    },

    toggle_in_server: function( url, subject_id ){
        $.post( url, {}, function(){
             likes.toggle_in_hash( subject_id );
        })
    },

    toggle_in_hash: function(subject_id){
       if( !likes.loaded ){
           likes.load_hash();
       }

       if( subject_id  in likes.hash){  //The subject is already liked i.e. in the hash, remove it
          delete likes.hash[subject_id];
       }else{  // the subject is not liked, add it to hash
          likes.hash[subject_id] = 'liked';
       }
    },

    load_hash: function(){
      if(typeof(zz.current_user_id) !== 'undefined' ){
            //To retrieve hashes user must be logged in.
            // This function wil return silently otherwise
            $.get( '/likes.json', {}, function( data ){
                likes.hash = data;
                likes.loaded = true;
            }, 'json');
      }
    },

    contains: function(subject_id){
        if( !likes.loaded ){
            likes.load_hash();
        }
       return( subject_id in likes.hash );
    }
};
