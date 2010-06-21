var agent =  {

    port : 9090,

    isAgentPresentAsync: function(callback)
    {

        var onSuccess = function()
        {
            callback(true)
        }

        var onError = function()
        {
            callback(false)
        }


        //TODO: this is an expensive call, chance to something else
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

	getThumbnailUrl: function(path)
	{
		return "http://localhost:" + agent.port + "/files/" + encodeURIComponent(path) + "/thumbnail"
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