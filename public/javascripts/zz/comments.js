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
        var self = this;

        var photo_id = 169911139720

        var comments_element = $(self.COMMENTS_TEMPLATE);


        var build_comment_element = function(comment_json){
            var comment = $(self.COMMENT_TEMPLATE);
            comment.find('.username').text(comment_json['user']['name']);
            comment.find('.when').text(comment_json['when'] + ' ago');
            comment.find('.text').text(comment_json['text']);
            comment.find('.profile-picture img').attr('data-src', comment_json['user']['profile_photo_url']);
            return comment;
        };


        var refresh_comments = function(){
            $.get(zz.routes.photo_comments_path(photo_id), function(comments_json){

                // clear the list
                comments_element.find('.comments').empty();

                // add all the comments
                _.each(comments_json['comments'], function(comment_json){
                    var comment_element = build_comment_element(comment_json);
                    comments_element.find('.comments').append(comment_element);
                });

                // show profile pictures -- need to do this after things are visible
                zz.profile_pictures.init_profile_pictures(comments_element.find('.profile-picture'))

                //resize comment rows to fit text -- no way to do this in css
                comments_element.find('.comment').each(function(){
                   var height = $(this).find('.text').height() + 45;
                   $(this).css({height: height +'px'});
                });
            });
        };


        var add_comment = function(text, post_to_facebook, post_to_twitter){
            var params = {
                'comment[text]': text,
                post_to_facebook: post_to_facebook,
                post_to_twitter: post_to_twitter
            };

            $.post(zz.routes.create_photo_comment_path(photo_id), params, function(comment_json){
                var comment_element = build_comment_element(comment_json);
                comments_element.find('.comments').prepend(comment_element);
                zz.profile_pictures.init_profile_pictures(comment_element.find('.profile-picture'));
            });
        };


        comments_element.find('.submit-button').click(function(){
            var text = comments_element.find('textarea.text').val();
            var post_to_facebook = comments_element.find('input.facebook').attr('checked');
            var post_to_twitter = comments_element.find('input.twitter').attr('checked');
            add_comment(text, post_to_facebook, post_to_twitter);

        });

        var dialog = zz.dialog.show_dialog(comments_element,{width:500, height:500});
        
        refresh_comments();





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








