class SpreeZangzingHooks < Spree::ThemeSupport::HookListener
    remove :product_images
    insert_after :cart_item_description, 'orders/line_item_photo'
    replace :cart_item_image, 'orders/line_item_image'
end