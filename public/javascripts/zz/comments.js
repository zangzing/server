var zz = zz || {};

zz.comments = {};

(function(){

    // todo: don't expand urls inline here. this gets called at page load. should do it lazy
    
    var COMMENTS_DIALOG =  '<div class="comments-dialog">' +
                                '<div class="header">' +
                                    '<div class="commented-photo">' +
                                        '<div class="photo-border">' +
                                            '<img class="photo-image" src="' + zz.routes.image_url('/images/blank.png') + '">' +
                                            '<img class="bottom-shadow" src="' + zz.routes.image_url('/images/photo/bottom-full.png') + '">' +
                                        '</div>' +
                                    '</div>' +
                                    '<div class="commented-photo-caption ellipsis multiline"></div>' +
                                    '<div class="button-bar">' +
                                        '<div class="button share-button"></div>' +
                                        '<div class="button like-button zzlike" data-zzid="" data-zztype="photo"><div class="zzlike-icon thumbdown"></div></div>' +
                                        '<div class="button buy-button"></div>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="body"></div>' +
                           '</div>';


    var COMMENTS_TEMPLATE = '<div class="comments-container">' +
                            '<div class="new-comment">' +
                               '<div class="background"></div>' +
                               '<div class="comment-picture">' +
                                   '<div class="profile-picture">' +
                                       '<div class="mask">' +
                                           '<img data-src="/images/default_profile.png" src="/images/default_profile.png">' +
                                       '</div>' +
                                   '</div>' +
                               '</div>' +
                               '<textarea placeholder="Write a comment..." class="text"></textarea>' +
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
                                        '<span class="username"></span>&nbsp;&nbsp;' +
                                        '<span class="when"></span>' +
                                    '</div>' +
                                    '<div class="text"></div>'+
                                    '<div class="delete-button"></div>' +
                                '</div>';

    var COMMENT_LOADING_TEMPLATE = '<div class="comment">' +
                                        '<div class="loading"></div>' +
                                   '</div>';





    // key is photo id, value is count
    // todo: can only track for one album at a time
    var comment_counts_for_photos = null;

    var like_count_subscribers = [];


    /*         Public Stuff
     ***********************************************************/

    zz.comments.get_comment_count_for_photo = function(album_id, photo_id, callback){
        if(comment_counts_for_photos){
            callback(comment_counts_for_photos[photo_id]);
        }
        else{
            zz.routes.comments.get_album_photos_comments_metadata(album_id, function(json){
                comment_counts_for_photos = {};
                _.each(json, function(commentable_json){
                    var photo_id = commentable_json['subject_id'];
                    var count = commentable_json['comments_count'];
                    comment_counts_for_photos[photo_id] = count;
                });
                callback(comment_counts_for_photos[photo_id]);
            });
        }
    };


    zz.comments.get_pretty_comment_count_for_photo = function(album_id, photo_id, callback){
        zz.comments.get_comment_count_for_photo(album_id, photo_id, function(count){
           if(count == 0){
               count = null;
           }
           else if(count > 1000){
                count = Math.floor(count / 1000) + 'k';
           }

           callback(count);
        });
    };


    zz.comments.subscribe_to_like_counts = function(callback){
       like_count_subscribers.push(callback);
    };


    zz.comments.show_in_dialog = function(album_id, cache_version, photo_id){
        zz.routes.photos.get_photo_json(album_id, cache_version, photo_id, function(photo){

            var comments_dialog = $(COMMENTS_DIALOG);

            zz.image_utils.pre_load_image(photo.thumb_url, function(image){
                var photo_element = comments_dialog.find('.header .photo-border');

                var scaled = zz.image_utils.scale({width: image.width, height: image.height}, {width: 180, height: 160});
                
                var image_element = photo_element.find('.photo-image');
                image_element.css({height: scaled.height, width: scaled.width});
                image_element.attr('src', photo.thumb_url);


                photo_element.find('.bottom-shadow').css({'width': (scaled.width + 14) + 'px'});
                photo_element.center_y();


                photo_element.click(function(){
                    jQuery.cookie('show_comments', 'true'); //todo: should manage this centrally
                    dialog.close();
                    zz.album.goto_single_picture(photo_id);
                });

                var photo_caption_element = comments_dialog.find('.header .commented-photo-caption');
                photo_caption_element.text(photo.caption);
                photo_caption_element.ellipsis();


                //share button
                var share_button = comments_dialog.find('.share-button');
                share_button.click(function(){
                    zz.sharemenu.show(share_button, 'photo', photo.id, {x: 0, y: 0}, 'comment-dialog', 'auto', function(){});
                });


                // like button
                var like_button = comments_dialog.find('.like-button');
                like_button.attr('data-zzid', photo.id);
                zz.like.draw_tag(like_button);

                var buy_button = comments_dialog.find('.buy-button');
                buy_button.click(function(){
                    ZZAt.track('photo.buy.comment.click');
                    alert('This feature is still under construction.');
                });


                


            });


            var comments_widget = zz.comments.build_comments_widget(photo_id);

            comments_dialog.find('.body').html(comments_widget.element);

            var dialog = zz.dialog.show_square_dialog(comments_dialog, {width:450, height:600});
            comments_widget.load_comments_for_photo(photo_id);

        });
    };




    zz.comments.build_comments_widget = function(photo_id){
        var comments_element = $(COMMENTS_TEMPLATE);

        // setup one-finger scroll for ipad
        comments_element.find('.comments').touchScrollY();

        var pending_request_for_comments = null;

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
                   comment_counts_for_photos[photo_id] -= 1;
                   notify_subscribers(photo_id);

               }
            });

            if(comment_json['user_id'] == zz.session.current_user_id){
                comment.addClass('deletable');
            }




            return comment;
        };


        var load_comments_for_photo = function(id){
            photo_id = id;



            // clear the list
            comments_element.find('.comments').empty();

            var comment_loading_element = $(COMMENT_LOADING_TEMPLATE);

            comments_element.find('.comments').append(comment_loading_element);


            // cancel pending request in case we try to load next
            // photo's comments before previous photo's comments finished.
            if(pending_request_for_comments){
                pending_request_for_comments.abort();
                pending_request_for_comments = null;
            }

            pending_request_for_comments = zz.routes.comments.get_comments_for_photo(photo_id, function(json){

                pending_request_for_comments = null;

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

            var success = function(comment_json){
                var comment_element = build_comment_element(comment_json);
                comment_loading_element.remove();
                comments_element.find('.comments').prepend(comment_element);
                zz.profile_pictures.init_profile_pictures(comment_element.find('.profile-picture'));
                resize_comments();
                comment_counts_for_photos[photo_id] = (comment_counts_for_photos[photo_id] + 1) || 1;
                notify_subscribers(photo_id);
            };

            var error = function(xhr){
                if(xhr.status == 401 && !zz.session.current_user_id){
                    // guest tried to create coment
                    // comment params are stored in session -- just need to login/join
                    // and then redirect to finish creting comment
                    zz.routes.users.goto_signin_screen(zz.routes.comments.finish_create_photo_comment_path(photo_id));
                }
            };

            zz.routes.comments.create_comment_for_photo(photo_id, params, success, error);
        };


        var build_new_comment_panel = function(){
            if(zz.session.profile_photo_url){
                comments_element.find('.new-comment .profile-picture img').attr('data-src', zz.session.profile_photo_url);
            }
            zz.profile_pictures.init_profile_pictures(comments_element.find('.new-comment .profile-picture'));

            var facebook_checkbox = comments_element.find('input.facebook');
            facebook_checkbox.change(function(){

                //undo the toggle and start over...
                facebook_checkbox.attr('checked', !facebook_checkbox.attr('checked'));

                //if it is checked, we can just uncheck
                if(facebook_checkbox.attr('checked')){
                    facebook_checkbox.attr('checked', false);
                }
                else{
                    // need to make sure we are signed into facebook
                    if(zz.session.has_facebook_token) {
                        facebook_checkbox.attr('checked', true);
                    }
                    else {
                        zz.oauthmanager.login_facebook(function(){
                            facebook_checkbox.attr('checked', true);
                        });
                    }
                }
            });



            var twitter_checkbox = comments_element.find('input.twitter');
            twitter_checkbox.change(function(){

                //undo the toggle and start over...
                twitter_checkbox.attr('checked', !twitter_checkbox.attr('checked'));

                //if it is checked, we can just uncheck
                if(twitter_checkbox.attr('checked')){
                    twitter_checkbox.attr('checked', false);
                }
                else{
                    // need to make sure we are signed into twitter
                    if(zz.session.has_twitter_token){
                        twitter_checkbox.attr('checked', true);
                    }
                    else {
                        zz.oauthmanager.login_twitter(function(){
                            twitter_checkbox.attr('checked', true);
                        });
                    }
                }
            });

            // if no current user then hide facebook and twitter options
            if(!zz.session.current_user_id){
                comments_element.find('.share').hide();
            }


            var submit_comment = function(){
                var text = $.trim(comments_element.find('textarea.text').val());
                if(text.length > 0){
                    var post_to_facebook = facebook_checkbox.attr('checked');
                    var post_to_twitter = twitter_checkbox.attr('checked');
                    add_comment(text, post_to_facebook, post_to_twitter);
                    comments_element.find('textarea.text').val('');
                    comments_element.find('textarea.text').blur();
                }
                else{
                    event.preventDefault();
                }
            };

            // trap arrow keys and enter keuy
            comments_element.find('textarea.text').keydown(function(event) {
                if (event.keyCode === 40) {
                    //down
                    event.stopPropagation();
                }
                else if (event.keyCode === 39) {
                    //right
                    event.stopPropagation();
                }
                else if (event.keyCode === 34) {
                    //page down
                    event.stopPropagation();
                }
                else if (event.keyCode === 38) {
                    //up
                    event.stopPropagation();
                }
                else if (event.keyCode === 37) {
                    //left
                    event.stopPropagation();
                }
                else if (event.keyCode === 33) {
                    //page up
                    event.stopPropagation();
                }
                else if (event.keyCode === 13) {
                    //enter
                    if(!event.altKey && !event.ctrlKey){
                        submit_comment();
                    }
                }
            });




            comments_element.find('.submit-button').click(function(){
                submit_comment();
            });
        };

        build_new_comment_panel();

        return {
            element: comments_element,

            load_comments_for_photo: function(photo_id){
                load_comments_for_photo(photo_id);
            }
        };

    };


    /*         Private Stuff
     ***********************************************************/

    function notify_subscribers(photo_id){
        _.each(like_count_subscribers, function(callback){
            callback(photo_id, comment_counts_for_photos[photo_id]);
        });
    }



})();









