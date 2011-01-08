(function( $, undefined ) {

    $.widget( "ui.zz_thumbscroller", {
        options: {
            photos: [],
            scrollable: null,
            cellWidth:null,
            cellHeight:null
        },


        _create: function() {
            var self = this;


            var animateScrollActive = false;
            var nativeScrollActive = false;

            self.thumbtray = self.element.zz_thumbtray(
            {
                photos:self.options.photos,
                showSelection:false,
                thumbnailSize:16,
                showSelectedIndexIndicator:true,
                onSelectPhoto: function(index, photo){
                    if(!nativeScrollActive){
                        if(photo){
                            var cell = self.options.scrollable.data().zz_photogrid.findCell(photo.id);
                            if(cell){
                                var cellTop = parseInt(cell.css('top'));
                                animateScrollActive = true;
                                self.options.scrollable.animate({scrollTop: cell.css}, 1000, 'easeOutCubic', function(){
                                    animateScrollActive = false;
                                });
                            }

                            }
                        }

                }
            }).data().zz_thumbtray;


            self.options.scrollable.scroll(function(event){
                if(! animateScrollActive){
                    nativeScrollActive = true;
                    var index = (((self.options.scrollable.scrollTop() / self.options.cellHeight)+1)*5)-1;
                    self.setSelectedIndex(index);
                    nativeScrollActive = false;
                }
            });



        },


        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );