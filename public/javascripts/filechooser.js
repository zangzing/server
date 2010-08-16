



var filechooser = {

    imageloader : null, 

    ancestors : [],

    roots : [
        {"open_url": "http://localhost:9090/iphoto/folders", "type": "folder", "name": "iPhoto"},
        {"open_url": "http://localhost:9090/filesystem/folders", "type": "folder", "name": "My Computer"},
        {"open_url": "http://localhost:9090/filesystem/folders/L1VzZXJzL2hvcGVtZW5n", "type": "folder", "name": "hopemeng"},
        {"open_url": "http://localhost:3000/facebook/folders.json", "type": "folder", "name": "Facebook"}
    ],



    init : function(){
        $("#filechooser-back-button").bind('click', filechooser.open_parent_folder)
        filechooser.open_root()
    },

    open_root: function(){
        filechooser.on_open_folder("Home", "", filechooser.roots)
    },


    open_folder: function(name, url){

        if(url == ""){
            filechooser.open_root()
        }
        else{
            if(url.indexOf("http://localhost:9090")===0){
                var user_session = $.cookie("user_credentials");

                url += "?session="+user_session+"&callback=?";

                $.jsonp({
                    url: url,
                    success: function(json){ filechooser.on_open_folder(name, url, json) },
                    error: filechooser.on_error
                });
            }
            else{
                $.ajax({
                   dataType: "json",
                   url: url,
                   success: function(json){ filechooser.on_open_folder(name, url, json) },
                   error: filechooser.on_error
                });
            }
        }
    },

    on_open_folder : function(name, url, children){
        //setup the imageloader
        if (filechooser.imageloader) {
            filechooser.imageloader.stop();
        }

        filechooser.imageloader = new ImageLoader(function(id, src) {
            $("#" + id).attr('src', src)
        });   



        //unpack the jsonp resonse
        if(children.body){
            children = children.body
        }

        var html=""
        for(var i in children){

            if(children[i].type=='folder'){
                html += "<li onclick=\"filechooser.open_folder('" + children[i].name + "','" + children[i].open_url + "')\">";
                html += children[i].name;
                html += "</li>";
            }
            else{
                var id = "photo_" + i 
                html += "<li>";
                html += "<img id='"+ id +"' src=''>"
                html += children[i].name;
                html += "</li>";

                filechooser.imageloader.add(id, children[i].thumb_url);

            }
        }

        $("#filechooser").html(html)

        filechooser.imageloader.start(5);



        if(filechooser.ancestors.length > 0){
            $("#filechooser-back-button").html(filechooser.ancestors[filechooser.ancestors.length-1].name);
        }
        else{
            $("#filechooser-back-button").html("");
        }

        $("#filechooser-title").html(name);

        filechooser.ancestors.push({name:name, url:url});

    },


    open_parent_folder: function()
    {
        var current = filechooser.ancestors.pop(); //discard this
        var parent = filechooser.ancestors.pop();
        filechooser.open_folder(parent.name, parent.url);
    },


    on_error : function(error){
        console.log("ERROR");
        console.log(error);
        $("#filechooser").html(error);
    }

}

$(document).ready(function() {
    filechooser.init()
});
