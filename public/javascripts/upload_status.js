var upload_stats = {

    stats_for_album: function(album_id, photos_in_album, callback){
        agent.callAgent("/upload_status", function(json){
            var in_progress = json['uploads_in_progress'];
            var in_queue = json['queued'];
            var list = [];

            for(var i in in_progress){
               list.push({album_id:in_progress[i]['album_id'], photo_id:in_progress[i]['photo_id'], bytes_remaining: in_progress[i]['size']-in_progress[i]['bytes_uploaded'] });
            }

            for(var i in in_queue){
               list.push({ album_id:in_queue[i]['album_id'],photo_id:in_queue[i]['photo_id'], bytes_remaining: in_queue[i]['size']});
            }



            var start_counting = false;
            var bytes_remaining = 0
            var album_photos_remaining = 0
            for(var i in list){
                if(!start_counting && list[i]['album_id'] === album_id){
                    start_counting = true;
                }

                if(list[i]['album_id'] === album_id){
                    album_photos_remaining += 1;
                }

                if(start_counting){
                    bytes_remaining += list[i]['bytes_remaining'];
                }
            }

            var time_remaining = 0
            if(bytes_remaining > 0){
                time_remaining = bytes_remaining / json['ave_bytes_sec'];
            }
                
            var percent_complete = photos_in_album - album_photos_remaining * 100 / photos_in_album;



            callback(time_remaining, percent_complete);
        });
    }
};