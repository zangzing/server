var added_photos_tray = {

    imageloader : null,

    refresh : function() {
        var get_album_photos_url = "/albums/" + filechooser.album_id + "/photos.json"

        $.ajax({
           dataType: "json",
           url: get_album_photos_url,
           success: added_photos_tray.on_refresh,
           error: filechooser.on_refresh_error
        });
    },

    on_refresh : function(photos){
        //setup the imageloader
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        var onStartLoadingImage = function(id, src) {
            $("#" + id).attr('src', '/images/loading.gif')
        };

        var onImageLoaded = function(id, src) {
            $("#" + id).attr('src', src)
        };
        filechooser.imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);



        var html =""
        for(var i in photos){
            html+="<div class='gridcell'>"
            html+="<img height='30' width='30' id='" + photos[i].id +"' src=''>"
            html+="</div>"

            if(photos[i].agent_id){
                //was uploaded from agent
                //todo: need to check that agent id matches local agent
                if(photos[i].state == 'ready'){
                    filechooser.imageloader.add(photos[i].id, photos[i].thumb_url);
                }
                else{
                    filechooser.imageloader.add(photos[i].id, "http://localhost:9090/albums/" +filechooser.album_id + "/photos/" + photos[i].id + ".thumb" + "?session=" + $.cookie("user_credentials"));
                }
            }
            else{
                //photo was side loaded or emailed
                if(photos[i].state == 'ready'){
                    filechooser.imageloader.add(photos[i].id, photos[i].thumb_url);
                }
                else{
                    filechooser.imageloader.add(photos[i].id, photos[i].source_thumb_url);
                }
            }


        }
        $("#added-pictures-tray").html(html)


        filechooser.imageloader.start(5);
    },


    on_refresh_error : function(error){
        
    }
}


var filechooser = {

    imageloader : null, 

    ancestors : [],

    album_id: null,

    roots : [
        {"open_url": "http://localhost:9090/iphoto/folders", "type": "folder", "name": "iPhoto"},
        {"open_url": "http://localhost:9090/filesystem/folders", "type": "folder", "name": "My Computer"},
        {"open_url": "http://localhost:9090/filesystem/folders/fg==", "type": "folder", "name": "Home"},
        {"open_url": "http://localhost:3000/facebook/folders.json", "type": "folder", "name": "Facebook", login_url:'http://localhost:3000/facebook/sessions/new'},
        {"open_url": "http://localhost:3000/flickr/folders.json", "type": "folder", "name": "Flickr", login_url:'http://localhost:3000/flickr/sessions/new'},
        {"open_url": "http://localhost:3000/kodak/folders.json", "type": "folder", "name": "Kodak", login_url:'http://localhost:3000/kodak/sessions/new'},
        {"open_url": "http://localhost:3000/smugmug/folders.json", "type": "folder", "name": "SmugMug", login_url:'http://localhost:3000/smugmug/sessions/new'},
        {"open_url": "http://localhost:3000/shutterfly/folders.json", "type": "folder", "name": "Shutterfly", login_url:'http://localhost:3000/shutterfly/sessions/new'}
    ],



    init : function(){
        $("#filechooser-back-button").bind('click', filechooser.open_parent_folder)
        filechooser.open_root()
        added_photos_tray.refresh()
    },


    set_album_id : function(album_id){
        filechooser.album_id = album_id;  
    },


    open_root: function(){
        filechooser.open_folder("Home", "")
    },


    open_folder: function(name, url, login_url){

        //
        filechooser.ancestors.push({name:name, url:url, login_url:login_url});
        

        //update title and back button
        if(filechooser.ancestors.length > 1){
            $("#filechooser-back-button").html(filechooser.ancestors[filechooser.ancestors.length-2].name);
        }
        else{
            $("#filechooser-back-button").html("");
        }

        $("#filechooser-title").html(name);        


        //update files
        $("#filechooser").html("<img src='/images/loading.gif'> Loading ...")
        if(url == ""){
            filechooser.on_open_root(name, url)
        }
        else{
            if(url.indexOf("http://localhost:9090")===0){
                var user_session = $.cookie("user_credentials");
                url += "?session="+user_session+"&callback=?";

                $.jsonp({
                    url: url,
                    success: function(json){ filechooser.on_open_folder(name, url, json) },
                    error: filechooser.on_error_opening_folder
                });
            }
            else{
                $.ajax({
                   dataType: "json",
                   url: url,
                   success: function(json){ filechooser.on_open_folder(name, url, json) },
                   error: filechooser.on_error_opening_folder
                });
            }
        }
    },


    on_open_root : function(name, url){
        filechooser.on_open_folder(name, url, filechooser.roots)
    },


    on_open_folder : function(name, url, children){

        //setup the imageloader
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        var onStartLoadingImage = function(id, src) {
            $("#" + id).attr('src', '/images/loading.gif')
        };

        var onImageLoaded = function(id, src) {
            $("#" + id).attr('src', src)
        };
        filechooser.imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);



        //unpack the jsonp resonse
        if(children.body){
            children = children.body
        }


        //build html for list of files/folders
        var html=""
        for(var i in children){

            if(children[i].type=='folder'){
                html += "<div class='gridcell'>";
                html += "<img src='/images/folder.jpg'>";
                html += "<br>"

                html += "<a href='#' onclick=\"filechooser.open_folder('" + children[i].name + "','" + children[i].open_url + "','" + children[i].login_url + "'); return false;\">"
                html += children[i].name;
                html += "</a>"

                if(children[i].add_url){
                  html += "&nbsp;<a href='#' onclick=\"filechooser.add_folder('" + children[i].add_url + "'); return false;\">(+)</a>"
                }
                html += "</div>";
            }
            else{
                var id = "photo_" + i 
                html += "<div class='gridcell'>";
                html += "<img id='"+ id +"' src=''>";
                html += "<br>"
                html += children[i].name;
                html += "&nbsp;<a href='#' onclick=\"filechooser.add_photo('" + children[i].add_url + "'); return false;\">(+)</a>"
                html += "</div>";



                if(children[i].thumb_url.indexOf("http://localhost")===0){
                    filechooser.imageloader.add(id, children[i].thumb_url + "?session=" + $.cookie("user_credentials"));
                }
                else{
                    filechooser.imageloader.add(id, children[i].thumb_url);
                }
            }
        }

        $("#filechooser").html(html)

        filechooser.imageloader.start(5);


    },


    add_photo : function(add_url){
        add_url += "?album_id="  + filechooser.album_id;

        if(add_url.indexOf("http://localhost:9090")===0){
            var user_session = $.cookie("user_credentials");

            add_url += "&session="+user_session+"&callback=?";

            $.jsonp({
                url: add_url,
                success: function(json){ filechooser.on_add_photo() },
                error: filechooser.on_error_adding_photo
            });
        }
        else{
            $.ajax({
               dataType: "json",
               url: add_url,
               success: function(json){ filechooser.on_add_photo() },
               error: filechooser.on_error_adding_photo
            });
        }
    },


    on_add_photo : function(){
        added_photos_tray.refresh()
    },


    add_folder : function(add_url){
        //todo: need different implemenatation here
        filechooser.add_photo(add_url)
    },

    open_parent_folder: function() {
        var current = filechooser.ancestors.pop(); //discard this
        var parent = filechooser.ancestors.pop();
        filechooser.open_folder(parent.name, parent.url, parent.login_url);
    },


    on_error_opening_folder : function(error){
        if(error.status === 401){
            $("#filechooser").html("you need to log into your account before you can see this folder; click <a href='' onclick='filechooser.open_login_window();return false'>here</a> to log in");
        }
    },

    on_error_adding_photo :function(){
        alert('error adding photo')
    },

    open_login_window : function(){
        var current = filechooser.ancestors[filechooser.ancestors.length-1]
        window.open (current.login_url,"login","status=0,toolbar=0,width=500,height=500");

    },

    on_login : function(){
        var current = filechooser.ancestors.pop(); //discard this
        filechooser.open_folder(current.name, current.url)
    }


}

$(document).ready(function() {
    filechooser.init()
});
