var image_utils = {

    // returns object with 'height' and 'width'
    scale: function(image_dimensions, target_dimensions){
        var scale = Math.min( target_dimensions.width / image_dimensions.width, target_dimensions.height / image_dimensions.height);


        return {
            width:  Math.floor(image_dimensions.width * scale),
            height: Math.floor(image_dimensions.height * scale)
        }
    },

    




    // returns object with 'top', 'left', 'height', width'
    scale_center_and_crop: function(image_dimensions, target_dimensions){

    },

    /**
     *
     * @param src
     * @param success (optional)
     * @param error (optional)
     */

    pre_load_image: function(src, success, error){


        var image = new Image();

        image.onload = function(){
            if(_.isFunction(success)){
                success(image);
            }
        };

        image.onerror = function(){
            if(_.isFunction(error))
            error(image);
        };


        image.src = src;

        return image;
    }

}