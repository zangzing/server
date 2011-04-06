/*!
 * photogrid.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function( $, undefined ) {

    $.widget( "ui.zz_photogrid", {
        options: {
            photos: [],
            cellWidth: 200,               //context
            cellHeight: 200,              //context

            allowDelete: false,           //context
            onDelete:jQuery.noop,         //move to photo-model

            allowEditCaption:false,       //context
            onChangeCaption:jQuery.noop,  //move to photo-model

            allowReorder: false,          //context
            onChangeOrder: jQuery.noop,   //move to photo-model

            onClickPhoto: jQuery.noop,    //move to photo-model

            showThumbscroller: true,      //context
            hideNativeScroller: false,    //context

            singlePictureMode: false,

            currentPhotoId: null,
            onScrollToPhoto: jQuery.noop,

            context: 'album-grid',

            lazyLoadThreshold:null,

            showButtonBar: false,          //model
            onClickShare: jQuery.noop
//            spaceBarTriggersClick: true


        },

        animatedScrollActive: false,


        _create: function() {
            var self = this;


            //scroll direction
            if(self.options.singlePictureMode){
                self.element.css({
                    'overflow-y':'hidden',
                    'overflow-x':'scroll'
                });
            }
            else{
                self.element.css({
                    'overflow-y':'scroll',
                    'overflow-x':'hidden'
                });
            }


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
            var droppableWidth = Math.floor(self.options.cellWidth * 1);
            var droppableLeft = -1 * Math.floor(droppableWidth/2);
            var droppableTop = Math.floor((self.options.cellHeight - droppableHeight)/2);

            var cells = [];


            if(self.options.lazyLoadThreshold!=0 && !self.options.lazyLoadThreshold && self.options.singlePictureMode){
                self.options.lazyLoadThreshold = self.options.cellWidth * 3;
            }




            $.each(self.options.photos, function(index, photo){
                var cell = template.clone();
                cells.push(cell);



                cell.appendTo(self.element)

                cell.zz_photo({
                    photo: photo,
                    photoId: photo.id,
                    previewSrc: photo.previewSrc,
                    src: photo.src,
                    rolloverSrc: photo.rolloverSrc,
                    maxWidth: Math.floor(self.options.cellWidth - 50),
                    maxHeight: Math.floor(self.options.cellHeight - 50),
                    allowDelete: self.options.allowDelete,
                    caption: photo.caption,
                    aspectRatio: photo.aspect_ratio,

                    onDelete:function(){
                        return self.options.onDelete(index,photo);
                    },

                    allowEditCaption:self.options.allowEditCaption,

                    onChangeCaption:function(caption){
                        return self.options.onChangeCaption(index, photo, caption);
                    },

                    onClick: function(action){
                        self.options.onClickPhoto(index, photo, cell, action);
                    },

                    scrollContainer: self.element,
                    lazyLoadThreshold: self.options.lazyLoadThreshold,
                    isUploading: ! _.isUndefined(photo.state) ? photo.state !== 'ready': false, //todo: move into photochooser.js
                    isError: photo.state === 'error',
//                    noShadow: photo.type === 'folder',                                          //todo: move into photochooser.js
//                    lazyLoad: photo.type !== 'folder',                                           //todo: move into photochooser.js

                    context: self.options.context,
                    type: _.isUndefined(photo.type) ? 'photo': photo.type,
                    showButtonBar: self.options.showButtonBar,
                    onClickShare: self.options.onClickShare

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
                        scrollSensitivity: self.options.cellHeight / 8,
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


                            var photo_id = draggedCell.data().zz_photo.getPhotoId();
                            var before_id = null;
                            if($(draggedCell).prev().length !==0){
                                before_id = $(draggedCell).prev().data().zz_photo.getPhotoId();
                            }
                            var after_id = droppedOnCell.data().zz_photo.getPhotoId();
                            self.options.onChangeOrder(photo_id, before_id, after_id);

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
                        if(!_.isUndefined($(element).data().zz_photo)){ //todo: sometimes this is undefined -- not sure why
                           $(element).data().zz_photo.loadIfVisible();
                        }
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


            //hideNativeScroller
            if(self.options.hideNativeScroller){

                if(self.options.singlePictureMode){
                    self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-horizontal"></div>').appendTo(self.element.parent());
                }
                else{
                    self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-vertical"></div>').appendTo(self.element.parent());
                }
            }

            //thumbscroller
            if(self.options.showThumbscroller){
                var nativeScrollActive = false;

                if(self.options.singlePictureMode){
                    self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-horizontal"></div>').appendTo(self.element.parent());
                }
                else{
                    self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(self.element.parent());
                }


                //remove any 'special' photos (eg blank one used for drag and drop on edit screen
                var photos = $.map(self.options.photos, function(photo, index){
                    if(photo.type == 'blank'){
                        return null;
                    }
                    else{
                        return photo;
                    }
                });

                self.thumbscroller = self.thumbscrollerElement.zz_thumbtray({
                    photos:photos,
                    srcAttribute: 'previewSrc',
                    showSelection:false,
                    thumbnailSize:20,
                    showSelectedIndexIndicator:true,
                    repaintOnResize:true,
                    onSelectPhoto: function(index, photo){
                        if(typeof photo != 'undefined'){
                            if(!nativeScrollActive){
                                self.scrollToPhoto(photo.id, 500, true);
                            }
                        }
                    }
                }).data().zz_thumbtray;

                self.element.scroll(function(event){
                    if(! self.animateScrollActive){
                        nativeScrollActive = true;
                        if(self.options.singlePictureMode){
                            var index = Math.floor(self.element.scrollLeft() / self.options.cellWidth);
                        }
                        else{
                            var index = Math.floor(self.element.scrollTop() / self.options.cellHeight * self.cellsPerRow());
                        }
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


                //capture all events
                $(document.documentElement).keydown(function(event){
                    if(event.keyCode === 40){
                        //down
                        self.nextPicture();
                    }
                    else if(event.keyCode === 39){
                        //right
                        self.nextPicture();
                    }
                    else if(event.keyCode === 34){
                        //page down
                        self.nextPicture();
                    }
                    else if(event.keyCode === 38){
                        //up
                        self.previousPicture();
                    }
                    else if(event.keyCode === 37){
                        //left
                        self.previousPicture();
                    }
                    else if(event.keyCode === 33){
                        //page up
                        self.previousPicture();
                    }
//                    else if(event.keyCode === 32){
//                        if(self.options.spaceBarTriggersClick){
//                            var index = self.indexOfPhoto(self.currentPhotoId());
//                            var cell = self.cellAtIndex(index);
//                            var photo = cell.data().zz_photo.options.photo;
//                            self.options.onClickPhoto(index, photo, cell, 'main');
//
//
//                        }
//                     }
                 });

                //block events to grid
                $(this.element).keydown(function(event){
                    event.preventDefault()
                });

            }


            

                       //scroll to photo
            if(self.options.currentPhotoId){
                self.scrollToPhoto(self.options.currentPhotoId,0, false);
            }


        },


        hideThumbScroller: function(){
            this.thumbscrollerElement.hide();
        },

        nextPrevActive : false,
        

        nextPicture: function(){
            var self = this;

            if(!self.nextPrevActive){
                var index = self.indexOfPhoto(self.currentPhotoId());
                index ++;

                if(index > self.options.photos.length-1){
                    return;
                }

                var id = self.options.photos[index].id;

                self.nextPrevActive = true;
                self.scrollToPhoto(id, 500, true, function(){
                    self.nextPrevActive = false;
                });
           }

        },

        previousPicture: function(){
            var self = this;

            if(!self.nextPrevActive){
                var index = self.indexOfPhoto(self.currentPhotoId());
                index --;

                if(index < 0){
                    return;
                }

                var id = self.options.photos[index].id;

                self.nextPrevActive = true;
                self.scrollToPhoto(id, 500, true, function(){
                    self.nextPrevActive = false;
                });
           }

        },

        currentPhotoId: function(){
            var self = this;
            if(self.options.currentPhotoId){
                return self.options.currentPhotoId;
            }
            else{
                return self.options.photos[0].id;
            }

        },

        indexOfPhoto: function(photoId){
            //todo: this function won't work after a drag-drop reorder
            var self = this;


            for(var i=0; i<self.options.photos.length; i++){
                if(self.options.photos[i].id == photoId){
                   return i;
                }
            }
            return -1;
        },

        scrollToPhoto: function(photoId, duration, highlightCell, callback){
            var self = this;

            var index = self.indexOfPhoto(photoId);

//            if(highlightCell){
//                var highlighted = self.cellAtIndex(index).find('.photo-border').addClass('highlighted');
//
//                setTimeout(function(){
//                    highlighted.removeClass('highlighted');
//
//                },duration + 1500);
//            }

            var onFinishAnimate = function(){
                self.options.currentPhotoId = photoId
                self.options.onScrollToPhoto(photoId);
                if(typeof callback !== 'undefined'){
                    callback();
                }
            }


            if(self.options.singlePictureMode){
                var x = index  * self.options.cellWidth;

                self.animateScrollActive = true;
                self.element.animate({scrollLeft: x}, duration, 'easeOutCubic', function(){
                    self.animateScrollActive = false;
                    onFinishAnimate();
                });

            }
            else{
                var y = Math.floor(index / self.cellsPerRow()) * self.options.cellHeight ;
                self.animateScrollActive = true;
                self.element.animate({scrollTop: y}, duration, 'easeOutCubic', function(){
                    self.animateScrollActive = false;
                    onFinishAnimate();
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

        cellForId: function(id){
            var index = this.indexOfPhoto(id);
            return this.cellAtIndex(index);
        },

        cellAtIndex : function(index){
            var cell = this.element.children(':nth-child(' + (index + 1 ) + ')');
            if (cell.length === 0){
                return null;
            }
            else{
                return cell;
            }
        },


        cells: function(){
            return this.element.children('.photogrid-cell');
        },

        cellsPerRow : function(){
            var self = this;
            if(self.options.singlePictureMode){
                return self.options.photos.length;                
            }
            else{
                return Math.floor(self.width / self.options.cellWidth);
            }
        },

        positionForIndex: function(index){
            var self = this;

            if(self.options.singlePictureMode){
                return {
                    top:0,
                    left: (index * self.options.cellWidth)

                }
            }
            else{
                var cellsPerRow = self.cellsPerRow();
                var row = Math.floor(index / cellsPerRow);
                var col = index % cellsPerRow;

                var paddingLeft = Math.floor((self.width - (cellsPerRow * self.options.cellWidth))/2);

                paddingLeft = paddingLeft - (20/2); //account for scroller //todo: use constant or lookup value for scroller width


                return {
                    top: row * self.options.cellHeight,
                    left: paddingLeft + (col * self.options.cellWidth)
                };
            }
        },


        destroy: function() {
            if(this.thumbscrollerElement){
                this.thumbscrollerElement.remove();
            }

            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );