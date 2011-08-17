/*!
 * photo.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

var zz = zz || {};
zz.template_cache = zz.template_cache || {};


(function($, undefined) {

    $.widget('ui.zz_photo', {
        options: {
            json: null,
            allowDelete: false,          //context
            onDelete: jQuery.noop,        //model
            maxHeight: 120,               //context
            maxWidth: 120,                //context
            caption: null,                //model
            allowEditCaption: false,      //context
            onChangeCaption: jQuery.noop, //model
            src: null,                    //model
            previewSrc: null,             //model
            rolloverSrc: null,            //model
            scrollContainer: null,
            lazyLoadThreshold: 0,
            onClick: jQuery.noop,         //model
            onMagnify: jQuery.noop,       //model
            photoId: null,                //model
            aspectRatio: 0,               //model
            isUploading: false,           //model
            isError: false,               //model
            showButtonBar: false,         //model
            infoMenuTemplateResololver: null,        // show InfoMenu or not and what style
            context: null,                //context -- album-edit, album-grid, album-picture, album-timeline, album-people, chooser-grid, chooser-picture
            type: 'photo',               //photo \ folder \ blank
            captionHeight: 30,
            rolloverFrameContainer: null

        },

        _create: function() {
            var self = this,
                el = self.element,
                o = self.options;

            // Store a finished template on the global namespace and re-use for every photo.
            if (_.isUndefined(zz.template_cache.photo_template)) {
                zz.template_cache.photo_caption_template = $('<div class="photo-caption"></div>');
                zz.template_cache.photo_template = $('<div class="photo-border">' +
                                                     '<img class="photo-image" src="' + zz.routes.image_url('/images/blank.png') + '">' +
                                                     '<img class="bottom-shadow" src="' + zz.routes.image_url('/images/photo/bottom-full.png') + '">' +
                                                     '</div>');

                zz.template_cache.photo_rollover_frame = $('<div class="photo-rollover-frame">' +
                                                                '<div class="social-buttons">' +
                                                                    '<div class="facebook-button"></div>' +
                                                                    '<div class="twitter-button"></div>' +
                                                                '</div>' +
                                                                '<div class="button-bar">' +
                                                                    '<div class="button share-button"></div>' +
                                                                    '<div class="button like-button zzlike" data-zzid="" data-zztype="photo"><div class="zzlike-icon thumbdown"></div></div>' +
                                                                    '<div class="button comment-button"><div class="count"></div></div>' +
                                                                    '<div class="button info-button"></div>' +
                                                                    '<div class="button buy-button"></div>' +
                                                                '</div>' +
                                                           '</div>');
            }

//                                    '<div class="button like-button zzlike" data-zzid="' + o.photoId + '" data-zztype="photo"><div class="zzlike-icon thumbdown"></div></div>';


            self.captionElement = zz.template_cache.photo_caption_template.clone();
            self.borderElement = zz.template_cache.photo_template.clone();
            self.imageElement = self.borderElement.find('.photo-image');
            self.bottomShadow = self.borderElement.find('.bottom-shadow');

            var initialHeight;
            var initialWidth;
            if (o.aspectRatio) {
                var srcWidth = o.aspectRatio;
                var srcHeight = 1;

                var scaled = zz.image_utils.scale({width: srcWidth, height: srcHeight}, {width: o.maxWidth, height: o.maxHeight - o.captionHeight});
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
                position: 'relative',
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
                    self.photoAddElement = $('<div class="photo-add-button">');
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
                self.uploadingElement = $('<div class="photo-uploading-icon">');
                self.borderElement.append(self.uploadingElement);
            }

            //error glyph
            if (o.isError) {
                self.errorElement = $('<div class="photo-error-icon">');
                self.borderElement.append(self.errorElement);
            }

            //edit caption
            self.isEditingCaption = false;
            if (o.allowEditCaption) {
                self.captionElement.click(function(event) {
                    self.editCaption();
                });
            }

            //lazy loading
            if (o.type !== 'photo') {
                self._loadImage();
            } else {
                self.imageElement.attr('src', zz.routes.image_url('/images/photo_placeholder.png'));
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


            if (o.showButtonBar) {

                el.mouseenter(function(){

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

                    var left = el.offset().left - rollover_clone_parent.offset().left ;
                    var top = el.offset().top - rollover_clone_parent.offset().top + rollover_clone_parent.scrollTop();


                    rollover_clone.css({left: left, top: top});
                    rollover_clone.appendTo(rollover_clone_parent);

                    
                    // setup the rollover frame
                    var rollover_frame = zz.template_cache.photo_rollover_frame.clone();
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


                    // setup facebook and twitter buttons
                    // 'defer' seems to improve the feel 
                    _.defer(function(){
                        var social_buttons = rollover_frame.find('.social-buttons');
                        var photo_url = zz.routes.photos.photo_url(o.photoId);
                        social_buttons.find('.twitter-button').append(zz.social_buttons.create_twitter_button_for_photo(photo_url));
                        social_buttons.find('.facebook-button').append(zz.social_buttons.create_facebook_button_for_photo(photo_url));
                    });


                    // setup the button bar
                    var button_bar = rollover_frame.find('.button-bar');

                    // share button
                    var share_button = button_bar.find('.share-button');
                    share_button.click(function(){
                        menu_open = true;
                        zz.sharemenu.show(share_button, 'photo', o.photoId, {x: 0, y: 0}, 'frame', 'auto', function(){
                            menu_open = false;
                            check_hide_frame();
                        });
                    });


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
                    comment_button.click(function(){
                        zz.comments.show_in_dialog(o.photoId);
                        hide_frame();
                    });



                    // info button and meny
                    var info_menu_template = null;
                    if (o.infoMenuTemplateResolver) {
                        info_menu_template = o.infoMenuTemplateResolver(o.json);
                    }

                    var info_button = button_bar.find('.info-button');
                    if(info_menu_template){
                        info_button.click(function(){
                            menu_open = true;
                            zz.infomenu.show(info_button, info_menu_template, self, o.photoId, function(){
                                menu_open = false;
                                check_hide_frame();
                            });

                        });
                    }
                    else{
                       info_button.hide(); 
                    }


                    button_bar.center_x()

                });
            }

            // insert elements into DOM
            el.append(self.captionElement).append(self.borderElement);
        },

        setMenuOpen: function(open) {
            if (open) {
                self.element.find('.photo-toolbar').addClass('menu-open');
            }
            else {
                self.element.find('.photo-toolbar').removeClass('menu-open');
            }
        },

        //delete
        delete_photo: function() {
            var self = this;

            if (self.options.scrollContainer.data().zz_photogrid) {
                self.photoGrid = self.options.scrollContainer.data().zz_photogrid;
            }

            if (confirm('Are you sure you want to delete this photo?')) {
                if (self.options.onDelete()) {
                    if (!_.isUndefined(self.captionElement)) {
                        self.captionElement.hide();
                    }
                    if (!_.isUndefined(self.deleteButtonElement)) {
                        self.deleteButtonElement.hide();
                    }
                    self.borderElement.hide('scale', {}, 300, function() {
                        self.element.animate({width: 0}, 500, function() {
                            self.element.remove();
                            if (!_.isUndefined(self.photoGrid)) {
                                self.photoGrid.resetLayout();
                                self.photoGrid.element.trigger('scroll');
                            }
                        });
                    });
                }
            }
        },

        checked: false,

        isChecked: function() {
            return this.checked;
        },

        setChecked: function(checked) {
            var self = this;
            self.checked = checked;
            if (self.options.context.indexOf('chooser') === 0) {
                if (checked) {
                    self.element.find('.photo-add-button').addClass('checked');
                }
                else {
                    self.element.find('.photo-add-button').removeClass('checked');
                }
            }
        },

        loadIfVisible: function(containerDimensions) {
            var self = this;
            if (!self.imageLoaded) {
                if (self._inLazyLoadRegion(containerDimensions)) {
                    self._loadImage();
                }
            }
        },

        changeSrc: function(src, previewSrc) {
            var self = this;
            self.options.src = src;
            self.options.previewSrc = previewSrc;
            self.options.aspectRatio = null;
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
                self._resize(1);

                //show the small version
                self.imageElement.attr('src', initialSrc);


                //show the full version
                zz.image_utils.pre_load_image(self.options.src, function(image) {
                    self.imageElement.attr('src', self.options.src);
                });
            });
        },

        _resize: function(percent) {
            var self = this,
                    o = self.options;

            var scaled = zz.image_utils.scale({width: self.imageObject.width, height: self.imageObject.height}, {width: self.options.maxWidth, height: self.options.maxHeight - o.captionHeight});


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

        editCaption: function() {
            var self = this;

            if (!self.isEditingCaption) {
                self.isEditingCaption = true;

                var captionEditor = $('<div class="edit-caption-border"><input type="text"><div class="caption-ok-button"></div></div>');
                self.captionElement.html(captionEditor);

                var textBoxElement = captionEditor.find('input');

                var commitChanges = function() {
                    var newCaption = textBoxElement.val();
                    if (newCaption !== self.options.caption) {
                        self.options.caption = newCaption;
                        self.options.onChangeCaption(newCaption);
                    }
                    self.captionElement.text(newCaption);
                    self.isEditingCaption = false;
                }


                textBoxElement.val(self.options.caption);
                textBoxElement.focus();
                textBoxElement.select();
                textBoxElement.blur(function() {
                    commitChanges();
                });

                textBoxElement.keydown(function(event) {

                    if (event.which == 13) {  //enter key
                        commitChanges();
                        return false;
                    }
                    else if (event.which == 9) { //tab key
                        if (event.shiftKey) {
                            textBoxElement.blur();

                            if (self.element.prev().length !== 0) {
                                self.element.prev().data().zz_photo.editCaption();
                            }
                            else {
                                self.element.parent().children().last().data().zz_photo.editCaption();
                            }
                        }
                        else {
                            textBoxElement.blur();
                            if (self.element.next().length !== 0) {
                                self.element.next().data().zz_photo.editCaption();
                            }
                            else {
                                self.element.parent().children().first().data().zz_photo.editCaption();
                            }
                        }
                        event.stopPropagation();
                        return false;
                    }
                });


                var okButton = captionEditor.find('.caption-ok-button');
                okButton.click(function(event) {
                    commitChanges();
                    event.stopPropagation();
                    return false;
                });


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
