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
        current_user_membership;

    zz.homepage.init = function( p_current_users_home_page,
                                 p_my_albums_path,
                                 p_session_user_liked_albums_path,
                                 p_liked_albums_path,
                                 p_liked_users_albums_path,
                                 p_invited_albums_path,
                                 p_session_user_invited_albums_path,
                                 p_current_user_membership) {

        current_users_home_page = p_current_users_home_page;
        my_albums_path = p_my_albums_path;
        session_user_liked_albums_path = p_session_user_liked_albums_path;
        liked_albums_path = p_liked_albums_path;
        liked_users_albums_path = p_liked_users_albums_path;
        invited_albums_path = p_invited_albums_path;
        session_user_invited_albums_path = p_session_user_invited_albums_path;
        current_user_membership = p_current_user_membership;

        arm_buttonset();
        filter_sort_and_render( );
        $('#article').touchScrollY();
    };


    function sort_by_name_asc(){
        set_sort_option( 'name_asc' );
        filter_sort_and_render( );
    }

    function sort_by_name_desc(){
        set_sort_option( 'name_desc' );
        filter_sort_and_render( );
    }

    function sort_by_updated_at_desc(){
        set_sort_option( 'updated_at_desc' );
        filter_sort_and_render( );
    }

    function sort_by_cover_date_asc(){
        set_sort_option( 'cover_date_asc' );
        filter_sort_and_render( );
    }

    function sort_by_cover_date_desc(){
            set_sort_option( 'cover_date_desc' );
            filter_sort_and_render( );
    };

    function show_all_albums(){
        set_filter_option( 'all' );
        filter_sort_and_render( );
    };

    function show_my_albums(){
        set_filter_option( 'my' );
        filter_sort_and_render( );
    };

    function show_invited_albums(){
        set_filter_option( 'invited' );
        filter_sort_and_render( );
    };

    function show_liked_albums(){
        set_filter_option( 'liked' );
        filter_sort_and_render( );
    };

    function show_following_albums(){
        set_filter_option( 'following' );
        filter_sort_and_render( );
    };


    // This function gets and caches the right albums from server according to the filter option
    // It uses the sort method indicated by the sort option


    function filter_sort_and_render( ){
        switch( get_filter_option() ){
            case('my'):
                if( my_albums ){
                    render( sort( my_albums ) );
                }else{
                    call_and_merge(  [my_albums_path, session_user_liked_albums_path, session_user_invited_albums_path] , [],function(albums) {
                        //show only albums for the current homepage
                        my_albums = _.filter(albums, function(album) {
                            return album.user_id == zz.page.displayed_user_id;
                        });
                        render( my_albums );
                        fetch_like_info(my_albums);
                    });

                }
                break;
            case('invited'):
                if(current_users_home_page){
                    if( invited_albums ){
                        render( sort( invited_albums ) );
                    }else{
                        call_and_merge([invited_albums_path], [], function(albums) {
                            invited_albums = albums;
                            render( invited_albums );
                            fetch_like_info(invited_albums);
                        });
                    }
                }
                break;
            case('liked'):
                if( liked_albums ){
                    render( sort( liked_albums) );
                }else{
                    call_and_merge([liked_albums_path], [], function(albums) {
                        liked_albums = albums;
                        render( liked_albums );
                        fetch_like_info(liked_albums);
                    });
                }
                break;
            case('following'):
                if( following_albums ){
                    render( sort( following_albums) );
                }else{
                    call_and_merge([ liked_users_albums_path ], [], function(albums) {
                        following_albums = albums;
                        render( following_albums );
                        fetch_like_info(following_albums);
                    });
                }
                break;
            case('all'):
            default: //all
                if( all_albums ){
                     render( sort( all_albums ) );
                }else{
                    var my_albums_urls = [ my_albums_path, session_user_liked_albums_path, session_user_invited_albums_path];
                    var additional_urls = [ liked_albums_path, liked_users_albums_path ];

                    if( current_users_home_page ){
                        additional_urls.push( invited_albums_path );
                    }

                    if( my_albums ){
                        // my_albums is already here and filtered, just get the passthroughs
                        call_and_merge( additional_urls, my_albums, function(albums) {
                            all_albums = albums;
                            render( all_albums );
                            fetch_like_info(all_albums);
                        });
                    }else{
                        //get my_albums_urls and filter to get my_albums then get the passthroughs
                        call_and_merge(my_albums_urls, [],function(albums) {
                            //show only albums for the current homepage
                            my_albums = _.filter(albums, function(album) {
                                return album.user_id == zz.page.displayed_user_id;
                            });
                            call_and_merge( additional_urls, my_albums, function(albums) {
                                all_albums = albums;
                                render( all_albums );
                                fetch_like_info(all_albums);
                            });
                        });
                    }
                }
        }
    }

    // Sorts the given array using the comparator indicated by the sort option
    function sort( albums ){
        switch( get_sort_option() ){
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
    // it sorts the results based on the sort option
    // The results will be seeded with seed
    function call_and_merge(urls, seed, callback) {
        var results = {};

        if(  seed.length > 0 ){
            results['seed'] = seed;
        }

        var check_is_done = function() {
            //do we have results for each call?
            var key;
            for(  key in results){
                if( !results[key] ) {
                    return;
                }
            }
            //all results are here

            //combine into one array
            var combined_results = [];
            for(  key in results){
                combined_results = combined_results.concat(results[key]);
            };

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
                        add_picons( albums );
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
        var ie = $.browser.msie; //!$.support.leadingWhitespace

        if( ie ){
            var container = $('div#albums');
        }
        _.each(albums, function(album) {
            if( !album.ui_cell ){

                var clone = cell.clone();
                var c_url = album.c_url;
                // Set the special cover for empty profile albums
                if(album.profile_album && album.photos_count <= 0 && zz.session.current_user_id == zz.page.displayed_user_id) {
                    c_url = "images/profile-default-add.png";
                }
                if( ie ){ //ie 8
                    container.append( clone );
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
                if( ie ){ //ie 8
                    clone.detach();
                }
            }
        });
    };


    // Cleans the container and inserts the album cells in
    // the order they are in the array.
    // Albums in the array must have picons already added ( see add_picons )
    function render( albums) {
        var container = $('div#albums');
        container.hide();
        container.find('div.album-cell').detach();
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
                return album.name.toLowerCase();
    }

    function name_desc_comprarator( album ){
       return String.fromCharCode.apply(String,
        _.map(album['name'].toLowerCase().split(''), function (c) {
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
        $('#view-all-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.view-all.button.mousedown');
           show_all_albums();
        });
        $('#view-my-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.view-my.button.click');
           show_my_albums();
        });
        $('#view-invited-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.view-invited.button.click');
           show_invited_albums();
        });
        $('#view-liked-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.view-liked.button.click');
            show_liked_albums();
        });
        $('#view-following-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.view-following.button.click');
           show_following_albums();
        });
        $('#sort-date-btn').bind( 'setbutton-click',  function(){
            if( $(this).hasClass('arrow-up')){
                ZZAt.track('homepage.sort-date-asc.button.click');
                sort_by_cover_date_asc();
            }else{
                ZZAt.track('homepage.sort-date-desc.button.click');
                sort_by_cover_date_desc();
            }
        });
        $('#sort-recent-btn').bind( 'setbutton-click',  function(){
            ZZAt.track('homepage.sort-recent.button.click');
           sort_by_updated_at_desc();
        } );
        $('#sort-name-btn').bind( 'setbutton-click',  function(){
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
        switch( get_sort_option() ){
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
        switch( get_filter_option() ){
            case('my'):
                $('#view-my-btn').addClass('active-state');
                break;
            case('invited'):
                if( current_users_home_page ){
                    $('#view-invited-btn').addClass('active-state');
                } else {
                  set_filter_option( 'all' )
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
        switch( get_sort_option() ){
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

    function set_option( option, value ){
        var key = 'homepage_options_'+zz.page.displayed_user_base_url
        var options = zz.local_storage.get( key ) || {};
        options[option] = options[option] || {};
        options[option] = value;
        zz.local_storage.set( key , options );
    }

    function set_sort_option(value){
        set_option('sort', value);
    }

    function set_filter_option( value ){
        set_option('filter', value);
    }


    function get_option( option, default_option ){
        var key = 'homepage_options_'+zz.page.displayed_user_base_url
        var options = zz.local_storage.get( key );
        if( options &&  options[option] ){
                return options[option];
        }
        return default_option;
    }

    function get_sort_option(){
        return get_option('sort','updated_at_desc');
    }

    function get_filter_option(){
        if( current_users_home_page ){
            return get_option('filter','all');
        }else{
            return get_option('filter','my');
        }
    }

})();
