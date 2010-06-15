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
        agent.callAgentAsync("listroots", {}, onSuccess, onError)

    },

	getFilesAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("listdir", {"path":path}, onSuccess, onError)
	},

    getRootsAsync: function(onSuccess, onError)
    {
        agent.callAgentAsync("listroots", {}, onSuccess, onError)
    },


	uploadAsync: function(path, albumId, onSuccess, onError)
	{
 		agent.callAgentAsync("upload", {"path":path, "albumid":albumId}, onSuccess, onError)
	},

	cancelUploadAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("cancel_upload", {"path":path}, onSuccess, onError)
	},


	getUploadStatsAsync: function(onSuccess, onError)
	{
		agent.callAgentAsync("upload_stats",{}, onSuccess, onError)
	},

	getThumbnailUrl: function(path)
	{
		return "http://localhost:" + agent.port + "/thumbnail?path=" + path;
	},


	callAgentAsync: function(command, params, onSuccess, onError)
	{
		var query = ""

        for(name in params)
        {
            if(query!="")
            {
                query+="&";
            }
            query+=name;
            query+="="
            query+=encodeURIComponent(params[name]);
        }


        var url = "http://localhost:" + agent.port + "/" + command + "?" + query + "&callback=?"

        $.jsonp({
            url: url,
            success: function(json) {
				onSuccess(json)
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