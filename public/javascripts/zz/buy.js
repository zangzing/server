var zz = zz || {};
zz.buy = zz.buy || {};

(function(){

    var DRAWER_SCREENS = {
        SELECT_PRODUCT: 'select_product',
        CONFIGURE_PRODUCT: 'configure_product',
        SELECT_PHOTOS: 'select_photos'
    };



    var EVENTS = {
        BEFORE_ACTIVATE: 'zz.buy.before_activate',
        ACTIVATE: 'zz.buy.activate',
        BEFORE_DEACTIVATE: 'zz.buy.before_deactivate',
        DEACTIVATE: 'zz.buy.deactivate'
    };


    var buy_screens_element = null;

    var BUY_SCREENS_TEMPLATE = function(){
        return '<div class="buy-screens">' +
                    '<div class="select-product-screen"></div>' +
                    '<div class="configure-product-screen">' +
                        '<div class="main-section">' +
                            '<img class="image" src="/images/photo_placeholder.png">' +
                            '<div class="learn-more">Learn More</div>' +
                            '<div class="options">' +
                            '</div>' +
                        '</div>' +
                        '<div class="footer-section">' +
                            '<img class="image" src="/images/photo_placeholder.png">' +
                            '<div class="product">Modern Framed Poster Print</div>' +
                            '<div class="variant">12x23 Framed Matte</div>' +
                            '<div class="price">Price <span class="value">$200.94</span></div>' +
                            '<a class="gray-button back"><span>Back</span></a>'+
                            '<a class="next-button next"><span>Next: Choose Photos</span></a>'+
                        '</div>' +
                    '</div>' +
                    '<div class="select-photos-screen">' +
                        '<div class="main-section">' +
                            '<div class="add-photos-message">Browse your photos and click on each one you would like for this product.</div>' +
                            '<a class="clear-all-photos hyperlink-button">Clear All Selected Photos</a>' +
                            '<div class="selected-photos"></div>' +
                        '</div>' +
                        '<div class="footer-section">' +
                            '<img class="image" src="/images/photo_placeholder.png">' +
                            '<div class="product">Modern Framed Poster Print</div>' +
                            '<div class="variant">12x23 Framed Matte</div>' +
                            '<div class="price">Price <span class="value">$200.94</span></div>' +
                            '<a class="hyperlink-button change">Change</a>' +
                            '<a class="gray-button back"><span>Add and Buy More</span></a>'+
                            '<a class="next-button next"><span>Add to Cart & Checkout</span></a>'+
                        '</div>' +
                    '</div>' +
               '</div>';
    };

    var PRODUCT_TEMPLATE = function(){
        return '<div class="product">' +
                   '<img class="image" src="/images/photo_placeholder.png">' +
                   '<div class="name"></div>' +
                   '<div class="description"><span class="text"></span>&nbsp;<span class="learn-more">Learn more.</span></div>' +
               '</div>';
    };

    var SELECTED_PHOTO_TEMPLATE = function(){
        return '<div class="selected-photo">' +
                    '<img class="image" src="/images/photo_placeholder.png">' +
               '</div>';
    };

    var PRODUCT_OPTION_TEMPLATE = function(){
        return '<div class="option">' +
                   '<div class="label"></div>' +
                   '<select class="drop-down"></select>' +
               '</div>';
    };




    zz.buy.init = function(){
        if(zz.buy.is_buy_mode_active()){
            open_drawer(false, function(){});
            $('#footer #buy-button').addClass('selected');
        }

        $('#footer #buy-button').click(function() {
            if (! $(this).hasClass('disabled')) {
                if(zz.buy.is_buy_mode_active()){
                    zz.buy.deactivate_buy_mode();
                    $(this).removeClass('selected');
                }
                else{
                    zz.buy.activate_buy_mode();
                    $(this).addClass('selected');
                }
            }
        });



    };


    zz.buy.toggle_visibility_with_buy_mode = function(element){
        if(zz.buy.is_buy_mode_active()){
            $(element).hide();
        }

        zz.buy.on_before_activate(function(){
            $(element).fadeOut('fast');

        });

        zz.buy.on_before_deactivate(function(){
            $(element).fadeIn('fast');

        });
    };

    zz.buy.is_buy_mode_active = function(){
        return jQuery.cookie('buy_mode') == 'true';
    };

    zz.buy.activate_buy_mode = function(){

        localStorage['zz.buy.current_screen'] = localStorage['zz.buy.current_screen'] || DRAWER_SCREENS.SELECT_PRODUCT;
        localStorage['zz.buy.current_product'] = localStorage['zz.buy.zz.buy.current_product'] || {};
        localStorage['zz.buy.selected_photos'] = localStorage['zz.buy.selected_photos'] || [];



        zz.pubsub.publish(EVENTS.BEFORE_ACTIVATE);
        jQuery.cookie('buy_mode', 'true', {path:'/'});
        open_drawer(true, function(){
            zz.pubsub.publish(EVENTS.ACTIVATE);
        });
    };

    zz.buy.deactivate_buy_mode = function(){
        zz.pubsub.publish(EVENTS.BEFORE_DEACTIVATE);
        jQuery.cookie('buy_mode', 'false', {path:'/'});
        close_drawer(function(){
            zz.pubsub.publish(EVENTS.DEACTIVATE);
        });
    };

    zz.buy.select_photo = function(photo_json, element, callback){

        if(zz.buy.is_photo_selected(photo_json.id)){
            // don't allow selecting the same photo more than once
            return; 
        }

        if(zz.buy.is_buy_mode_active() && current_screen() != DRAWER_SCREENS.SELECT_PHOTOS){
            alert('Please select and configure a product and then add photos.');
            return;
        }



        var imageElement = element.find('.photo-image');

        var start_top = imageElement.offset().top;
        var start_left = imageElement.offset().left;

        var end_top = $('#footer #buy-button').offset().top;
        var end_left = $('#footer #buy-button').offset().left;



        imageElement.clone()
                .css({position: 'absolute', left: start_left, top: start_top, border: '1px solid #ffffff'})
                .appendTo('body')
                .addClass('animate-photo-to-tray')
                .animate({
                             width: '20px',
                             height: '20px',
                             top: (end_top) + 'px',
                             left: (end_left) + 'px'
                         },
                         1000,
                         'easeInOutCubic',
                         function(){
                            $(this).remove();
                         }
                );



        var selected_photos = zz.local_storage.get('zz.buy.selected_photos') || [];
        selected_photos.push(photo_json);
        zz.local_storage.set('zz.buy.selected_photos', selected_photos);

        add_photo_to_selected_photos_screen(photo_json);



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



    function render_select_product_screen(){
        set_drawer_title("Choose Product")

        zz.routes.store.get_products(function(products){

            var screen_element = buy_screens_element.find('.select-product-screen');
            screen_element.empty();

            _.each(products, function(product){
                var product_element = $(PRODUCT_TEMPLATE());
                product_element.find('.name').text(product.name);
                product_element.find('.description .text').text(product.description);
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
        set_drawer_title(get_selected_product().name + " Settings");


        buy_screens_element.find('.configure-product-screen .footer-section .back').unbind('click').click(function(){
            slide_to_screen(DRAWER_SCREENS.SELECT_PRODUCT, true);
        });

        buy_screens_element.find('.configure-product-screen .footer-section .next').unbind('click').click(function(){
            slide_to_screen(DRAWER_SCREENS.SELECT_PHOTOS, true);
        });


        var variant = get_selected_variant();


        buy_screens_element.find('.configure-product-screen .main-section .learn-more').unbind('click').click(function(){
            show_glamour_page(null);
        });

        // build the product configuration options
        var options_element = buy_screens_element.find('.configure-product-screen .main-section .options');
        options_element.empty();


        var on_change_variant = function(){
            var current_product = get_selected_product();

            var current_variant =_.detect(current_product.variants, function(variant){
                return _.all(variant.values, function(value){
                    return _.detect(options_element.find('.drop-down option:selected'), function(option_element){
                        var selected_option_value = $(option_element).data('value');
                        return value.type_id == selected_option_value.type_id && value.id == selected_option_value.id;
                    });
                });
            });

            set_selected_variant(current_variant);

            if(current_variant){
                buy_screens_element.find('.configure-product-screen .footer-section .product').text(current_product.name);
                buy_screens_element.find('.configure-product-screen .footer-section .variant').text(current_variant.name);
                buy_screens_element.find('.configure-product-screen .footer-section .price').text(current_variant.price);
            }
            else{
                alert("Sorry, there was an unexpected error: no matching variant");
            }


        };


        _.each(get_selected_product().options, function(option){
            var option_element = $(PRODUCT_OPTION_TEMPLATE());
            option_element.find('.label').text(option.name);
            option_element.change(function(){
                on_change_variant();
            });

            _.each(option.values, function(value){
                var value_element = $('<option>' + value.name + '</option>');
                value_element.data('value', value); // hang onto this for later
                option_element.find('.drop-down').append(value_element);
            });

            options_element.append(option_element);
        });
        on_change_variant();






    }

    function render_select_photos_screen(){
        set_drawer_title("Choose Photos");

        buy_screens_element.find('.select-photos-screen .footer-section .back').unbind('click').click(function(){
            add_selected_photos_to_cart(function(){
                zz.local_storage.set('zz.buy.current_screen', null);
                window.location.reload();
            });
        });

        buy_screens_element.find('.select-photos-screen .footer-section .next').unbind('click').click(function(){
            add_selected_photos_to_cart(function(){
                zz.routes.store.goto_cart();
            });
        });

        buy_screens_element.find('.select-photos-screen .footer-section .change').unbind('click').click(function(){
            slide_to_screen(DRAWER_SCREENS.CONFIGURE_PRODUCT, true);
        });


        refresh_selected_photos_list();

        buy_screens_element.find('.select-photos-screen .main-section .clear-all-photos').unbind('click').click(function(){
            zz.local_storage.set('zz.buy.selected_photos',[]);
            refresh_selected_photos_list();
        });


        buy_screens_element.find('.select-photos-screen .footer-section .product').text(get_selected_product().name);
        buy_screens_element.find('.select-photos-screen .footer-section .variant').text(get_selected_variant().name);
        buy_screens_element.find('.select-photos-screen .footer-section .price').text(get_selected_variant().price);



    }

    function refresh_selected_photos_list(){
        var selected_photos = zz.local_storage.get('zz.buy.selected_photos');

        var photo_list_element = buy_screens_element.find('.select-photos-screen .main-section .selected-photos');
        photo_list_element.empty();

        if(selected_photos && selected_photos.length > 0){
            _.each(selected_photos, function(photo_json){
                 add_photo_to_selected_photos_screen(photo_json);
             });
        }
        else{
            buy_screens_element.find('.select-photos-screen .main-section .add-photos-message').show();
            buy_screens_element.find('.select-photos-screen .main-section .clear-all-photos').hide();
        }
    }

    function add_photo_to_selected_photos_screen(photo_json){
        var photo_list_element = buy_screens_element.find('.select-photos-screen .main-section .selected-photos');

        var photo_element = $(SELECTED_PHOTO_TEMPLATE());
        photo_element.find('.image').attr('src', photo_json.thumb_url);

        photo_list_element.append(photo_element);

        buy_screens_element.find('.select-photos-screen .main-section .add-photos-message').hide();
        buy_screens_element.find('.select-photos-screen .main-section .clear-all-photos').show();
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

    function add_selected_photos_to_cart(callback){
        var sku = get_selected_variant().sku
        var photo_ids = []
        _.each(zz.local_storage.get('zz.buy.selected_photos'), function(photo){
            photo_ids.push(photo.id);
        });

        zz.routes.store.add_to_cart(sku, photo_ids, function(){
            zz.local_storage.set('zz.buy.selected_photos',[]);
            zz.local_storage.set('zz.buy.current_screen', null);

            if(callback){
                callback()
            }
        }, function(){
            alert('Sorry, there was an error adding items to your cart');
        })


    }


    function slide_to_screen(name, animate, title, callback){
        var left;

        if(animate){
            $('#right-drawer .header .title').hide();
        }

        switch (name){
            case DRAWER_SCREENS.SELECT_PRODUCT:
                left = '0px';
                render_select_product_screen();
                break;
            case DRAWER_SCREENS.CONFIGURE_PRODUCT:
                left = '-445px';
                render_configure_product_screen();
                break;
            case DRAWER_SCREENS.SELECT_PHOTOS:
                left = '-890px';

                render_select_photos_screen();
                break;
        }

        zz.local_storage.set('zz.buy.current_screen', name);

        if(animate){
            buy_screens_element.animate({left:left},500, function(){
                $('#right-drawer .header .title').fadeIn('fast');

                if(callback) callback();
            });
        }
        else{
            buy_screens_element.css({left:left});
            if(callback) callback();

       }

    }

    function current_screen(){
        return zz.local_storage.get('zz.buy.current_screen') || DRAWER_SCREENS.SELECT_PRODUCT;
    }

    function open_drawer(animate, callback){

        buy_screens_element = $(BUY_SCREENS_TEMPLATE());

        $('#right-drawer .content').html(buy_screens_element);

        $('#right-drawer .header .close-button').click(function(){
            $('#footer #buy-button').click(); //todo: hack -- should be better way to wire these together
        });

        if(animate){
            $('#article').fadeOut('fast', function(){

                $('#right-drawer').show().animate({right:0},500, function(){
                    $('#article').css({right:445});
                    $('#article').show();
                    callback();
                });
            });
        }
        else{
            $('#article').css({right:445});
            $('#article').show();

            $('#right-drawer').css({right:0}).show();


            callback();
        }

        slide_to_screen(current_screen(), false);

    }

    function close_drawer(callback){
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


})();