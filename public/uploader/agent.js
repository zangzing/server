var agent =  {
		
	getFilesAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("listdir", path, onSuccess, onError)
	},
	

	uploadAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("upload", path, onSuccess, onError)
	},
	
	cancelUploadAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("cancel_upload", path, onSuccess, onError)
	},
	
	
	getUploadStatsAsync: function(onSuccess, onError)
	{
		agent.callAgentAsync("upload_stats", null, onSuccess, onError)
	},
	
	getThumbnailUrl: function(path)
	{
		return "http://localhost:9090/thumbnail/" + path;
	},

    authenticate: function(sessionId)
    {
        //alert("authenticating with sessionid: " + sessionId)
    },
	
	callAgentAsync: function(command, param, onSuccess, onError)
	{
		$.ajax({
            url: "http://localhost:9090/" + command + "/" + param,
            dataType: "json", 
            success:function(response){
				onSuccess(response)
            },
            error:function (xhr, ajaxOptions, thrownError){
				alert("error in '/" + command + "':" + thrownError);
				onError(thrownError);
            }    
        });		
	}
}