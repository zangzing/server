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

            showThumbscroller: true
        },


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

            $.each(self.options.photos, function(index, photo){
                var cell = template.clone();
                cells.push(cell);



                cell.appendTo(self.element)

                cell.zz_photo({
                    photoId: photo.id,
                    previewSrc: photo.stamp_url,
                    src: photo.thumb_url,
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

                    scrollContainer: self.element
                    
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
                },500);

            });



            //thumbscroller
            if(self.options.showThumbscroller){
                var animateScrollActive = false;
                var nativeScrollActive = false;

                self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(self.element.parent());


                self.thumbscroller = self.thumbscrollerElement.zz_thumbtray({
                    photos:self.options.photos,
                    showSelection:false,
                    thumbnailSize:16,
                    showSelectedIndexIndicator:true,
                    repaintOnResize:true,
                    onSelectPhoto: function(index, photo){
                        if(!nativeScrollActive){
                            if(photo){
                                var highlighted = self.cellAtIndex(index).find('.photo-border').addClass('highlighted');

                                setTimeout(function(){
                                    highlighted.removeClass('highlighted');

                                },1000 + 1500);
                            }



                            var y = (Math.floor(index / self.cellsPerRow())  ) * self.options.cellHeight ;


                            animateScrollActive = true;
                            self.element.animate({scrollTop: y}, 500, 'easeOutCubic', function(){
                                animateScrollActive = false;
                            });
                        }
                    }
                }).data().zz_thumbtray;

                self.element.scroll(function(event){
                    if(! animateScrollActive){
                        nativeScrollActive = true;
                        var index = Math.floor(self.element.scrollTop() / self.options.cellHeight * self.cellsPerRow());
                        self.thumbscroller.setSelectedIndex(index);
                        nativeScrollActive = false;
                    }
                });
            }
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

            return {
                top: row * self.options.cellHeight,
                left: col * self.options.cellWidth
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