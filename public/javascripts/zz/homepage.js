var zz = zz || {};

zz.homepage = {};

// Builds the homepage from the different cached assets.

(function(){


    var cell = $('<div class="album-cell"></div>');
    var my_albums      = null;
    var liked_albums   = null;
    var invited_albums = null
    var wanted_subjects = {};

    zz.homepage.render = function(current_users_home_page, my_albums_path, session_user_liked_albums_path, liked_albums_path, liked_users_albums_path, invited_albums_path, session_user_invited_albums_path, current_user_membership) {

        // My Albums
        call_and_merge([my_albums_path, session_user_liked_albums_path, session_user_invited_albums_path], function(albums) {
            //show only albums for the current homepage
            albums = _.filter(albums, function(album) {
                return album.user_id == zz.page.displayed_user_id;
            });

            add_picons( albums );
            my_albums = albums;
            render_section($('#my-albums'), albums);
        });

        // Albums I Like
        call_and_merge([liked_albums_path, liked_users_albums_path], function(albums) {
            add_picons( albums );
            liked_albums = albums;
            render_section($('#liked-albums'), albums);
        });

        // Albums I have been invited to
        if(current_users_home_page){
            call_and_merge([invited_albums_path], function(albums) {
                add_picons( albums );
                invited_albums = albums;
                render_section($('#invited-albums'), albums);
            });
        }
        zz.like.add_id_array(wanted_subjects);
        $('#article').touchScrollY();
        arm_sort_buttons();
    };

    zz.homepage.sort_by_caption_asc = function(){
        if( _.isUndefined( my_albums ) ){
            alert('You must render the homepage first before you sort it by caption');
        }
        sort_and_render( alpha_caption_asc_comprarator )
    };

    zz.homepage.sort_by_updated_at_desc = function(){
        if( _.isUndefined( my_albums ) ){
            alert('You must render the homepage first before you sort it by caption');
        }
        sort_and_render( most_recent_first_comparator )
    };

    //sorts existing arrays and refreshes display
    function sort_and_render( comparator ){
        render_section( $('#my-albums'), _.sortBy(my_albums, comparator ) );
        render_section($('#liked-albums'), _.sortBy(liked_albums, comparator ) );

        if( !_.isUndefined( invited_albums )){
            render_section($('#invited-albums'), _.sortBy(invited_albums, comparator ) );
        }
    }


    // gets the albums from each url in the urls array
    // calls back with the merged,sorted,deduped array of albums
    function call_and_merge(urls, callback) {
        var results = {};

        var check_is_done = function() {

            //do we have results for each call?
            _.each(results, function(result) {
                if (! result) {
                    return;
                }
            });
            //all results are back

            //combine into one array
            var combined_results = [];
            _.each(results, function(result) {
                combined_results = combined_results.concat(result);
            });

            //sort
            var sorted_results = _.sortBy(combined_results, most_recent_first_comparator );

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
    }

    // creates a picon cell for each album in the array
    // the picon cell is stored in album.ui_cell
    function add_picons( albums ){
        _.each(albums, function(album) {
            var clone = cell.clone();
            album.ui_cell = clone;
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
                onDelete: function() {
                    if (confirm('Are you sure you want to delete this album?')) {
                        clone.find('.picon').hide('scale', {}, 300, function() {
                            clone.remove();
                        });
                        zz.routes.call_delete_album(album.id);
                    }
                },
                allowDelete      : !album.profile_album && album.user_id == zz.session.current_user_id,
                allowEditCaption : !album.profile_album && album.user_id == zz.session.current_user_id,
                infoMenuTemplateResolver: function(album){
                    var infomenu_template_matrix = [
                        [ null, zz.infomenu.download_template ],
                        [ zz.infomenu.delete_template, zz.infomenu.download_delete_template]
                    ];

                    var del = 0,
                        download = 0;

                    //delete
                    if(  !album.profile_album && album.user_id == zz.session.current_user_id ){
                        del = 1;
                    }
                    //download
                    if( album.c_url ){
                        switch( album.who_can_download ){
                            case 'everyone':
                                download = 1;
                                break;
                            case 'viewers': // group
                                if( album.id in current_user_membership ){
                                    download = 1;
                                }
                                break;
                            case 'owner':
                                if( album.user_id == zz.session.current_user_id ){
                                    download = 1;
                                }
                                break;
                        }
                    }
                    return infomenu_template_matrix[del][download];

                },
                onChangeCaption: function( newAlbumName, onSuccess, onError ){
                    // send it to the back end
                    zz.routes.albums.update( album.id,{'name': newAlbumName },
                        function(data){
                            onSuccess( data );
                        },
                        function(xhr){
                            zz.dialog.show_flash_dialog(JSON.parse(xhr.responseText).message, function(){ onError(); } );
                        });
                }
            });
        });
    };


    // Cleans the container and inserts the album cells in
    // the order they are in the array.
    // Albums in the array must have picons already added ( see add_picons )
    function render_section(container, albums) {

        container.find('div.album-cell').detach();
        container.fadeOut( 'fast');
        var new_container = container.clone();
        _.each(albums, function(album) {
            if( !_.isUndefined( album.ui_cell ) ){
                new_container.append( album.ui_cell );
                wanted_subjects[album.id] = 'album';
            }
        });
        container.replaceWith( new_container );
        new_container.fadeIn( 'slow');
        container.remove();
    }

    // used to sort album array by most recent first
    function most_recent_first_comparator(album){
                return -1 * album.updated_at;
    }

    // alphabetic ascending
    function alpha_caption_asc_comprarator( album ){
                return album.name;
    }

    function arm_sort_buttons(){
        $('#sort-recent-button').click( function(){
            ZZAt.track('homepage.sort-recent.button.click');
            zz.homepage.sort_by_updated_at_desc();
        } );
        $('#sort-name-button').click( function(){
            ZZAt.track('homepage.sort-name.button.click');
            zz.homepage.sort_by_caption_asc();
        } );
    }

})();