(function( $, undefined ) {

    $.widget( "ui.zz_photo", {
        options: {
            allowDelete: false,
            onDelete:jQuery.noop,
            allowRename: false,
            onRename:jQuery.noop,
            maxHeight:100,
            maxWidth:100,
            caption:null,
            src:null,
            rolloverSrc:null
        },

        _create: function() {
            var self = this;

            var html = '';
            html += '<div class="photo-wrapper">'
            html += '<img class="photo-image" src="/images/bg-blk-75.png">';

            if(self.options.allowDelete){
                html += '<img class="photo-delete-button" src="/images/btn-delete-photo.png">';
            }
            html += '<div class="photo-caption">' + self.options.caption +'</div>'; 
            html += '</div>';
            
            self.wrapperElement = $(html);
            self.imageElement = self.wrapperElement.find('img.photo-image');

            self.imageElement.css({
                width: self.options.maxWidth,
                height: self.options.maxHeight,
            });


            var wrapperWidth = self.options.maxWidth + 10;
            var wrapperHeight = self.options.maxHeight + 10;

            self.wrapperElement.css({
                position: "relative",
                top: (this.element.height() - wrapperWidth) / 2,
                left: (this.element.width() - wrapperHeight) / 2,
                width: wrapperWidth,
                height: wrapperHeight
            })


            self.wrapperElement.appendTo(this.element);

            self.imageObject = new Image();
            self.imageObject.onload = function(){

                var height;
                var width;

                if(self.imageObject.width >= self.imageObject.height){
                    width = self.options.maxWidth;
                    height = self.imageObject.height * (self.options.maxWidth / self.imageObject.width);
                }
                else{
                    width = self.imageObject.width * (self.options.maxHeight / self.imageObject.height);
                    height = self.options.maxHeight;

                }

                self.imageElement.css({
                    width: width,
                    height: height
                });


                var wrapperWidth = width + 10;
                var wrapperHeight = height + 10;

                self.wrapperElement.css({
                    position: "relative",
                    top: (self.element.height() - wrapperHeight) / 2,
                    left: (self.element.width() - wrapperWidth) / 2,
                    width: wrapperWidth,
                    height: wrapperHeight
                });

                self.imageElement.attr("src",self.options.src);




            };

            self.imageObject.src = self.options.src;








        },




        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );