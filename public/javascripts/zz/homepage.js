var zz = zz || {};

zz.homepage = {};

// Builds the homepage from the different cached assets.

(function(){


    var cell = $('<div class="album-cell"></div>');
    var my_albums        = null;
    var liked_albums     = null;
    var following_albums = null;
    var invited_albums   = null;
    var all_albums       = null;

    var current_users_home_page,
        my_albums_path,
        session_user_liked_albums_path,
        liked_albums_path,
        liked_users_albums_path,
        invited_albums_path,
        session_user_invited_albums_path,
        current_user_membership,
        all_albums_title,
        my_albums_title,
        liked_albums_title,
        invited_albums_title,
        following_albums_title;


    zz.homepage.init = function( p_current_users_home_page,
                                 p_my_albums_path,
                                 p_session_user_liked_albums_path,
                                 p_liked_albums_path,
                                 p_liked_users_albums_path,
                                 p_invited_albums_path,
                                 p_session_user_invited_albums_path,
                                 p_current_user_membership,
                                 p_all_albums_title,
                                 p_my_albums_title,
                                 p_invited_albums_title,
                                 p_liked_albums_title,
                                 p_following_albums_title) {

        current_users_home_page = p_current_users_home_page;
        my_albums_path = p_my_albums_path;
        session_user_liked_albums_path = p_session_user_liked_albums_path;
        liked_albums_path = p_liked_albums_path;
        liked_users_albums_path = p_liked_users_albums_path;
        invited_albums_path = p_invited_albums_path;
        session_user_invited_albums_path = p_session_user_invited_albums_path;
        current_user_membership = p_current_user_membership;
        all_albums_title = p_all_albums_title;
        my_albums_title = p_my_albums_title;
        invited_albums_title = p_invited_albums_title;
        liked_albums_title = p_liked_albums_title;
        following_albums_title = p_following_albums_title;
        
        filter_sort_and_render( );
        $('#article').touchScrollY();
        arm_buttons();
    };


    zz.homepage.sort_by_caption_asc = function(){
        jQuery.cookie('zz.homepage.sort', 'caption_asc', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.sort_by_updated_at_desc = function(){
        jQuery.cookie('zz.homepage.sort', 'updated_at_desc', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.sort_by_created_at_asc = function(){
        jQuery.cookie('zz.homepage.sort', 'created_at_asc', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.show_all_albums = function(){
        jQuery.cookie('zz.homepage.filter', 'all', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.show_my_albums = function(){
        jQuery.cookie('zz.homepage.filter', 'my', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.show_invited_albums = function(){
        jQuery.cookie('zz.homepage.filter', 'invited', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.show_liked_albums = function(){
        jQuery.cookie('zz.homepage.filter', 'liked', {path:'/'});
        filter_sort_and_render( );
    };

    zz.homepage.show_following_albums = function(){
        jQuery.cookie('zz.homepage.filter', 'following', {path:'/'});
        filter_sort_and_render( );
    };

    function filter_sort_and_render( ){
        switch( $.cookie('zz.homepage.filter')){
            case('my'):
                if( my_albums ){
                    render( my_albums_title, sort( my_albums ));
                }else{
                    call_and_merge([my_albums_path, session_user_liked_albums_path, session_user_invited_albums_path], function(albums) {
                        //show only albums for the current homepage
                        albums = _.filter(albums, function(album) {
                            return album.user_id == zz.page.displayed_user_id;
                        });
                        add_picons( albums );
                        my_albums = albums;
                        render(my_albums_title, my_albums);
                        fetch_like_info(my_albums);
                    });

                }
                break;
            case('invited'):
                if(current_users_home_page){
                    if( invited_albums ){
                        render( invited_albums_title, sort( invited_albums ));
                    }else{
                        call_and_merge([invited_albums_path], function(albums) {
                            add_picons( albums );
                            invited_albums = albums;
                            render(invited_albums_title, invited_albums);
                            fetch_like_info(invited_albums);
                        });
                    }
                }
                break;
            case('liked'):
                if( liked_albums ){
                    render(liked_albums_title, sort( liked_albums) );
                }else{
                    call_and_merge([liked_albums_path], function(albums) {
                        add_picons( albums );
                        liked_albums = albums;
                        render(liked_albums_title, liked_albums);
                        fetch_like_info(liked_albums);
                    });
                }
                break;
            case('following'):
                if( following_albums ){
                    render(following_albums_title, sort( following_albums) );
                }else{
                    call_and_merge([ liked_users_albums_path ], function(albums) {
                        add_picons( albums );
                        following_albums = albums;
                        render(following_albums_title,following_albums);
                        fetch_like_info(following_albums);
                    });
                }
                break;
            case('all'):
            default: //all
                if( all_albums ){
                     render(all_albums_title, sort( all_albums ) );
                }else{
                    var all_urls = [
                        my_albums_path,
                        session_user_liked_albums_path,
                        session_user_invited_albums_path,
                        liked_albums_path,
                        liked_users_albums_path
                    ];

                    if( current_users_home_page ){
                        all_urls.push( invited_albums_path );
                    }
                    call_and_merge( all_urls , function(albums) {
                        add_picons( albums );
                        all_albums = albums;
                        render(all_albums_title,all_albums);
                        fetch_like_info(all_albums);
                    });
                }
        }
    }

    function sort( albums ){
        switch( $.cookie('zz.homepage.sort')){
                case('caption_asc'):
                    return _.sortBy(albums, alpha_caption_asc_comprarator );
                case('updated_at_desc'):
                    return _.sortBy(albums, most_recent_first_comparator );
                case('created_at_asc'):
                    return _.sortBy(albums, most_recent_first_comparator ); //TODO: Write correct comparator
                default:
                    return _.sortBy(albums, most_recent_first_comparator );
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
            var sorted_results = sort( combined_results );
            
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
    function render(title, albums) {
        var container = $('div#albums');
        container.find('div.album-cell').detach();
        container.fadeOut( 'fast');
        container.find('div#albums-title').text( title );
        var new_container = container.clone();
        _.each(albums, function(album) {
            if( !_.isUndefined( album.ui_cell ) ){
                new_container.append( album.ui_cell );
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

    function fetch_like_info(albums){
         var wanted_subjects  = {};
        _.each(albums, function(album) {
                wanted_subjects[album.id] = 'album';
        });
         zz.like.add_id_array(wanted_subjects);
    }

    function arm_buttons(){
        $('#view-all-btn').click( function(){
            ZZAt.track('homepage.view-all.button.click');
            zz.homepage.show_all_albums();
            set_button_selection();
        });
        $('#view-my-btn').click( function(){
            ZZAt.track('homepage.view-my.button.click');
            zz.homepage.show_my_albums();
            set_button_selection();
        });
        $('#view-invited-btn').click( function(){
            ZZAt.track('homepage.view-invited.button.click');
            zz.homepage.show_invited_albums();
            set_button_selection();
        });
        $('#view-liked-btn').click( function(){
            ZZAt.track('homepage.view-liked.button.click');
            zz.homepage.show_liked_albums();
            set_button_selection();
        });
        $('#view-following-btn').click( function(){
            $(this).addClass('selected');
            ZZAt.track('homepage.view-following.button.click');
            zz.homepage.show_following_albums();
            set_button_selection();
        });
        $('#sort-date-btn').click( function(){
            $(this).addClass('selected');
            ZZAt.track('homepage.sort-date.button.click');
            zz.homepage.sort_by_created_at_asc();
            set_button_selection();
        });
        $('#sort-recent-btn').click( function(){
            $(this).addClass('selected');
            ZZAt.track('homepage.sort-recent.button.click');
            zz.homepage.sort_by_updated_at_desc();
            set_button_selection();
        } );
        $('#sort-alpha-btn').click( function(){
            ZZAt.track('homepage.sort-name.button.click');
            zz.homepage.sort_by_caption_asc();
            set_button_selection();
        } );
        set_button_selection();
    }

    function clear_selection(){
        $('div#view-sort-bar div.zz-setbutton').removeClass('active-state');
    }

    function set_button_selection(){
        clear_selection();
        switch( $.cookie('zz.homepage.sort')){
            case('caption_asc'):
                $('#sort-name-btn').addClass('active-state');
                break;
            case('created_at_asc'):
                $('#sort-date-btn').addClass('active-state');
                break;
            case('updated_at_desc'):
            default:
                $('#sort-recent-btn').addClass('active-state');
        }
        switch( $.cookie('zz.homepage.filter')){
            case('my'):
                $('#view-my-btn').addClass('active-state');
                break;
            case('invited'):
                $('#view-invited-btn').addClass('active-state');
                break;
            case('liked'):
                $('#view-liked-btn').addClass('active-state');
                break;
            case('following'):
                $('#view-following-btn').addClass('active-state');
                break;
            case('all'):
            default: //all
                $('#view-all-btn').addClass('active-state');
        }
    }

    function sort( albums ){
        switch( $.cookie('zz.homepage.sort')){
                case('caption_asc'):
                    return _.sortBy(albums, alpha_caption_asc_comprarator );
                case('updated_at_desc'):
                    return _.sortBy(albums, most_recent_first_comparator );
                case('created_at_asc'):
                    return _.sortBy(albums, most_recent_first_comparator ); //TODO: Write correct comparator
                default:
                    return _.sortBy(albums, most_recent_first_comparator );
            }
    }

})();
