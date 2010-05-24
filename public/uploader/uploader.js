
setInterval("uploader.refresh()", 3000)

var uploader = {

    refresh: function()
    {
        agent.getUploadStatsAsync(function(json) {
            uploader.refreshCallBack(json);
        });
    },


    upload: function(path, albumId)
    {

        console.log("uploading: " + path +" " + albumId)        

        uploader._justAddedToUpload = true

        agent.uploadAsync(path, albumId, function(response) {
            if(filechooser)
            {
                filechooser.refresh();
            }
            uploader.refresh();
        });
    },

    cancelUpload: function(path)
    {
        agent.cancelUploadAsync(path, function(response) {
            if(filechooser)
            {
                filechooser.refresh();
            }
            uploader.refresh();
        });
    },

    refreshCallBack : function(json)
    {
        var html="<div style='width:" + (json.length+1) * 200 + "'>"
        for(var i=0;i<json.length;i++)
        {
            var file = json[i];


            html += "<div style='text-align:middle; width:200px; height:150px; border:0px; float:left'>";
            html += "<center><img height='100' src='" + agent.getThumbnailUrl(file.path) + "'></center>";
            html += "<br>";

            if(file.isRunning || file.isDone)
            {
                html += "<center><div style='border:1px solid black;height:8px;width:150px'>";
                html += "<div style='float:left;border-top:4px solid blue; border-bottom:4px solid blue; height:0px;width:" + ((150 * file.bytesUploaded)/file.size) + "px'></div>"
                html += "</div></center>"
            }
            html += "<center>" + file.name + "</center>";
            html += "<center>[<a href=\"javascript:uploader.cancelUpload('" + file.path + "')\">cancel upload</a>]</center>";

            if(file.error!="")
            {
                html += "<center>ERROR: " + file.error + "</center>"
            }

            html += "</div>";


            //[{"bytesUploaded": 0, "path": "/Users/hopemeng/Desktop/Cambodia/DSC_0153.JPG", "isRunning": true, "isDone": false, "size": 4600850}]
        }
        html += "</div>";
        $("#uploader").html(html);

        if(uploader._justAddedToUpload)
        {
            $("#uploader").scrollLeft(json.length*200);
            uploader._justAddedToUpload=false
        }

    }
}
