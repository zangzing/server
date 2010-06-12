// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//





//
// This function is like executing body onload.
// it is used to trigger the parsing of the album and resolution of the photo URLs
// once the page is loaded.
// Global Variable albumJSON must contain the album JSON. It should be set in the view HTML
//

function installAlbumReadyListener( albumJSON )
{
    $(document).ready(  function() {
        console.log('application.js ready observed!');
        showAlbumPhotos( albumJSON )
    });
    console.log('AlbumReadyListenerInstalled!');
}

//
// Used to decide if the agent is present or not. If the agent is present ALL images are
// requested from the agent. Otherwise all image requests are sent to the server.
//
function setPhotoURL( photo )
{
        //console.log("Getting url for photo ==%s== with agent %s", photo.thumb_url, agentPresent?"present":"NOT present" );

        //SOLVE URL
        // ALERT: Until the agentPresent check is called, this view will ALWAYS behave like the agent is NOT present.
        // agentPresent = TODO: Call Agent Present Check


        if( agentPresent ){
            photoURL = "http://"+location.host+"/photos/"+photo.id; // # TODO: ADD AGENT WHEN AGENT IS READY
        }else{
            photoURL = photo.thumb_url;
        }

        //DISPLAY PHOTO
        //Modify div block class "gridcellphoto" id "photoid<ID>_HERE>" created by the Photo/_photo partial
        //The photo is displayed as a background image of the div block
        photoImgId = "#photoid"+photo.id
        console.log(photoImgId+" URL:"+photoURL)
        $(photoImgId).attr("src",photoURL);
}

//
// Parses the album json received from the server in the Album View HTML and
// resolves/sets the url for every photo in the album
//
function showAlbumPhotos( albumJSON ){
        album = jQuery.parseJSON( albumJSON );
        for( i=0; i< album.photos.length; i++){
            setPhotoURL(album.photos[i]);
        }
}
