/*!
 * photogrid.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function($, undefined) {

    var photogrid_droppablecell_template =  $('<div class="photogrid-cell"><div class="photogrid-droppable"></div></div>');
    var photogrid_cell_template =  $('<div class="photogrid-cell"></div>');
    var add_all_button = { id: 'add-all-photos',  caption: '', type: 'blank' };

    $.widget('ui.zz_photogrid', {
        options: {
            photos: [],                   // The photos array
            sort: 'date-asc',             // The desired sort method for photos date-asc, date-desc, name-desc, name-asc

            context: 'album-grid',        // Where is the grid being used
            centerPhotos: true,           // Used to center photogrid on screen (not centered on timeline or people view)
            topPadding: 10,               // The space between the top of the photogrid element and the top row of photos

            cellWidth: 200,               // Cell size
            cellHeight: 200,

            allowDelete: false,           // Should delete show in the info-menu?
            onDelete: jQuery.noop,        // delete callback

            allowEditCaption: false,       // Should caption be editable
            onChangeCaption: jQuery.noop,  // caption change callback

            allowReorder: false,           // Should grid be re-orderable
            onChangeOrder: jQuery.noop,    // reorder callback

            onClickPhoto: jQuery.noop,     // click callback

            showThumbscroller:  true,       // Bottom thumb scroller (picture view)
            hideNativeScroller: false,     // hide horizontal scroller

            singlePictureMode: false,      // Picture View
            currentPhotoId: null,          // Scroll Picture View to this photo
            onScrollToPhoto: jQuery.noop,  // picture view scroll callback

            lazyLoadThreshold: null,

            showButtonBar: false,           // Should the rollover button bar be displayed (photochooser or picture view)
            rolloverFrameContainer: $('#article'), //Where to attach the rollover button bar
            infoMenuTemplateResolver: null, // Function used to decide which buttons should show on the info menu.

            addAllButton : false           // When true, the add-all button will be shown in the first grid position
        },

        _create: function() {
            var self = this,
                o = self.options,
                el = self.element;

            // - create photo_array and photo_hash
            // - free memory taken by o.photos by clearing it
            // for performance improvement
            self._process_photos();
            o.photos = new Array();

            if( o.currentPhotoId == 'first'){
                o.currentPhotoId = self.photo_array[0].id;
            }

            // Large album optimization flag
            self.large_album = self.photo_count > 2000 ;
            if( self.large_album ){
                self.large_album_dialog = zz.dialog.show_spinner_progress_dialog("Wowsers! Your album has "+self.photo_count+" photos. It will take us a minute or two to display it. Please be patient", 350, 150);
            }

            // decide scroll direction
            // for grid view (vertical) or single picture view (horizontal)
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

            // save the current container size before we hide it
            self.width = parseInt(el.css('width'));
            self.height = parseInt(el.css('height'));
            el.hide(); //hide it for speed inserting photos

            //choose template for cells and size it as desired
            var template;
            if( o.allowReorder ){
                template = photogrid_droppablecell_template.clone();
            }else{
                 // when allowReorder is 'false' don't add the drop target elements
                template = photogrid_cell_template.clone();
            }
            template.css({
                width: o.cellWidth,
                height: o.cellHeight
            });

            // Setup the lazyLoad edge threshold
            if (o.lazyLoadThreshold != 0 && !o.lazyLoadThreshold && o.singlePictureMode) {
                o.lazyLoadThreshold = o.cellWidth * 3;
            }

            //max dimenstions for photos
            var max_width = Math.floor(o.cellWidth - 50);
            var max_height = Math.floor(o.cellHeight - 50 - 5); //35 accounts for height if caption. this is also set in photo.js

            // This function creates a single photo cell and appends it to the grid.
            // It is called below inside a loop that regularly allows the system to
            // process other events.
            var create_photo = function(index, photo) {
                var cell = template.clone();
                cell.zz_photo({
                    photoGrid:   self,

                    json:        photo,
                    photoId:     photo.id,
                    caption:     photo.caption,
                    aspectRatio: photo.aspect_ratio,
                    previewSrc:  photo.previewSrc,
                    src:         photo.src,
                    rolloverSrc: photo.rolloverSrc,

                    type:        _.isUndefined(photo.type) ? 'photo' : photo.type,
                    isUploading: ! _.isUndefined(photo.state) ? photo.state !== 'ready' : false, //todo: move into photochooser.js
                    isError:     photo.state === 'error',

                    context:     o.context,
                    maxWidth:    max_width,
                    maxHeight:   max_height,

                    allowDelete: o.allowDelete,
                    onDelete: function() {
                        var i = self.indexOfPhoto( photo.id );
                        self.photo_array.splice( i, 1);
                        delete self.photo_hash[photo.id];
                        self.photo_count--;
                        if (o.showThumbscroller) {
                            self.thumbscroller.removePhoto( i );
                        }
                        return o.onDelete(index, photo);
                    },

                    allowEditCaption: o.allowEditCaption,
                    onChangeCaption: function(caption) {
                        var i = self.indexOfPhoto( photo.id );
                        photo.caption = caption;
                        self.photo_array[i].caption_sort_key = caption+self.photo_array[i].date_sort_key;
                        self.current_sort = 'none';
                        return o.onChangeCaption(index, photo, caption);
                    },

                    onClick: function(action) {
                        o.onClickPhoto(index, photo, cell, action);
                    },

                    scrollContainer: el,
                    lazyLoadThreshold: o.lazyLoadThreshold,

                    showButtonBar: o.showButtonBar,
                    infoMenuTemplateResolver: o.infoMenuTemplateResolver,
                    rolloverFrameContainer: o.rolloverFrameContainer
                });
                // Append cell, lay it out in the right spot and save the ui components
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
            var time_lapse = 1; //milliseconds between batches
            var create_some_photos = function(i) {
                if (i < self.photo_count) { //recursion termination condition

                    //create a batch of photos
                    for (var j = i; j < i + batch_size && j < self.photo_count; j++) {
                       create_photo(j, self._get_photo(j));
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
                                create_photo(index, self._get_photo( index ) );
                            }
                            self._show_and_arm();
                            self._get_photo( index ).ui_photo.loadIfVisible();
                        }else{
                            // Grid View - Show as soon as we have first screen ready
                            // loadif visible for first screen only
                            if( !self.large_album ){
                                setTimeout( function(){
                                    self._show_and_arm();
                                    for (var k = i; k < j ; k++) {
                                        self._get_photo(k).ui_photo.loadIfVisible();
                                    }
                                }, time_lapse);
                            }
                        }
                    }

                    // Queue next batch for processing
                    //  Even a 0 timeout lets the system process any pending stuff and then this.
                    setTimeout( function(){ create_some_photos(i + batch_size); }, time_lapse);

                } else {
                    //All photos have been created, add bells and whistles
                    if( self.large_album ){
                        setTimeout( function(){
                            self._show_and_arm();
                            self.large_album_dialog.close();
                            for (var k = 0; k < self.photo_count ; k++) {
                                self._get_photo(k).ui_photo.loadIfVisible();
                            }
                            self._trigger('ready');
                        }, time_lapse);
                    }

                    //hideNativeScroller
                    if (o.hideNativeScroller) {
                        if (o.singlePictureMode) {
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-horizontal"></div>').appendTo(el.parent());
                        }else{
                            self.thumbscrollerElement = $('<div class="photogrid-hide-native-scroller-vertical"></div>').appendTo(el.parent());
                        }
                    }

                    //thumbscroller
                    self._setupThumbScroller();

                    //mousewheel, swipe  and keyboard for single picture
                    if (o.singlePictureMode) {
                        el.mousewheel(function(event) {
                            var delta;
                            if (typeof(event.wheelDelta) !== 'undefined') {
                                delta = event.wheelDelta;
                            } else {
                                delta = -1 * event.detail;
                            }

                            if (delta < 0) {
                                self.nextPicture();
                            } else {
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

                        //capture keys
                        $(document.documentElement).keydown(function(event) {
                            switch( event.keyCode ){
                                case 40: //down
                                    self.nextPicture();
                                    break;
                                case 39:  //right
                                    self.nextPicture();
                                    break;
                                case 34: //page down
                                    self.nextPicture();
                                    break;
                                case 38: //up
                                    self.previousPicture();
                                    break;
                                case 37: //left
                                    self.previousPicture();
                                    break;
                                case 33: //page up
                                    self.previousPicture();
                                    break;
                            }
                        });
                    }

                    //scroll to photo
                    if (o.currentPhotoId !== null) {
                        self.scrollToPhoto(o.currentPhotoId, 0, false);
                    }
                     if( !self.large_album ){
                        self._trigger('ready');
                     }
                }
            };

            if( self.photo_count > 0 ){
                //Insert add all button (must be called before sort)
                if( o.addAllButton ){
                    add_all_button.src = zz.routes.image_url('/images/blank.png');
                    self._insert_add_all_button();
                }
                //sort the photos for the grid
                if( o.sort ){
                    self.sort_by( o.sort, true ); //no layout
                }else{
                    self.current_sort = 'date-asc'
                }

                //optimize parameters for large albums
                if( self.large_album ){
                    batch_size = 200;
                }
                // Start creating photos, at the end of the creation
                // process all grid elements will be bound and active
                create_some_photos(0);
            }else{
                //Empty Album - Display no photos in this album sign
                el.html('<div class="no-photos">There are no photos in this album</div>');
                el.show();
            }
        },

        // Display the element (which was hidded in _create)
        // bind scrolling and window resizing
        _show_and_arm: function(){
            var self = this,
                o    = self.options,
                el   = self.element;

            el.fadeIn('fast');

            // Window Resize Handler
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

            // Scroll Handler
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
                    for( var i=0; i < self.photo_count ; i++){
                        var photo = self._get_photo(i);
                        if( !_.isUndefined( photo.ui_photo) ){
                            photo.ui_photo.loadIfVisible( containerDimensions );
                        }
                    }
                }, 200);
            });
            self._trigger('visible');
        },

        hideThumbScroller: function() {
            if (this.thumbscrollerElement) {
                this.thumbscrollerElement.hide();
            }
        },

        nextPrevActive: false,

        nextPicture: function(afterScroll) {
            var self = this;

            if (!self.nextPrevActive) {
                var animateDuration = 500;

                var index = self.indexOfPhoto(self.currentPhotoId());
                index++;

                if (index > self.photo_count - 1) {
                    // if at the end, then go to beginning
                    index = 0;
                    animateDuration = 0;
                }

                var photo = self._get_photo(index);
                if( self.options.allowEditCaption ){
                    photo.ui_photo.resetCaption();
                }
                self.nextPrevActive = true;
                self.scrollToPhoto( photo.id, animateDuration, true, function() {
                    self.nextPrevActive = false;
                     if( !_.isUndefined( afterScroll )){
                        afterScroll( photo );
                    }
                });
            }
        },

        previousPicture: function( afterScroll ) {
            var self = this;

            if (!self.nextPrevActive) {
                var animateDuration = 500;

                var index = self.indexOfPhoto(self.currentPhotoId());
                index--;

                if (index < 0) {
                    // go to the end
                    index = self.photo_count-1;
                    var animateDuration = 0;
                }

                var photo = self._get_photo( index );
                if( self.options.allowEditCaption ){
                    photo.ui_photo.resetCaption();
                }
                self.nextPrevActive = true;
                self.scrollToPhoto(photo.id, animateDuration, true, function() {
                    self.nextPrevActive = false;
                    if( !_.isUndefined( afterScroll )){
                        afterScroll( photo );
                    }
                });
            }
        },

        nextPhoto: function( id ) {
            var self = this;
            var index = self.indexOfPhoto(id);
            index++;
            if (index > self.photo_count - 1){
                // if at the end, then go to beginning
                index = 0;
            }
            return self._get_photo( index );
        },

        previousPhoto: function( id ){
            var self = this;
            var index = self.indexOfPhoto(id);
            index--;
            if (index < 0){
                // go to the end
                index = self.photo_count-1;
            }
            return self._get_photo( index );
        },


        currentPhotoId: function() {
            var self = this,
                o = self.options;
            if (o.currentPhotoId) {
                return o.currentPhotoId;
            }else {
                if (self.photo_count > 0) {
                    return self.photo_array[0].id;
                } else {
                    return null;
                }
            }
        },

        indexOfPhoto: function(photoId) {
            //todo: this function won't work after a drag-drop reorder
            var self = this,
                wanted_id = photoId.toString();

            for (var i = 0; i < self.photo_count; i++) {
                if (self.photo_array[i].id == wanted_id) {
                    return i;
                }
            }
            return -1;
        },

        scrollToPhoto: function(photoId, duration, highlightCell, callback) {
            var self = this,
                o = self.options;

            if (self.photo_count == 0) {
                return;
            }

            var index = self.indexOfPhoto(photoId);

            if (index == -1) {
                index = 0;
                photoId = self.photo_array[0].id;
            }

            var onFinishAnimate = function() {
                self._get_photo( index ).ui_photo.loadIfVisible();
                o.currentPhotoId = photoId;
                o.onScrollToPhoto( index, self._get_photo( index ));
                if (typeof callback !== 'undefined') {
                    callback();
                }
            }


            if (o.singlePictureMode) {
                var x = index * o.cellWidth;

                self.animateScrollActive = true;
                self.element.animate({scrollLeft: x}, duration, 'easeOutCubic', function() {
                    self.animateScrollActive = false;
                    onFinishAnimate();
                });

            }
            else {
                var y = Math.floor(index / self.cellsPerRow()) * o.cellHeight;
                self.animateScrollActive = true;
                self.element.animate({scrollTop: y}, duration, 'easeOutCubic', function() {
                    self.animateScrollActive = false;
                    onFinishAnimate();
                });
            }
        },

        resetLayout: function(duration, easing, showIfVisible, callback) {
            var self = this,
                o = self.options,
                el = self.element;

            if (duration === undefined) {
                duration = 0;
            }

            el.find('.scroll-padding').remove();

            var top_of_last_row = 0;

            //do not animate albums with over 200 photos
            if( self.photo_count > 200 ){
                duration = 0;
                easing = 0;
            }

            var batch_size = 200;
            var layout_some_photos = function(i) {
               if (i < self.photo_count) { //recursion termination condition
                   //layout a batch of photos
                   for (var j = i; j < i + batch_size && j < self.photo_count; j++) {
                       self._layoutPhoto( self._get_photo(j), j, duration, easing, showIfVisible );
                   }
                    // Queue next batch for processing
                   //  Even a 0 timeout lets the system process any pending stuff and then this.
                   setTimeout( function(){ layout_some_photos(i + batch_size); }, 0);
               }else{
                   if(!_.isUndefined( callback ) ){
                       callback();
                   }
               }
            };
            layout_some_photos(0);

            if(!self.options.singlePictureMode){
                var scroll_padding = $('<div class="scroll-padding"></div>');
                scroll_padding.css({top: 330 }); // add the right of the rollover frame
                el.append(scroll_padding);
            }

        },

        _layoutPhoto: function( photo, index, duration, easing, showIfVisible ){
            if (  _.isUndefined( photo.ui_photo ) || _.isUndefined( photo.ui_cell ) ){
                return;
            }

            // calculate the position for this index
            var position = this.positionForIndex(index);

            //todo: moght want to check that things have actually changed before setting new properties
            if (duration && duration > 0 ) {
                photo.ui_cell.animate(position, duration, easing, function(){
                    if( showIfVisible ){
                        photo.ui_photo.loadIfVisible();
                    }
                });
            }else {
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
                return self.photo_count;
            }else {
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
            var self = this;
            if( self.large_album && typeof no_layout == 'undefined'){
                self.large_album_dialog = zz.dialog.show_spinner_progress_dialog("Hot Diggety! Did you take all of these? Sorting them for you, give us a minute", 350,150);
            }
            setTimeout( function(){
                switch(  self.current_sort  ){
                    case 'date-asc':
                        break;
                    case 'date-desc':
                        self.photo_array.reverse();
                        break;
                    default:
                        self._sort(  function (){ return this.date_sort_key; });
                        break;
                }

                if( typeof no_layout == 'undefined'){
                    self._timed_out_layout();
                }
            },10);
        },

        sort_by_date_desc: function( no_layout ){
            var self = this;
            if( self.large_album && typeof no_layout == 'undefined'){
                self.large_album_dialog = zz.dialog.show_spinner_progress_dialog("Blimey! Ordering a double-stack of pics. Give us a minute", 350,150);
            }
            setTimeout( function(){
                switch(  self.current_sort  ){
                    case 'date-asc':
                        self.photo_array.reverse();
                        break;
                    case 'date-desc':
                        break;
                    default:
                        self._sort(  function (){ return this.date_sort_key; });
                        self.photo_array.reverse();
                        break;
                }
                if( typeof no_layout == 'undefined'){
                    self._timed_out_layout();
                }
            },10);
        },

        sort_by_name_asc: function(no_layout){
            var self = this;
            if( self.large_album && typeof no_layout == 'undefined'){
                self.large_album_dialog = zz.dialog.show_spinner_progress_dialog("Woooha! We are sorting a ton of photos. Give us a minute", 350,150);
            }
            setTimeout( function(){
                switch(  self.current_sort  ){
                    case 'name-asc':
                        break;
                    case 'name-desc':
                        self.photo_array.reverse();
                        break;
                    default:
                        self._sort(  function(){ return this.caption_sort_key; });
                        break;
                }
                if( typeof no_layout == 'undefined'){
                    self._timed_out_layout();
                }
            },10);
        },

        sort_by_name_desc: function( no_layout ){
            var self = this;
            if(  self.large_album && typeof no_layout == 'undefined' ){
                self.large_album_dialog = zz.dialog.show_spinner_progress_dialog("Yeeeepeee! We are shuffling a bundle of photos. Give us a minute", 350,150);
            }
            setTimeout( function(){
                switch(  self.current_sort  ){
                    case 'name-asc':
                        self.photo_array.reverse();

                        break;
                    case 'name-desc':
                        break;
                    default:

                        self._sort(  function (){ return this.caption_sort_key; });
                        self.photo_array.reverse();


                        break;
                }
                if( typeof no_layout == 'undefined'){
                    self._timed_out_layout();
                }
            }, 10);
        },

        _timed_out_layout: function(){
            var self = this;
            if( self.large_album ){
                self.element.hide();
            }
            self.resetLayout(200, 'easeInOutCubic', true, function(){
                if( self.large_album ){
                    self.element.fadeIn('fast');
                    self.large_album_dialog.close();
                } else {
                    self.resetLayout(400, 'easeInOutCubic', true);
                }
            });
        },

        _sort: function( key_function ){
            if( this.options.addAllButton ){
                this._remove_add_all_button();                  // - remove add all button from the begining of array
            }
            var save = Object.prototype.toString;
            Object.prototype.toString = key_function;
            this.photo_array.sort();
            Object.prototype.toString = save;

            if( this.options.addAllButton ){
                this._insert_add_all_button();  // - insert add all button at the begining of array
            }
        },

        _setupThumbScroller: function(){
            var self = this,
                el = self.element,
                o = self.options;

            if (o.showThumbscroller) {
                var nativeScrollActive = false;

                if (o.singlePictureMode) {
                    self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-horizontal"></div>').appendTo(el.parent());
                } else {
                    self.thumbscrollerElement = $('<div class="photogrid-thumbscroller-vertical"></div>').appendTo(el.parent());
                }

                //remove any 'special' photos (eg blank one used for drag and drop on edit screen
                var photos = $.map(self.photo_array, function(lwphoto, index) {
                    var photo = self._get_photo( index );
                    return (photo.type != 'blank' ? photo : null);
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
                        } else {
                            index = Math.floor(el.scrollTop() / o.cellHeight * self.cellsPerRow());
                        }
                        self.thumbscroller.setSelectedIndex(index);
                        nativeScrollActive = false;
                    }
                });
            }
        },

        // Creates an array of lwphoto_array lightweight objects that contain
        // -id = photo id
        // -date_sort_key = capture_date_as_string+id_as_string
        // -caption_sort_key = caption+date_sort_key
        // the order of the photos is now preserved in this array not the options.photos
        // This method also processes options.photos and creates a photo_hash indexed by id
        // so we can quickly access photos using info from the lwphoto_array
        _process_photos: function(){
            var self = this,
                o = self.options,
                photos = o.photos;

            self.photo_array = new Array();
            self.photo_hash = {};
            self.photo_count = photos.length;
            for( var i= 0; i < self.photo_count; i++){
                var id_string = photos[i].id.toString();
                // create the date sort key
                var date_sort_key;
                if( photos[i].capture_date == null || photos[i].capture_date == ''){
                    date_sort_key = '0000-00-00T00:00:00-00:00'+id_string;
                }else{
                    date_sort_key = photos[i].capture_date.toString()+id_string;
                }
                // create the caption sort key
                var caption_sort_key;
                if( photos[i].caption == null || photos[i].caption == ''){
                    caption_sort_key = '                    '+date_sort_key;
                }else{
                    caption_sort_key = photos[i].caption.toLowerCase()+date_sort_key;
                }

                //create the hash and the array
                self.photo_hash[ id_string ] = photos[i];
                self.photo_array.push( {
                    id              : id_string ,
                    date_sort_key   : date_sort_key,
                    caption_sort_key: caption_sort_key
                } );
            }
        },

        _get_photo: function( index ){
            return this.photo_hash[ this.photo_array[index].id ];
        },

        _insert_add_all_button: function(){
            self.photo_array.unshift(add_all_button); //insert add all button at the begining of array
            self.photo_hash[ add_all_button.id ] = add_all_button
            self.photo_count++;
        },

        _remove_add_all_button: function(){
            self.photo_array.shift(); //insert add all button at the begining of array
            delete self.photo_hash[ add_all_button.id ];
            self.photo_count--;
        },
        destroy: function() {
            if (this.thumbscrollerElement) {
                this.thumbscrollerElement.remove();
            }
            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });

})(jQuery);
