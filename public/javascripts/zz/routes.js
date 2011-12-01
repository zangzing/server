var zz = zz || {};

(function(){

    zz.routes = {

        path_prefix: '/service',

        store: {
            get_products: function(success, error){
                do_get('/store/products.json', {}, success, error);
            },

            goto_cart: function(){
                document.location.href = 'https://' + document.location.host + '/store/cart';
            },

            goto_checkout: function(){
                document.location.href = 'https://' + document.location.host + '/store/checkout';
            },

            add_to_cart: function(product_id, sku, photo_ids, success, error ){
                do_post('/store/orders/add_to_order.json', {product_id: product_id, sku: sku, photo_ids:photo_ids}, success, error);
            },

            get_glamour_page_html: function(product_id, success, failure){
                var url = '/store/products/' + product_id;
                do_get_html(url, {}, success, failure);
            }
        },

        comments: {
            delete_comment: function(comment_id, success, error){
                var url = '/service/comments/:comment_id'.replace(':comment_id', comment_id);
                return $.post(url, {_method: 'delete'}, success, error);
            },

            get_comments_for_photo: function(photo_id, success, error){
                var url = '/service/photos/:photo_id/comments'.replace(':photo_id', photo_id);
                return do_get(url, {}, success, error);
            },

            create_comment_for_photo: function(photo_id, comment_params, success, failure){
                var url = '/service/photos/:photo_id/comments'.replace(':photo_id', photo_id);
                return do_post(url, comment_params, success, failure);
            },

            get_album_photos_comments_metadata: function(album_id, success, failure){
                var url = '/service/albums/:album_id/photos/comments/metadata'.replace(':album_id', album_id);
                return do_get(url, {}, success, failure);
            },

            finish_create_photo_comment_path: function(photo_id){
                return '/service/photos/:photo_id/comments/finish_create'.replace(':photo_id', photo_id);
            }




        },

        users: {
            user_home_page_path: function(username){
                return '/' + username;
            },

            goto_join_screen: function(return_to){
                if(return_to){
                    document.location.href = '/join?return_to=:return_to'.replace(':return_to', return_to);
                }
                else{
                    document.location.href = '/join';
                }
            },

            goto_signin_screen: function(return_to){
                if(return_to){
                    document.location.href = '/signin?return_to=:return_to'.replace(':return_to', encodeURIComponent(return_to));
                }
                else{
                    document.location.href = '/signin';
                }
            }
        },

        albums:{
            request_viewer: function(album_id, message, success, error){
                do_post('/service/albums/' +album_id+'/request_access', {message: message, access_type: 'viewer'}, success, error);
            },
            request_contributor: function(album_id, message, success, error){
                do_post('/service/albums/' +album_id+'/request_access', {message: message, access_type: 'contributor'}, success, error);
            },
            update: function( album_id, data_hash, success,error){
                do_put('/zz_api/albums/'+album_id, data_hash, success, error );
            },
            add_photos: function( album_id ){
                window.location = '/service/albums/' +album_id+'/add_photos';
            }
        },

        photos: {

            _cache: {},  //key is <album_id>-<cache_version>, value is album photos json

            photo_url: function(photo_id, album_base_url){
                album_base_url = album_base_url || zz.page.album_base_url;
                return "http://{{host}}{{album_base_url}}/photos/#!:photo_id".replace('{{host}}', document.location.host)
                                                                             .replace('{{album_base_url}}', album_base_url)
                                                                             .replace(':photo_id', photo_id);
            },

            album_photos_url: function(album_id, cache_version){
                return zz.routes.path_prefix + '/albums/' + album_id + '/photos_json?ver=' + cache_version;
            },

            get_photo_json: function(album_id, cache_version, photo_id, success){
                var json = zz.routes.photos._cache[album_id + '-' + cache_version];

                var find_photo = function(json, photo_id){
                    return _.detect(json, function(photo){
                       if(photo.id == photo_id){
                           return true;
                       }
                    });
                };

                if(json){
                    success(find_photo(json, photo_id));
                }
                else{
                    zz.routes.photos.get_album_photos_json(album_id, cache_version, function(json){
                        success(find_photo(json, photo_id));
                    });
                }
            },

            get_album_photos_json: function(album_id, cache_version, success, error){
                var url = zz.routes.photos.album_photos_url(album_id, cache_version);

                var on_success = function(json){
                    zz.routes.photos._cache[album_id + '-' + cache_version] = json;
                    json = translate_photos_json(json);
                    success(json);
                };

                var on_error = function(xhr, message, exception){
                    zz.cache_helper.check_bad_album_json(xhr, message, album_id, url);
                    if(error){
                        error(xhr, message, exception);
                    }
                };

                do_get(url, {}, on_success, on_error);

            }
        },


        edit_user_path: function(username) {
            return '/:username/settings'.replace(':username', username);
        },

        delete_identity_path: function(identity_name) {
            return '/service/:identity_name/sessions/destroy'.replace(':identity_name', identity_name);
        },

        new_identity_path: function(identity_name) {
            return '/service/:identity_name/sessions/new'.replace(':identity_name', identity_name);

        },

        signin_path: function() {
            return '/signin';
        },

        image_url: function(path) {
            if (zz.config.rails_asset_host) {
                var host_num = path.length % 4;
                return document.location.protocol + '//' + zz.config.rails_asset_host.replace('%d', host_num) + path + '?' + zz.config.rails_asset_id;
            }
            else {
                return path + '?' + zz.config.rails_asset_id;
            }
        },





        // todo: not sure these really belong here...
        //       but seems we do need central place to manage
        //       calls to server




        call_delete_album: function(album_id, success, error) {
            $.ajax({
                type: 'POST',
                dataType: 'json',
                data: {_method: 'delete'},
                url: zz.routes.path_prefix + '/albums/' + album_id + '.json',
                error: function() {
                    if (!_.isUndefined(error)) {
                        error();
                    }
                },
                success: function() {
                    zz.agent.callAgent('/albums/' + album_id + '/photos/*/cancel_upload');
                    if (!_.isUndefined(success)) {
                        success();
                    }
                }

            });
        },

        call_set_album_cover: function(album_id, photo_id, success, error) {
            $.ajax({ type: 'POST',
                url: zz.routes.path_prefix + '/albums/' + album_id,
                data: { '_method': 'put', 'album[cover_photo_id]': photo_id },
                error: function() {
                    if (!_.isUndefined(error)) {
                        error();
                    }
                },
                success: function() {
                    if (!_.isUndefined(success)) {
                        success();
                    }
                }
            });
        },

        call_delete_photo: function(photo_id, success, error) {
            $.ajax({
                type: 'POST',
                dataType: 'json',
                data: {_method: 'delete'},
                url: zz.routes.path_prefix + '/photos/' + photo_id + '.json',
                error: function() {
                    if (!_.isUndefined(error)) {
                        error();
                    }
                },
                success: function() {
                    zz.agent.callAgent('/albums/' + zz.page.album_id + '/photos/' + photo_id + '/cancel_upload');
                    if (!_.isUndefined(success)) {
                        success();
                    }
                }
            });
        },

        call_rotate_photo_left: function(photo_id, success, failure) {
            call_rotate_photo(photo_id, 'left', success, failure);
        },

        call_rotate_photo_right: function(photo_id, success, failure) {
            call_rotate_photo(photo_id, 'right', success, failure);
        }

    };


    // shows progress dialog and rotates photo on the server
    // success callback is passed the json of the rotated photo
    function call_rotate_photo(photo_id, direction, success, failure) {
        var dialog = zz.dialog.show_progress_dialog('Rotating photo...');

        var on_success = function(json) {
            dialog.close();
            if (_.isFunction(success)) {
                success(json);
            }
        };

        var on_failure = function(request, error, errorThrown) {
            dialog.close();
            if (_.isFunction(failure)) {
                failure(request, error, errorThrown);
            }
            alert(error);
        };

        zz.async_ajax.put('/service/photos/' + photo_id + '/async_rotate_' + direction, on_success, on_failure);
    }

    function do_post(url, params, success, error){
       return $.ajax({
           type: 'post',
           url: url,
           data: params,
           success: success,
           error: error
       });
    }

    function do_put(url, params, success, error){
        params = params || {};
        params['_method'] = 'put';

        return $.ajax({
            type: 'post',
            url: url,
            data: params,
            success: success,
            error: error
        });

    }

    function do_delete(url, params, success, error){
        params = params || {};
        params['_method'] = 'delete';

        return $.ajax({
            type: 'post',
            url: url,
            data: params,
            success: success,
            error: error
        });

    }

    function do_get(url, params, success, error){
        return $.ajax({
             type: 'get',
             url: url,
             data: params,
             success: success,
             error: error
         });
    }

    function do_get_html(url, params, success, error){
        return $.ajax({
             dataType: 'html',
             type: 'get',
             url: url,
             data: params,
             success: success,
             error: error
         });
    }



    function translate_photos_json(photos){
        // use native loop to keep fast
        for(var i=0;i<photos.length; i++){
            var photo = photos[i];
            if(photo.photo_base){
                photo.stamp_url = photo.photo_base.replace('#{size}',photo.photo_sizes.stamp);
                photo.thumb_url = photo.photo_base.replace('#{size}',photo.photo_sizes.thumb);
                photo.screen_url = photo.photo_base.replace('#{size}',photo.photo_sizes.screen);
                photo.full_screen_url = photo.photo_base.replace('#{size}',photo.photo_sizes.full_screen);
            }
        }
        return photos;
    }



})();
