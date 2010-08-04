//
// agent.js
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//


var server = {
    createPhoto : function(albumId, onSuccess, onError){

        var callServer = function(agentId){

            $.ajax({
               type: "POST",
               dataType: "json",
               url: "/albums/" + albumId + "/photos.json",
               data: {'photo[agent_id]':agentId},
               success: onSuccess,
               error: onError
            });
        }
        
        agent.getAgentId(callServer, onError)
    },


    createMultiplePhotos : function(albumId, count, onSuccess, onError){

        var callServer = function(agentId){

            $.ajax({
               type: "POST",
               dataType: "json",
               url: "/albums/" + albumId + "/photos/create_multiple.json?count=" + count,
               data: {'photo[agent_id]':agentId},
               success: onSuccess,
               error: onError
            });
        }

        agent.getAgentId(callServer, onError)
    },




    destroyPhoto : function(albumId, photoId, onSuccess, onError){

        var callServer = function(agentId){

            $.ajax({
               type: "DELETE",
               dataType: "json",
               url: "/photos/" + photoId + ".json",
               data: {'photo[agent_id]':agentId},  
               success: onSuccess,
               error: onError
            });
        }

        agent.getAgentId(callServer, onError)


   }
}
