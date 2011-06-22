var profile_pictures = {

    init_profile_pictures: function(elements){
        _.each(elements, function(element){
            var profile_element = $(element);
            var img_element = profile_element.find('img');
            var profile_pic_url = img_element.attr('data-src');
            if(profile_pic_url){
                image_utils.pre_load_image(profile_pic_url, function(image){
                    var css = image_utils.scale_center_and_crop(image, {width: profile_element.width(), height: profile_element.height()});
                    img_element.css(css);
                    img_element.attr('src', profile_pic_url);

                });
            }
        });
    }
};