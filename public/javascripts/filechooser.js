



$(function() {

    // Bind an event to window.onhashchange that, when the hash changes, gets the
    // hash and adds the class "selected" to any matching nav link.
    $(window).bind('hashchange', function() {
        filechooser.showPath(document.location.hash.substring(1))

    })

    // Since the event is only triggered when the hash changes, we need to trigger
    // the event now, to handle the hash the page may have loaded with.
    $(window).trigger('hashchange');
});


var filechooser = {

    selection : [],
    json : [],
    imageloader : null,
    virtualPath: null,
    albumId: null,


    showPath: function(virtualPath) {
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        filechooser.imageloader = new ImageLoader(function(id, src) {
            $("#" + id).attr('src', src)
        });

        filechooser.virtualPath = virtualPath;
        filechooser.reloadChooser();


    },

    setAlbumId: function(albumId) {
        filechooser.albumId = albumId
    },

    reloadChooser : function() {

        var callback = function(json) {
            filechooser.json = json
            filechooser.repaintChooser()
        }


        if (filechooser.virtualPath == "") {
            agent.getRoots(callback);
        }
        else {
            agent.getFiles(filechooser.virtualPath, callback);
        }

    },

    repaintChooser : function() {
        $("#filechooser-back-button").html(filechooser.buildBackButtonHtml())
        $("#filechooser-title").html(filechooser.buildTitleHtml())
        $("#filechooser-files").html(filechooser.buildChooserHtml(filechooser.json))

        filechooser.imageloader.start(5);
    },


    selectedPhotos : function() {
        return filechooser.selection
    },

    isSelected : function(virtual_path) {
        for (var i in filechooser.selection) {
            if (filechooser.selection[i]["virtual_path"] == virtual_path) {
                return true
            }
        }
        return false
    },


    selectFolder : function(folderVirtualPath){

        var onGetFiles = function(json){
            //2. add photos to 'added photos' tray

            var photos = []
            for (i in json){
                if(json[i]['is_dir'] == false ){
                    var photo = {}
                    photos[photos.length] = photo
                    photo["virtual_path"] = json[i]["virtual_path"]
                    photo["photo_id"] = null
                    filechooser.selection.push(photo)
                }
            }


            var onCreatePhotos = function(json){
                //4. update photo ids of items in 'added photos' tray
                for(i in photos){
                    photos[i]['photo_id'] = json[i]['id']
                }
                filechooser.repaintSelection(); //we now have the photo_id, so we can display the close box
                
                //5. call the agent to upload each photo
                for(i in photos){
                    //todo: create agent api that uploads contents of folder given a virtual_path and a list of photo ids
                    agent.uploadPhoto(filechooser.albumId, photos[i]['photo_id'], photos[i]['virtual_path'], function(){}, function(){});
                }


            }

            //3. create photo object on server for each photo in folder
            server.createMultiplePhotos(filechooser.albumId, photos.length, onCreatePhotos, function(){})
        }


        //1. get contents of folder from the agent
        agent.getFiles(folderVirtualPath, onGetFiles);

    },

    selectPhoto : function(virtual_path) {
        var photo = {}
        photo["virtual_path"] = virtual_path
        photo["photo_id"] = null


        filechooser.selection.push(photo)
        filechooser.repaintSelection() //moves picture to selection tray
//        filechooser.repaintChooser() //very inefficiently change clicked photo to gray


        var onCreatePhoto = function(json){
            var photoId = json["id"];

            photo["photo_id"] = photoId;
            filechooser.repaintSelection(); //we now have the photo_id, so we can display the close box

            agent.uploadPhoto(filechooser.albumId, photoId, virtual_path, function(){}, function(){});
        }

        server.createPhoto(filechooser.albumId, onCreatePhoto)



    },

    unselectPhoto : function(photoId) {
        var list = [];
        for (var i in filechooser.selection) {
            var test = filechooser.selection[i]
            if (test["photo_id"] != photoId) {
                list[list.length] = test
            }
        }
        filechooser.selection = list
        filechooser.repaintSelection()
//        filechooser.reloadChooser()
        

        server.destroyPhoto(filechooser.albumId, photoId, function(){}, function(){})
        agent.cancelUpload(filechooser.albumId, photoId, function(){}, function(){})

    },

    repaintSelection : function() {
        $("#filechooser-selection").html(filechooser.buildSelectionHtml())
        $("#filechooser-selection").scrollLeft(10000)
    },


    buildSelectionHtml : function() {
        var html = ""
        // var width = 200 * filechooser.selection.length

        for (var i in filechooser.selection) {

            var photo = filechooser.selection[i]


            var hint = ""
            if (photo.hint_thumb_path) {
                hint = "hint=" + encodeURIComponent(file.hint_thumb_path)
            }


            html += "<div style='float:left'>"
            html += "<img height='75' style='margin-left:8px; border:4px solid white' src='" + agent.getThumbnailUrl(photo['virtual_path'], hint) + "'>";

            if (photo["photo_id"] != null) {
                html += "<a style=\"float:right;margin-left:0px\" href=\"\" onclick=\"filechooser.unselectPhoto(" + photo['photo_id'] + ");return false;\">"
                html += "(x)"
                html += "</a>"
            }
            html += "</div>"

        }
        return html

    },

    buildChooserHtml: function(json) {

        var html = ""

        for (var i = 0; i < json.length; i++) {

            html += "<div style='text-align:center; width:180px; height:140px; float:left; border:0px'>"


            var file = json[i]

            if (file.is_dir == true) {
                html += "<a href=\"\" onclick=\"filechooser.selectFolder(\'" + file.virtual_path + "\');return false;\">"
                html += "<img height='100' src='/images/folder.jpeg'>"
                html += "</a>"
            }
            else {
                var BOX = 125
                var width;
                var height;

                if (file.aspect_ratio) {
                    if (file.aspect_ratio == 1) {
                        height = BOX
                        width = BOX
                    }
                    else if (file.aspect_ratio < 1) {
                        height = BOX
                        width = BOX * file.aspect_ratio
                    }
                    else {
                        width = BOX
                        height = BOX / file.aspect_ratio
                    }
                }
                else {
                    height = BOX
                    width = BOX
                }


                var hint = ""
                if (file.hint_thumb_path) {
                    hint = encodeURIComponent(file.hint_thumb_path)
                }


                var url = agent.getThumbnailUrl(file.virtual_path, hint)
                var id = "thumbnail_" + i

                filechooser.imageloader.add(id, url);

                if (!filechooser.isSelected(file.virtual_path)) {
                    html += "<a href=\"\" onclick=\"filechooser.selectPhoto(\'" + file.virtual_path + "\');return false;\">"
                    html += "<img id='" + id + "' height='" + height + "' width='" + width + "' style='border:4px solid white' src='/images/blank.gif'>"
                    html += "</a>"
                }
                else {
                    html += "<img id='" + id + "' height='" + height + "' width='" + width + "' style='border:4px solid #AAAAAA' src='/images/blank.gif'>"
                }


            }

            html += "<br/>"

            if (file.is_dir == true) {
                html += "<a href='#" + file.virtual_path + "'>"
                html += file.name
                html += "</a>"
            }

            html += "</div>"
        }
        return html

    },


    buildBreadCrumbs : function() {
        var breadcrumbs = []
        var path = filechooser.virtualPath


        for (; ;) {
            var breadcrumb = {}
            var i = path.lastIndexOf('/')

            if (i == -1) {
                breadcrumb["title"] = "Home"
                breadcrumb["virtual_path"] = ""
                breadcrumbs[breadcrumbs.length] = breadcrumb
                break
            }
            else {
                breadcrumb["title"] = path.substring(i + 1)
                breadcrumb["virtual_path"] = path
                breadcrumbs[breadcrumbs.length] = breadcrumb

                path = path.substring(0, i)
            }

        }
        return breadcrumbs.reverse()
    },

    buildBackButtonHtml: function() {
        var breadcrumbs = filechooser.buildBreadCrumbs()
        breadcrumbs.pop()
        var crumb = breadcrumbs.pop()
        if (crumb) {
            html = "<a href='#" + crumb["virtual_path"] + "'>"
            html += "&lt;"
            html += crumb["title"]
            html += "]"
            html += "</a>"
            return html
        }
        else {
            return ""
        }

    },

    buildTitleHtml: function() {
        return "[" + filechooser.buildBreadCrumbs().pop()["title"] + "]"
    }
}