/*!
 * photo.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};
zz.template_cache = zz.template_cache || {};

(function($, undefined) {
    var photo_template = null,
        photo_caption_template = null,
        photo_rollover_frame = null;

    $.widget('ui.zz_photo', {
        options: {
            photoGrid: null,

            json: null,
            caption: null,                //model
            src: null,                    //model
            previewSrc: null,             //model
            rolloverSrc: null,            //model

            allowDelete: false,          //context
            onDelete: jQuery.noop,        //model
            maxHeight: 120,               //context
            maxWidth: 120,                //context
            rotatedHeight: 0,
            rotatedWidth: 0,

            allowEditCaption: false,      //context
            onChangeCaption: jQuery.noop, //model

            scrollContainer: null,
            lazyLoadThreshold: 0,
            onClick: jQuery.noop,         //model
            photoId: null,                //model
            aspectRatio: 0,               //model
            isUploading: false,           //model
            isError: false,               //model
            showButtonBar: false,         //model
            infoMenuTemplateResolver: null,        // show InfoMenu or not and what style
            context: null,                //context -- album-edit, album-grid, album-picture, album-timeline, album-people, chooser-grid, chooser-picture
            type: 'photo',               //photo \ folder \ blank
            rolloverFrameContainer: null,
            captionHeight: 30,
            captionLength: 400
        },

        _create: function() {
            var self = this,
                el = self.element,
                o = self.options;

            // Store a finished template re-use for every photo.
            if ( photo_template == null ) {
                photo_caption_template = $('<div class="photo-caption ellipsis multiline"></div>');
                photo_template = $('<div class="photo-border">' +
                                                     '<img class="photo-image" src="' +zz.routes.image_url('/images/photo_placeholder.png') + '">' +
                                                     '<img class="bottom-shadow" src="' + zz.routes.image_url('/images/photo/bottom-full.png') + '">' +
                                                     '</div>');

               photo_rollover_frame = $('<div class="photo-rollover-frame">' +
                                                                '<div class="button-bar">' +
                                                                    //SUNSET'<div class="button share-button"></div>' +
                                                                    '<div class="button like-button zzlike" data-zzid="" data-zztype="photo"><div class="zzlike-icon thumbdown"></div></div>' +
                                                                    //SUNSET'<div class="button comment-button"><div class="count"></div></div>' +
                                                                    '<div class="button info-button"></div>' +
                                                                    //SUNSET'<div class="button buy-button"></div>' +
                                                                '</div>' +
                                                           '</div>');
            }

            
            self.captionElement = photo_caption_template.clone();
            self.borderElement = photo_template.clone();
            self.imageElement = self.borderElement.find('.photo-image');
            self.bottomShadow = self.borderElement.find('.bottom-shadow');

            var initialHeight;
            var initialWidth;
            if (o.aspectRatio) {
                var srcWidth = o.aspectRatio;
                var srcHeight = 1;

                var scaled = zz.image_utils.scale({width: srcWidth, height: srcHeight}, {width: Math.min(o.maxWidth, o.json.rotated_width), height: Math.min(o.maxHeight - o.captionHeight, o.json.rotated_height)});
                initialHeight = scaled.height;
                initialWidth = scaled.width;
            } else {
                var min = Math.min(o.maxWidth, o.maxHeight);
                initialWidth = min;
                initialHeight = min;
            }

            self.imageElement.css({
                width: initialWidth,
                height: initialHeight
            });

            self.bottomShadow.css({'width': (initialWidth + 14) + 'px'});

            //element is probably invisible at this point, so we need to check the css attributes
            self.width = parseInt(el.css('width'));
            self.height = parseInt(el.css('height'));

            var borderWidth = initialWidth + 10;
            var borderHeight = initialHeight + 10;

            self.borderElement.css({
                top: (self.height - borderHeight - o.captionHeight) / 2,
                left: (self.width - borderWidth) / 2,
                width: borderWidth,
                height: borderHeight
            });


            // delete Button
            if (o.allowDelete) {
                self.deleteButtonElement = $('<div class="photo-delete-button">')
                        .click(function() {
                    self.delete_photo();
                });
                self.borderElement.append(self.deleteButtonElement);
            }

            //caption
            self.captionElement.text(o.caption);

            //for selenium tests...
            self.borderElement.attr('id', 'photo-border-' + (o.caption || '').replace(/[\W]+/g, '-'));

            if (o.type === 'blank') {
                self.borderElement.hide();
                self.captionElement.hide();
            }

            if (o.context.indexOf('chooser') === 0) {
                //magnify
                if (o.type === 'photo') {
                    self.photoAddElement = $('<div class="photo-add-button"><div class="scrim"></div><div class="icon"></div></div>');
                    self.photoAddElement.click(function(event) {
                        o.onClick('main');
                    });
                    self.photoMagnifyElement = $('<div class="magnify-button">');
                    self.photoMagnifyElement.click(function(event) {
                        o.onClick('magnify');
                    });
                    self.borderElement.append(self.photoAddElement).append(self.photoMagnifyElement);
                }
                else {
                    self.borderElement.addClass('no-shadow');
                }
            }

            //click
            self.imageElement.click(function(event) {
                o.onClick('main');
            });

            //uploading glyph
            if (o.isUploading && !o.isError) {
                self.uploadingElement = $('<div class="photo-status-scrim"></div><div class="photo-status-bar"><span class="photo-status uploading">Uploading</span></div>');
                self.borderElement.append(self.uploadingElement);
            }

            //error glyph
            if (o.isError) {
                self.errorElement = $('<div class="photo-status-scrim"></div><div class="photo-status-bar"><span class="photo-status error">Error</span></div>');
                self.borderElement.append(self.errorElement);
            }


            //lazy loading
            if (o.type !== 'photo') {
                // for photos the src is set to  '/images/photo_placeholder.png'
                self._loadImage();
            }

            //rollover
            if (o.rolloverSrc) {
                //preload rollover
                zz.image_utils.pre_load_image(o.rolloverSrc);

                el.mouseover(function() {
                    self.imageElement.attr('src', o.rolloverSrc);
                });

                el.mouseout(function() {
                    self.imageElement.attr('src', o.src);
                });
            }

            self._mouseEnterHandler = function(){
                // bunch of tricky stuff here
                // - on rollover, we need to clone the photo, add the rollover frame, then append
                //   it another element so that the rollover frame can spill out of the photo grid element
                //
                // - because the cloned element appears over the original, we need to 'hand off' the mouseover
                //   events from one to the other
                //
                // - while any of the menus is open, we need to keep the rollover frame open, even if mouse is no
                //   longer over the frame

                var rollover_clone_parent = self.options.rolloverFrameContainer;
                var rollover_clone = el.clone();
                self.rollover_clone = rollover_clone;
                var left = el.offset().left - rollover_clone_parent.offset().left ;
                var top = el.offset().top - rollover_clone_parent.offset().top + rollover_clone_parent.scrollTop();

                rollover_clone.css({left: left, top: top});
                rollover_clone.appendTo(rollover_clone_parent);

                // setup the rollover frame
                var rollover_frame = photo_rollover_frame.clone();
                var menu_open = false;
                var mouse_over_el = true;
                var mouse_over_clone = false;

                var hide_frame = function(){
                    rollover_clone.remove();
                };

                var check_hide_frame = function(){
                    // defer so that all the event handlers have had a
                    // chance to run (we might have one mouseout and one mouseover)

                    _.defer(function(){
                        if(!menu_open && !mouse_over_el && !mouse_over_clone){
                            hide_frame();
                        }
                    });
                };


                rollover_clone.mouseover(function(){
                    mouse_over_clone = true;
                });

                rollover_clone.mouseleave(function(){
                    mouse_over_clone = false;
                    check_hide_frame();
                });

                el.mouseout(function(){
                    mouse_over_el = false;
                    check_hide_frame();
                });


                rollover_clone.prepend(rollover_frame);
                rollover_frame.center_x();
                rollover_clone.css({'z-index': 100});


                // redirect clicks to the original element...
                rollover_clone.find('.photo-image').click(function(){
                    rollover_clone.remove();
                    self.imageElement.click();
                });


                // setup the button bar
                var button_bar = rollover_frame.find('.button-bar');

                // share button
                var share_button = button_bar.find('.share-button');
//                share_button.click(function(){
//                    menu_open = true;
//                    zz.sharemenu.show(share_button, 'photo', o.photoId, {x: 0, y: 0}, 'frame', 'auto', function(){
//                        menu_open = false;
//                        check_hide_frame();
//                    });
//                });


                // like button
                var like_button = button_bar.find('.like-button');
                like_button.attr('data-zzid', o.photoId);
                zz.like.draw_tag(like_button);



                // comment button
                var comment_button = button_bar.find('.comment-button');
                zz.comments.get_pretty_comment_count_for_photo(zz.page.album_id, o.photoId, function(count){
                    var count_element = comment_button.find('.count');
                    if(!count){
                        count_element.hide();
                    }
                    else{
                        count_element.text(count);
                    }
                });
//                comment_button.click(function(){
//                    zz.comments.show_in_dialog(zz.page.album_id, zz.page.album_cache_version_key, o.photoId);
//                    hide_frame();
//                    ZZAt.track('photo.comment.frame.click');
//                });



                // info button and menu
                var info_menu_template = null;
                if (o.infoMenuTemplateResolver) {
                    info_menu_template = o.infoMenuTemplateResolver(o.json);
                }

                var info_button = button_bar.find('.info-button');
                if(info_menu_template){
                    info_button.click(function(){
                        menu_open = true;
                        zz.infomenu.show_in_photo(info_button, info_menu_template, self, o.photoId, function(){
                            menu_open = false;
                            check_hide_frame();
                        });

                    });
                }
                else{
                    info_button.hide();
                }

                var buy_button = button_bar.find('.buy-button');
//SUNSET
//                buy_button.click(function(){
//                    ZZAt.track('photo.buy.frame.click');
//                    if(zz.buy.is_photo_selected(o.photoId)){
//                        zz.buy.activate_buy_mode();
//                    }
//                    else{
//                        zz.buy.add_selected_photo(o.json, self.element);
//                    }
//                });

                //Enable Caption Editing
                if( o.allowEditCaption ){
                    if( self.isEditingCaption ){
                        //If editing caption is active when mouseover happens turn it off
                        self.resetCaption();
                    }
                    rollover_clone.find('div.photo-caption').unbind('click.edit_caption').bind('click.edit_caption',function(event) {
                        self.editCaption();
                    });
                }
                button_bar.center_x();
            };

            el.append(self.captionElement).append(self.borderElement);

            if (o.showButtonBar) {
                el.mouseenter(self._mouseEnterHandler);
            }else{
                if( o.allowEditCaption ){
                    self.captionElement.ellipsis();
                    self.setupCaptionEdit();
                }
            }

            // insert elements into DOM
            if (o.context.indexOf('chooser') === 0) {
                self.updateChecked();
            }
        },

        delete_photo: function() {
            var self = this,
                o = self.options;
            if( !_.isUndefined( self.rollover_clone )){
                self.rollover_clone.trigger('mouseleave');
            }
            if (confirm('Are you sure you want to delete this photo?')) {
                var next_photo = o.photoGrid.nextPhoto( o.json.id );
                if( o.onDelete() ) {
                    if (!_.isUndefined(self.captionElement)) {
                        self.captionElement.hide();
                    }
                    if (!_.isUndefined(self.deleteButtonElement)) {
                        self.deleteButtonElement.hide();
                    }
                    self.borderElement.hide('scale', {}, 300, function() {
                        self.element.animate({width: 0}, 500, function() {
                            if( !_.isUndefined( self.rollover_clone )){
                                self.rollover_clone.trigger('mouseleave');
                            }
                            self.element.remove();
                            if (o.photoGrid) {
                                o.photoGrid.resetLayout();
                                if( o.context == 'album-picture'){
                                    o.photoGrid.scrollToPhoto(next_photo.id);
                                }else{
                                    o.photoGrid.element.trigger('scroll');
                                }
                            }
                            self.destroy();
                        });
                    });
                }
            }
        },

        updateChecked: function(){
            var self = this;

            if (self.options.context.indexOf('chooser') === 0) {
                if (self.isChecked()) {
                    self.element.find('.photo-add-button').addClass('checked');
                }
                else {
                    self.element.find('.photo-add-button').removeClass('checked');
                }
            }
        },

        isChecked: function() {
            return this.options.json.checked;
        },

        setChecked: function(checked) {
            var self = this;
            self.options.json.checked = checked;
            self.updateChecked();
        },

        loadIfVisible: function(containerDimensions) {
            var self = this;
            if( !_.isUndefined( self.rollover_clone) ){
              self.rollover_clone.trigger('mouseleave');
            }
            if (!self.imageLoaded) {
                if (self._inLazyLoadRegion(containerDimensions)) {
                    self._loadImage();
                }
            }
        },


        loadIfVisibleFast: function( offset, height, width ){
            if (!this.imageLoaded) {
                if (this._inLazyLoadRegionFast(offset, height, width)) {
                    this._loadImage();
                }
            }
        },

        _inLazyLoadRegionFast: function(offset, height, width) {
            var threshold = this.options.lazyLoadThreshold;
            
            var elementOffset = $(this.element).offset(); //todo: expensive call. cache/pass-in if possible; maybe can cache after grid resize
            var elementWidth = this.options.maxWidth;
            var elementHeight = this.options.maxHeight;

            var foldBottom = offset.top + height;
            var foldRight = offset.left + width;
            var foldTop = offset.top;
            var foldLeft = offset.left;


            var left = (foldLeft >= elementOffset.left + threshold + elementWidth);
            var above = (foldTop >= elementOffset.top + threshold + elementHeight);
            var right = (foldRight <= elementOffset.left - threshold);
            var below = (foldBottom <= elementOffset.top - threshold);

            return (!left) && (!right) && (!above) && (!below);
        },


        changeSrc: function(json_photo) {
            var self = this,
                o = self.options;


            if( o.context == 'album-picture' ) {
                o.src = json_photo.full_screen_url;
            }else{
                o.src = json_photo.screen_url;
            }

            o.previewSrc  = json_photo.stamp_url;
            o.rolloverSrc = json_photo.rolloverSrc;
            o.aspectRatio = 0;
            
            //propagate the changes to the model
            o.json.full_screen_url = json_photo.full_screen_url;
            o.json.screen_url = json_photo.screen_url;
            o.json.stamp_url = json_photo.stamp_url;
            self._trigger('changesrc', null, json_photo);
            self._loadImage();
        },

        _loadImage: function() {
            var self = this;

            var initialSrc = self.options.src;

            if (self.options.previewSrc) {
                initialSrc = self.options.previewSrc;
            }

            zz.image_utils.pre_load_image(initialSrc, function(image) {
                self.imageObject = image;
                self.imageLoaded = true;
                self._resize();

                //show the small version
                self.imageElement.attr('src', initialSrc);


                //show the full version
                zz.image_utils.pre_load_image(self.options.src, function(image) {
                    self.imageElement.attr('src', self.options.src);
                    self._resize({height: image.height, width: image.width});
                });
            });
        },

        _resize: function(imageSize) {
            var self = this,
                    o = self.options;

            var scaled = zz.image_utils.scale({width: self.imageObject.width, height: self.imageObject.height}, {width: self.options.maxWidth, height: self.options.maxHeight - o.captionHeight});


            // make sure we don't stretch smaller photos. they should not
            // be bigger than their natural size
            if(imageSize){
                if(scaled.width > imageSize.width){
                    scaled = imageSize;
                }
            }


            var borderWidth = scaled.width + 10;
            var borderHeight = scaled.height + 10;


            self.borderElement.css({
                top: (self.height - borderHeight - o.captionHeight) / 2,
                left: (self.width - borderWidth) / 2,
                width: borderWidth,
                height: borderHeight
            });

            self.imageElement.css({
                width: scaled.width,
                height: scaled.height
            });

            self.bottomShadow.css({'width': (scaled.width + 14) + 'px'});
        },

        _inLazyLoadRegion: function(containerDimensions /*optional param with container dimensions */) {
            var container = this.options.scrollContainer;
            var threshold = this.options.lazyLoadThreshold;

            if (containerDimensions) {
                var containerOffset = containerDimensions.offset;
                var containerHeight = containerDimensions.height;
                var containerWidth = containerDimensions.width;
            }
            else {
                var containerOffset = $(container).offset();
                var containerHeight = $(container).height();
                var containerWidth = $(container).width();
            }


            var elementOffset = $(this.element).offset(); //todo: expensive call. cache/pass-in if possible; maybe can cache after grid resize
            var elementWidth = this.options.maxWidth;
            var elementHeight = this.options.maxHeight;

            if (container === undefined || container === window) {
                var foldBottom = $(window).height() + $(window).scrollTop();
                var foldRight = $(window).width() + $(window).scrollLeft();
                var foldTop = $(window).scrollTop();
                var foldLeft = $(window).scrollLeft();
            } else {
                var foldBottom = containerOffset.top + containerHeight;
                var foldRight = containerOffset.left + containerWidth;
                var foldTop = containerOffset.top;
                var foldLeft = containerOffset.left;
            }


            var left = (foldLeft >= elementOffset.left + threshold + elementWidth);
            var above = (foldTop >= elementOffset.top + threshold + elementHeight);
            var right = (foldRight <= elementOffset.left - threshold);
            var below = (foldBottom <= elementOffset.top - threshold);

            return (!left) && (!right) && (!above) && (!below);
        },

        setupCaptionEdit: function(){
            var self = this;
            if( self.options.allowEditCaption ){
                self.captionElement.unbind('click.edit_caption');
                self.captionElement.bind('click.edit_caption',function() {
                    self.editCaption();
                });
            }
        },

        resetCaption: function( caption ){
            var self = this;
            if (self.isEditingCaption){

                if( typeof(caption) == 'undefined' ){
                    caption = self.options.caption;
                }

                self.captionElement.text(caption);
                self.isEditingCaption = false;
                self.captionElement.ellipsis();
                self.setupCaptionEdit();
                if( self.options.showButtonBar ){
                    self.element.mouseenter( self._mouseEnterHandler );
                }
            }
        },

        editCaption: function() {
            var self = this,
                o = self.options;

            if (!self.isEditingCaption){
                self.isEditingCaption = true;

                //Avoid having the frame rollover appear if we are editing caption
                self.element.unbind( 'mouseenter', self._mouseEnterHandler);

                if( !_.isUndefined( self.rollover_clone) ){
                    //If the rollover is active, hide it by triggering mouseleave
                    self.rollover_clone.trigger('mouseout').trigger('mouseleave');
                }

                var captionEditor = $('<div class="caption-editor"><div class="caption-editor-inner"><div class="edit-caption-border"><input type="text"><div class="caption-ok-button"></div></div></div></div>');
                self.captionElement.html(captionEditor);

                var textBoxElement = captionEditor.find('input');
                var okButton = captionEditor.find('.caption-ok-button');

                var commitChanges = function(){
                    disarmCaptionEditor(); //disarm to avoid rapid clickcing
                    ZZAt.track('photoframe.caption.edit.click');
                    var newCaption = $.trim( textBoxElement.val() );
                    if (newCaption !== o.caption) {
                        o.caption = newCaption;
                        o.json.caption = newCaption;
                        o.onChangeCaption(newCaption);
                    }
                    self.resetCaption( newCaption );
                };

                var armCaptionEditor = function(){
                    textBoxElement.val(o.caption);

                    okButton.click(function(event) {
                        commitChanges();
                        event.stopPropagation();
                        return false;
                    });
                    textBoxElement.blur(function() {
                        commitChanges();
                        return false;
                    });

                    textBoxElement.keyup(function(){
                        var text = $(this).val();
                        if(text.length > o.captionLength ){
                            alert("Photo caption name cannot exceed "+o.captionLength+" characters");
                            var new_text = text.substr(0, o.captionLength);
                            $(this).val(new_text);
                            $(this).selectRange( o.captionLength,o.captionLength);
                        }
                    });

                    textBoxElement.keydown(function(e) {
                        e.stopPropagation();
                        if(  e.keyCode == 13 ){  //enter key
                            commitChanges();
                            return false;
                        }else if(  e.keyCode == 9 ){ //tab key
                            commitChanges();
                            if( e.shiftKey ){ //tab back
                                if (!_.isUndefined(o.photoGrid)) {
                                    if( o.showButtonBar ){ //grid view
                                        var prev_photo = o.photoGrid.previousPhoto(o.json.id);
                                        o.photoGrid.scrollToPhoto( prev_photo.id, 100, false, function(){ prev_photo.ui_photo.editCaption();});
                                    }else{
                                        o.photoGrid.previousPicture(function(photo){
                                            photo.ui_photo.editCaption();
                                        });
                                    }
                                }
                            } else { //tab forward
                                if (!_.isUndefined(o.photoGrid)) {
                                    if( o.showButtonBar ){ //grid view
                                        var next_photo = o.photoGrid.nextPhoto(o.json.id);
                                        o.photoGrid.scrollToPhoto( next_photo.id, 100, false, function(){ next_photo.ui_photo.editCaption();});
                                    }else{
                                        o.photoGrid.nextPicture(function(photo){
                                            photo.ui_photo.editCaption();
                                        });
                                    }
                                }
                            }
                            return false;
                        }else if( e.keyCode == 27 ){  //escape
                            self.resetCaption();
                        }
                    });
                    textBoxElement.focus();
                    textBoxElement.select();
                };

                var disarmCaptionEditor = function(){
                    okButton.unbind('click');
                    textBoxElement.unbind( 'keydown')
                        .unbind('blur');
                };

                armCaptionEditor();
            }
        },

        getPhotoId: function() {
            return this.options.photoId;
        },

        dragStart: function() {
            this.element.addClass('dragging');
        },

        dragEnd: function() {
            this.element.removeClass('dragging');
        },

        dragHelper: function() {
            var helper = this.element.clone();
            helper.find('.photo-delete-button').hide();
            return helper;
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });

})(jQuery);
