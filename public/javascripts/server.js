//
// agent.js
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//


var server = {
    createPhoto : function(albumId, onSuccess, onError){
        $.ajax({
           type: "POST",
           dataType: "json",
           url: "/albums/" + albumId + "/photos.json",
           data: {'photo[agent_id]':'AGENT_ID_SET_IN_AGENT_JS'},
           success: onSuccess,
           error: onError
         });

    },


    destroyPhoto : function(albumId, photoId, onSuccess, onError){
        $.ajax({
           type: "DELETE",
           dataType: "json",
           url: "/photos/" + photoId + ".json",
           data: {'photo[agent_id]':'AGENT_ID_SET_IN_AGENT_JS'},
           success: onSuccess,
           error: onError
         });
    }
}