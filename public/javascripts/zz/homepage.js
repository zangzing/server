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

        arm_buttonset();
        filter_sort_and_render( );
        $('#article').touchScrollY();
    };


    function sort_by_name_asc(){
        jQuery.cookie('zz.homepage.sort', 'name_asc', {path:'/'});
        filter_sort_and_render( );
    }

    function sort_by_name_desc(){
        jQuery.cookie('zz.homepage.sort', 'name_desc', {path:'/'});
        filter_sort_and_render( );
    }

    function sort_by_updated_at_desc(){
        jQuery.cookie('zz.homepage.sort', 'updated_at_desc', {path:'/'});
        filter_sort_and_render( );
    }

    function sort_by_cover_date_asc(){
        jQuery.cookie('zz.homepage.sort', 'cover_date_asc', {path:'/'});
        filter_sort_and_render( );
    }

    function sort_by_cover_date_desc(){
            jQuery.cookie('zz.homepage.sort', 'cover_date_desc', {path:'/'});
            filter_sort_and_render( );
    };

    function show_all_albums(){
        jQuery.cookie('zz.homepage.filter', 'all', {path:'/'});
        filter_sort_and_render( );
    };

    function show_my_albums(){
        jQuery.cookie('zz.homepage.filter', 'my', {path:'/'});
        filter_sort_and_render( );
    };

    function show_invited_albums(){
        jQuery.cookie('zz.homepage.filter', 'invited', {path:'/'});
        filter_sort_and_render( );
    };

    function show_liked_albums(){
        jQuery.cookie('zz.homepage.filter', 'liked', {path:'/'});
        filter_sort_and_render( );
    };

    function show_following_albums(){
        jQuery.cookie('zz.homepage.filter', 'following', {path:'/'});
        filter_sort_and_render( );
    };


    // This function gets and caches the right albums from server according to the filter cookie
    // It uses the sort method indicated by the sort cookie
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
                        all_albums = albums;
                        render(all_albums_title,all_albums);
                        fetch_like_info(all_albums);
                    });
                }
        }
    }

    // Sorts the given array using the comparator indicated by the sort cookie
    function sort( albums ){
        switch( $.cookie('zz.homepage.sort')){
                case('name_asc'):
                    return _.sortBy(albums, name_asc_comprarator );
                case('name_desc'):
                    return _.sortBy(albums, name_desc_comprarator );
                case('updated_at_desc'):
                    return _.sortBy(albums, most_recent_first_comparator );
                case('cover_date_asc'):
                    return _.sortBy(albums, cover_date_asc_comparator );
                case('cover_date_desc'):
                    return _.sortBy(albums, cover_date_desc_comparator );
                default:
                    return _.sortBy(albums, updated_at_desc_comparator );
            }
    }

    // gets the albums from each url in the urls array
    // calls back with the merged,sorted,deduped array of albums
    // it sorts the results based on the sort cookie
    function call_and_merge(urls, callback) {
        var results = {};

        var check_is_done = function() {

            //do we have results for each call?
            _.each(results, function(result) {
                if (! result) {
                    return;
                }else{
                    add_picons( result );
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
            if( !album.ui_cell ){

                var clone = cell.clone();
                var c_url = album.c_url;
                // Set the special cover for empty profile albums
                if(album.profile_album && album.photos_count <= 0 && zz.session.current_user_id == zz.page.displayed_user_id) {
                    c_url = "images/profile-default-add.png";
                }

                album.ui_cell = clone;
                clone.zz_picon({
                    album:   album,
                    caption: album.name,
                    coverUrl: c_url,
                    albumId: album.id,
                    albumUrl: 'http://' + document.location.host + album.album_path,
                    onClick: function() {
                        $('#article').css('width',$('#article').width());
                        $('#article').css({overflow: 'hidden'}).animate({left: -1 * $('#article').width()}, 500, 'easeOutQuart');
                        $('#user-info').fadeOut(200);
                        if(album.photos_count <= 0 && zz.session.current_user_id == album.user_id) {
                            zz.routes.albums.add_photos(album.id);
                        } else {
                            document.location.href = album.album_path;
                        }

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
                    onChangeCaption: function( new_album_name, on_success, on_error ){
                        // send it to the back end
                        zz.routes.albums.update( album.id,{'name': new_album_name },
                            function(data){
                                album.name = new_album_name; //update the model
                                on_success( data );
                            },
                            function(xhr){
                                zz.dialog.show_flash_dialog(JSON.parse(xhr.responseText).message, function(){ on_error(); } );
                            });
                    }
                });
            }
        });
    };


    // Cleans the container and inserts the album cells in
    // the order they are in the array.
    // Albums in the array must have picons already added ( see add_picons )
    function render(title, albums) {
        var container = $('div#albums');
        container.hide();
        container.find('div.album-cell').detach();
        container.find('div#albums-title').text( title );
        _.each(albums, function(album) {
            if( !_.isUndefined( album.ui_cell ) ){
                container.append( album.ui_cell );
            }
        });
        container.show();
    }


    function updated_at_desc_comparator(album){
                return -1 * album.updated_at;
    }


    function cover_date_asc_comparator(album){
                return  album.cover_date;
    }

    function cover_date_desc_comparator(album){
                return  -1 * album.cover_date;
    }

    function name_asc_comprarator( album ){
                return album.name;
    }

    function name_desc_comprarator( album ){
       return String.fromCharCode.apply(String,
        _.map(album['name'].split(""), function (c) {
            return 0xffff - c.charCodeAt();
        }));
    }

    function fetch_like_info(albums){
         var wanted_subjects  = {};
        _.each(albums, function(album) {
                wanted_subjects[album.id] = 'album';
        });
         zz.like.add_id_array(wanted_subjects);
    }


    function arm_buttonset(){
        // Arm Buttons
        $('#view-all-btn').click( function(){
            ZZAt.track('homepage.view-all.button.click');
           show_all_albums();
        });
        $('#view-my-btn').click( function(){
            ZZAt.track('homepage.view-my.button.click');
           show_my_albums();
        });
        $('#view-invited-btn').click( function(){
            ZZAt.track('homepage.view-invited.button.click');
           show_invited_albums();
        });
        $('#view-liked-btn').click( function(){
            ZZAt.track('homepage.view-liked.button.click');
            show_liked_albums();
        });
        $('#view-following-btn').click( function(){
            ZZAt.track('homepage.view-following.button.click');
           show_following_albums();
        });
        $('#sort-date-btn').click( function(){
            if( $(this).hasClass('arrow-up')){
                ZZAt.track('homepage.sort-date-asc.button.click');
                sort_by_cover_date_asc();
            }else{
                ZZAt.track('homepage.sort-date-desc.button.click');
                sort_by_cover_date_desc();
            }
        });
        $('#sort-recent-btn').click( function(){
            ZZAt.track('homepage.sort-recent.button.click');
           sort_by_updated_at_desc();
        } );
        $('#sort-name-btn').click( function(){
            if( $(this).hasClass('arrow-up')){
                ZZAt.track('homepage.sort-name-asc.button.click');
                sort_by_name_asc();
            }else{
                ZZAt.track('homepage.sort-name-desc.button.click');
                sort_by_name_desc();
            }
        } );
        set_button_selection();
    }


    function set_button_selection(){
        switch( $.cookie('zz.homepage.sort')){
            case('name_asc'):
                $('#sort-name-btn').addClass('active-state arrow-up');
                break;
            case('name_desc'):
                $('#sort-name-btn').addClass('active-state arrow-down');
                break;
            case('cover_date_asc'):
                $('#sort-date-btn').addClass('active-state arrow-up');
                break;
            case('cover_date_desc'):
                $('#sort-date-btn').addClass('active-state arrow-down');
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
                if( $('#view-invited-btn').length != 0 ){
                    $('#view-invited-btn').addClass('active-state');
                } else {
                   jQuery.cookie('zz.homepage.filter', 'all', {path:'/'});
                   $('#view-all-btn').addClass('active-state');
                }
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
                case('name_asc'):
                    return _.sortBy(albums, name_asc_comprarator );
                case('name_desc'):
                    return _.sortBy(albums, name_desc_comprarator );
                case('updated_at_desc'):
                    return _.sortBy(albums, updated_at_desc_comparator );
                case('cover_date_asc'):
                    return _.sortBy(albums, cover_date_asc_comparator );
                case('cover_date_desc'):
                    return _.sortBy(albums, cover_date_desc_comparator );
                default:
                    return _.sortBy(albums, updated_at_desc_comparator );
            }
    }

})();
