/*
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
                                            '<div class="button share-button"></div>' +
                                            '<div class="button like-button zzlike" data-zzid="'+self.options.albumId+'" data-zztype="album"><div class="zzlike-icon thumbdown"></div></div>' +
                                            '<div class="button delete-button"></div>' +
                                        '</div>' +
                                    '</div>'+
                                '</div>' +
                              '</div>');

            self.captionHeight = 80;

            //create & bind toolbar
            this.element.append(self.template);

            //for selenium tests...
            self.element.find('.picon').attr('id', 'picon-' + self.options.caption.replace(/[\W]+/g,'-'));

            //rotate stack
            var stackOption = Math.floor(Math.random() * self.options.stackAngles.length );
            self.template.find('.stacked-image:eq(0)').rotate(self.options.stackAngles[stackOption][0]);
            self.template.find('.stacked-image:eq(1)').rotate(self.options.stackAngles[stackOption][1]);
            self.topOfStack = self.template.find('.stacked-image:last');

            //set caption
            self.template.find('.caption').text(self.options.caption);

            self.template.find('.cover-photo').click(function(){
                self.options.onClick();
            });

            self._resize(self.options.maxCoverWidth, self.options.maxCoverHeight);

            var toolbarOpen = false;
            var menuOpen = false;
            var hover    = false;
            var height;

            var checkCloseToolbar = function(){
                if( !menuOpen && !hover){
                    self.topOfStack.css({height: height});
                    self.topOfStack.find('.button-bar').hide();
                    toolbarOpen = false;
                }
            };

            var mouse_in = function(){
                hover = true;
                //display toolbar
                if( !toolbarOpen ){
                    self.topOfStack = self.template.find('.stacked-image:last');
                    height = self.topOfStack.height();
                    toolbarOpen = true;
                    self.topOfStack.css({height: height + 30});
                    self.topOfStack.find('.button-bar').show();
                }
            };

            var mouse_out =function(){
                hover = false;
                checkCloseToolbar();
            };

            // Share button
            self.template.find('.share-button').zz_menu(
            {   subject_id:      self.options.albumId,
                subject_type:    'album',
                container:       $('#article'),
                zza_context:     'frame',
                style:           'auto',
                bind_click_open:   true,
                append_to_element: true, //use the element zzindex so the overflow goes under the bottom toolbar
                menu_template:   sharemenu.template,
                click:           sharemenu.click_handler,
                open:  function(){ menuOpen = true;  },
                close: function(){ menuOpen = false; checkCloseToolbar(); }
            });

            // Like button
            like.draw_tag( self.template.find('.like-button') );

            // Delete button
            if(!self.options.allowDelete){
                self.template.find('.delete-button').hide();
            }else{
                self.template.find('.delete-button').click(function(){
                    self.options.onDelete();
                });
            }

            //load cover photos and display menus
            if(self.options.coverUrl){
                var onload = function(image){
                    var scaledSize = image_utils.scale(image, {width:self.options.maxCoverWidth, height:self.options.maxCoverHeight});
                    self._resize(scaledSize.width, scaledSize.height);
                    self.template.find('.cover-photo').attr('src', image.src);
                    self.element.hover( mouse_in, mouse_out );
                };
                var onerror = function(image){
                    self.element.hover( mouse_in, mouse_out );
                };
                image_utils.pre_load_image(self.options.coverUrl, onload, onerror);
            }else{
                self.element.hover( mouse_in, mouse_out );
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




