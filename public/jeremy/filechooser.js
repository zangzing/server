//{
//	'name': '!ROOT!',
//	'import_url':'',
//
//	children: [
//		{
//			'name':'iPhoto',
//			'show_url':'http://localhost:9090/iphoto/folders',
//			'import_action_url':'',
//			'type':'folder',
//		},
//		{
//			'name':'My Pictures'
//			'show_url':'http://localhost:9090/filesystem/my_pictures'
//			'import_action_url':'http://localhost:9090/filesystem/my_pictures/import'
//			'type':'folder'
//		},
//		{
//			'name':'Flickr'
//			'show_url':'/flickr/folders'
//			'import_action_url':''
//			'type':'folder'
//		}
//	]
//}


var filechooser = {

    ancestors : [],

    init : function(){
        $("#filechooser_back_button").bind('click', filechooser.open_parent_folder)
        filechooser.open_root()
    },

    open_root: function(){
        filechooser.open_folder('Facebook', '/facebook/folders');
    },


    open_folder: function(name, url){
        $.ajax({
           dataType: "json",
           url: url,
           success: function(json){ filechooser.on_open_folder(name, url, json) },
           error: filechooser.on_error
        });
    },

    on_open_folder : function(name, url, children){
        $("#filechooser").html("")        

        for(var i in children){

            var html=""
            if(children[i].type=='folder'){
                html += "<li id='" + i + "'>";
                html += children[i].name;
                html += "</li>";
            }
            else{
                html += "<li>";
                html += children[i].name;
                html += "</li>";
            }

            $("#filechooser").append(html)

            $("#" + i).bind('click', function(){filechooser.open_folder(children[i].name, children[i].open_url)});
        }

        if(filechooser.ancestors.length > 0){
            $("#filechooser_back_button").html(filechooser.ancestors[filechooser.ancestors.length-1].name);
        }
        else{
            $("#filechooser_back_button").html("");
        }

        $("#filechooser_title").html(name);

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
