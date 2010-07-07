//
// agent.js
//
// Copyright ©2010, ZangZing LLC. All rights reserved.
//

var agent = {

    port : 9090,

    isAvailable: function(callback) {

        var onSuccess = function() {
            callback(true)
        }

        var onError = function() {
            callback(false)
        }


        this.callAgent("/ping", onSuccess, onError)

    },

    getFiles: function(virtualPath, onSuccess, onError) {
        this.callAgent("/files/" + encodeURIComponent(virtualPath), onSuccess, onError)
    },

    getRoots: function(onSuccess, onError) {
        this.callAgent("/roots", onSuccess, onError)
    },


    uploadPhoto: function(albumId, photoId, virtualPath, onSuccess, onError) {
        this.callAgent("/albums/" + albumId + "/photos/" + photoId + "/upload?path=" + encodeURIComponent(virtualPath), onSuccess, onError)
    },

    cancelUpload : function(albumId, photoId, onSuccess, onError) {
        this.callAgent("/albums/" + albumId + "/photos/" + photoId + "/cancel_upload", onSuccess, onError)
    },


    getThumbnailUrl: function(path, hint) {
        var url = "http://localhost:" + this.port + "/files/" + encodeURIComponent(path) + "/thumbnail";
        if (hint && hint.length > 0) {
            url += "?hint=" + hint;
        }
        return url;
    },


    callAgent: function(path, onSuccess, onError) {
        var url;
        if (path.indexOf('?') == -1) {
            url = "http://localhost:" + this.port + path + "?callback=?"
        }
        else {
            url = "http://localhost:" + this.port + path + "&callback=?"
        }

        $.jsonp({
            url: url,
            success: onSuccess,
            error: onError
        });
    }
}