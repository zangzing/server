var zz = zz || {};
zz.buy = zz.buy || {};

(function(){

    var BETA_USERS = [
        //jeremy
        'hope',
        'lauriehermann',
        'jlh',
        'jeremyhermann',

        //joseph
        'j',
        'david',
        'jamesrharker',
        'ebothwell',
        'jaymce',
        'rosen',
        'joseph',

        //kathryn
        'k',
        'erika',
        'sheripollock',
        'tyler',
        'jrwatts',
        'kmcmaster',


        //mauricio
        'mauricio',
        'ximena',
        'eugetomelu',
        'wythes',
        'mm',
        'castiron',

        //richa
        'sfmishras',
        'rimish',
        'sintak',
        'richamisra',

         //greg
        'gseitz',
        'lyogi',

        //phil
        'pbeisel',
        'surfkayak',
        'dgfoster',
        'beiselpaul',

        //user testing
        'usertesting001',
        'usertesting002',
        'usertesting003'


    ];

    var OPTION_FILTERS = [

    /*****************************
     *        Franed Prints
     ******************************/
        {
            type_id: 4, // size
            id: 15,     // 4x6
            option_values_to_remove: [
                {
                    type_id: 12, //frame
                    id: 50      //chocolate with no matte
                },
                {
                    type_id: 12, //frame
                    id: 47      //black with no matte
                }
            ]
        },
        {
            type_id: 4, // size
            id: 20,     // 20x30
            option_values_to_remove: [
                {
                    type_id: 12, //frame
                    id: 51      //chocolate with white matte
                },
                {
                    type_id: 12, //frame
                    id: 52      //chocolate with off-white matte
                },
                {
                    type_id: 12, //frame
                    id: 48      //black with white matte
                },
                {
                    type_id: 12, //frame
                    id: 49      //black with off-white matte
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 51,     // Chocolate with White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 52,     // Chocolate with Off-White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 50,     // Chocolate with No Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 48,     // Black with White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 49,     // Black with Off-White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 12, // frame
            id: 47,     // Black with No Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },



    /*****************************
     *        Prints
     ******************************/
        {
            type_id: 4, // size
            id: 15,     // 4x6
            option_values_to_remove: [
                {
                    type_id: 7, //frame
                    id: 31      //chocolate with no matte
                },
                {
                    type_id: 7, //frame
                    id: 34      //black with no matte
                }
            ]
        },
        {
            type_id: 4, // size
            id: 20,     // 20x30
            option_values_to_remove: [
                {
                    type_id: 7, //frame
                    id: 29      //chocolate with white matte
                },
                {
                    type_id: 7, //frame
                    id: 30      //chocolate with off-white matte
                },
                {
                    type_id: 7, //frame
                    id: 32      //black with white matte
                },
                {
                    type_id: 7, //frame
                    id: 33      //black with off-white matte
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 29,     // Chocolate with White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 30,     // Chocolate with Off-White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 31,     // Chocolate with No Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 32,     // Black with White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 33,     // Black with Off-White Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        },
        {
            type_id: 7, // frame
            id: 34,     // Black with No Matte
            option_values_to_remove: [
                {
                    type_id: 3,
                    id: 11       // Glossy
                },
                {
                    type_id: 3,
                    id: 12       // Matte
                },
                {
                    type_id: 3,
                    id: 13      // Lustre
                },
                {
                    type_id: 3,
                    id: 14          // Metallic
                }
            ]
        }
    ];



    var DRAWER_SCREENS = {
        SELECT_PRODUCT: 'select_product',
        CONFIGURE_PRODUCT: 'configure_product'
    };



    var EVENTS = {
        BEFORE_ACTIVATE: 'zz.buy.before_activate',
        ACTIVATE: 'zz.buy.activate',
        BEFORE_DEACTIVATE: 'zz.buy.before_deactivate',
        DEACTIVATE: 'zz.buy.deactivate',
        REMOVE_SELECTED_PHOTO: 'zz.buy.remove_selected_photo',
        ADD_SELECTED_PHOTO: 'zz.buy.add_selected_photo'
    };


    var SELECTED_PHOTO_MAX_SIZE = {
        WIDTH: 185,
        HEIGHT: 145
    };

    var buy_screens_element = null;

    var SCRIM_TEMPLATE = function(){
        return '<div class="buy-drawer-scrim" style="display: block; ">' +
                   '<div class="scrim"></div>' +
                   '<div class="message" style="display: block; left: 403px; ">Please choose a product, then you will be able to select photos for that product.</div>' +
                '</div>'
    };

    var BUY_SCREENS_TEMPLATE = function(){
        return '<div class="buy-screens">' +
                    '<div class="select-product-screen"><div class="loading"></div></div>' +
                    '<div class="configure-product-screen">' +
                        '<div class="product-summary-section">' +
                           '<img class="image" src="/images/photo_placeholder.png">' +
                           '<div class="description">16x20 Mounted Print with a Black Frame</div>' +
                           '<div class="count-and-price">12 for $200.00</div>' +
                           '<a class="green-button checkout-button"><span>Add to Cart</span></a>' +
                        '</div>' +
                        '<div class="bad-photos-error">' +
                           '<div class="icon"></div>' +
                           '<div class="message">Some of your photos are not large enough for this product. Please remove the photos or select a different product.</div>' +
                        '</div>' +
                        '<div class="main-section">' +
                            '<div class="options-section">' +
                                '<div class="price">' +
                                    '<div class="label">Price</div>' +
                                    '<div class="value"></div>' +
                                '</div>' +
                                '<div class="options"></div>' +
                            '</div>' +
                            '<div class="selected-photos-section">' +
                                '<a class="add-all-photos hyperlink-button">Add All Photos from Album</a>' +
                                '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
                                '<a class="clear-all-photos hyperlink-button">Clear Selected Photos</a>' +
                                '<div class="add-photos-message">Choose product settings and then click to choose your photos.</div>' +
                                '<div class="selected-photos"></div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
               '</div>';
    };

    var PRODUCT_TEMPLATE = function(){
        return '<div class="product">' +
                   '<img class="image" src="/images/photo_placeholder.png">' +
                   '<div class="name"></div>' +
                   '<div class="description"></div>' +
                   '<div class="learn-more">Learn more</div>' +
                   '<div class="arrow"></div>' +
               '</div>';
    };

    var SELECTED_PHOTO_TEMPLATE = function(){
        return '<div class="selected-photo">' +
                    '<div class="photo-border">' +
                        '<img class="photo-image" src="/images/photo_placeholder.png">' +
                        '<div class="photo-delete-button"></div>' +
                        '<img class="bottom-shadow" src="/images/photo/bottom-full.png?1">' +
                        '<img class="error-icon" src="/images/buy/large-error-icon.png">' +
                    '</div>' +
               '</div>';
    };

    var PRODUCT_OPTION_TEMPLATE = function(){
        return '<div class="option">' +
                   '<div class="label"></div>' +
                   '<select class="drop-down"></select>' +
               '</div>';
    };




    zz.buy.init = function(){
        if(zz.page.rails_controller_name == 'users'){
            return;
        }

        if(zz.buy.is_buy_mode_active()){
            open_drawer(false, function(){});
            $('#footer #buy-button').addClass('selected');
        }

        $('#footer #buy-button').click(function() {
            if (! $(this).hasClass('disabled')) {
                if(zz.buy.is_buy_mode_active()){
                    zz.buy.deactivate_buy_mode();
                }
                else{
                    zz.buy.activate_buy_mode();
                }
            }
        });

        $('#footer #cart-button').click(function() {
            if ($(this).hasClass('disabled') || $(this).hasClass('selected')) {
                return;
            }

            if(zz.session.cart_item_count > 0){
                zz.routes.store.goto_cart();
            }
            else{
               if(!zz.buy.is_buy_mode_active()){
                   zz.buy.activate_buy_mode();
               }
            }


        });

        if(zz.session.cart_item_count > 0){
            $('#footer #cart-button .cart-count').removeClass('empty').text(zz.session.cart_item_count);
        }



        if(zz.session.cart_item_count > 0 && jQuery.cookie('hide_checkout_banner') != 'true'){
            $('#checkout-banner').show();
            if(zz.session.cart_item_count == 1){
                $('#checkout-banner .message').text('You have ' + zz.session.cart_item_count + ' item in your cart.');
            }
            else{
                $('#checkout-banner .message').text('You have ' + zz.session.cart_item_count + ' items in your cart.');
            }


            $('#checkout-banner .close-button').click(function(){
                //create cookie that expires in 1 hour or when user quits browser
                var expires = new Date();
                expires.setTime(expires.getTime() + 60 * 60 * 1000);
                jQuery.cookie('hide_checkout_banner', 'true', {expires: expires});

                $('#checkout-banner').animate({top:-20}, 200);
                $('#checkout-banner').animate({top:-20}, 200);
            });


            $('#checkout-banner .view-cart-button').click(function(){
                zz.routes.store.goto_cart();
            });

            $('#checkout-banner .checkout-button').click(function(){
                zz.routes.store.goto_cart();
            });

            var center = function(){
                $('#checkout-banner').center_x($('#article'));
            };

            $(window).resize(function() {
                center();
            });

            zz.comments.on_close_comments(function(){
                center();
            });

            zz.comments.on_open_comments(function(){
                center();
            });

            zz.buy.on_change_buy_mode(function(){
                center();
            });

            center();

        }
    };

    zz.buy.hide_checkout_banner = function(){
        $('#checkout-banner').hide();
    };

    zz.buy.toggle_visibility_with_buy_mode = function(element){
        if(zz.buy.is_buy_mode_active()){
            $(element).hide();
        }
        else{
            $(element).show();
        }

        zz.buy.on_before_activate(function(){
            $(element).fadeOut('fast');

        });

        zz.buy.on_before_deactivate(function(){
            $(element).fadeIn('fast');

        });
    };

    zz.buy.is_buy_mode_active = function(){
        return zz.local_storage.get('zz.buy.buy_mode_active') == true;

    };

    zz.buy.activate_buy_mode = function(){

        if(!is_beta_user()){
            alert("This feature is still under construction");
            return;
        }

        zz.local_storage.set('zz.buy.current_screen', zz.local_storage.get('zz.buy.current_screen') || DRAWER_SCREENS.SELECT_PRODUCT);
        zz.local_storage.set('zz.buy.selected_photos', zz.local_storage.get('zz.buy.selected_photos') || []);


        zz.pubsub.publish(EVENTS.BEFORE_ACTIVATE);
        zz.local_storage.set('zz.buy.buy_mode_active', true);
        open_drawer(true, function(){
            zz.pubsub.publish(EVENTS.ACTIVATE);
        });

        $('#footer #buy-button').addClass('selected');

    };

    zz.buy.deactivate_buy_mode = function(){
        zz.pubsub.publish(EVENTS.BEFORE_DEACTIVATE);
        zz.local_storage.set('zz.buy.buy_mode_active', false);
        close_drawer(function(){
            zz.pubsub.publish(EVENTS.DEACTIVATE);
        });
        $('#footer #buy-button').removeClass('selected');
        $('#right-drawer .header .gray-back-button').hide();
    };



    zz.buy.add_selected_photo = function(photo_json, element, callback){

        if(!is_beta_user()){
            alert("This feature is still under construction");
            return;
        }

        if(zz.buy.is_photo_selected(photo_json.id)){
            // don't allow selecting the same photo more than once
            return;
        }

        if(photo_json.state != 'ready'){
            alert("Sorry, you can't purchase a photo until it has finished uploading.");
            return;
        }

        if(zz.buy.is_buy_mode_active() && current_screen() != DRAWER_SCREENS.CONFIGURE_PRODUCT){
            alert('Please select select a product and then add photos.');
            return;
        }


        if(element){
            var imageElement = element.find('.photo-image');

            var start_top = imageElement.offset().top;
            var start_left = imageElement.offset().left;


            var end_top;
            var end_left;

            if(!zz.buy.is_buy_mode_active()){
                end_top = $('#footer #buy-button').offset().top;
                end_left = $('#footer #buy-button').offset().left;
            }
            else{
                //figure out position of last photo in selected photo screen
                var selected_photos_section = $('.configure-product-screen .main-section .selected-photos-section .selected-photos');
                var last_selected_photo = $('.configure-product-screen .main-section .selected-photos-section .selected-photos .selected-photo:last');

                if(last_selected_photo.length == 0){
                    end_top = selected_photos_section.offset().top;
                    end_left = selected_photos_section.offset().left + 100;
                }
                else{
                    end_top = last_selected_photo.offset().top + SELECTED_PHOTO_MAX_SIZE.HEIGHT;
                    end_left = selected_photos_section.offset().left + 100;

                    var fold = selected_photos_section.offset().top + selected_photos_section.height();
                    if(end_top > fold){
                        end_top = fold - 150;
                    }

                }
            }


            var size = zz.image_utils.scale({
                                                width: imageElement.width(),
                                                height: imageElement.height()
                                            },
                                            {
                                                width:SELECTED_PHOTO_MAX_SIZE.WIDTH,
                                                height:SELECTED_PHOTO_MAX_SIZE.HEIGHT
                                            });


            imageElement.clone()
                    .css({position: 'absolute', left: start_left, top: start_top, border: '1px solid #ffffff'})
                    .appendTo('body')
                    .addClass('animate-photo-to-tray')
                    .animate({
                                 width: size.width,
                                 height: size.height,
                                 top: (end_top) + 'px',
                                 left: (end_left) + 'px'
                             },
                             500,
                             'easeInOutCubic',
                             function(){
                                $(this).remove();
                                 // todo: this needs to be refactored/cleaned up
                                 //       too much logic here.
                                 if(!zz.buy.is_buy_mode_active()){
                                     zz.buy.activate_buy_mode();
                                 }
                                 else{
                                     if(current_screen() == DRAWER_SCREENS.CONFIGURE_PRODUCT){
                                        add_photo_to_selected_photos_screen(photo_json);
                                     }
                                 }
                             }
                    );

        }


        var selected_photos = zz.local_storage.get('zz.buy.selected_photos') || [];
        selected_photos.push(photo_json);
        zz.local_storage.set('zz.buy.selected_photos', selected_photos);

        zz.pubsub.publish(EVENTS.ADD_SELECTED_PHOTO);



        // don't wait for animation to finish
        if(callback){
            callback();
        }
    };


    zz.buy.is_photo_selected = function(photo_id){
        return _.any(zz.local_storage.get('zz.buy.selected_photos'), function(photo_json){
            return photo_json.id == photo_id;
        });
    };

    zz.buy.on_before_activate = function(callback){
        zz.pubsub.subscribe(EVENTS.BEFORE_ACTIVATE, callback);
    };

    zz.buy.on_activate = function(callback){
        zz.pubsub.subscribe(EVENTS.ACTIVATE, callback);
    };

    zz.buy.on_before_deactivate = function(callback){
        zz.pubsub.subscribe(EVENTS.BEFORE_DEACTIVATE, callback);
    };

    zz.buy.on_deactivate = function(callback){
        zz.pubsub.subscribe(EVENTS.DEACTIVATE, callback);
    };

    zz.buy.on_before_change_buy_mode = function(callback){
        zz.buy.on_before_activate(callback);
        zz.buy.on_before_deactivate(callback);
    };

    zz.buy.on_change_buy_mode = function(callback){
        zz.buy.on_activate(callback);
        zz.buy.on_deactivate(callback);
    };

    zz.buy.on_remove_selected_photo = function(callback){
        zz.pubsub.subscribe(EVENTS.REMOVE_SELECTED_PHOTO, callback);
    };

    zz.buy.on_add_selected_photo = function(callback){
        zz.pubsub.subscribe(EVENTS.ADD_SELECTED_PHOTO, callback);
    };

    zz.buy.on_change_selected_photos= function(callback){
        zz.buy.on_remove_selected_photo(callback);
        zz.buy.on_add_selected_photo(callback);
    };


    function get_option_values_to_remove(selected_option_values){
        var option_values_to_remove = [];

        // loop thru the selected option values
        _.each(selected_option_values, function(option_value){

            // find all the filters that match these option values
            _.each(OPTION_FILTERS, function(option_filter){
                if(option_value.id == option_filter.id && option_value.type_id == option_filter.type_id){
                    option_values_to_remove = _.union(option_values_to_remove, option_filter.option_values_to_remove);
                }
            });
        });

        return option_values_to_remove;
    }

    function render_select_product_screen(){
        show_scrim();

        set_drawer_title("Choose a Product");


        zz.routes.store.get_products(function(products){

            var screen_element = buy_screens_element.find('.select-product-screen');
            screen_element.empty();

            _.each(products, function(product){
                var product_element = $(PRODUCT_TEMPLATE());
                product_element.find('.image').attr('src', product.image_url);
                product_element.find('.name').text(product.name);
                product_element.find('.description').text(product.description);
                product_element.find('.learn-more').click(function(event){
                    show_glamour_page(null);
                    event.stopPropagation();
                });
                screen_element.append(product_element);
                product_element.click(function(){
                    set_selected_product(product);
                    slide_to_screen(DRAWER_SCREENS.CONFIGURE_PRODUCT, true);
                });
            });

        });
    }



    function render_configure_product_screen(){
        hide_scrim();

        //header section

        set_drawer_title(get_selected_product().name);


        $('#right-drawer .header .gray-back-button').unbind('click').click(function(){
            slide_to_screen(DRAWER_SCREENS.SELECT_PRODUCT, true);
        });


        buy_screens_element.find('.configure-product-screen .product-summary-section .checkout-button').unbind('click').click(function(){
            if(get_selected_photos().length == 0){
                alert("Please select one or more photos for this product.");
                return;
            }

            if(has_bad_photos()){
                alert('One or more photos are not large enough for this product. Please remove the photos or select a different product.')
                return;
            }


            // remove click handler to prevent multiple clicks
            buy_screens_element.find('.configure-product-screen .product-summary-section .checkout-button').unbind('click');

            // add the photos and go to the cart
            var dialog = zz.dialog.show_progress_dialog('Adding to cart...');
            add_selected_photos_to_cart(function(){
                zz.routes.store.goto_cart();
            });
        });



        // build the product configuration options
        var options_element = buy_screens_element.find('.configure-product-screen .main-section .options');
        options_element.empty();

        var resolve_selected_variant = function(){
            var current_product = get_selected_product();

            // figure ou the selected options
            var selected_option_values = _.map(options_element.find('.drop-down option:selected'), function(option_element){
                return $(option_element).data('value');
            });


            if(selected_option_values.length == 0){
                // for some reason, the first time in, IE9 won't have any values at this point, so we need to just grab the first ones

                selected_option_values = _.map(options_element.find('.drop-down'), function(drop_down_element){
                    return $(drop_down_element).find('option:first').data('value');
                });
            }


            // find variant that matches all the selected options
            var current_variant =_.detect(current_product.variants, function(variant){
                return _.all(variant.values, function(value){
                    return _.detect(selected_option_values, function(selected_option_value){
                         return value.type_id == selected_option_value.type_id && value.id == selected_option_value.id;
                    });
                });
            });

            set_selected_variant(current_variant);


            if(current_variant){
                buy_screens_element.find('.configure-product-screen .product-summary-section .image').attr('src', current_variant.image_url);
                buy_screens_element.find('.configure-product-screen .product-summary-section .description').text(current_variant.description);
                buy_screens_element.find('.configure-product-screen .options-section .price .value').text(current_variant.price);
                update_price_and_count();
            }
            else{
                buy_screens_element.find('.configure-product-screen .product-summary-section .image').attr('src', '');
                buy_screens_element.find('.configure-product-screen .product-summary-section .description').text('!!ERROR!!');
                buy_screens_element.find('.configure-product-screen .product-summary-section .count-and-price').text('!!ERROR!!');
                buy_screens_element.find('.configure-product-screen .options-section .price .value').text('!!ERROR!!');
            }
        };



        var on_change_option = function(set_to_current_variant){
            var selected_option_values = null;

            if(set_to_current_variant && get_selected_variant()){
                selected_option_values = get_selected_variant().values;
            }
            else{
                selected_option_values = _.map(options_element.find('.drop-down option:selected'), function(option_element){
                    return $(option_element).data('value');
                });
            }

            var option_values_to_remove = get_option_values_to_remove(selected_option_values);

            var should_remove_option_value = function(option_value){
                if(option_values_to_remove){
                    return _.detect(option_values_to_remove, function(option_value_to_remove){
                        return (option_value.type_id == option_value_to_remove.type_id && option_value.id == option_value_to_remove.id);
                    });
                }
                else{
                    return false;
                }
            };

            options_element.empty();

            _.each(get_selected_product().options, function(option){
                var option_element = $(PRODUCT_OPTION_TEMPLATE());
                option_element.find('.label').text(option.name);
                option_element.change(function(){
                    // hack: need to run this one time for each option
                    //       so that we capture all the cases where dependent
                    //       options need to be shown or removed
                    on_change_option();
                    on_change_option();
                    on_change_option();
                    check_bad_photos();
                });

                var has_values = false;
                _.each(option.values, function(value){
                    if(!should_remove_option_value(value)){
                        has_values = true;
                        var value_element = $('<option>' + value.name + '</option>');
                        value_element.data('value', value); // hang onto this for later
                        option_element.find('.drop-down').append(value_element);

                        _.detect(selected_option_values, function(selected_option_value){
                            if(_.isEqual(value, selected_option_value)){
                                value_element.attr('selected', true);
                                return true;
                            }
                        });
                    }
                });

                if(has_values){
                    options_element.append(option_element);
                }
            });

            resolve_selected_variant();
        };




        buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .clear-all-photos').unbind('click').click(function(){
            var selected_photos = zz.local_storage.get('zz.buy.selected_photos');
            zz.local_storage.set('zz.buy.selected_photos',[]);
            refresh_selected_photos_list();
            zz.pubsub.publish(EVENTS.REMOVE_SELECTED_PHOTO, selected_photos);
            update_price_and_count();
            check_bad_photos();

        });


        if(zz.page.album_id){
            buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .add-all-photos').show().unbind('click').click(function(){
                zz.routes.photos.get_album_photos_json(zz.page.album_id, zz.page.cache_version_key, function(photos){
                    _.each(photos, function(photo){
                        if(photo.state == 'ready'){
                            zz.buy.add_selected_photo(photo);
                        }
                    });
                    refresh_selected_photos_list();
                });
            });
        }


        // hack: need to run this one time for each option
        //       so that we capture all the cases where dependent
        //       options need to be shown or removed
        on_change_option(true);
        on_change_option();
        on_change_option();


        refresh_selected_photos_list();

        check_bad_photos();

    }

    function refresh_selected_photos_list(){
        var selected_photos = zz.local_storage.get('zz.buy.selected_photos');

        var photo_list_element = buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .selected-photos');
        photo_list_element.empty();

        if(selected_photos && selected_photos.length > 0){
            _.each(selected_photos, function(photo_json){
                 add_photo_to_selected_photos_screen(photo_json);
             });
        }

        check_empty_photo_list();
    }

    function check_empty_photo_list(){
        var selected_photos = zz.local_storage.get('zz.buy.selected_photos');

        if(selected_photos && selected_photos.length == 0){
            buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .add-photos-message').show();
            buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .clear-all-photos').hide();
        }
    }

    function update_price_and_count(){
           var count = get_selected_photos().length;
           var price = parseFloat(get_selected_variant().price.substring(1));
           var count_and_price = count + ' for $' + format_currency(count * price);
           $('.configure-product-screen .product-summary-section .count-and-price').text(count_and_price);

    }

    function format_currency(amount){
        var i = parseFloat(amount);
        if(isNaN(i)) { i = 0.00; }
        var minus = '';
        if(i < 0) { minus = '-'; }
        i = Math.abs(i);
        i = parseInt((i + .005) * 100);
        i = i / 100;
        var s = new String(i);
        if(s.indexOf('.') < 0) { s += '.00'; }
        if(s.indexOf('.') == (s.length - 2)) { s += '0'; }
        s = minus + s;
        return s;
    }

    function add_photo_to_selected_photos_screen(photo_json){
        var photo_list_element = buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .selected-photos');

        var photo_element = $(SELECTED_PHOTO_TEMPLATE());
        photo_element.addClass('photo-id-' + photo_json.id);


        var size = zz.image_utils.scale({
                                            width: 100 * photo_json.aspect_ratio,
                                            height: 100
                                         },
                                         {
                                             width:SELECTED_PHOTO_MAX_SIZE.WIDTH,
                                             height:SELECTED_PHOTO_MAX_SIZE.HEIGHT
                                         });



        photo_element.find('.photo-image').attr('src', photo_json.thumb_url)
                                          .css({width: size.width, height: size.height});


        photo_element.find('.photo-delete-button').click(function(){
            photo_element.fadeOut('fast', function(){
                photo_element.remove();
                check_bad_photos();
            });
            var selected_photos = zz.local_storage.get('zz.buy.selected_photos');
            selected_photos = _.reject(selected_photos, function(selected_photo){
                return photo_json.id == selected_photo.id;
            });
            zz.local_storage.set('zz.buy.selected_photos', selected_photos);
            zz.pubsub.publish(EVENTS.REMOVE_SELECTED_PHOTO, [photo_json.id]);
            update_price_and_count();
            check_empty_photo_list();
        });

        photo_list_element.append(photo_element);

        buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .add-photos-message').hide();
        buy_screens_element.find('.configure-product-screen .main-section .selected-photos-section .clear-all-photos').show();

        update_price_and_count();
        check_bad_photos();
    }


    function show_scrim(){
        var scrim = $(SCRIM_TEMPLATE());
        $('body').append(scrim);
        $('.buy-drawer-scrim .message ').center_x();
        scrim.show();
    }

    function hide_scrim(){
        $('.buy-drawer-scrim').remove();
    }

    function set_drawer_title(title){
        $('#right-drawer .header .title').html(title);
    }

    function set_selected_product(product){
        zz.local_storage.set('zz.buy.selected_product', product);
    }

    function get_selected_product(){
        return zz.local_storage.get('zz.buy.selected_product');
    }

    function set_selected_variant(variant){
        zz.local_storage.set('zz.buy.selected_variant', variant);
    }

    function get_selected_variant(){
        return zz.local_storage.get('zz.buy.selected_variant');
    }

    function get_selected_photos(){
        return zz.local_storage.get('zz.buy.selected_photos') || [];
    }

    function set_selected_photos(photos){
        zz.local_storage.set('zz.buy.selected_photos', photos);
    }


    function add_selected_photos_to_cart(callback){
        var sku = get_selected_variant().sku;
        var product_id = get_selected_product().id;
        var photo_ids = [];
        _.each(zz.local_storage.get('zz.buy.selected_photos'), function(photo){
            photo_ids.push(photo.id);
        });

        zz.routes.store.add_to_cart(product_id, sku, photo_ids, function(){
            zz.local_storage.set('zz.buy.selected_photos',[]);
            zz.local_storage.set('zz.buy.current_screen', null);

            if(callback){
                callback();
            }
        }, function(){
            alert('Sorry, there was an error adding items to your cart');
        });
    }


    function slide_to_screen(name, animate, title, callback){
        var left;

        if(animate){
            $('#right-drawer .header .title').hide();
            $('#right-drawer .header .gray-back-button').hide();
        }

        switch (name){
            case DRAWER_SCREENS.SELECT_PRODUCT:
                left = '0px';
                render_select_product_screen();
                break;
            case DRAWER_SCREENS.CONFIGURE_PRODUCT:
                left = '-381px';
                render_configure_product_screen();
                break;
        }

        zz.local_storage.set('zz.buy.current_screen', name);

        if(animate){
            buy_screens_element.animate({left:left},500, function(){
                $('#right-drawer .header .title').fadeIn('fast');
                if(name == DRAWER_SCREENS.CONFIGURE_PRODUCT){
                    $('#right-drawer .header .gray-back-button').fadeIn('fast');  //todo: this should be managed somewher else
                }
                if(callback) callback();
            });
        }
        else{
            buy_screens_element.css({left:left});
            if(name == DRAWER_SCREENS.CONFIGURE_PRODUCT){
                $('#right-drawer .header .gray-back-button').show(); //todo: this should be managed somewher else
            }
            if(callback) callback();

       }

    }

    function current_screen(){
        return zz.local_storage.get('zz.buy.current_screen') || DRAWER_SCREENS.SELECT_PRODUCT;
    }

    function open_drawer(animate, callback){

        buy_screens_element = $(BUY_SCREENS_TEMPLATE());

        $('#right-drawer .content').html(buy_screens_element);

        $('#right-drawer .header .close-button').unbind('click').click(function(){
            $('#footer #buy-button').click(); //todo: hack -- should be better way to wire these together
        });

        if(animate){
            $('#article').fadeOut('fast', function(){

                $('#right-drawer').show().animate({right:0},500, function(){
                    $('#article').css({right:381});
                    $('#article').show();
                    callback();
                });
            });
        }
        else{
            $('#article').css({right:381});
            $('#article').show();

            $('#right-drawer').css({right:0}).show();


            callback();
        }

        slide_to_screen(current_screen(), false);

    }

    function close_drawer(callback){
        hide_scrim();
        $('#article').fadeOut('fast', function(){
            $('#right-drawer').animate({right:-450},500, function(){
                $('#article').css({right:0});
                $('#article').show();
                $('#right-drawer').hide();
                callback();
            });
        });
    }


    function show_glamour_page(product_id){
        zz.dialog.show_square_dialog('glamour page', {width:640, height:480});
    }

    function is_beta_user(){
        return _.detect(BETA_USERS, function(name){
            return (zz.session.current_user_name == name);
        });
    }

    function check_bad_photos(){
        var min_width = get_selected_variant().min_photo_width;
        var min_height = get_selected_variant().min_photo_height;
        var bad_photos = false;

        _.each(get_selected_photos(), function(photo){
            var selector = '.buy-screens .configure-product-screen .main-section .selected-photos-section .selected-photos .selected-photo.photo-id-' + photo.id;

            if(Math.min(photo.width, photo.height) < Math.min(min_width, min_height) || Math.max(photo.width, photo.height) < Math.max(min_width, min_height)){
                bad_photos = true;
                $(selector).addClass('bad-size');
            }
            else{
                $(selector).removeClass('bad-size');
            }

        });

        if(bad_photos){
            $('.buy-screens .configure-product-screen').addClass('bad-photos');
        }
        else{
            $('.buy-screens .configure-product-screen').removeClass('bad-photos');
        }

        _.defer(function(){
            $('.buy-screens .configure-product-screen .main-section .selected-photos-section .selected-photos .selected-photo.bad-size .photo-border .error-icon').center_xy();;
        });

    }

    function has_bad_photos(){
        return $('.buy-screens .configure-product-screen.bad-photos').length > 0;
    }



})();