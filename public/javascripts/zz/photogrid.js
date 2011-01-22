(function( $, undefined ) {

    $.widget( "ui.zz_photogrid", {
        options: {
            photos: [],
            cellWidth: 180,
            cellHeight: 180,

            allowDelete: false,
            onDelete:jQuery.noop,

            allowEditCaption:false,
            onChangeCaption:jQuery.noop,

            allowReorder: false,
            onChangeOrder: jQuery.noop,

            onClickPhoto: jQuery.noop,

            showThumbscroller: true,

            singlePictureMode: false,

            scrollToPhoto: null


        },

        animatedScrollActive: false,


        _create: function() {
            var self = this;

            self.width = parseInt(self.element.css('width'));
            self.height = parseInt(self.element.css('height'));


            //template for cells
            //todo: when allowReorder is 'false' don't add the drop target elements
            var template = $('<div class="photogrid-cell"><div class="photogrid-droppable"></div></div>');
            template.css({
                width: self.options.cellWidth,
                height: self.options.cellHeight
            });



            //create cells and attach photo objects
            self.element.hide();


            var droppableHeight = Math.floor(self.options.cellHeight * 0.8);
            var droppableWidth = Math.floor(self.options.cellWidth * 0.6);
            var droppableLeft = -1 * Math.floor(droppableWidth/2);
            var droppableTop = Math.floor((self.options.cellHeight - droppableHeight)/2);

            var cells = [];

            var lazyLoadThreshold = 0;
            if(self.options.singlePictureMode){
                lazyLoadThreshold = self.options.maxWidth * 3;
            }

            $.each(self.options.photos, function(index, photo){
                var cell = template.clone();
                cells.push(cell);



                cell.appendTo(self.element)

                cell.zz_photo({
                    photoId: photo.id,
                    previewSrc: photo.previewSrc,
                    src: photo.src,
                    maxWidth: Math.floor(self.options.cellWidth * .85),
                    maxHeight: Math.floor(self.options.cellHeight * .85),
                    allowDelete: self.options.allowDelete,
                    caption: photo.caption,

                    onDelete:function(){
                        return self.options.onDelete(index,photo);
                    },

                    allowEditCaption:self.options.allowEditCaption,

                    onChangeCaption:function(caption){
                        return self.options.onChangeCaption(index, photo, caption);
                    },

                    onClick: function(){
                        self.options.onClickPhoto(index, photo);
                    },

                    scrollContainer: self.element,
                    lazyLoadThreshold: lazyLoadThreshold
                    
                });


                //setup drag and drop
                if(self.options.allowReorder){
                    //todo: consider clone and add these to cloned cell template -- might be faster
                    var droppable = cell.find('.photogrid-droppable');

                    droppable.css({
                        top: droppableTop,
                        height: droppableHeight,
                        width: droppableWidth,
                        left: droppableLeft
                    });

                     //draggable
                    cell.draggable({
                        start: function(){
                            cell.data().zz_photo.dragStart();
                        },
                        stop: function(){
                            cell.data().zz_photo.dragEnd();
                        },
                        drag: function(event){

                        },
                        revert: 'invalid',
                        revertDuration:400,
                        zIndex: 2700,
                        opacity:0.50,
                        helper: function(){
                            return cell.data().zz_photo.dragHelper();
                        },
                        scroll: true,
                        scrollSensitivity: self.options.cellHeight / 2,
                        scrollSpeed:self.options.cellHeight / 3
                    });

                    var nudgeOnDragOver = Math.floor(self.options.cellWidth / 2)

                    droppable.droppable({
                        tolerance: 'pointer',
                        over: function(event, ui){
                            if(ui.draggable[0] == droppable.parent().prev()[0]){
                                return;
                            }
                            cell.rowLeft().animateRelative(-1 * nudgeOnDragOver, 0, 100);
                            cell.rowRight().add(cell).animateRelative(nudgeOnDragOver, 0, 100);
                        },

                        out: function(){
                            self.resetLayout(100);
                        },

                        drop: function(event, ui){
                            var draggedCell = ui.draggable;


                            //create clone so we have something to face out
                            var draggedCellClone = draggedCell.clone().appendTo(draggedCell.parent());
                            draggedCellClone.fadeOut(400, function(){
                                draggedCellClone.remove();
                            });


                            //move the dragged cell to the new spot
                            var droppedOnCell = droppable.parent();
                            draggedCell.insertBefore(droppedOnCell);
                            draggedCell.css({
                                top: parseInt(droppedOnCell.css('top')),
                                left: parseInt(droppedOnCell.css('left')) - self.options.cellWidth
                            });


                            self.resetLayout(800, 'easeInOutCubic');
                        }

                    });
                }

            });

            self.resetLayout();

            self.element.show();


            this.element.children('.photogrid-cell').each(function(index, element){
                $(element).data().zz_photo.loadIfVisible();
            });



            //handle window resize
            var resizeTimer = null;
            $(window).resize(function(event){
                if(resizeTimer){
                    clearTimeout(resizeTimer);
                    resizeTimer = null;
                }

                resizeTimer = setTimeout(function(){
                    self.width = parseInt(self.element.css('width'));
                    self.height = parseInt(self.element.css('height'));

                    self.resetLayout();

                    self.element.children('.photogrid-cell').each(function(index, element){
                        $(element).data().zz_photo.loadIfVisible();
                    });


                },100);
            });

            //handle scroll
            var scrollTimer = null;
            self.element.scroll(function(event){
                if(scrollTimer){
                    clearTimeout(scrollTimer);
                    scrollTimer = null;
                }

                scrollTimer = setTimeout(function(){

                    var containerDimensions = {
                        offset: self.element.offset(),
                        height: self.element.height(),
                        width: self.element.width()
                    };

                    self.element.children('.photogrid-cell').each(function(index, element){
                        if($(element).data().zz_photo){ //not sure why this woultn't be here -- maybe if it is a scroll helper?? in any case was seeing js errors
                            $(element).data().zz_photo.loadIfVisible(containerDimensions);
                        }
                    });
                },200);

            });



            //thumbscroller
            if(self.options.showThumbscroller){
                var nativeScrollActive = false;

                self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(self.element.parent());


                self.thumbscroller = self.thumbscrollerElement.zz_thumbtray({
                    photos:self.options.photos,
                    srcAttribute: 'previewSrc',
                    showSelection:false,
                    thumbnailSize:16,
                    showSelectedIndexIndicator:true,
                    repaintOnResize:true,
                    onSelectPhoto: function(index, photo){
                        if(!nativeScrollActive){
                            self.scrollToIndex(index, 500, true);
                        }
                    }
                }).data().zz_thumbtray;

                self.element.scroll(function(event){
                    if(! self.animateScrollActive){
                        nativeScrollActive = true;
                        var index = Math.floor(self.element.scrollTop() / self.options.cellHeight * self.cellsPerRow());
                        self.thumbscroller.setSelectedIndex(index);
                        nativeScrollActive = false;
                    }
                });
            }


            //mousewheel and keyboard for single picture
            if(self.options.singlePictureMode){
                this.element.mousewheel(function(event){

                    var delta;

                    if(typeof(event.wheelDelta)!== 'undefined'){
                        delta = event.wheelDelta;
                    }
                    else{
                        delta = -1 * event.detail;
                    }


                    if(delta < 0){
                        self.nextPicture();
                    }
                    else{
                        self.previousPicture();
                    }

                    return false;
                });

                $(document.documentElement).keydown(function(event){
                    if(event.keyCode === 40){
                        //down
                        self.nextPicture();
                        event.preventDefault();
                    }
                    else if(event.keyCode === 39){
                        //right
                        self.nextPicture();
                        event.preventDefault();
                    }
                    else if(event.keyCode === 34){
                        //page down
                        self.nextPicture();
                        event.preventDefault();
                    }
                    else if(event.keyCode === 38){
                        //up
                        self.previousPicture();
                        event.preventDefault();
                    }
                    else if(event.keyCode === 37){
                        //left
                        self.previousPicture();
                        event.preventDefault();
                    }
                    else if(event.keyCode === 33){
                        //page up
                        self.previousPicture();
                        event.preventDefault();
                    }
                    logger.debug(event.keyCode)
                });
            }

                       //scroll to photo
            if(self.options.scrollToPhoto){
                self.scrollToPhoto(self.options.scrollToPhoto,0, false);
            }


        },


        nextPrevActive : false,
        

        nextPicture: function(){
            var self = this;

            if(!self.nextPrevActive){
                self.nextPrevActive = true;
                var x =  this.element.scrollTop() + self.options.cellHeight;
                self.element.animate({scrollTop: x}, 500, 'easeOutCubic', function(){
                    self.nextPrevActive = false;
                });
            }

        },

        previousPicture: function(){
            var self = this;

            if(!self.nextPrevActive){
                self.nextPrevActive = true;
                var x =  this.element.scrollTop() - self.options.cellHeight;
                self.element.animate({scrollTop: x}, 500, 'easeOutCubic' ,function(){
                    self.nextPrevActive = false;
                });
            }

        },


        indexOfPhoto: function(photoId){
            //todo: this function won't work after a drag-drop reorder
            var self = this;


            for(var i=0; i<self.options.photos.length; i++){
                if(self.options.photos[i].id === photoId){
                   return i;
                }
            }
            return -1;
        },

        scrollToPhoto: function(photoId, duration, highlightCell){
            var index = this.indexOfPhoto(photoId);
            this.scrollToIndex(index, duration, highlightCell);
        },

        scrollToIndex: function(index, duration, highlightCell){
            var self = this;

            if(highlightCell){
                var highlighted = self.cellAtIndex(index).find('.photo-border').addClass('highlighted');

                setTimeout(function(){
                    highlighted.removeClass('highlighted');

                },duration + 1500);
            }

            var y = (Math.floor(index / self.cellsPerRow())  ) * self.options.cellHeight ;

            self.animateScrollActive = true;
            self.element.animate({scrollTop: y}, duration, 'easeOutCubic', function(){
                self.animateScrollActive = false;
            });
        },

        resetLayout: function(duration, easing){
            var self = this;

            if(duration === undefined){
                duration = 0;
            }




            this.element.children('.photogrid-cell').each(function(index, element){
                if(! $(element).data().zz_photo){
                    return;
                }


                var position = self.positionForIndex(index);
                var css = {
                    top: position.top,
                    left: position.left
                };

                //todo: moght want to check that things have actuall changed before setting new properties
                if(duration > 0){
                    $(element).animate(css, duration, easing);
                }
                else{
                    $(element).css(css);
                }





            });
        },

        cellAtIndex : function(index){
            return this.element.children(':nth-child(' + (index + 1 ) + ')');
        },

        cellsPerRow : function(){
            var self = this;
            return Math.floor(self.width / self.options.cellWidth);
        },

        positionForIndex: function(index){
            var self = this;
            var cellsPerRow = self.cellsPerRow();
            var row = Math.floor(index / cellsPerRow);
            var col = index % cellsPerRow;

            var paddingLeft = Math.floor((self.width - (cellsPerRow * self.options.cellWidth))/2);

            var paddingLeft = paddingLeft - (16/2); //account for scroller //todo: use constant or lookup value for scroller width 


            return {
                top: row * self.options.cellHeight,
                left: paddingLeft + (col * self.options.cellWidth) 
            };

        },


        destroy: function() {
            if(this.thumbscrollerElement){
                this.thumbscrollerElement.remove();
            }

            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );