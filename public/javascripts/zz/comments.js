comments = {

    album_photos_metadata: null,

    load_album_photos_metadata: function(album_id){
        var self = this;
        var url = '/albums/:album_id/photos/comments/metadata'.replace(':album_id', album_id);
        $.get(url, function(json){
            self.album_photos_metadata = json;
        });

    },

    comment_count_for_photo: function(photo_id, callback){
        var self = this;
        var try_again = function(){
            if(self.album_photos_metadata){
                for(var i=0; i<self.album_photos_metadata.length;i++){
                    if(self.album_photos_metadata[i].photo_id == photo_id){
                        callback(self.album_photos_metadata[i].comments_count);
                        return;
                    }
                }
            }
            else{
                setTimeout(try_again, 100);
            }
        };

        try_again();
    }

    

};








