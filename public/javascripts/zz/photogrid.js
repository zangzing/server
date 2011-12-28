/*!
 * photogrid.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function($, undefined) {


    var photogrid_droppablecell_template =  $('<div class="photogrid-cell"><div class="photogrid-droppable"></div></div>');
    var photogrid_cell_template =  $('<div class="photogrid-cell"></div>');

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
            rolloverFrameContainer: $('#article'),
            topPadding: 10,
            defaultSort: null
        },

        _create: function() {
            var self = this,
                o = self.options,
                el = self.element;

            //scroll direction
            if (o.singlePictureMode) {
                el.css({
                    'overflow-y': 'hidden',
                    'overflow-x': 'scroll'
                });
            } else {
                el.css({
                    'overflow-y': 'auto',
                    'overflow-x': 'hidden'
                });
                el.touchScrollY();
            }

            // save the current container sise
            self.width = parseInt(el.css('width'));
            self.height = parseInt(el.css('height'));
            el.hide();

            //choose template for cells
            if( o.allowReorder ){
                var template = photogrid_droppablecell_template.clone();
            }else{
                 // when allowReorder is 'false' don't add the drop target elements
                var template = photogrid_cell_template.clone();
            }
            template.css({
                width: o.cellWidth,
                height: o.cellHeight
            });


            if (o.lazyLoadThreshold != 0 && !o.lazyLoadThreshold && o.singlePictureMode) {
                o.lazyLoadThreshold = o.cellWidth * 3;
            }

            // Create a single photo cell and append it to the grid
            // called below inside a loop that regularly allows the system to
            // process other events.
            var create_photo = function(index, photo) {
                var cell = template.clone();
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
                        photo.caption = caption;
                        return o.onChangeCaption(index, photo, caption);
                    },

                    onClick: function(action) {
                        o.onClickPhoto(index, photo, cell, action);
                    },

                    scrollContainer: el,
                    lazyLoadThreshold: o.lazyLoadThreshold,
                    isUploading: ! _.isUndefined(photo.state) ? photo.state !== 'ready' : false, //todo: move into photochooser.js
                    isError: photo.state === 'error',

                    context: o.context,
                    type: _.isUndefined(photo.type) ? 'photo' : photo.type,
                    showButtonBar: o.showButtonBar,
                    infoMenuTemplateResolver: o.infoMenuTemplateResolver,
                    onClickShare: o.onClickShare,
                    rolloverFrameContainer: o.rolloverFrameContainer
                });
                cell.appendTo(el);
                photo.ui_cell = cell;
                photo.ui_photo = cell.data().zz_photo;
                self._layoutPhoto( photo, index );

                //setup drag and drop if allowed
                if (o.allowReorder) {
                    var droppable = cell.find('.photogrid-droppable');
                    var droppableHeight = Math.floor(o.cellHeight * 0.8);
                    var droppableWidth = Math.floor(o.cellWidth);
                    var droppableLeft = -1 * Math.floor(droppableWidth / 2);
                    var droppableTop = Math.floor((o.cellHeight - droppableHeight) / 2);
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

            // - Build and load screen photos in batches ( using create_some_photos recursively )
            // - Set the batch size to the average photos that are displayed upon loading (how many fit in the screen)
            // - Optimize insert, draw, and load speed for the first batch (first batch is inserted with element hidden)
            // - Show element and draw photos as soon as first batch is ready
            // - Once first batch is on screen then build, and insert the rest of the photos at your leisure
            // - Add timeout every batch to prevent lockout warnings
            var batch_size = 60;
            var create_some_photos = function(i) {
                if (i < o.photos.length) { //recursion termination condition

                    //create a batch of photos
                    for (var j = i; j < i + batch_size && j < o.photos.length; j++) {
                       create_photo(j, o.photos[j]);
                    }

                    // Display the grid after the first batch is ready
                    if( i < batch_size ){
                        //  Single picture view - Display the selected photo
                        if( o.singlePictureMode  ){
                            var index = 0;
                            if( o.currentPhotoId != null){
                                index = self.indexOfPhoto(o.currentPhotoId);
                            }
                            if( index >= batch_size ){ // create photo if not in first batch
                                create_photo(index, o.photos[index]);
                            }
                            self._show_and_arm();
                            o.photos[index].ui_photo.loadIfVisible();
                        }else{
                            // Grid View - Show as soon as we have first screen ready
                            self._show_and_arm();
                            for (var k = i; i < j ; i++) {
                                o.photos[i].ui_photo.loadIfVisible();
                            }
                        }
                    }

                    // Queue next batch for processing
                    //  Even a 0 timeout lets the system process any pending stuff and then this.
                    setTimeout( function(){ create_some_photos(i + batch_size); }, 1);

                } else {
                    //All photos have been created, add bells and whistles

                    //hideNativeScroller
                    if (o.hideNativeScroller) {
                        if (o.singlePictureMode) {
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-horizontal"></div>').appendTo(el.parent());
                        }else{
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-vertical"></div>').appendTo(el.parent());
                        }
                    }

                    //thumbscroller
                    if (o.showThumbscroller) {
                        var nativeScrollActive = false;

                        if (o.singlePictureMode) {
                            self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-horizontal"></div>').appendTo(el.parent());
                        } else {
                            self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(el.parent());
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

                        el.scroll(function(event) {
                            if (! self.animateScrollActive) {
                                nativeScrollActive = true;

                                var index;
                                if (o.singlePictureMode) {
                                    index = Math.floor(el.scrollLeft() / o.cellWidth);
                                }
                                else {
                                    index = Math.floor(el.scrollTop() / o.cellHeight * self.cellsPerRow());
                                }
                                self.thumbscroller.setSelectedIndex(index);
                                nativeScrollActive = false;
                            }
                        });
                    }

                    //mousewheel and keyboard for single picture
                    if (o.singlePictureMode) {
                        el.mousewheel(function(event) {
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


                        el.swipe({
                            swipeRight: function(){
                                self.previousPicture();
                            },
                            swipeLeft: function(){
                                self.nextPicture();
                            }
                        });

                        //capture all events
                        $(document.documentElement).keydown(function(event) {
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
                        });

                        //block events to grid
                        $(el).keydown(function(event) {
                            event.preventDefault();
                        });

                    }

                    //scroll to photo
                    if (o.currentPhotoId !== null) {
                        self.scrollToPhoto(o.currentPhotoId, 0, false);
                    }

                }
            };

            if( o.photos.length > 0 ){
                //create the photos for the grid
                if( o.defaultSort ){
                    self.sort_by( o.defaultSort, true ); //no layout
                }
                create_some_photos(0);
            }else{
                //Empty Album - Display no photos in this album sign
                el.html('<div class="no-photos">There are no photos in this album</div>');
                el.show();
            }
        },

        _show_and_arm: function(){
            var self = this,
                o    = self.options,
                el   = self.element;

            el.show();

            // Window Resize
            var resizeTimer = null;
            $(window).resize(function(event) {
                if (resizeTimer) {
                    clearTimeout(resizeTimer);
                    resizeTimer = null;
                }
                resizeTimer = setTimeout(function() {
                    self.width = parseInt(el.css('width'));
                    self.height = parseInt(el.css('height'));
                    self.resetLayout(0,0, true); //no duration, no easing, yes loadIfVisible
                }, 100);
            });

            // Scroll
            var scrollTimer = null;
            el.scroll(function(event) {
                if (scrollTimer) {
                    clearTimeout(scrollTimer);
                    scrollTimer = null;
                }
                scrollTimer = setTimeout(function() {
                    var containerDimensions = {
                        offset: el.offset(),
                        height: el.height(),
                        width: el.width()
                    };
                    for( var i=0; i < o.photos.length; i++){
                        o.photos[i].ui_photo.loadIfVisible( containerDimensions );
                    }
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

        nextPhoto: function( id ) {
            var self = this;
            var index = self.indexOfPhoto(id);
            index++;
            if (index > self.options.photos.length - 1){
                // if at the end, then go to beginning
                index = 0;
            }
            return self.options.photos[index];
        },

        previousPhoto: function( id ){
            var self = this;
            var index = self.indexOfPhoto(id);
            index--;

            if (index < 0){
                // go to the end
                index = self.options.photos.length-1;
            }

            return self.options.photos[index];
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

        resetLayout: function(duration, easing, showIfVisible) {
            var self = this,
                o = self.options,
                el = self.element;


            if (duration === undefined) {
                duration = 0;
            }

            el.find('.scroll-padding').remove();

            var top_of_last_row = 0;

            if( o.photos.length > 300 ){
                duration = 0;
                easing = 0;
            }
            for( var i=0; i < o.photos.length ; i++){
                var position = self._layoutPhoto( o.photos[i], i, duration, easing, showIfVisible );
                if( position ){
                    top_of_last_row = position.top;
                }
            }

            if(!self.options.singlePictureMode){
                var top = top_of_last_row + 330; // add the right of the rollover frame
                var scroll_padding = $('<div class="scroll-padding"></div>');
                scroll_padding.css({top: top});
                el.append(scroll_padding);
            }
        },

        _layoutPhoto: function( photo, index, duration, easing, showIfVisible ){
            if (!'ui_photo' in photo ) {
                return;
            }

            // calculate the position for this index
            var position = this.positionForIndex(index);

            //todo: moght want to check that things have actuall changed before setting new properties
            if (duration && duration > 0 ) {
                photo.ui_cell.animate(position, duration, easing, function(){
                    if( showIfVisible ){
                        photo.ui_photo.loadIfVisible();
                    }
                });
            }
            else {
                photo.ui_cell.css(position);
                if( showIfVisible ){
                    photo.ui_photo.loadIfVisible();
                }
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
                    top: row * self.options.cellHeight + self.options.topPadding,
                    left: paddingLeft + (col * self.options.cellWidth)
                };
            }
        },

        sort_by: function( sort_method, no_layout ){
            switch( sort_method ){
                case'name-asc':
                    this.sort_by_name_asc(no_layout);
                    break;
                case'name-desc':
                    this.sort_by_name_desc(no_layout);
                    break;
                case'date-desc':
                    this.sort_by_date_desc(no_layout);
                    break;
                case'date-asc':
                default:
                    this.sort_by_date_asc(no_layout);
                    break;
            }
        },

        sort_by_date_asc: function( no_layout ){
             this._sort( this._capture_date_asc_comp );
             if( typeof no_layout == 'undefined'){
                this.resetLayout(400, 'easeInOutCubic', true);
             }
        },

        sort_by_date_desc: function( no_layout ){
             this._sort( this._capture_date_desc_comp );
            if( typeof no_layout == 'undefined'){
                this.resetLayout(400, 'easeInOutCubic', true);
            }
        },

        sort_by_name_desc: function( no_layout ){
            var self = this;
            this._sort( function( a, b ){
                if( a.caption == b.caption ){
                    return self._capture_date_desc_comp( a, b);
                }else if( a.caption == null || a.caption.length <= 0){
                    return -1;
                }else if( b.caption == null || b.caption.length <= 0){
                    return 1;
                }
                return  ( a.caption.toLowerCase() < b.caption.toLowerCase() ? 1 : -1);
            });
            if( typeof no_layout == 'undefined'){
                this.resetLayout(400, 'easeInOutCubic', true);
            }
        },

        sort_by_name_asc: function(no_layout){
            var self = this;
            function reverse_char(astring){
                return String.fromCharCode.apply(String,
                    _.map( astring.toLowerCase().split(''), function (c) {
                        return 0xffff - c.charCodeAt();
                    }));
            }

            this._sort( function( a, b ){
                var arcap = reverse_char( a.caption );
                var brcap = reverse_char( b.caption );
                if( arcap == brcap ){
                    //if caption equal go to capture date
                    return self._capture_date_asc_comp( a, b);
                }else if( arcap == null || arcap.length <= 0){
                    return 1;
                }else if( brcap == null || brcap.length <= 0){
                    return -1;
                }
                return ( arcap > brcap? -1 : 1 );
            } );
            if( typeof no_layout == 'undefined'){
                this.resetLayout(400, 'easeInOutCubic', true);
            }
        },

        _capture_date_desc_comp: function ( a, b ){
            if( a.capture_date == b.capture_date ){
                //if capture date equal go to created at
                if( a.created_at == b.created_at ){
                    return( a.id < b.id ? 1 : -1 );
                }else{
                    return( a.created_at < b.created_at ? 1 : -1 );
                }
            }else if( a.capture_date == null || a.capture_date == 0 ){
                return 1;
            }else if( b.capture_date == null || a.capture_date == 0 ){
                return -1;
            }else{
                return( a.capture_date < b.capture_date ? 1 : -1 );
            }
        },

        _capture_date_asc_comp: function ( a, b ){
            if( a.capture_date == b.capture_date ){
                //if capture_date equal or null go to created_at
                if( a.created_at == b.created_at ){
                    // if created_at equal go to id
                    return( a.id > b.id ? 1 : -1 );
                }else{
                    return( a.created_at > b.created_at ? 1 : -1 );
                }
            }else if( a.capture_date == null || a.capture_date == 0 ){
                return -1;
            }else if( b.capture_date == null || a.capture_date == 0 ){
                return 1;
            }else{
                return( a.capture_date > b.capture_date ? 1 : -1 );
            }
        },


        _sort: function( comparator ){
            this.options.photos.sort( comparator );
        },



        destroy: function() {
            if (this.thumbscrollerElement) {
                this.thumbscrollerElement.remove();
            }

            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });


})(jQuery);
