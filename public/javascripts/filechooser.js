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

    selection : [],

    setPath: function(path)
    {
        filechooser.path = path;
        filechooser.refresh();
    },

    setAlbumId: function(albumId)
    {
        filechooser.albumId = albumId
    },

    refresh : function()
    {

        if(filechooser.path == "")
        {
            agent.getRootsAsync(function(json) {
                filechooser.refreshCallBack(json);
            });
        }
        else
        {
            agent.getFilesAsync(filechooser.path, function(json) {
                filechooser.refreshCallBack(json);
            });
        }

    },


    selectedPhotos : function()
    {
        return filechooser.selection
    },

    addToSelection : function(virtual_path)
    {
        filechooser.selection.push(virtual_path);
        filechooser.refreshSelection();
        agent.uploadAsync(filechooser.albumId, virtual_path)
    },
    
    refreshCallBack: function(json)
    {
        $("#filechooser-back-button").html(filechooser.buildBackButtonHtml());
        $("#filechooser-title").html(filechooser.buildTitleHtml());
        $("#filechooser-files").html(filechooser.buildFileListHtml(json));
    },


    refreshSelection : function()
    {
        $("#filechooser-selection").html(filechooser.buildSelectionHtml());
        $("#filechooser-selection").scrollLeft(10000);


    },


    buildSelectionHtml : function()
    {
        var html = ""
       // var width = 200 * filechooser.selection.length

        html += "<table border=1><tr><td nowrap>"
        for(var i in filechooser.selection)
        {
            var virtual_path = filechooser.selection[i]
            html += "<img height='75' style='margin-left:3px; border:4px solid white' src='" + agent.getThumbnailUrl(virtual_path) + "'>";

        }
        html += "</td></tr></table>"
        return html
        
    },

    buildFileListHtml: function(json)
    {

        var html = "";

        for (var i = 0; i < json.length;i++)
        {

            html += "<div style='text-align:center; width:180px; height:140px; float:left; border:0px'>";


            var file = json[i];

            if (file.is_dir == true)
            {
                html += "<img height='100' src='/images/folder.jpeg'>";
            }
            else
            {
                html += "<a href=\"\" onclick=\"filechooser.addToSelection(\'" + file.virtual_path + "\');return false;\">"

                html += "<img height='100' style='border:4px solid white' src='" + agent.getThumbnailUrl(file.virtual_path) + "'>";
                html += "</a>"
            }

            html += "<br/>"

            if (file.is_dir == true)
            {
                html += "<a href='#" + file.virtual_path + "'>";
                html += file.name
                html += "</a>";
            }

            html += "</div>";
        }
        return html;

    },


    buildBreadCrumbs : function()
    {
        var breadcrumbs = []
        var path = filechooser.path


        for(;;)
        {
            var breadcrumb = {}
            var i = path.lastIndexOf('/')

            if(i == -1)
            {
                breadcrumb["title"] = "Home"
                breadcrumb["virtual_path"] = ""
                breadcrumbs[breadcrumbs.length] = breadcrumb
                break;
            }
            else
            {
                breadcrumb["title"] = path.substring(i+1);
                breadcrumb["virtual_path"] = path;
                breadcrumbs[breadcrumbs.length] = breadcrumb

                path = path.substring(0,i);
            }

        }
        return breadcrumbs.reverse()
    },

    buildBackButtonHtml: function()
    {
        var breadcrumbs = filechooser.buildBreadCrumbs()
        breadcrumbs.pop()
        var crumb = breadcrumbs.pop()
        if(crumb)
        {
            html =   "<a href='#" + crumb["virtual_path"] + "'>"
            html += "&lt;"
            html += crumb["title"];
            html += "]"
            html += "</a>"
            return html
        }
        else
        {
            return ""
        }

    },

    buildTitleHtml: function()
    {
        return "[" + filechooser.buildBreadCrumbs().pop()["title"] + "]"
    }
}