var zz = zz || {};

zz.comments = {};

(function(){

    var COMMENTS_TEMPLATE = '<div class="comments-container">' +
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
                        '</div>';



    var COMMENT_TEMPLATE =      '<div class="comment">' +
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
                                    '<div class="delete-button"></div>' +
                                '</div>';

    var COMMENT_LOADING_TEMPLATE = '<div class="comment">' +
                                        '<div class="loading"></div>' +
                                   '</div>';






    zz.comments.test = function(){
        var photo_id = 169911139720;
        var element = zz.comments.build_comments_widget(photo_id)
        var dialog = zz.dialog.show_dialog(element,{width: 500, height: 500});
    };


    zz.comments.build_comments_widget = function(photo_id){
        var comments_element = $(COMMENTS_TEMPLATE);

        var build_comment_element = function(comment_json){
            var comment_text = comment_json['text'];
            comment_text = comment_text.replace(/\n/g, '<br>');

            var comment = $(COMMENT_TEMPLATE);
            comment.find('.username').text(comment_json['user']['name']);
            comment.find('.username').click(function(){
                document.location.href = zz.routes.users.user_home_page_path(comment_json['user']['username']);
            });
            comment.find('.when').text(comment_json['when'] + ' ago');
            comment.find('.text').html(comment_text);  //this was sanitized on the server, so html() is OK
            comment.find('.profile-picture img').attr('data-src', comment_json['user']['profile_photo_url']);
            comment.find('.delete-button').click(function(){
               if(confirm('Are you sure you want to delete this comment?')){
                   zz.routes.comments.delete_comment(comment_json['id']);
                   comment.fadeOut('fast', function(){
                       comment.remove();
                   });
               }
            });

            if(comment_json['user_id'] == zz.session.current_user_id){
                comment.addClass('deletable');
            }

            return comment;
        };


        var refresh_comments = function(){
            // clear the list
            comments_element.find('.comments').empty();

            var comment_loading_element = $(COMMENT_LOADING_TEMPLATE);

            comments_element.find('.comments').append(comment_loading_element);


            zz.routes.comments.get_comments_for_photo(photo_id, function(json){

                comment_loading_element.remove();

                //set deleteable flag
                if(json['current_user']['can_delete_comments']){
                    comments_element.find('.comments').addClass('deleteable');
                }
                

                // add all the comments
                _.each(json['commentable']['comments'], function(comment_json){
                    var comment_element = build_comment_element(comment_json);
                    comments_element.find('.comments').append(comment_element);
                });

                // show profile pictures -- need to do this after things are visible
                zz.profile_pictures.init_profile_pictures(comments_element.find('.profile-picture'));

                resize_comments();

            });
        };

        var resize_comments = function(){
            //resize comment rows to fit text -- no way to do this in css
            comments_element.find('.comment').each(function(){
               var height = $(this).find('.text').height() + 55;
               $(this).css({height: height +'px'});
            });
        };

        var add_comment = function(text, post_to_facebook, post_to_twitter){
            var params = {
                'comment[text]': text,
                post_to_facebook: post_to_facebook,
                post_to_twitter: post_to_twitter
            };

            var comment_loading_element = $(COMMENT_LOADING_TEMPLATE);

            comments_element.find('.comments').prepend(comment_loading_element);

            zz.routes.comments.create_comment_for_photo(photo_id, params, function(comment_json){
                var comment_element = build_comment_element(comment_json);
                comment_loading_element.remove();
                comments_element.find('.comments').prepend(comment_element);
                zz.profile_pictures.init_profile_pictures(comment_element.find('.profile-picture'));
                resize_comments();
            });
        };


        var build_new_comment_panel = function(){
            if(zz.session.profile_photo_url){
                comments_element.find('.new-comment .profile-picture img').attr('data-src', zz.session.profile_photo_url);

                zz.profile_pictures.init_profile_pictures(comments_element.find('.new-comment .profile-picture'));

                comments_element.find('.submit-button').click(function(){
                    var text = $.trim(comments_element.find('textarea.text').val());
                    if(text.length > 0){
                        var post_to_facebook = comments_element.find('input.facebook').attr('checked');
                        var post_to_twitter = comments_element.find('input.twitter').attr('checked');
                        add_comment(text, post_to_facebook, post_to_twitter);
                        comments_element.find('textarea.text').val('');
                    }

                });

            }
        };

        build_new_comment_panel();
        refresh_comments();

        return comments_element;
    };

//    show_photo_comments: function(photo_id){
//        var url = "/service/photos/:photo_id/comments".replace(':photo_id', photo_id)
//        $.get(url, function(json){
//
//
//
//
//        });
//    },
//
//
//
//
//
//    load_album_photos_metadata: function(album_id){
//        var self = this;
//        var url = '/albums/:album_id/photos/comments/metadata'.replace(':album_id', album_id);
//        $.get(url, function(json){
//            self.album_photos_metadata = json;
//        });
//
//    },
//
//    comment_count_for_photo: function(photo_id, callback){
//        var self = this;
//        var try_again = function(){
//            if(self.album_photos_metadata){
//                for(var i=0; i<self.album_photos_metadata.length;i++){
//                    if(self.album_photos_metadata[i].photo_id == photo_id){
//                        callback(self.album_photos_metadata[i].comments_count);
//                        return;
//                    }
//                }
//            }
//            else{
//                setTimeout(try_again, 100);
//            }
//        };
//
//        try_again();
//    }



})();









