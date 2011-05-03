/**
 *
 */

(function( $, undefined ) {

    $.widget( "ui.zz_picon", {
        options: {
            caption: "",
            coverUrl: "",
            albumUrl:null,
            albumId:null,
            onClick: function(){},
            onLike: function(){},
            onDelete: function(){},
            allowDelete: false,
            stackAngles: [
                [-6,-3],
                [-3,3],
                [6,3]
            ],

            maxCoverWidth: 180,
            maxCoverHeight: 150



        },


        _create: function() {
            var self = this;

            self.template = $('<div class="picon">' +
                                '<div class="caption"></div>' +
                                '<div class="stacked-image"></div>' +
                                '<div class="stacked-image"></div>' +
                                '<div class="stacked-image">' +
                                    '<img class="cover-photo" src="' + path_helpers.image_url('/images/photo_placeholder.png')+ '">' +
                                    '<div class="button-bar">' +
                                        '<div class="buttons">' +
                                            '<div class="share-button"></div>' +
                                            '<div class="like-button"></div>' +
                                            '<div class="delete-button"></div>' +
                                        '</div>' +
                                    '</div>'+
                                '</div>' +
                              '</div>');


            self.captionHeight = 80;


            this.element.append(self.template);

            //rotate stack
            var stackOption = Math.floor(Math.random() * self.options.stackAngles.length );
            self.template.find('.stacked-image:eq(0)').rotate(self.options.stackAngles[stackOption][0]);
            self.template.find('.stacked-image:eq(1)').rotate(self.options.stackAngles[stackOption][1]);

            //set caption
            self.template.find('.caption').text(self.options.caption);


            self.template.find('.cover-photo').click(function(){
                self.options.onClick();
            });

            self.template.find('.share-button').click(function(){
                share.show_share_menu($(this), 'album', self.options.albumUrl, self.options.albumId);
            });

            self.template.find('.like-button').click(function(){
                self.options.onLike();
            });


            if(!self.options.allowDelete){
                self.template.find('.delete-button').hide();
            }
            else{
                self.template.find('.delete-button').click(function(){
                    self.options.onDelete();
                });
            }


            var initMouseOver = function(){
                self.topOfStack = self.template.find('.stacked-image:last');

                var height = self.topOfStack.height();

                self.topOfStack.mouseover(function(){
                    self.topOfStack.css({height: height + 30});
                    self.topOfStack.find('.button-bar').show();

                });

                self.topOfStack.mouseout(function(){
                    self.topOfStack.css({height: height});
                    self.topOfStack.find('.button-bar').hide();
                });
            };
                


            self._resize(self.options.maxCoverWidth, self.options.maxCoverHeight);


            //load cover photo
            if(self.options.coverUrl){
                var onload = function(image){
                    var scaledSize = image_utils.scale(image, {width:self.options.maxCoverWidth, height:self.options.maxCoverHeight});
                    self._resize(scaledSize.width, scaledSize.height);
                    self.template.find('.cover-photo').attr('src', image.src);
                    initMouseOver();
                };

                var onerror = function(image){
                    initMouseOver();
                }

                image_utils.pre_load_image(self.options.coverUrl, onload, onerror);
            }
            else{
                initMouseOver();
            }

        },



        _resize: function(coverWidth, coverHeight){
            var self = this;

      
            self.template.find('.cover-photo').css({
                height:coverHeight,
                width:coverWidth
            });


            self.template.find('.stacked-image').css({
                height:coverHeight + 10,
                width:coverWidth + 10
            });
            
            self.template.find('.stacked-image').center_xy({
                top:40,
                left:0,
                width: self.element.width(), //save room for caption
                height: self.element.height() - (self.captionHeight + 40)
            });

        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
        

    });



})( jQuery );




