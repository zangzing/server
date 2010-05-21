var agent =  {
		
	getFilesAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("listdir", path, null, onSuccess, onError)
	},
	

	uploadAsync: function(path, albumId, onSuccess, onError)
	{
		agent.callAgentAsync("upload", path, albumId, onSuccess, onError)
	},
	
	cancelUploadAsync: function(path, onSuccess, onError)
	{
		agent.callAgentAsync("cancel_upload", path, null, onSuccess, onError)
	},
	
	
	getUploadStatsAsync: function(onSuccess, onError)
	{
		agent.callAgentAsync("upload_stats",null, null, onSuccess, onError)
	},
	
	getThumbnailUrl: function(path)
	{
		return "http://localhost:9090/thumbnail/null/" + path;
	},

	
	callAgentAsync: function(command, param1, param2, onSuccess, onError)
	{
		$.ajax({
            url: "http://localhost:9090/" + command + "/" + param2 + "/" + param1,
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