//
// album.js
//
// The album object contains methods to display the album and photo views
// uses the agent js objec
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//

var album;
album = {
    //
    // initializeforGrid
    //
    // Initializes the agent (find out if agent is present )
    // Installs a listener on doc.ready (like executing body onload)
    // Once the body is ready it will display the upload form and insert urls for all photos in album
    // based on agent presence
    //
    // albumJSON: the album in json. This is where we get photo image paths.
    //
    initializeForGrid: function(albumJson)
    {
        // Find out if agent is present
        agent.initialize()
        $(document).ready(function()
        {
             album.insertUploadForm();
             album.insertGridUrls(albumJson);

        })
    },

    //
    // initializeforSlideshow
    //
    // Installs a listener on doc.ready (like executing body onload)
    // Once the body is ready it will insert the url for the photo being displayed
    // based on agent presence
    //
    // albumJSON: the album in json. This is where we get photo image paths.
    //
    initializeForSlideshow: function(photoJson)
    {
        // Find out if agent is present
        agent.initialize()
        $(document).ready(function()
        {
             album.insertPhotoUrl(photoJson);
        })
    },


    //
    // insertGridUrls
    //
    // Used to set the appropiate image url depending on agent presence.
    // If the agent is present ALL image URLs point to the agent,
    // otherwise all image URLs are to the server.
    //
    // photo: the photo object containing id and actual image urls
    //
    insertGridUrls: function(albumJson)
    {

        activeAlbum = jQuery.parseJSON(albumJson);

        for (i = 0; i < activeAlbum.photos.length; i++) {
            if (agent.isPresent) {
                photoUrl = "http://" + location.host + "/photos/" + activeAlbum.photos[i].id; // # TODO: ADD AGENT WHEN AGENT IS READY
            } else {
                photoUrl = activeAlbum.photos[i].thumb_url;
            }

            //Modify div block which id is "photoid<ID_HERE>" created by the Photo/_photo partial
            //The photo is displayed as a floating image of the div block
            photoImgId = "#photoid" + activeAlbum.photos[i].id
            $(photoImgId).attr("src", photoUrl);
        }
    },

    //
    // insertUploadForm
    //
    // The upload form div block has id = 'uploadform'
    // If the agent is NOT present then show a file upload field as default (done in albums/show view)
    // if the agent is present show a button to display the agent uploader
    insertUploadForm:  function()
    {
        if(agent.isPresent) {
            $("#uploadform").html('<%= button_to "Upload Photos", upload_path( @album.id ), :method => :get %>');
       }
    },

//
    // insertPhotoUrl
    //
    // Used to set the appropiate image url depending on agent presence.
    // If the agent is present ALL image URLs point to the agent,
    // otherwise all image URLs are to the server.
    //
    // photo: the photo object containing id and actual image urls
    //
    insertPhotoUrl: function(photoJson)
    {

        activePhoto = jQuery.parseJSON(photoJson);

        if (agent.isPresent) {
                photoUrl = "http://" + location.host + "/photos/" + activePhoto.id; // # TODO: ADD AGENT WHEN AGENT IS READY
        } else {
                photoUrl = activePhoto.medium_url;
        }

        //Modify div block which id is "photoid<ID_HERE>" created by the Photo/_photo partial
        //The photo is displayed as a floating image of the div block
        photoImgId = "#photoid" + activePhoto.id;
        $(photoImgId).attr("src", photoUrl);

    }
}
