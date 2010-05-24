$(function() {

    // Bind an event to window.onhashchange that, when the hash changes, gets the
    // hash and adds the class "selected" to any matching nav link.
    $(window).bind('hashchange', function() {
        filechooser.setPath(document.location.hash.substring(1))

    })

    // Since the event is only triggered when the hash changes, we need to trigger
    // the event now, to handle the hash the page may have loaded with.
    $(window).trigger('hashchange');

});


var filechooser = {


    setPath: function(path)
    {
        //console.log("setting path: " + path)
        filechooser._path = path;
        filechooser.refresh();
    },

    setAlbumId: function(albumId)
    {
        filechooser._albumId = albumId
    },

    refresh : function()
    {

        if(filechooser._path == "!")
        {
            agent.getRootsAsync(function(json) {
                filechooser.refreshCallBack(json);
            });
        }
        else
        {
            agent.getFilesAsync(filechooser._path, function(json) {
                filechooser.refreshCallBack(json);
            });
        }

    },

    refreshCallBack: function(json)
    {
        $("#filechooser-files").html(filechooser.buildFileListHtml(json));
        $("#filechooser-breadcrumbs").html(filechooser.buildBreadCrumbsHtml());

    },



    buildFileListHtml: function(json)
    {

        var html = "";

        html += "";

        for (var i = 0; i < json.length;i++)
        {

            html += "<div style='text-align:center; width:200px; height:160px; float:left; border:0px'>";


            var file = json[i];

            if (file.isImage == true)
            {
                html += "<img height='100' src='" + agent.getThumbnailUrl(file.path) + "'>";
            }
            else if (file.isDirectory == true)
            {
                html += "<img height='100' src='folder.jpeg'>";
            }
            else
            {
                html += "<img height='100' src='file.png'>";
            }

            html += "<br/>"

            if (file.isDirectory == true)
            {
                html += "<a href='#" + file.path + "'>";
                html += file.name
                html += "</a>";
            }
            else
            {
                html += file.name
            }

            //html += "<br>" + i


            if ((file.isMarkedForUpload != true))
            {
                html += "<br/>[<a href=\"javascript:filechooser.upload('" + file.path + "','" + filechooser._albumId + "')\">"

                if (file.isDirectory == true)
                {
                    html += "upload all"
                }
                else
                {
                    html += "upload"
                }

                html += "</a>]"

            }
            else
            {

                if (file.isDirectory == true)
                {
                    //not supported
                    //html += "cancel upload"
                }
                else
                {
                    html += "<br/>[<a href=\"javascript:filechooser.cancelUpload('" + file.path + "')\">"
                    html += "cancel upload"
                    html += "</a>]"
                }

            }

            html += "</div>";
        }
        return html;

    },

    upload : function(path, albumId)
    {
        uploader.upload(path, albumId);
    },

    cancelUpload : function(path)
    {
        uploader.cancelUpload(path);
    },

    buildBreadCrumbsHtml: function()
    {
        var segments = filechooser._path.split("/");
        var url = "!";
        var html = "<a href='#!'>My Computer</a> ";
        for (i = 1; i < segments.length; i++)
        {

            url += "/" + segments[i];
            html += " / "
            html += "<a href='#" + url + "'>";
            html += segments[i];
            html += "</a>";
        }
        return html;
    }
}