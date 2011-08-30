/*!
 * thumbtray.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function($, undefined) {

    $.widget('ui.zz_thumbtray', {
        options: {
            photos: [],
            srcAttribute: 'src',
            previewSize: 120,
            selectionSize: 140,
            allowDelete: false,
            showSelection: false,
            selectedIndex: -1,
            thumbnailSize: 20,
            showSelectedIndexIndicator: false,
            repaintOnResize: false,
            onDeletePhoto: function(index, photo) {
            },
            onSelectPhoto: function(index, photo) {
            },
            onPreviewPhoto: function(index, photo) {
            }
        },

        currentIndex: -1,
        selectedIndex: -1,
        traySize: null,
        orientation: null,
        ORIENTATION_X: 'x',
        ORIENTATION_Y: 'y',
        PLACEHOLDER_IMAGE: '/images/photo_placeholder.png',

        _create: function() {
            var self = this;


            var html = '';
            html += '<div class="thumbtray-wrapper">';
            html += '<div class="thumbtray-thumbnails"></div>';
            html += '<div class="thumbtray-selection">';
            html += '<img src="' + zz.routes.image_url('/images/photo_placeholder.png') + '">';
            html += '</div>';
            html += '<div class="thumbtray-preview">';
            html += '<img src="' + zz.routes.image_url('/images/photo_placeholder.png') + '">';
            html += '<div class="thumbtray-delete-button"></div>';
            html += '</div>';
            html += '<img class="thumbtray-loading-indicator" src="' + zz.routes.image_url('/images/loading.gif') + '"/>';
            html += '<div class="thumbtray-mask"></div>';
            html += '<div class="thumbtray-current-index-indicator"></div>';
            html += '<div class="thumbtray-scrim"></div>';
            html += '</div>';

            this.element.html(html);


            this.wrapperElement = this.element.find('.thumbtray-wrapper');
            this.scrimElement = this.element.find('.thumbtray-scrim');
            this.maskElement = this.element.find('.thumbtray-mask');
            this.previewElement = this.element.find('.thumbtray-preview');
            this.selectionElement = this.element.find('.thumbtray-selection');
            this.thumbnailsElement = this.element.find('.thumbtray-thumbnails');
            this.loadingIndicator = this.element.find('.thumbtray-loading-indicator');
            this.selectedIndexIndicator = this.element.find('.thumbtray-current-index-indicator');


            //size and resize
            var setSize = function() {
                //these only work if element's is visible (ie display !- none)
                var width = self.element.width();
                var height = self.element.height();

                if (width > height) {
                    self.orientation = self.ORIENTATION_X;
                }
                else {
                    self.orientation = self.ORIENTATION_Y;
                }

                self.wrapperElement.css({width: width, height: height});
                self.scrimElement.css({width: width, height: height});
                self.maskElement.css({width: width, height: height});
                self.thumbnailsElement.css({width: width, height: height});


                if (self.orientation === self.ORIENTATION_X) {
                    self.previewElement.addClass('x');
                    self.selectionElement.addClass('x');
                    self.selectionElement.find('img').css({height: self.options.selectionSize});
                    self.previewElement.find('img').css({height: self.options.previewSize});
                    self.traySize = width;
                }
                else {
                    self.previewElement.addClass('y');
                    self.selectionElement.addClass('y');
                    self.selectionElement.find('img').css({width: self.options.selectionSize});
                    self.previewElement.find('img').css({width: self.options.previewSize});
                    self.traySize = height;
                }
            };
            setSize();

            if (self.options.repaintOnResize) {
                $(window).resize(function() {
                    setSize();
                    self._repaintThumbnails();
                });
            }



            this._repaintThumbnails();

            this._setSelectedIndex(this.options.selectedIndex);


            //delete button
            if (this.options.allowDelete) {
                self.previewElement.find('.thumbtray-delete-button').show().click(function() {
                    self.previewElement.find('.thumbtray-delete-button').hide();
                    self.removePhoto(self._getCurrentIndex());
                    self.previewElement.hide('scale', {}, 300, function() {
                        self.previewElement.find('.thumbtray-delete-button').show();
                    });

//                    self.previewElement.fadeOut('fast', function(){
//                        self.removePhoto(self._getCurrentIndex())
//                    });
                });
            }


            //mouse over and click handlers
            var mouseOver = false;


            var showPreview = function() {
                mouseOver = true;
                self.previewElement.fadeIn('fast');
            }

            var hidePreview = function() {
                mouseOver = false;
                setTimeout(function() {
                    if (!mouseOver) {
                        self.previewElement.fadeOut('fast');
                        if (self.options.showSelection) {
                            self.selectionElement.animate({opacity: 1}, 100);
                        }
                    }
                }, 100);
            }


            self.scrimElement.mousemove(function(event) {
                var index = null;

                if (self.orientation === self.ORIENTATION_X) {
                    self._getIndexForPosition(event.pageX - self.element.offset().left);
                }
                else {
                    self._getIndexForPosition(event.pageY - self.element.offset().top);
                }

                if (index !== -1) {
                    if (self.orientation === self.ORIENTATION_X) {
                        self.showPreviewForPosition(event.pageX - self.element.offset().left);
                    }
                    else {
                        self.showPreviewForPosition(event.pageY - self.element.offset().top);
                    }
                }
                else {
                    hidePreview();
                    self._setCurrentIndex(-1);
                }
            });

            self.scrimElement.mouseover(function(event) {
                showPreview();
            });

            self.scrimElement.mouseout(function(event) {
                hidePreview();
            });


            self.scrimElement.mousedown(function(event) {
                self._setSelectedIndex(self._getCurrentIndex());
                if (self.options.showSelection === true) {
                    self.previewElement.hide();
                    self.selectionElement.css({opacity: 1});
                }
            });


            self.previewElement.mouseover(function(event) {
                showPreview();
            });

            self.previewElement.mouseout(function(event) {
                hidePreview();
            });

            self.previewElement.click(function(event) {
                self._setSelectedIndex(self._getCurrentIndex());
                if (self.options.showSelection === true) {
                    self.previewElement.hide();
                }
            });


        },

        showPreviewForPosition: function(position) {
            var index = this._getIndexForPosition(position);
            this._setCurrentIndex(index);
            this.options.onPreviewPhoto(index, this.options.photos[index]);
            this.previewElement.show();
        },

        _getMaxVisibleThumbnails: function() {
            return this.traySize / this.options.thumbnailSize;
        },

        _getThumbnailActiveSize: function() {
            var len = this.options.photos.length;
            if (len * this.options.thumbnailSize < this.traySize) {
                return this.options.thumbnailSize;
            }
            else {
                return this.traySize / len;
            }

        },

        _getThumbnailSize: function() {
            return this.options.thumbnailSize;
        },

        _setCurrentIndex: function(index) {
            if (index !== this.currentIndex) {
                this.currentIndex = index;

                if (index !== -1) {
                    this.previewElement.find('img').attr('src', this.PLACEHOLDER_IMAGE);
                    this.previewElement.find('img').attr('src', this.options.photos[index][this.options.srcAttribute]);

                    if (this.orientation === this.ORIENTATION_X) {
                        this.previewElement.css('left', Math.round(this._getPositionForIndex(index) - this.previewElement.width() / 2));
                    }
                    else {
                        this.previewElement.css('top', Math.round(this._getPositionForIndex(index) - this.previewElement.height() / 2));
                    }


                    if (this.options.showSelection) {
                        this.selectionElement.css({opacity: .5});
                    }
                }
            }
        },

        _getCurrentIndex: function() {
            return this.currentIndex;
        },

        _setSelectedIndex: function(index) {
            this.selectedItem = index;

            if (index !== -1) {
                if (this.options.showSelection === true) {
                    this.selectionElement.find('img').attr('src', this.PLACEHOLDER_IMAGE);
                    this.selectionElement.find('img').attr('src', this.options.photos[index][this.options.srcAttribute]);
                    this.selectionElement.show();
                    this.selectionElement.css({opacity: 1});


                    if (this.orientation === this.ORIENTATION_X) {
                        this.selectionElement.css('left', this._getPositionForIndex(index) - this.selectionElement.width() / 2);
                    }
                    else {
                        this.selectionElement.css('top', this._getPositionForIndex(index) - this.selectionElement.height() / 2);
                    }
                }

                if (this.options.showSelectedIndexIndicator) {
                    if (this.orientation === this.ORIENTATION_X) {
                        this.selectedIndexIndicator.css('left', this._getPositionForIndex(index) - this.selectedIndexIndicator.width()); //for some reason 'width()' rather than 'width() / 2' works
                    }
                    else {
                        this.selectedIndexIndicator.css('top', this._getPositionForIndex(index) - this.selectedIndexIndicator.height()); //for some reason 'width()' rather than 'width() / 2' works
                    }
                    this.selectedIndexIndicator.show();
                }


            }

            this.options.onSelectPhoto(index, this.options.photos[index]);
        },

        _getSelectedIndex: function() {
            return this.selectedItem;
        },

        _getIndexForPosition: function(position) {
            var len = this.options.photos.length;
            var index = Math.floor(position / this._getThumbnailActiveSize());
            if (index >= len) {
            }
            else {
                return index;
            }
        },

        _getPositionForIndex: function(index) {
            return index * this._getThumbnailActiveSize() + (this._getThumbnailActiveSize() / 2);
        },


        _repaintThumbnails: function() {
            var html = '';
            var thumbnails = this.options.photos.slice(); //copy the array so we dont modify the original

            if (thumbnails.length > this._getMaxVisibleThumbnails()) {
                //trim extra from middle of list
                var extra = thumbnails.length - this._getMaxVisibleThumbnails();
                var removeEach = (thumbnails.length - 2) / extra;
                for (var i = extra; i > 0; i--) {
                    var indexToRemove = Math.round(i * removeEach);
                    thumbnails.splice(indexToRemove, 1);
                }
            }

            for (var i = 0; i < thumbnails.length; i++) {
                var thumbnail = thumbnails[i];
                html += '<img style="height:' + this._getThumbnailSize() + 'px; width:' + this._getThumbnailSize() + 'px" src="' + thumbnail[this.options.srcAttribute] + '">';
            }

            this.thumbnailsElement.html(html);

            if (this.orientation === this.ORIENTATION_X) {
                this.scrimElement.css('width', (thumbnails.length * this._getThumbnailSize()));
            }
            else {
                this.scrimElement.css('height', (thumbnails.length * this._getThumbnailSize()));
            }

        },


        destroy: function() {
            this.element.html('');
            $.Widget.prototype.destroy.apply(this, arguments);
        },


        removePhoto: function(index) {
            this.options.onDeletePhoto(index, this.options.photos[index]);
            this.options.photos.splice(index, 1);
            this._repaintThumbnails();
        },

        setPhotos: function(photos) {
            this.options.photos = photos.slice();
            this._setSelectedIndex(-1);
            this._repaintThumbnails();
        },

        addPhotos: function(photos) {
            this.options.photos = this.options.photos.concat(photos);
            this._repaintThumbnails();
        },

        nextThumbOffsetX: function() {
            if (this.options.photos.length === 0) {
                return this.thumbnailsElement.offset().left;
            }
            else if (this.options.photos.length >= this._getMaxVisibleThumbnails()) {
                return this.thumbnailsElement.offset().left + this.thumbnailsElement.width() - 20;
            }
            else {
                return this.thumbnailsElement.offset().left + (this.options.photos.length * 20);
            }
        },

        setSelectedIndex: function(index) {
            this._setSelectedIndex(index);
        },

        showLoadingIndicator: function() {
            this.loadingIndicator.css('left', this.nextThumbOffsetX() - this.wrapperElement.offset().left);
            this.loadingIndicator.show();

        },

        hideLoadingIndicator: function() {
            this.loadingIndicator.hide();
        }



    });


})(jQuery);
