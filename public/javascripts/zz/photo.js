/*!
 * photo.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
(function( $, undefined ) {

    $.widget( "ui.zz_photo", {
        options: {
            allowDelete: false,
            onDelete:jQuery.noop,
            maxHeight:120,
            maxWidth:120,
            caption:null,
            allowEditCaption:false,
            onChangeCaption:jQuery.noop,
            src:null,
            previewSrc:null,
            scrollContainer:null,
            lazyLoadThreshold:0,
            onClick:jQuery.noop,
            photoId:null,
            aspectRatio:0
        },

        _create: function() {
            var self = this;

            if(self.options.scrollContainer.data().zz_photogrid){
                self.photoGrid = self.options.scrollContainer.data().zz_photogrid;
            }


            var html = '';

            html += '<div class="photo-border">'
            html += '<img class="photo-image" src="/images/photo_placeholder.png">';
            html += '<img class="photo-delete-button" src="/images/btn-delete-photo.png">';
            html += '<div class="photo-caption">' + self.options.caption +'</div>';
            html += '</div>';

            $(html).appendTo(this.element);

            self.borderElement = self.element.find('.photo-border');
            self.imageElement = self.element.find('.photo-image');
            self.captionElement = self.element.find('.photo-caption');
            self.deleteButtonElement = self.element.find('.photo-delete-button');





            if(self.options.aspectRatio){
                var srcWidth =  1 * self.options.aspectRatio;
                var srcHeight = 1;
                var scale = Math.min( self.options.maxWidth / srcWidth, self.options.maxHeight / srcHeight)

                var initialWidth = srcWidth * scale;
                var initialHeight = srcHeight * scale;
            }
            else{
                var initialWidth = Math.min(self.options.maxWidth, self.options.maxHeight);
                var initialHeight = initialWidth;
            }




            self.imageElement.css({
                width: initialWidth,
                height: initialHeight
            });


            //element is probably invisible at this point, so we need to check the css attributes
            self.width = parseInt(self.element.css('width'));
            self.height = parseInt(self.element.css('height'));



            //click
            self.imageElement.mousedown(function(mouseDownEvent){
                var mouseUpHandler = function(mouseUpEvent){
                    if(mouseDownEvent.pageX === mouseUpEvent.pageX && mouseDownEvent.pageY === mouseUpEvent.pageY){
                        self.options.onClick(mouseUpEvent);
                    }
                    self.imageElement.unbind('mouseup', mouseUpHandler);
                };
                self.imageElement.mouseup(mouseUpHandler);

            });





            var wrapperWidth = initialWidth + 10;
            var wrapperHeight = initialHeight + 10;



            self.borderElement.css({
                position: "relative",
                top: (self.height - wrapperHeight) / 2,
                left: (self.width - wrapperWidth) / 2,
                width: wrapperWidth,
                height: wrapperHeight
            });




/*
            //bind lazy loader to scroll container
            //todo: may want to have delegate handle the timer so we don't have lots and lots of timers running (and scroll event handlers)
            self.imageLoaded = false;
            if(self.options.scrollContainer){
                var timer = null;
                $(self.options.scrollContainer).scroll(function(){
                    if(!self.imageLoaded){
                        if(timer){
                            clearTimeout(timer);
                        }
                        if(self._inLazyLoadRegion()){
                            timer = setTimeout(function(){
                                self._loadImage();
                            },100);
                        }
                    }
                });
            }

*/

            //uploading glyph

            //delete
            if(self.options.allowDelete){
                self.deleteButtonElement.click(function(){
                    if(self.options.onDelete()){
                        self.captionElement.hide();
                        self.deleteButtonElement.hide();
                        self.borderElement.hide("scale", {}, 300, function(){
                            self.element.animate({width:0},500, function(){
                                self.element.remove();

                                if(self.photoGrid){
                                    self.photoGrid.resetLayout();
                                }

                            })
                        });
                    }
                });
            }
            else{
                self.deleteButtonElement.remove();   
            }


            //edit caption
            var isEditingCaption = false;
            if(self.options.allowEditCaption){
                self.captionElement.click(function(event){
                    self.editCaption();
                });
            }
        },

        loadIfVisible: function(containerDimensions){
            var self = this;
            if(!self.imageLoaded){
                if(self._inLazyLoadRegion(containerDimensions)){
                    self._loadImage();
                }
            }
        },


        _loadImage : function(){
            var self = this;

            var initialSrc = self.options.src;

            if(self.options.previewSrc){
                initialSrc= self.options.previewSrc;
            }


            self.imageObject = new Image();

            self.imageObject.onload = function(){

                self.imageLoaded = true;
                self._resize(1);

                //show the small version
                self.imageElement.attr("src", initialSrc);

                //show the full version
                self.imageElement.attr("src", self.options.src);


//                self.element.mouseover(function(){
//                    self._resize(1.15);
//                    self.element.css({'z-index':1000});
//                });
//
//                self.element.mouseout(function(){
//                    self._resize(1);
//                    self.element.css({'z-index':-1});
//                })
           };


            self.imageObject.src = initialSrc;
        },

        _resize: function(percent){
            var self = this;

            var scale = Math.min(self.options.maxWidth/self.imageObject.width, self.options.maxHeight/self.imageObject.height);
            var width = Math.floor(self.imageObject.width * scale);
            var height = Math.floor(self.imageObject.height * scale);

            var wrapperWidth = width + 10;
            var wrapperHeight = height + 10;


            self.borderElement.css({
                top: (self.height - wrapperHeight) / 2,
                left: (self.width - wrapperWidth) / 2,
                width: wrapperWidth,
                height: wrapperHeight
            });

            self.imageElement.css({
                width: width,
                height: height
            });



        },




        _inLazyLoadRegion: function(containerDimensions /*optional param with container dimensions */){
            var container = this.options.scrollContainer;
            var threshold = this.options.lazyLoadThreshold;

            if(containerDimensions){
                var containerOffset = containerDimensions.offset;
                var containerHeight = containerDimensions.height;
                var containerWidth = containerDimensions.width;
            }
            else{
                var containerOffset = $(container).offset();
                var containerHeight = $(container).height();
                var containerWidth = $(container).width();
            }



            var elementOffset = $(this.element).offset(); //todo: expensive call. cache/pass-in if possible; maybe can cache after grid resize
            var elementWidth =  this.options.maxWidth;
            var elementHeight = this.options.maxHeight; 

            if (container === undefined || container === window) {
                var foldBottom = $(window).height() + $(window).scrollTop();
                var foldRight =  $(window).width() + $(window).scrollLeft();
                var foldTop =    $(window).scrollTop();
                var foldLeft =   $(window).scrollLeft();
            } else {
                var foldBottom = containerOffset.top + containerHeight;
                var foldRight =  containerOffset.left + containerWidth;
                var foldTop =    containerOffset.top;
                var foldLeft =   containerOffset.left;
            }


            var left =  (foldLeft >= elementOffset.left + threshold + elementWidth);
            var above = (foldTop >= elementOffset.top + threshold  + elementHeight);
            var right = (foldRight <= elementOffset.left - threshold);
            var below = (foldBottom <= elementOffset.top - threshold);

            return (!left) && (!right) && (!above) && (!below);



        },

        editCaption: function(){
            var self = this;

            if(!self.isEditingCaption){
                self.isEditingCaption = true;

                var textBoxElement = $('<input type="text">');
                self.captionElement.html(textBoxElement);

                textBoxElement.val(self.options.caption);
                textBoxElement.focus();
                textBoxElement.select();

                textBoxElement.blur(function(){
                    var newCaption = textBoxElement.val()
                    if(newCaption !== self.options.caption){
                        self.options.caption = newCaption
                        self.options.onChangeCaption(newCaption);
                    }
                    self.captionElement.html(newCaption);
                    self.isEditingCaption = false;

                });

                textBoxElement.keydown(function(event){


                    if (event.which == 13) {  //enter key
                        textBoxElement.blur();
                        return false;
                    }
                    else if(event.which == 9){ //tab key
                        if(event.shiftKey){
                            textBoxElement.blur();

                            if(self.element.prev().length !== 0){
                                self.element.prev().data().zz_photo.editCaption();
                            }
                            else{
                                self.element.parent().children().last().data().zz_photo.editCaption();
                            }
                        }
                        else{
                            textBoxElement.blur();
                            if(self.element.next().length !== 0){
                                self.element.next().data().zz_photo.editCaption();
                            }
                            else{
                                self.element.parent().children().first().data().zz_photo.editCaption();
                            }
                        }
                        event.stopPropagation();
                        return false;
                    }
                });
            }

        },

        dragStart: function(){
            this.element.addClass('dragging');
        },

        dragEnd: function(){
            this.element.removeClass('dragging');
        },

        dragHelper: function(){
            var helper = this.element.clone();
            helper.find('.photo-delete-button').hide();
            return helper;
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );