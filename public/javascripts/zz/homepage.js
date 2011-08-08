var zz = zz || {};


// Builds the homepage from the different cached assets.
//

zz.homepage = {

    render: function(my_albums_path, session_user_liked_albums_path, liked_albums_path, liked_users_albums_path ) {
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
                            zz.cache_helper.check_bad_homepage_json(xhr, message, zz.displayed_user_id, this.url);
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
                    caption: album.name,
                    coverUrl: album.c_url,
                    albumId: album.id,
                    albumUrl: 'http://' + document.location.host + album.album_path,
                    onClick: function() {
                        $('#article').css({overflow:'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                        $('#user-info').fadeOut(200);
                        document.location.href = album.album_path;
                    },
                    onLike: function() {
                        alert('This feature is still under construction. It will allow you to like an album.')
                    },
                    onDelete: function() {
                        if (confirm("Are you sure you want to delete this album?")) {
                            clone.find('.picon').hide("scale", {}, 300, function() {
                                clone.remove();
                            });
                            zzapi_album.delete_album(album.id);
                        }
                    },
                    allowDelete: !album.profile_album && album.user_id == zz.current_user_id
                });
                wanted_subjects[album.id] = 'album';
            });

            // Update the like array if it exists.
            // todo: why would it not exist? (jeremy 8/7)
            if (typeof( zz.like ) != 'undefined') {
                zz.like.add_id_array(wanted_subjects);
            }
        };

        call_and_merge([my_albums_path, session_user_liked_albums_path], function(albums) {
            //show only albums for the current homepage
            albums = _.filter(albums, function(album) {
                return album.user_id == zz.displayed_user_id;
            });

            render_albums($('#my-albums'), albums);
        });


        call_and_merge([liked_albums_path, liked_users_albums_path], function(albums) {
            render_albums($('#liked-albums'), albums);
        });


        $('#article').touchScrollY();

    }

};