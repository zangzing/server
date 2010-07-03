//
// agent.js
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//

var agent =  {

    port : 9090,

    isPresent : false,
    hasBeenPinged : false,

    
    isAgentPresentAsync: function(callback)
    {

        var onSuccess = function()
        {
            agent.isPresent = true;
            agent.hasBeenPinged = true;
            callback(true)
        }

        var onError = function()
        {
            agent.isPresent = false;
            agent.hasBeenPinged = true;
            callback(false)
        }


        agent.callAgentAsync("/ping", onSuccess, onError)

    },

	getFilesAsync: function(virtual_path, onSuccess, onError)
	{
		agent.callAgentAsync("/files/" + virtual_path, onSuccess, onError)
	},

    getRootsAsync: function(onSuccess, onError)
    {
        agent.callAgentAsync("/roots", onSuccess, onError)
    },


	addPhotoAsync: function(albumId, virtual_path, onSuccess, onError)
	{
 		agent.callAgentAsync("/albums/" + albumId + "/photos/create?path=" + encodeURIComponent(virtual_path), onSuccess, onError)
	},

	deletePhotoAsynch: function(albumId, photoId, onSuccess, onError)
	{
        agent.callAgentAsync("/albums/" + albumId + "/photos/" + photoId + "/destroy", onSuccess, onError)
	},


	getUploadStatsAsync: function(onSuccess, onError)
	{
        //todo
	},

	getThumbnailUrl: function(path, hint)
	{
        url = "http://localhost:" + agent.port + "/files/" + encodeURIComponent(path) + "/thumbnail"
        if(hint && hint.length > 0)
        {
            url+= "?hint=" + hint           
        }
        return url

	},


	callAgentAsync: function(path, onSuccess, onError)
	{
        var url;
        if(path.indexOf('?')==-1)
        {
            url = "http://localhost:" + agent.port  + path + "?callback=?"
        }
        else
        {
            url = "http://localhost:" + agent.port  + path + "&callback=?"
        }
        $.jsonp({
            url: url,
            success: function(json) {
				if(onSuccess)
                {
                    onSuccess(json)
                }
            },
            error: function() {
                if(onError)
                {
                    onError("error calling " + url)
                }
            }
        });
	}
}