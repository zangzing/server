(function( $, undefined ) {

    $.widget( "ui.zz_thumbtray", {
        options: {
            photos: [],
            previewSize: 115,
            allowDelete: false,
            showSelection: false,
            onDeletePhoto: function(index){return true;},
            onSelectPhoto: function(index){return true;}
        },

        currentIndex : -1,
        selectedIndex : -1,

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
            template += '        <img src="" style="height:115px">';
            template += '    </div>';
            template += '    <div class="preview" style="display:none;position:absolute;left:0;bottom:21;border:1px solid #00FF00; background-color:#00FF00">';
            template += '        <img src="" style="height:80px">';
            template += '        <div class="delete" style="display:none;position:absolute;right:-10;top:-10;cursor: pointer">(x)</div>';
            template += '    </div>';
            template += '    <div class="scrim"   style="z-index:0;height:${height};width:${width};position:absolute;left:0;top:0;opacity:.5;filter:alpha(opacity=50);background-color:#fff"></div>'
            template += '</div>';

            $.tmpl( $.template(null, template), {height: height, width: width} ).appendTo(this.element);


            this.scrimElement = this.element.find('.scrim');
            this.previewElement = this.element.find('.preview');
            this.selectionElement = this.element.find('.selection');
            this.thumbnailsElement = this.element.find('.thumbnails');
            this.thumbnailSize = this.element.height();

            var mouseOver = false;

            var showPreview = function(){
                mouseOver = true;
                self.previewElement.fadeIn('fast');
            }

            var hidePreview = function(){
                mouseOver = false;
                setTimeout(function(){
                    if(!mouseOver){
                        self.previewElement.fadeOut('slow');
                    }
                },200);
            }

            //delete photo

            if(this.options.allowDelete){
                self.previewElement.find('.delete').show().click(function(){
                    if(self.removePhoto(self._getCurrentIndex())){
                        hidePreview();
                    }
                });
            }

            self.scrimElement.mousemove(function(event){
                var index = self._getIndexForPosition(event.pageX - self.element.offset().left);
                if(index !== -1){
                    self.previewElement.show();
                    self._setCurrentIndex(self._getIndexForPosition(event.pageX - self.element.offset().left));
                }
                else{
                    self.previewElement.hide();
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
                    console.log(indexToRemove);
                    photos.splice(indexToRemove, 1);
                }
            }

            for(var i in photos){
                var photo = this.options.photos[i];
                html += '<img style="height:' + this.thumbnailSize + ';width:' + this.thumbnailSize + '" src="' + photo.src + '">'
            }

            this.thumbnailsElement.html(html);


        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        },


        removePhoto: function(index){
            if(this.options.onDeletePhoto(index) === true){
                this.options.photos.splice(index,1);
                this._repaintThumbnails();
                return true;
            }
            else{
                return false;
            }

        }
    });



})( jQuery );