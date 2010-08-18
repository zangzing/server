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
        agent.isAvailable( function( agentPresent ){ album.setupGrid( agentPresent, albumJson) } )
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
        // Find out if agent is present and callback the url setup
        agent.isAvailable( function( agentPresent ){  album.setupSlideshow( agentPresent, photoJson )})
    },

    //
    // setupGrid
    //
    // Does two things depending on agent presence:
    // 1.- Replaces the default upload fields with the upload button to show the agent uploader
    // 2.- inserts the appropiate image urls depending on agent presence.
    //     If the agent is present ALL image URLs point to the agent,
    //     otherwise all image URLs are to the server.
    //
    // The upload form div block has id = 'uploadform'
    // If the agent is NOT present then show a file upload field as default (done in albums/show view)
    // if the agent is present show a button to display the agent uploader
    //
    // agentPresent: true or false
    // albumJson: the album object containing photos with ids and actual image urls
    //
    setupGrid: function(agentPresent, albumJson)
    {

        activeAlbum = jQuery.parseJSON(albumJson);

        if( agentPresent ){
//           $("#uploadform").html('<form method="get" action="/albums/'+activeAlbum.id+'/upload" class="button-to"><div><input type="submit" value="Upload Photos" /></div></form>');
            for (i = 0; i < activeAlbum.photos.length; i++) {
                 photoUrl = activeAlbum.photos[i].thumb_url; // # TODO: USE AGENT WHEN AGENT IS READY
                //Modify div block which id is "photoid<ID_HERE>" created by the Photo/_photo partial
                //The photo is displayed as a floating image of the div block
                photoImgId = "#photoid" + activeAlbum.photos[i].id
                $(photoImgId).attr("src", photoUrl);
            }
        }else{
            for (i = 0; i < activeAlbum.photos.length; i++) {
                photoUrl = activeAlbum.photos[i].thumb_url;
                //Modify div block which id is "photoid<ID_HERE>" created by the Photo/_photo partial
                //The photo is displayed as a floating image of the div block
                photoImgId = "#photoid" + activeAlbum.photos[i].id
                $(photoImgId).attr("src", photoUrl);
            }
        }
    },


    //
    // setupSlideshow
    //
    // Used to set the appropiate image url depending on agent presence.
    // If the agent is present ALL image URLs point to the agent,
    // otherwise all image URLs are to the server.
    //
    // photo: the photo object containing id and actual image urls
    //
    setupSlideshow: function(agentPresent, photoJson)
    {

        activePhoto = jQuery.parseJSON(photoJson);

        if (agentPresent) {
                 //:TODO when the agent is ready replace this call to point to the agent
                //photoUrl = "http://" + location.host + "/photos/" + activePhoto.id; // # TODO: ADD AGENT WHEN AGENT IS READY
                photoUrl = activePhoto.medium_url;
        } else {
                photoUrl = activePhoto.medium_url;
        }

        //Modify div block which id is "photoid<ID_HERE>" created by the Photo/_photo partial
        //The photo is displayed as a floating image of the div block
        photoImgId = "#photoid" + activePhoto.id;
        $(photoImgId).attr("src", photoUrl);
    }
}
