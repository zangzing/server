var zz = zz || {};

zz.comments = {

    album_photos_metadata: null,


    COMMENTS_TEMPLATE:  '<div class="comments-container">' +
                            '<div class="new-comment">' +
                               '<div class="comment-picture">' +
                                   '<div class="profile-picture">' +
                                       '<div class="mask">' +
                                           '<img data-src="/images/default_profile.png" src="/images/default_profile.png">' +
                                       '</div>' +
                                   '</div>' +
                               '</div>' +
                               '<textarea placeholder="Write something here" class="text"></textarea>' +
                               '<div class="share">' +
                                   'Share on &nbsp;&nbsp;<input type="checkbox" class="facebook"> Facebook &nbsp;&nbsp;<input type="checkbox" class="twitter"> Twitter' +
                               '</div>' +
                               '<a class="submit-button green-button"><span>Comment</span></a>' +
                            '</div>' +
                            '<div class="comments">' +
                            '</div>' +
                        '</div>',



    COMMENT_TEMPLATE:      '<div class="comment">' +
                                '<div class="comment-picture">' +
                                    '<div class="profile-picture">' +
                                        '<div class="mask">' +
                                            '<img data-src="/images/default_profile.png" src="/images/default_profile.png">' +
                                        '</div>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="posted-by">' +
                                    '<span class="username"></span>&nbsp;&nbsp;'+
                                    '<span class="when"></span>'+
                                '</div>' +
                                '<div class="text"></div>'+
                           '</div>',



    test: function(){
        var photo_id = 169911139720

        var comments_element = $(this.COMMENTS_TEMPLATE);

        for(var i=0;i<100;i++){
            var comment = $(this.COMMENT_TEMPLATE);
            comment.find('.username').text('Jeremy Hermann');
            comment.find('.when').text('About an hour ago');
            comment.find('.text').text('This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. This is a comment. ');
            comments_element.find('.comments').append(comment);
        }


        var dialog = zz.dialog.show_dialog(comments_element,{width:500, height:500});

        zz.profile_pictures.init_profile_pictures(comments_element.find('.profile-picture'))

        comments_element.find('.comment').each(function(){
           var height = $(this).find('.text').height() + 45;
           $(this).css({height: height +'px'});
        });


    },

    show_photo_comments: function(photo_id){
        var url = "/service/photos/:photo_id/comments".replace(':photo_id', photo_id)
        $.get(url, function(json){
            



        });
    },





    load_album_photos_metadata: function(album_id){
        var self = this;
        var url = '/albums/:album_id/photos/comments/metadata'.replace(':album_id', album_id);
        $.get(url, function(json){
            self.album_photos_metadata = json;
        });

    },

    comment_count_for_photo: function(photo_id, callback){
        var self = this;
        var try_again = function(){
            if(self.album_photos_metadata){
                for(var i=0; i<self.album_photos_metadata.length;i++){
                    if(self.album_photos_metadata[i].photo_id == photo_id){
                        callback(self.album_photos_metadata[i].comments_count);
                        return;
                    }
                }
            }
            else{
                setTimeout(try_again, 100);
            }
        };

        try_again();
    }

    

};








