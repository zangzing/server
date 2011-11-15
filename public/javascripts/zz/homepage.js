var zz = zz || {};


// Builds the homepage from the different cached assets.
//

zz.homepage = {

    render: function(current_users_home_page, my_albums_path, session_user_liked_albums_path, liked_albums_path, liked_users_albums_path, invited_albums_path, session_user_invited_albums_path) {
        var cell = $('<div class="album-cell"></div>');

        var call_and_merge = function(urls, callback) {
            var results = {};

            var check_is_done = function() {
                //do we have results for each call?

                var done = true;
                _.each(results, function(result) {
                    if (! result) {
                        done = false;
                    }
                });

                if (!done) {
                    return;
                }


                //combine into one array
                var combined_results = [];
                _.each(results, function(result) {
                    combined_results = combined_results.concat(result);
                });


                //sort
                var sorted_results = _.sortBy(combined_results, function(album) {
                    return -1 * album.updated_at;
                });


                //remove duplicates
                var previous_album = null;
                var unique_results = _.select(sorted_results, function(album) {
                    var keep;
                    if (previous_album) {
                        if (album.id == previous_album.id) {
                            keep = false;
                        }
                        else {
                            keep = true;
                        }
                    }
                    else {
                        keep = true;
                    }
                    previous_album = album;
                    return keep;
                });


                callback(unique_results);
            };


            _.each(urls, function(url) {
                if (url) {
                    results[url] = null;
                    $.ajax({
                        url: url,
                        success: function(albums) {
                            results[url] = albums;
                            check_is_done();
                        },
                        error: function(xhr, message, exception) {
                            zz.cache_helper.check_bad_homepage_json(xhr, message, zz.page.displayed_user_id, this.url);
                        }
                    });
                }
            });
        };


        var render_albums = function(container, json) {
            var wanted_subjects = {};
            _.each(json, function(album) {

                var clone = cell.clone();
                container.append(clone);

                clone.zz_picon({
                    album:   album,
                    caption: album.name,
                    coverUrl: album.c_url,
                    albumId: album.id,
                    albumUrl: 'http://' + document.location.host + album.album_path,
                    onClick: function() {
                        $('#article').css('width',$('#article').width());
                        $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                        $('#user-info').fadeOut(200);
                        document.location.href = album.album_path;
                    },
                    onLike: function() {
                        alert('This feature is still under construction. It will allow you to like an album.');
                    },
                    infoMenuTemplateResolver: zz.homepage.infomenu_template_resolver
                });
                wanted_subjects[album.id] = 'album';
            });

            zz.like.add_id_array(wanted_subjects);
        };

        call_and_merge([my_albums_path, session_user_liked_albums_path, session_user_invited_albums_path], function(albums) {
            //show only albums for the current homepage
            albums = _.filter(albums, function(album) {
                return album.user_id == zz.page.displayed_user_id;
            });

            render_albums($('#my-albums'), albums);
        });


        call_and_merge([liked_albums_path, liked_users_albums_path], function(albums) {
            render_albums($('#liked-albums'), albums);
        });

        if(current_users_home_page){
            call_and_merge([invited_albums_path], function(albums) {
                render_albums($('#invited-albums'), albums);
            });
        }

        $('#article').touchScrollY();

    },


    infomenu_template_resolver: function(album) {
       if( typeof( zz.homepage.infomenu_template_matrix ) == 'undefined' ){
           zz.homepage.infomenu_template_matrix = [
                [ null, zz.infomenu.download_template ],
                [ zz.infomenu.delete_template, zz.infomenu.download_delete_template]
            ];
        }

        var del = 0,
            download = 0;

        //delete
        if(  !album.profile_album && album.user_id == zz.session.current_user_id ){
            del = 1;
        } 
        //download
        switch( album.who_can_download ){
            case 'everyone':
                download = 1;
                break;
            case 'viewers': // group
                if( album.id in zz.session.current_user_membership ){
                    download = 1;
                }
                break;
            case 'owner':
                if( album.user_id == zz.session.current_user_id ){
                    download = 1;
                }
                break;
        }
        return zz.homepage.infomenu_template_matrix[del][download];
    }
};
