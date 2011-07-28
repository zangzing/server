class SpreeZangzingHooks < Spree::ThemeSupport::HookListener
    remove :product_images
    insert_before :inside_product_cart_form, 'products/line_item_photo_data'
    insert_after :cart_item_description, 'orders/line_item_photo_data'
    replace :cart_item_image, 'orders/line_item_image'
end