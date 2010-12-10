(function( $, undefined ) {

    $.widget( "ui.zz_thumbtray", {
        options: {
            photos: [],
            previewSize: 80,
            selectionSize: 115,
            allowDelete: false,
            showSelection: false,
            selectedIndex:-1,
            thumbnailSize: 20,
            onDeletePhoto: function(index, photo){},
            onSelectPhoto: function(index, photo){}
        },

        currentIndex : -1,
        selectedIndex : -1,
        traySize:null,
        orientation: null,
        ORIENTATION_X: 'x',
        ORIENTATION_Y: 'y',

        
        _create: function() {
            var self = this;

            //these only work if element's is visible (ie display !- none)
            var width = this.element.width();
            var height = this.element.height();

            if(width > height){
                this.orientation = this.ORIENTATION_X;
            }
            else{
                this.orientation = this.ORIENTATION_Y;
            }

            var html = '';
            html += '<div class="thumbtray-wrapper">';
            html += '    <div class="thumbtray-thumbnails"></div>'
            html += '    <div class="thumbtray-selection">';
            html += '        <img src="">';
            html += '    </div>';
            html += '    <div class="thumbtray-preview">';
            html += '        <img src="">';
            html += '        <div class="thumbtray-delete-button"></div>';
            html += '    </div>';
            html += '    <div class="thumbtray-scrim"></div>'
            html += '</div>';

            this.element.html(html);


            this.wrapperElement = this.element.find('.thumbtray-wrapper');
            this.scrimElement = this.element.find('.thumbtray-scrim');
            this.previewElement = this.element.find('.thumbtray-preview');
            this.selectionElement = this.element.find('.thumbtray-selection');
            this.thumbnailsElement = this.element.find('.thumbtray-thumbnails');


            this.wrapperElement.css({width:width, height:height});
            this.scrimElement.css({width:width, height:height});
            this.thumbnailsElement.css({width:width, height:height});

            if(this.orientation === this.ORIENTATION_X){
                this.previewElement.addClass('x');
                this.selectionElement.addClass('x');
                this.selectionElement.find('img').css({height:this.options.selectionSize});
                this.previewElement.find('img').css({height:this.options.previewSize});
                this.traySize = width;
            }
            else{
                this.previewElement.addClass('y');
                this.selectionElement.addClass('y');
                this.selectionElement.find('img').css({width:this.options.selectionSize});
                this.previewElement.find('img').css({width:this.options.previewSize});
                this.traySize = height;

            }




            this._repaintThumbnails();

            this._setSelectedIndex(this.options.selectedIndex)




            //delete button
            if(this.options.allowDelete){
                self.previewElement.find('.thumbtray-delete-button').show().click(function(){
                    self.previewElement.fadeOut('fast', function(){
                        self.removePhoto(self._getCurrentIndex())
                    });
                });
            }


            //mouse over and click handlers
            var mouseOver = false;




            var showPreview = function(){
                mouseOver = true;
                self.previewElement.fadeIn('fast');
            }

            var hidePreview = function(){
                mouseOver = false;
                setTimeout(function(){
                     if(!mouseOver){
                         self.previewElement.fadeOut('fast');
                         if(self.options.showSelection){
                             self.selectionElement.animate({opacity:1},100);
                         }
                     }
               },100);
            }


            self.scrimElement.mousemove(function(event){
                var index = null;

                if(self.orientation === self.ORIENTATION_X){
                    self._getIndexForPosition(event.pageX - self.element.offset().left);
                }
                else{
                    self._getIndexForPosition(event.pageY - self.element.offset().top);
                }

                if(index !== -1){
                    if(self.orientation === self.ORIENTATION_X){
                        self.showPreviewForPosition(event.pageX - self.element.offset().left);
                    }
                    else{
                        self.showPreviewForPosition(event.pageY - self.element.offset().top);
                    }
                }
                else{
                    hidePreview();
                    self._setCurrentIndex(-1);
                }
            });

            self.scrimElement.mouseover(function(event){
                showPreview()
            });

            self.scrimElement.mouseout(function(event){
                hidePreview();
            });


            self.scrimElement.click(function(event){
                self._setSelectedIndex(self._getCurrentIndex());
                if(self.options.showSelection === true){
                    self.previewElement.hide();
                    self.selectionElement.css({opacity:1});
                }
            });


            self.previewElement.mouseover(function(event){
                showPreview()
            });

            self.previewElement.mouseout(function(event){
                hidePreview();
            });

            self.previewElement.click(function(event){
                self._setSelectedIndex(self._getCurrentIndex());
                if(self.options.showSelection === true){
                    self.previewElement.hide();
                }
            });

        },

        showPreviewForPosition: function(position){
            this._setCurrentIndex(this._getIndexForPosition(position));
            this.previewElement.show();
        },

        _getMaxVisibleThumbnails: function(){
            return this.traySize / this.options.thumbnailSize;
        },

        _getThumbnailActiveSize: function(){
            var len = this.options.photos.length;
            if(len * this.options.thumbnailSize < this.traySize){
                return this.options.thumbnailSize;
            }
            else{
                return this.traySize / len;
            }

        },

        _getThumbnailSize: function(){
            return this.options.thumbnailSize;
        },

        _setCurrentIndex: function(index){
            if(index !== this.currentIndex){
                this.currentIndex = index;

                if(index !== -1){
                    this.previewElement.find('img').attr('src', this.options.photos[index].src)

                    if(this.orientation === this.ORIENTATION_X){
                        this.previewElement.css('left', this._getPositionForIndex(index) - this.previewElement.width() / 2);
                    }
                    else{
                        this.previewElement.css('top', this._getPositionForIndex(index) - this.previewElement.height() / 2);
                    }


                    if(this.options.showSelection){
                        this.selectionElement.css({opacity:.5});
                    }
                }
            }
        },

        _getCurrentIndex: function(){
            return this.currentIndex;
        },

        _setSelectedIndex: function(index){
            this.selectedItem = index;

            this.options.onSelectPhoto(index, this.options.photos[index])
            

            if(index !== -1){
                if(this.options.showSelection === true){
                    this.selectionElement.find('img').attr('src', this.options.photos[index].src)
                    this.selectionElement.show();
                    this.selectionElement.css({opacity:1});


                    if(this.orientation === this.ORIENTATION_X){
                        this.selectionElement.css('left', this._getPositionForIndex(index) - this.selectionElement.width() / 2);
                    }
                    else{
                        this.selectionElement.css('top', this._getPositionForIndex(index) - this.selectionElement.height() / 2);
                    }


                }
            }
        },

        _getSelectedIndex: function(){
            return this.selectedItem;
        },

        _getIndexForPosition: function(position){
            var len = this.options.photos.length;
            var index = Math.floor(position / this._getThumbnailActiveSize());
            if(index >= len){
                return -1;
            }
            else{
                return index;
            }
        },

        _getPositionForIndex: function(index){
            return index * this._getThumbnailActiveSize() + (this._getThumbnailActiveSize() / 2);
        },


        _repaintThumbnails: function(){
            var html = '';
            var photos = this.options.photos.slice(0); //copy the array so we dont modify the original

            if(photos.length > this._getMaxVisibleThumbnails()){
                //trim extra from middle of list
                var extra = photos.length - this._getMaxVisibleThumbnails();
                var removeEach = (photos.length - 2) / extra;
                for(var i = extra;i > 0; i--){
                    var indexToRemove = Math.round(i*removeEach)
                    photos.splice(indexToRemove, 1);
                }
            }

            for(var i in photos){
                var photo = photos[i];
                html += '<img style="height:' + this._getThumbnailSize() + 'px; width:' + this._getThumbnailSize() + 'px" src="' + photo.src + '">'
            }

            this.thumbnailsElement.html(html);

            if(this.orientation === this.ORIENTATION_X){
                this.scrimElement.css('width', (photos.length * this._getThumbnailSize()));
            }
            else{
                this.scrimElement.css('height', (photos.length * this._getThumbnailSize()));
            }

        },



        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        },


        removePhoto: function(index){
            this.options.onDeletePhoto(index, this.options.photos[index]);
            this.options.photos.splice(index,1);
            this._repaintThumbnails();
        }
    });



})( jQuery );