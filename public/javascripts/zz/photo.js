/*!
 * photo.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
(function( $, undefined ) {

    $.widget( "ui.zz_photo", {
        options: {
            allowDelete: false,          //context
            onDelete:jQuery.noop,        //model
            maxHeight:120,               //context
            maxWidth:120,                //context
            caption:null,                //model
            allowEditCaption:false,      //context
            onChangeCaption:jQuery.noop, //model
            src:null,                    //model
            previewSrc:null,             //model
            rolloverSrc:null,            //model
            scrollContainer:null,
            lazyLoadThreshold:0,
            onClick:jQuery.noop,         //model
            onMagnify:jQuery.noop,       //model
            photoId:null,                //model
            aspectRatio:0,               //model
            isUploading:false,           //model
            isUploading:false,           //model
            isError:false,               //model
            showButtonBar:false,           //model
//            onClickShare: jQuery.noop,     //model
//            noShadow:false,              //context / type
//            lazyLoad:true ,              //context / type
            context:null,                 //context -- album-edit, album-grid, album-picture, album-timeline, album-people, chooser-grid, chooser-picture
            type: 'photo'                 //photo \ folder \ blank
        },

        _create: function() {
            var self = this;

            if(self.options.scrollContainer.data().zz_photogrid){
                self.photoGrid = self.options.scrollContainer.data().zz_photogrid;
            }


            var html = '';
            html += '<div class="photo-caption"></div>';

            html += '<div class="photo-border">'
            html += '   <img class="photo-image" src="' + path_helpers.image_url('/images/blank.png') + '">';
            html += '   <div class="photo-delete-button"></div>';
            html += '   <div class="photo-uploading-icon"></div>';
            html += '   <div class="photo-error-icon"></div>';
            html += '   <img class="bottom-shadow" src="' + path_helpers.image_url('/images/photo/bottom-full.png') + '">';

            if(self.options.context.indexOf('chooser')===0 && self.options.type === 'photo'){
                html += '   <div class="photo-add-button"></div>';
                html += '   <div class="magnify-button"></div>';
            }


            html += '</div>';

            var template = $(html);
            template.appendTo(this.element);


            self.borderElement = this.element.find('.photo-border');
            self.imageElement = this.element.find('.photo-image');
            self.captionElement = this.element.find('.photo-caption');
            self.deleteButtonElement = this.element.find('.photo-delete-button');
            self.uploadingElement = this.element.find('.photo-uploading-icon');
            self.errorElement = this.element.find('.photo-error-icon');
            self.bottomShadow = this.element.find('.bottom-shadow');

            self.captionElement.text(self.options.caption);

            //for selenium tests...
            self.borderElement.attr('id', 'photo-border-' + self.options.caption.replace(/[\W]+/g,'-'));


            if(self.options.type === 'blank'){
                self.borderElement.hide();
                self.captionElement.hide();
            }




            if(self.options.context.indexOf('chooser')===0){
                //magnify
                this.element.find('.magnify-button').click(function(event){
                    self.options.onClick('magnify')
                });


                //add photo action
                self.element.find('.photo-add-button').click(function(event){
                    self.options.onClick('main');
                });


                //hide drop shadow for folders and 'add all' butons
                if(self.options.type !== 'photo'){
                    self.borderElement.addClass('no-shadow');
                }

            }









            //click
            self.imageElement.click(function(event){
                self.options.onClick('main')
            });




            self.captionHeight = 30;



            var initialHeight;
            var initialWidth;


            if(self.options.aspectRatio){
                var srcWidth =  1 * self.options.aspectRatio;
                var srcHeight = 1;

                var scaled = image_utils.scale({width:srcWidth, height:srcHeight}, {width:self.options.maxWidth, height:self.options.maxHeight - self.captionHeight});

                initialHeight = scaled.height;
                initialWidth = scaled.width;

            }
            else{
                var min = Math.min(self.options.maxWidth, self.options.maxHeight);
                initialWidth = min;
                initialHeight = min;
            }


            self.imageElement.css({
                width: initialWidth,
                height: initialHeight
            });

            self.bottomShadow.css({'width': (initialWidth + 14) + "px"});
  

            //element is probably invisible at this point, so we need to check the css attributes
            self.width = parseInt(self.element.css('width'));
            self.height = parseInt(self.element.css('height'));



            var borderWidth = initialWidth + 10 ;
            var borderHeight = initialHeight + 10;




            self.borderElement.css({
                position: "relative",
                top: (self.height - borderHeight - self.captionHeight) / 2,
                left: (self.width - borderWidth) / 2,
                width: borderWidth,
                height: borderHeight 
            });





            //uploading glyph
            if(self.options.isUploading && !self.options.isError){
                self.uploadingElement.show();
            }


            //error glyph
            if(self.options.isError){
                self.errorElement.show();
            }


            //delete
            if(self.options.allowDelete){
                self.deleteButtonElement.click(function(){
                    if(self.options.onDelete()){
                        self.captionElement.hide();
                        self.deleteButtonElement.hide();
                        self.borderElement.hide("scale", {}, 300, function(){
                            self.element.animate({width:0},500, function(){
                                self.element.remove();

                                if(self.photoGrid){
                                    self.photoGrid.resetLayout();
                                }

                            })
                        });
                    }
                });
            }
            else{
                self.deleteButtonElement.remove();   
            }


            //edit caption
            var isEditingCaption = false;
            if(self.options.allowEditCaption){
                self.captionElement.click(function(event){
                    self.editCaption();
                });
            }

            //lazy loading
            if(self.options.type !== 'photo'){
                self._loadImage()
            }
            else{
                self.imageElement.attr('src', path_helpers.image_url('/images/photo_placeholder.png'));
            }


            //rollover
            if(self.options.rolloverSrc){

                //preload rollover
                image_utils.pre_load_image(self.options.rolloverSrc);

                self.element.mouseover(function(){
                    self.imageElement.attr('src', self.options.rolloverSrc);
                });

                self.element.mouseout(function(){
                    self.imageElement.attr('src', self.options.src);
                });
            }


            //todo: can these move to css?
            if(self.options.showButtonBar){
                var toolbarTemplate = '<div class="photo-toolbar">' +
                                          '<div class="buttons">' +
                                              '<div class="share-button"></div>' +
                                              '<div class="like-button"></div>' +
                                              '<div class="info-button"></div>' +
                                          '</div>' +
                                       '</div>';



                var menuOpen = false;

                var checkCloseToolbar = function(){
                    if(!menuOpen ){
                        self.borderElement.css({'padding-bottom': '0px'});
                        self.imageElement.css({'border-bottom': '5px solid #fff'});
                        self.toolbarElement.remove();
                    }
                };

                self.element.mouseenter(function(){

                    hover = true;

                    if(!menuOpen){
                        self.toolbarElement = $(toolbarTemplate);
                        self.borderElement.append(self.toolbarElement);
                        self.borderElement.css({'padding-bottom': '30px'});
                        self.imageElement.css({'border-bottom': '35px solid #fff'});

                        self.toolbarElement.find('.share-button').mousedown(function(){
                            menuOpen = true;
                            share.show_share_menu($(this), 'photo', self.options.photoId, {x:0,y:0}, 'frame', function(){
                                menuOpen = false;
                                checkCloseToolbar();
                            });
                        });

                        self.toolbarElement.find('.like-button').click(function(){
                            alert("This feature is still under construction. This will allow you to like an individual photo.");
                        });

                        //imenu
                        self.toolbarElement.find('.info-button').zz_menu(
                            { subject_id:   self.options.photoId,
                              subject_type: 'photo'
                              //callback:  USE Default callback
                            });
                    }
                });

                self.element.mouseleave(function(){
                    checkCloseToolbar();
               });
            }
        },

        setMenuOpen: function(open){
            if(open){
                self.element.find('.photo-toolbar').addClass('menu-open');
            }
            else{
                self.element.find('.photo-toolbar').removeClass('menu-open');
            }
        },


        checked:false,

        isChecked:function(){
            return this.checked;
        },

        setChecked: function(checked){
            var self = this;
            self.checked = checked;
            if(self.options.context.indexOf('chooser')===0){
                if(checked){
                    self.element.find('.photo-add-button').addClass('checked');
                }
                else{
                    self.element.find('.photo-add-button').removeClass('checked');
                }
            }
        },

        loadIfVisible: function(containerDimensions){
            var self = this;
            if(!self.imageLoaded){
                if(self._inLazyLoadRegion(containerDimensions)){
                    self._loadImage();
                }
            }
        },


        _loadImage : function(){
            var self = this;

            var initialSrc = self.options.src;

            if(self.options.previewSrc){
                initialSrc= self.options.previewSrc;
            }


            image_utils.pre_load_image(initialSrc, function(image){
                self.imageObject = image;
                self.imageLoaded = true;
                self._resize(1);

                //show the small version
                self.imageElement.attr("src", initialSrc);


                //show the full version
                image_utils.pre_load_image(self.options.src, function(image){
                    self.imageElement.attr("src", self.options.src);
                });
            });
        },

        _resize: function(percent){
            var self = this;

            var scaled = image_utils.scale({width:self.imageObject.width, height:self.imageObject.height}, {width:self.options.maxWidth, height:self.options.maxHeight - self.captionHeight});



            var borderWidth = scaled.width + 10;
            var borderHeight = scaled.height + 10;


            self.borderElement.css({
                top: (self.height - borderHeight - self.captionHeight) / 2,
                left: (self.width - borderWidth) / 2,
                width: borderWidth,
                height: borderHeight
            });

            self.imageElement.css({
                width: scaled.width,
                height: scaled.height
            });

            self.bottomShadow.css({'width': (scaled.width + 14) + "px"});


        },




        _inLazyLoadRegion: function(containerDimensions /*optional param with container dimensions */){
            var container = this.options.scrollContainer;
            var threshold = this.options.lazyLoadThreshold;

            if(containerDimensions){
                var containerOffset = containerDimensions.offset;
                var containerHeight = containerDimensions.height;
                var containerWidth = containerDimensions.width;
            }
            else{
                var containerOffset = $(container).offset();
                var containerHeight = $(container).height();
                var containerWidth = $(container).width();
            }



            var elementOffset = $(this.element).offset(); //todo: expensive call. cache/pass-in if possible; maybe can cache after grid resize
            var elementWidth =  this.options.maxWidth;
            var elementHeight = this.options.maxHeight; 

            if (container === undefined || container === window) {
                var foldBottom = $(window).height() + $(window).scrollTop();
                var foldRight =  $(window).width() + $(window).scrollLeft();
                var foldTop =    $(window).scrollTop();
                var foldLeft =   $(window).scrollLeft();
            } else {
                var foldBottom = containerOffset.top + containerHeight;
                var foldRight =  containerOffset.left + containerWidth;
                var foldTop =    containerOffset.top;
                var foldLeft =   containerOffset.left;
            }


            var left =  (foldLeft >= elementOffset.left + threshold + elementWidth);
            var above = (foldTop >= elementOffset.top + threshold  + elementHeight);
            var right = (foldRight <= elementOffset.left - threshold);
            var below = (foldBottom <= elementOffset.top - threshold);

            return (!left) && (!right) && (!above) && (!below);



        },

        editCaption: function(){
            var self = this;

            if(!self.isEditingCaption){
                self.isEditingCaption = true;

                var captionEditor = $('<div class="edit-caption-border"><input type="text"><div class="caption-ok-button"></div></div>');
                self.captionElement.html(captionEditor);

                var textBoxElement = captionEditor.find('input');
 
                var commitChanges = function(){
                    var newCaption = textBoxElement.val()
                    if(newCaption !== self.options.caption){
                        self.options.caption = newCaption
                        self.options.onChangeCaption(newCaption);
                    }
                    self.captionElement.text(newCaption);
                    self.isEditingCaption = false;
                }


                textBoxElement.val(self.options.caption);
                textBoxElement.focus();
                textBoxElement.select();
                textBoxElement.blur(function(){
                    commitChanges();
                });

                textBoxElement.keydown(function(event){

                    if (event.which == 13) {  //enter key
                        commitChanges();
                        return false;
                    }
                    else if(event.which == 9){ //tab key
                        if(event.shiftKey){
                            textBoxElement.blur();

                            if(self.element.prev().length !== 0){
                                self.element.prev().data().zz_photo.editCaption();
                            }
                            else{
                                self.element.parent().children().last().data().zz_photo.editCaption();
                            }
                        }
                        else{
                            textBoxElement.blur();
                            if(self.element.next().length !== 0){
                                self.element.next().data().zz_photo.editCaption();
                            }
                            else{
                                self.element.parent().children().first().data().zz_photo.editCaption();
                            }
                        }
                        event.stopPropagation();
                        return false;
                    }
                });


                var okButton = captionEditor.find('.caption-ok-button');
                okButton.click(function(event){
                    commitChanges();
                    event.stopPropagation();
                    return false;
                });

                
            }

        },

        getPhotoId: function(){
           return this.options.photoId;  
        },

        dragStart: function(){
            this.element.addClass('dragging');
        },

        dragEnd: function(){
            this.element.removeClass('dragging');
        },

        dragHelper: function(){
            var helper = this.element.clone();
            helper.find('.photo-delete-button').hide();
            return helper;
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });



})( jQuery );