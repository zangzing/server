var image_utils = {

    // returns object with 'height' and 'width'
    scale: function(image_dimensions, target_dimensions){
        var scale = Math.min( target_dimensions.width / image_dimensions.width, target_dimensions.height / image_dimensions.height);


        return {
            width:  Math.floor(image_dimensions.width * scale),
            height: Math.floor(image_dimensions.height * scale)
        }
    },





    /**
     *
     * @param {object} image_dimensions height/width
     * @param {object} target_dimensions height/width
     * @return {object} with top, left, height, width attributes
     */
    scale_center_and_crop: function(image_dimensions, target_dimensions){
        var height, width, top, left;

        if(image_dimensions.width / image_dimensions.height > target_dimensions.width / target_dimensions.height){
            //image is wider than target
            height = target_dimensions.height;
            top = 0;
            width = Math.round(image_dimensions.width / image_dimensions.height * target_dimensions.height);
            left = Math.round((target_dimensions.width - width)/2);

        }
        else{
            //image is narrower than target
            width = target_dimensions.width;
            left = 0;
            height = Math.round(image_dimensions.height / image_dimensions.width * target_dimensions.width);
            top = Math.round((target_dimensions.height - height)/2);
        }

        return {
            top: top,
            left: left,
            height: height,
            width: width
        };

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
            if(success){
                success(image);
            }
        };

        image.onerror = function(){
            if(error){
                error(image);
            }
        };


        image.src = src;

        return image;
    }

};