/*!
 * photogrid.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function($, undefined) {

    var PADDING_TOP = 10;


    $.widget('ui.zz_photogrid', {
        options: {
            photos: [],
            cellWidth: 200,               //context
            cellHeight: 200,              //context



            allowDelete: false,           //context
            onDelete: jQuery.noop,         //move to photo-model

            allowEditCaption: false,       //context
            onChangeCaption: jQuery.noop,  //move to photo-model

            allowReorder: false,          //context
            onChangeOrder: jQuery.noop,   //move to photo-model

            onClickPhoto: jQuery.noop,    //move to photo-model

            showThumbscroller: true,      //context
            hideNativeScroller: false,    //context

            singlePictureMode: false,

            currentPhotoId: null,
            onScrollToPhoto: jQuery.noop,

            context: 'album-grid',

            lazyLoadThreshold: null,

            showButtonBar: false,          //model
            infoMenuTemplateResolver: null, //album model

            onClickShare: jQuery.noop,
            centerPhotos: true,
            rolloverFrameContainer: $('#article')

//            spaceBarTriggersClick: true

        },

        animatedScrollActive: false,

        _create: function() {
            var self = this;
            var o = self.options;

            if( o.currentPhotoId == 'first'){
               o.currentPhotoId = o.photos[0].id;
            }

            //scroll direction
            if (o.singlePictureMode) {
                self.element.css({
                    'overflow-y': 'hidden',
                    'overflow-x': 'scroll'
                });
            }
            else {
                self.element.css({
                    'overflow-y': 'auto',
                    'overflow-x': 'hidden'
                });

                self.element.touchScrollY();

            }


            self.width = parseInt(self.element.css('width'));
            self.height = parseInt(self.element.css('height'));


            //template for cells
            //todo: when allowReorder is 'false' don't add the drop target elements
            var template = $('<div class="photogrid-cell"><div class="photogrid-droppable"></div></div>');
            template.css({
                width: o.cellWidth,
                height: o.cellHeight
            });


            //create cells and attach photo objects
            self.element.hide();


            var droppableHeight = Math.floor(o.cellHeight * 0.8);
            var droppableWidth = Math.floor(o.cellWidth * 1);
            var droppableLeft = -1 * Math.floor(droppableWidth / 2);
            var droppableTop = Math.floor((o.cellHeight - droppableHeight) / 2);



            if (o.lazyLoadThreshold != 0 && !o.lazyLoadThreshold && o.singlePictureMode) {
                o.lazyLoadThreshold = o.cellWidth * 3;
            }



            // This function is called below, inside a loop that regularly allows the system to
            // process other events.
            var create_photo = function(index, photo) {
                var cell = template.clone();
                cell.appendTo(self.element);
                cell.zz_photo({
                    json: photo,
                    photoId: photo.id,
                    previewSrc: photo.previewSrc,
                    src: photo.src,
                    rolloverSrc: photo.rolloverSrc,
                    maxWidth: Math.floor(o.cellWidth - 50),
                    maxHeight: Math.floor(o.cellHeight - 50 - 5),  //35 accounts for height if caption. this is also set in photo.js
                    allowDelete: o.allowDelete,
                    caption: photo.caption,
                    aspectRatio: photo.aspect_ratio,

                    onDelete: function() {
                        return o.onDelete(index, photo);
                    },

                    allowEditCaption: o.allowEditCaption,

                    onChangeCaption: function(caption) {
                        return o.onChangeCaption(index, photo, caption);
                    },

                    onClick: function(action) {
                        o.onClickPhoto(index, photo, cell, action);
                    },

                    scrollContainer: self.element,
                    lazyLoadThreshold: o.lazyLoadThreshold,
                    isUploading: ! _.isUndefined(photo.state) ? photo.state !== 'ready' : false, //todo: move into photochooser.js
                    isError: photo.state === 'error',
//                    noShadow: photo.type === 'folder',                                          //todo: move into photochooser.js
//                    lazyLoad: photo.type !== 'folder',                                           //todo: move into photochooser.js

                    context: o.context,
                    type: _.isUndefined(photo.type) ? 'photo' : photo.type,
                    showButtonBar: o.showButtonBar,
                    infoMenuTemplateResolver: o.infoMenuTemplateResolver,
                    onClickShare: o.onClickShare,
                    rolloverFrameContainer: o.rolloverFrameContainer
                });
                self._layoutPhoto( cell, index );
                photo.ui_cell = cell;

                //cell.data().zz_photo.loadIfVisible();

                //setup drag and drop
                if (o.allowReorder) {
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
                        start: function() {
                            cell.data().zz_photo.dragStart();
                        },
                        stop: function() {
                            cell.data().zz_photo.dragEnd();
                        },
                        drag: function(event) {

                        },
                        revert: 'invalid',
                        revertDuration: 400,
                        zIndex: 2700,
                        opacity: 0.50,
                        helper: function() {
                            return cell.data().zz_photo.dragHelper();
                        },
                        scroll: true,
                        scrollSensitivity: o.cellHeight / 8,
                        scrollSpeed: o.cellHeight / 3
                    });

                    var nudgeOnDragOver = Math.floor(o.cellWidth / 2);

                    droppable.droppable({
                        tolerance: 'pointer',
                        over: function(event, ui) {
                            if (ui.draggable[0] == droppable.parent().prev()[0]) {
                                return;
                            }
                            cell.rowLeft().animateRelative(-1 * nudgeOnDragOver, 0, 100);
                            cell.rowRight().add(cell).animateRelative(nudgeOnDragOver, 0, 100);
                        },

                        out: function() {
                            self.resetLayout(100);
                        },

                        drop: function(event, ui) {
                            var draggedCell = ui.draggable;


                            //create clone so we have something to face out
                            var draggedCellClone = draggedCell.clone().appendTo(draggedCell.parent());
                            draggedCellClone.fadeOut(400, function() {
                                draggedCellClone.remove();
                            });


                            //move the dragged cell to the new spot
                            var droppedOnCell = droppable.parent();
                            draggedCell.insertBefore(droppedOnCell);
                            draggedCell.css({
                                top: parseInt(droppedOnCell.css('top')),
                                left: parseInt(droppedOnCell.css('left')) - o.cellWidth
                            });


                            self.resetLayout(800, 'easeInOutCubic');


                            var photo_id = draggedCell.data().zz_photo.getPhotoId();
                            var before_id = null;
                            if ($(draggedCell).prev().length !== 0) {
                                before_id = $(draggedCell).prev().data().zz_photo.getPhotoId();
                            }
                            var after_id = droppedOnCell.data().zz_photo.getPhotoId();
                            o.onChangeOrder(photo_id, before_id, after_id);

                        }

                    });
                }
                return cell;
            };

            // - Build and load screen photos in batches
            // - Set the batch size to the average photos that are displayed upon loading (how many fit in the screen)
            // - Optimize insert, draw, and load speed for the first batch (first batch is inserted with element hidden)
            // - Check if second batch is visible just in case you are using a huge browser window
            // - Once first batch is on screen then build, and insert the rest of the photos at your leisure
            // - Add timeout every batch to prevent lockout warnings

            var batch_size = 60;
            var create_some_photos = function(i) {
                if (i < o.photos.length) {
                    var cells = [];
                    for (var j = i; j < i + batch_size && j < o.photos.length; j++) {
                        cells.push( create_photo(j, o.photos[j]) );
                    }
                    if( !o.singlePictureMode && i < batch_size ){
                        self._show_and_arm();
                        for (var k = 0; k < cells.length ; k++) {
                            cells[k].data().zz_photo.loadIfVisible();
                        }
                    }
                    var next_batch = function() {
                        create_some_photos(i + batch_size);
                    };
                    setTimeout(next_batch, 0); //A 0 timeout lets the system process any pending stuff and then this.
                } else {
                    if ( o.singlePictureMode ){
                         self._show_and_arm()
                         if( o.currentPhotoId != null){
                            o.photos[ self.indexOfPhoto(o.currentPhotoId) ].ui_cell.data().zz_photo.loadIfVisible();
                         }else{
                            o.photos[0].ui_cell.data().zz_photo.loadIfVisible();
                         }
                    }
                    
                    //self.resetLayout(); Done when each photo is created
                    //self.element.show(); Done after first batch is created
                   //self.element.children('.photogrid-cell').each(function(index, element) {
                   //     $(element).data().zz_photo.loadIfVisible();
                   // }); Done only for first and second batches, the rest of the photos will get it when they come
                   // into view

                    //hideNativeScroller
                    if (o.hideNativeScroller) {
                        if (o.singlePictureMode) {
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-horizontal"></div>').appendTo(self.element.parent());
                        }else {
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-vertical"></div>').appendTo(self.element.parent());
                        }
                    }

                    //thumbscroller
                    if (o.showThumbscroller) {
                        var nativeScrollActive = false;

                        if (o.singlePictureMode) {
                            self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-horizontal"></div>').appendTo(self.element.parent());
                        } else {
                            self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(self.element.parent());
                        }

                        //remove any 'special' photos (eg blank one used for drag and drop on edit screen
                        var photos = $.map(o.photos, function(photo, index) {
                            if (photo.type == 'blank') {
                                return null;
                            }
                            else {
                                return photo;
                            }
                        });

                        self.thumbscroller = self.thumbscrollerElement.zz_thumbtray({
                            photos: photos,
                            srcAttribute: 'previewSrc',
                            showSelection: false,
                            thumbnailSize: 20,
                            showSelectedIndexIndicator: true,
                            repaintOnResize: true,
                            onSelectPhoto: function(index, photo) {
                                if (typeof photo != 'undefined') {
                                    if (!nativeScrollActive) {
                                        self.scrollToPhoto(photo.id, 500, true);
                                    }
                                }
                            }
                        }).data().zz_thumbtray;

                        self.element.scroll(function(event) {
                            if (! self.animateScrollActive) {
                                nativeScrollActive = true;

                                var index;
                                if (o.singlePictureMode) {
                                    index = Math.floor(self.element.scrollLeft() / o.cellWidth);
                                }
                                else {
                                    index = Math.floor(self.element.scrollTop() / o.cellHeight * self.cellsPerRow());
                                }
                                self.thumbscroller.setSelectedIndex(index);
                                nativeScrollActive = false;
                            }
                        });
                    }


                    //mousewheel and keyboard for single picture
                    if (o.singlePictureMode) {
                        self.element.mousewheel(function(event) {

                            var delta;

                            if (typeof(event.wheelDelta) !== 'undefined') {
                                delta = event.wheelDelta;
                            }
                            else {
                                delta = -1 * event.detail;
                            }


                            if (delta < 0) {
                                self.nextPicture();
                            }
                            else {
                                self.previousPicture();
                            }

                            return false;
                        });


                        self.element.swipe({
                            swipeRight: function(){
                                self.previousPicture();
                            },
                            swipeLeft: function(){
                                self.nextPicture();
                            }
                        });

                        //capture all events
                        $(document.documentElement).keydown(function(event) {
                        	if (event.target.nodeName.toLowerCase() === 'body') {
	                            if (event.keyCode === 40) {
	                                //down
	                                self.nextPicture();
	                            }
	                            else if (event.keyCode === 39) {
	                                //right
	                                self.nextPicture();
	                            }
	                            else if (event.keyCode === 34) {
	                                //page down
	                                self.nextPicture();
	                            }
	                            else if (event.keyCode === 38) {
	                                //up
	                                self.previousPicture();
	                            }
	                            else if (event.keyCode === 37) {
	                                //left
	                                self.previousPicture();
	                            }
	                            else if (event.keyCode === 33) {
	                                //page up
	                                self.previousPicture();
	                            }
                        	}
                        });

                        //block events to grid
                        $(self.element).keydown(function(event) {
                            event.preventDefault();
                        });

                    }


                    //scroll to photo
                    if (o.currentPhotoId !== null) {
                        self.scrollToPhoto(o.currentPhotoId, 0, false);
                    }

                }
            };
            create_some_photos(0);


        },

        _show_and_arm: function(){
            var self = this,
                o = self.options;

            self.element.show();

            // Window Resize
            var resizeTimer = null;
            $(window).resize(function(event) {
                if (resizeTimer) {
                    clearTimeout(resizeTimer);
                    resizeTimer = null;
                }

                resizeTimer = setTimeout(function() {
                    self.width = parseInt(self.element.css('width'));
                    self.height = parseInt(self.element.css('height'));
                    self.resetLayout();
                    self.element.children('.photogrid-cell').each(function(index, element) {
                        if (!_.isUndefined($(element).data().zz_photo)) { //todo: sometimes this is undefined -- not sure why
                            $(element).data().zz_photo.loadIfVisible();
                        }
                    });
                }, 100);
            });

            // Scroll
            var scrollTimer = null;
            self.element.scroll(function(event) {
                if (scrollTimer) {
                    clearTimeout(scrollTimer);
                    scrollTimer = null;
                }

                scrollTimer = setTimeout(function() {
                    var containerDimensions = {
                        offset: self.element.offset(),
                        height: self.element.height(),
                        width: self.element.width()
                    };

                    self.element.children('.photogrid-cell').each(function(index, element) {
                        if ($(element).data().zz_photo) { //not sure why this woultn't be here -- maybe if it is a scroll helper?? in any case was seeing js errors
                            $(element).data().zz_photo.loadIfVisible(containerDimensions);
                        }
                    });
                }, 200);
            });
        },

        findFirstScrollableContainer: function(){
            var self = this;
            var container = self.element;

            for(;;){
                if(container.css('overflow-y') == 'auto'){
                    return container;
                }
                container = container.parent();
            }
        },


        hideThumbScroller: function() {
            if (this.thumbscrollerElement) {
                this.thumbscrollerElement.hide();
            }
        },

        nextPrevActive: false,



        nextPicture: function() {
            var self = this;

            if (!self.nextPrevActive) {
                var animateDuration = 500;

                var index = self.indexOfPhoto(self.currentPhotoId());
                index++;

                if (index > self.options.photos.length - 1) {
                    // if at the end, then go to beginning
                    index = 0;
                    animateDuration = 0;
                }

                var id = self.options.photos[index].id;

                self.nextPrevActive = true;
                self.scrollToPhoto(id, animateDuration, true, function() {
                    self.nextPrevActive = false;
                });
            }

        },

        previousPicture: function() {
            var self = this;

            if (!self.nextPrevActive) {
                var animateDuration = 500;

                var index = self.indexOfPhoto(self.currentPhotoId());
                index--;

                if (index < 0) {
                    // go to the end
                    index = self.options.photos.length-1;
                    var animateDuration = 0;
                }

                var id = self.options.photos[index].id;

                self.nextPrevActive = true;
                self.scrollToPhoto(id, animateDuration, true, function() {
                    self.nextPrevActive = false;
                });
            }

        },

        currentPhotoId: function() {
            var self = this;
            if (self.options.currentPhotoId) {
                return self.options.currentPhotoId;
            }
            else {
                if (self.options.photos.length > 0) {
                    return self.options.photos[0].id;
                }
                else {
                    return null;
                }
            }

        },

        indexOfPhoto: function(photoId) {
            //todo: this function won't work after a drag-drop reorder
            var self = this;


            for (var i = 0; i < self.options.photos.length; i++) {
                if (self.options.photos[i].id == photoId) {
                    return i;
                }
            }
            return -1;
        },

        scrollToPhoto: function(photoId, duration, highlightCell, callback) {
            var self = this;

            if (self.options.photos.length == 0) {
                return;
            }


            var index = self.indexOfPhoto(photoId);

            if (index == -1) {
                index = 0;
                photoId = self.options.photos[0].id;
            }

            var onFinishAnimate = function() {
                self.options.currentPhotoId = photoId;
                self.options.onScrollToPhoto(photoId, index);
                if (typeof callback !== 'undefined') {
                    callback();
                }
            }


            if (self.options.singlePictureMode) {
                var x = index * self.options.cellWidth;

                self.animateScrollActive = true;
                self.element.animate({scrollLeft: x}, duration, 'easeOutCubic', function() {
                    self.animateScrollActive = false;
                    onFinishAnimate();
                });

            }
            else {
                var y = Math.floor(index / self.cellsPerRow()) * self.options.cellHeight;
                self.animateScrollActive = true;
                self.element.animate({scrollTop: y}, duration, 'easeOutCubic', function() {
                    self.animateScrollActive = false;
                    onFinishAnimate();
                });
            }
        },

        resetLayout: function(duration, easing) {
            var self = this;

            if (duration === undefined) {
                duration = 0;
            }

            this.element.find('.scroll-padding').remove();

            var top_of_last_row = 0;

            this.element.children('.photogrid-cell').each(function(index, element) {
                var position = self._layoutPhoto( element, index, duration, easing );
                if( position ){
                    top_of_last_row = position.top;
                }
            });

            if(!self.options.singlePictureMode){
                var top = top_of_last_row + 330; // add the right of the rollover frame
                var scroll_padding = $('<div class="scroll-padding"></div>');
                scroll_padding.css({top: top});
                this.element.append(scroll_padding);
            }
        },

        _layoutPhoto: function( photo, index, duration, easing ){
            if (! $(photo).data().zz_photo) {
                return;
            }

            var position = this.positionForIndex(index);
            var css = {
                top: position.top,
                left: position.left
            };

            //todo: moght want to check that things have actuall changed before setting new properties
            if (duration && duration > 0) {
                $(photo).animate(css, duration, easing);
            }
            else {
                $(photo).css(css);
            }
            return position;
        },

        cellForId: function(id) {
            var index = this.indexOfPhoto(id);
            return this.cellAtIndex(index);
        },

        cellAtIndex: function(index) {
            var cell = this.element.children(':nth-child(' + (index + 1) + ')');
            if (cell.length === 0) {
                return null;
            }
            else {
                return cell;
            }
        },


        cells: function() {
            return this.element.children('.photogrid-cell');
        },

        cellsPerRow: function() {
            var self = this;
            if (self.options.singlePictureMode) {
                return self.options.photos.length;
            }
            else {
                return Math.floor(self.width / self.options.cellWidth);
            }
        },

        positionForIndex: function(index) {
            var self = this;

            if (self.options.singlePictureMode) {
                return {
                    top: 0,
                    left: (index * self.options.cellWidth)

                };
            }
            else {
                var cellsPerRow = self.cellsPerRow();
                var row = Math.floor(index / cellsPerRow);
                var col = index % cellsPerRow;


                var paddingLeft = 0;
                
                if(self.options.centerPhotos){
                    paddingLeft = Math.floor((self.width - (cellsPerRow * self.options.cellWidth)) / 2);
                    paddingLeft = paddingLeft - (20 / 2); //account for scroller //todo: use constant or lookup value for scroller width
                }



                return {
                    top: row * self.options.cellHeight + PADDING_TOP,
                    left: paddingLeft + (col * self.options.cellWidth)
                };
            }
        },


        destroy: function() {
            if (this.thumbscrollerElement) {
                this.thumbscrollerElement.remove();
            }

            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });


})(jQuery);
