(function( $, undefined ) {

    $.widget( "ui.zz_thumbtray", {
        options: {
            photos: [],
            previewSize: 80,
            selectionSize: 115,
            allowDelete: false,
            showSelection: false,
            selectedIndex:-1,
            onDeletePhoto: function(index){return true;},
            onSelectPhoto: function(index){return true;}
        },

        currentIndex : -1,
        selectedIndex : -1,
        thumbnailSize: 0,
        
        _getMaxVisibleThumbnails: function(){
            return this.element.width() / this.thumbnailSize;
        },

        _getThumbnailActiveSize: function(){
            var len = this.options.photos.length;
            if(len * this.thumbnailSize < this.element.width()){
                return this.thumbnailSize;
            }
            else{
                return this.element.width() / len;
            }

        },

        _getThumbnailSize: function(){
            return this.thumbnailSize;
        },

        _setCurrentIndex: function(index){
            this.currentItem = index;
            if(index !== -1){
                this.previewElement.find('img').attr('src', this.options.photos[index].src)
                this.previewElement.css('left', this._getPositionForIndex(index) - this.previewElement.width() / 2);
            }
        },

        _getCurrentIndex: function(){
            return this.currentItem;
        },

        _setSelectedIndex: function(index){
            this.selectedItem = index;

            if(index !== -1){
                if(this.options.showSelection === true){
                    this.selectionElement.find('img').attr('src', this.options.photos[index].src)
                    this.selectionElement.css('left', this._getPositionForIndex(index) - this.selectionElement.width() / 2);
                    this.selectionElement.show();
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
        

        _create: function() {
            var self = this;
            var width = this.element.width();
            var height = this.element.height();
            var template = '';
            template += '<div class="wrapper" style="height:${height};width:${width};position:relative">';
            template += '    <div class="thumbnails"   style="z-index:0;height:${height};width:${width};position:absolute;left:0;top:0"></div>'
            template += '    <div class="selection" style="display:none;position:absolute;left:0;bottom:21;border:1px solid #CCCCCC">';
            template += '        <img src="" style="height:${selectionSize}px">';
            template += '    </div>';
            template += '    <div class="preview" style="display:none;position:absolute;left:0;bottom:21;border:1px solid #00FF00; background-color:#00FF00">';
            template += '        <img src="" style="height:${previewSize}px">';
            template += '        <div class="delete" style="display:none;position:absolute;right:-10;top:-10;cursor: pointer">(x)</div>';
            template += '    </div>';
            template += '    <div class="scrim" style="z-index:0;height:${height};width:${width};position:absolute;left:0;top:0;opacity:.5;filter:alpha(opacity=50);background-color:#fff"></div>'
            template += '</div>';

            $.tmpl( $.template(null, template), {height: height, width: width, previewSize:this.options.previewSize, selectionSize:this.options.selectionSize} ).appendTo(this.element);


            this.wrapperElement = this.element.find('.wrapper');
            this.scrimElement = this.element.find('.scrim');
            this.previewElement = this.element.find('.preview');
            this.selectionElement = this.element.find('.selection');
            this.thumbnailsElement = this.element.find('.thumbnails');
            this.thumbnailSize = this.element.height();

            var mouseOver = false;

            var showPreview = function(){
                mouseOver = true;
                self.previewElement.fadeIn('fast');
                if(self.options.showSelection){
                    self.selectionElement.animate({opacity:.5},100);
                }
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

            //delete photo

            if(this.options.allowDelete){
                self.previewElement.find('.delete').show().click(function(){
                    self.previewElement.fadeOut('fast', function(){
                        self.removePhoto(self._getCurrentIndex())
                    });
                });
            }

            self.scrimElement.mousemove(function(event){
                var index = self._getIndexForPosition(event.pageX - self.element.offset().left);
                if(index !== -1){
                    self.previewElement.show();
                    self._setCurrentIndex(self._getIndexForPosition(event.pageX - self.element.offset().left));
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

            this._repaintThumbnails();

            this._setSelectedIndex(this.options.selectedIndex)
        },

        _repaintThumbnails: function(){
            var html = '';
            var photos = this.options.photos.slice(0); //copy the array so we dont modify the original

            if(photos.length > this._getMaxVisibleThumbnails()){
                //trim extra from middle of list
                var extra = photos.length - this._getMaxVisibleThumbnails();
                var removeEach = Math.floor((photos.length - 2) / extra);
                for(var i = extra;i > 0; i--){
                    var indexToRemove = 1 + (i*removeEach)
                    photos.splice(indexToRemove, 1);
                }
            }

            for(var i in photos){
                var photo = this.options.photos[i];
                html += '<img style="height:' + this._getThumbnailSize() + ';width:' + this._getThumbnailSize() + '" src="' + photo.src + '">'
            }

            this.thumbnailsElement.html(html);

            this.scrimElement.css('width', (photos.length * this._getThumbnailSize()));

        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        },


        removePhoto: function(index){
            this.options.photos.splice(index,1);
            this._repaintThumbnails();
        }
    });



})( jQuery );