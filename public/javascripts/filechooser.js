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
    json : [],

    setPath: function(path)
    {
        filechooser.path = path;
        filechooser.reloadChooser();
    },

    setAlbumId: function(albumId)
    {
        filechooser.albumId = albumId
    },

    reloadChooser : function()
    {

        var callback = function(json)
        {
            filechooser.json = json
            filechooser.repaintChooser()
        }


        if(filechooser.path == "")
        {
            agent.getRootsAsync(callback);
        }
        else
        {
            agent.getFilesAsync(filechooser.path, callback);
        }

    },

    repaintChooser : function()
    {
        $("#filechooser-back-button").html(filechooser.buildBackButtonHtml())
        $("#filechooser-title").html(filechooser.buildTitleHtml())
        $("#filechooser-files").html(filechooser.buildChooserHtml(filechooser.json))
    },


    selectedPhotos : function()
    {
        return filechooser.selection
    },

    isSelected : function(virtual_path)
    {
        for(var i in filechooser.selection)
        {
            if(filechooser.selection[i]["virtual_path"] == virtual_path)
            {
                return true
            }
        }
        return false
    },

    addPhoto : function(virtual_path)
    {
        var photo = {}
        photo["virtual_path"] = virtual_path
        photo["photo_id"] = null


        filechooser.selection.push(photo)
        filechooser.repaintChooser() //change clicked photo to gray
        filechooser.repaintSelection() //moves picture to selection tray

        agent.addPhotoAsync(filechooser.albumId, virtual_path, function(response){
            photo["photo_id"] = response["photo_id"]
            filechooser.repaintSelection() //we now have the photo_id, so we can display the close box
        }, function(response){
            logger.debug(response)
        });
    },

    removePhoto : function(photo_id)
    {
        agent.deletePhotoAsynch(filechooser.albumId, photo_id, function(){
            var list = [];
            for(i in filechooser.selection)
            {
                var test = filechooser.selection[i]
                if(test["photo_id"] != photo_id)
                {
                    list[list.length] = test
                }
            }
            filechooser.selection = list
            filechooser.repaintSelection()
            filechooser.reloadChooser()
        })
    },

    repaintSelection : function()
    {
        $("#filechooser-selection").html(filechooser.buildSelectionHtml())
        $("#filechooser-selection").scrollLeft(10000)
    },


    buildSelectionHtml : function()
    {
        var html = ""
       // var width = 200 * filechooser.selection.length

        for(var i in filechooser.selection)
        {

            var photo = filechooser.selection[i]

            html += "<div style='float:left'>"
            html += "<img height='75' style='margin-left:8px; border:4px solid white' src='" + agent.getThumbnailUrl(photo['virtual_path']) + "'>";

            if(photo["photo_id"] != null)
            {
                html += "<a style=\"float:right;margin-left:0px\" href=\"\" onclick=\"filechooser.removePhoto(" + photo['photo_id'] + ");return false;\">"
                html += "(x)"
                html += "</a>"
            }
            html += "</div>" 

        }
        return html
        
    },

    buildChooserHtml: function(json)
    {

        var html = ""

        for (var i = 0; i < json.length;i++)
        {

            html += "<div style='text-align:center; width:180px; height:140px; float:left; border:0px'>"


            var file = json[i]

            if (file.is_dir == true)
            {
                html += "<img height='100' src='/images/folder.jpeg'>"
            }
            else
            {
                var BOX = 125
                var width;
                var height;

                if(file.aspect_ratio)
                {
                    if(file.aspect_ratio == 1)
                    {
                        height = BOX
                        width = BOX
                    }
                    else if(file.aspect_ratio < 1)
                    {
                        height = BOX
                        width = BOX * file.aspect_ratio
                    }
                    else
                    {
                        width = BOX
                        height = BOX / file.aspect_ratio
                    }
                }
                else
                {
                    height = BOX
                    width = BOX
                }


                if(!filechooser.isSelected(file.virtual_path))
                {
                    html += "<a href=\"\" onclick=\"filechooser.addPhoto(\'" + file.virtual_path + "\');return false;\">"
                    html += "<img height='" + height + "' width='" + width + "' style='border:4px solid white' src='" + agent.getThumbnailUrl(file.virtual_path) + "'>"
                    html += "</a>"
                }
                else
                {
                    html += "<img height='" + height + "' width='" + width + "' style='border:4px solid #AAAAAA' src='" + agent.getThumbnailUrl(file.virtual_path) + "'>"
                }
            }

            html += "<br/>"

            if (file.is_dir == true)
            {
                html += "<a href='#" + file.virtual_path + "'>"
                html += file.name
                html += "</a>"
            }

            html += "</div>"
        }
        return html

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
                break
            }
            else
            {
                breadcrumb["title"] = path.substring(i+1)
                breadcrumb["virtual_path"] = path
                breadcrumbs[breadcrumbs.length] = breadcrumb

                path = path.substring(0,i)
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
            html += crumb["title"]
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