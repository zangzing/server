(function( $, undefined ) {

    $.widget( "ui.zz_photo", {
        options: {
            allowDelete: false,
            onDelete:jQuery.noop,
            allowRename: false,
            onRename:jQuery.noop,
            maxHeight:120,
            maxWidth:120,
            caption:null,
            allowEditCaption:false,
            onChangeCaption:jQuery.noop,
            src:null,
            previewSrc:null,
            scrollContainer:null,
            lazyLoadThreshold:0,
            onClick:jQuery.noop
        },

        _create: function() {
            var self = this;

            var html = '';

            html += '<div class="photo-droppable"><div class="photo-droppable-marker"></div></div>'
            html += '<div class="photo-border">'
            html += '<img class="photo-image" src="/images/bg-blk-75.png">';
            html += '<img class="photo-delete-button" src="/images/btn-delete-photo.png">';
            html += '<div class="photo-caption">' + self.options.caption +'</div>';
            html += '</div>';

            this.element.html(html);

            self.borderElement = self.element.find('.photo-border');
            self.droppableElement = self.element.find('.photo-droppable');
            self.droppableMarkerElement = self.element.find('.photo-droppable-marker');
            self.imageElement = self.element.find('.photo-image');
            self.captionElement = self.element.find('.photo-caption');
            self.deleteButtonElement = self.element.find('.photo-delete-button');


            self.imageElement.css({
                width: self.options.maxWidth,
                height: self.options.maxHeight
            });





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





            var wrapperWidth = self.options.maxWidth + 10;
            var wrapperHeight = self.options.maxHeight + 10;

//            self.borderElement.css({
//                position: "relative",
//                top: (this.element.height() - wrapperWidth) / 2,
//                left: (this.element.width() - wrapperHeight) / 2,
//                width: wrapperWidth,
//                height: wrapperHeight
//            })


            self.borderElement.css({
                position: "relative",
                top: (parseInt(self.element.css('height')) - wrapperHeight) / 2,
                left: (parseInt(self.element.css('width')) - wrapperWidth) / 2,
                width: wrapperWidth,
                height: wrapperHeight
            });


            self.droppableElement.css({
                top: (parseInt(this.element.css('height')) - Math.floor(self.options.maxHeight * .75) ) / 2,
                height: Math.floor(self.options.maxHeight * .75),
                width: Math.floor(self.options.maxHeight * .5),
                left: -1* Math.floor(self.options.maxHeight * .5)/2 
            });




            self.loadIfVisible();

            //bind lazy loader to scroll container
            //todo: may want to have delegate handle the timer so we don't have lots and lots of timers running
            if(self.options.scrollContainer){
                var timer;
                $(self.options.scrollContainer).scroll(function(){
                    clearTimeout(timer);
                    if(self._inLazyLoadRegion()){
                        timer = setTimeout(function(){
                            self._loadImage();
                        },100);
                    }
                });
            }






            //draggable
            this.borderElement.draggable({
                start: function(){
                    $(this).css({'z-index':1000});
                },
                stop: function(){
                    //clear droppable targets
                    $('.photo-droppable-marker').hide();

                },
                revert: true,
                revertDuration:400,
                zIndex: 2700,
                opacity:0.25
            });

            //droppable
            this.droppableElement.droppable({
                tolerance: 'pointer',

                over: function(event){
//                    self.droppableMarkerElement.show();
                    self.element.animate({
                        'margin-left':'20px',
                        'margin-right':'-20px'
                    },100);
                    self.element.prev().animate({
                        'margin-left':'-20px',
                        'margin-right':'20px'
                    },100)
                },
                out: function(){
//                    self.droppableMarkerElement.hide();
                    self.element.animate({
                        'margin-left':'0px',
                        'margin-right':'0px'
                    },100);
                    self.element.prev().animate({
                        'margin-left':'0px',
                        'margin-right':'0px'
                    },100)

                },


                drop: function(event, ui){
//                    $('.photo-droppable-marker').hide();

                    self.element.animate({
                        'margin-left':'0px',
                        'margin-right':'0px'
                    },100);
                    self.element.prev().animate({
                        'margin-left':'0px',
                        'margin-right':'0px'
                    },100)


                    var droppedPhotoContainer = ui.draggable.parent().data().zz_photo.element;
                    if(droppedPhotoContainer !== self){
                        var width = droppedPhotoContainer.width();
                        var clone = droppedPhotoContainer.clone();

                        droppedPhotoContainer.children().hide();
                        droppedPhotoContainer.css({width:'0px'})

                        clone.insertBefore(droppedPhotoContainer);


                        droppedPhotoContainer.insertBefore(self.element);
                        droppedPhotoContainer.animate({width: width},500, function(){
                            droppedPhotoContainer.children().fadeIn('fast');
                        });

                        clone.animate({width: 0},500, function(){
                            clone.remove();
                        });


                    }
                }

            });

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
                            })
                        });
                    }
                });
            };


            //edit caption
            var isEditingCaption = false;
            if(self.options.allowEditCaption){
                self.captionElement.click(function(event){
                    self.editCaption();
                });
            }
        },

        loadIfVisible: function(){
            var self = this;
            if(self._inLazyLoadRegion()){
                self._loadImage();
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


                self.borderElement.css({
                    position: "relative",
                    top: (parseInt(self.element.css('height')) - wrapperHeight) / 2,
                    left: (parseInt(self.element.css('width')) - wrapperWidth) / 2,
                    width: wrapperWidth,
                    height: wrapperHeight
                });

                //show the small version
                self.imageElement.attr("src", initialSrc);

                //show the full version
                self.imageElement.attr("src", self.options.src);

            };

            self.imageObject.src = initialSrc;
        },


        _inLazyLoadRegion: function(){
            return (!this._belowView(this.element, this.options.scrollContainer,this.options.lazyLoadThreshold) &&
                    !this._rightOfView(this.element, this.options.scrollContainer,this.options.lazyLoadThreshold) &&
                    !this._aboveView(this.element, this.options.scrollContainer,this.options.lazyLoadThreshold) &&
                    !this._leftOfView(this.element, this.options.scrollContainer,this.options.lazyLoadThreshold)
                    );



        },

        _belowView : function(element, container, threshold) {
            if (container === undefined || container === window) {
                var fold = $(window).height() + $(window).scrollTop();
            } else {
                var fold = $(container).offset().top + $(container).height();
            }
            return fold <= $(element).offset().top - threshold;
        },

        _rightOfView : function(element, container, threshold) {
            if (container === undefined || container === window) {
                var fold = $(window).width() + $(window).scrollLeft();
            } else {
                var fold = $(container).offset().left + $(container).width();
            }
            return fold <= $(element).offset().left - threshold;
        },

        _aboveView : function(element, container, threshold) {
            if (container === undefined || container === window) {
                var fold = $(window).scrollTop();
            } else {
                var fold = $(container).offset().top;
            }
            return fold >= $(element).offset().top + threshold  + $(element).height();
        },

        _leftOfView : function(element, container, threshold) {
            if (container === undefined || container === window) {
                var fold = $(window).scrollLeft();
            } else {
                var fold = $(container).offset().left;
            }
            return fold >= $(element).offset().left + threshold + $(element).width();
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

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );