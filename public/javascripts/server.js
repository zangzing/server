//
// agent.js
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//


var server = {
    createPhoto : function(albumId, onSuccess, onError){

        console.debug("create photo")

        var callServer = function(agentId){


            console.debug("adding picture with agent id " + agentId)

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


    destroyPhoto : function(albumId, photoId, onSuccess, onError){

        var callServer = function(agentId){

            console.debug("deleting picture with agent id " + agentId)

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
