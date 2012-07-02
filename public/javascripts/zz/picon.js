/*
 *
 */

(function($, undefined) {

    // Pre-rotated stack frames
    //stackAngles: [   [-6, -3], [-3, 3], [6, 3] ]
    var rbPlus3  = $('<div class="stacked-image">').rotate( 3),
        rbMinus3 = $('<div class="stacked-image">').rotate(-3),
        rbPlus6  = $('<div class="stacked-image">').rotate( 6),
        rbMinus6 = $('<div class="stacked-image">').rotate(-6),
        rotated_borders = [
            [rbMinus6,rbMinus3],
            [rbMinus3,rbPlus3],
            [rbPlus6,rbPlus3]
        ];


    var  cover_photo_template = null, //$('<img class="cover-photo">'),
         caption_template  = $('<div class="photo-caption">'),
         button_bar_template = $('<div class="button-bar">'),
         buttons_template = $('<div class="buttons">'),
         like_button_template = $('');//SUNSET<div class="button like-button zzlike"  data-zztype="album"><div class="zzlike-icon thumbdown">'),
         info_button_template = $('<div class="button info-button">'),
         share_button_template = $('');//SUNSET<div class="button share-button">');

    var MAX_NAME = 50;


    $.widget('ui.zz_picon', {
        options: {
            album: null, //album json
            caption: '',
            coverUrl: '',
            albumUrl: null,
            albumId: null,
            onClick: $.noop,
            onDelete: $.noop,
            allowDelete: false,
            onChangeCaption: $.noop,
            allowEditCaption: false,
            maxCoverWidth: 180,
            maxCoverHeight: 150,
            containerWidth:  230,
            containerHeight: 230,
            captionHeight: 80,
            infoMenuTemplateResolver: null        // show InfoMenu or not and what style
        },

        _create: function() {
            var self = this,
                    el = self.element,
                    o = self.options;

            if( cover_photo_template == null ){
                            cover_photo_template = $('<img class="cover-photo" src="' + zz.routes.image_url('/images/photo_placeholder.png') + '">');
            }

            self.template =  $('<div class="picon">');
            self.captionElement = caption_template.clone();
            var     caption = self.captionElement,
                    cover_photo = cover_photo_template.clone(),
                    button_bar = button_bar_template.clone();

            self.topOfStack = $('<div class="stacked-image">').append(cover_photo);

            //randomly pick from the stack from pre-rotated frames
            var stackOption = Math.floor(Math.random() * rotated_borders.length);
            var stacked_image_0 = rotated_borders[stackOption][0].clone();
            var stacked_image_1 = rotated_borders[stackOption][1].clone();

            //for selenium tests...
            self.template.attr('id', 'picon-' + o.caption.replace(/[\W]+/g, '-'));

            self.template.append(caption)
                    .append(stacked_image_0)
                    .append(stacked_image_1)
                    .append(self.topOfStack);


            //wire click
            cover_photo.click(function() {
                o.onClick();
            });

            //set clean and arm caption click
            caption.text(self._ellipsis(o.caption));
            self._setupCaptionEditing();

            // insert picon into container and calculate preliminary size
            el.append(self.template);
            self._resize(o.maxCoverWidth, o.maxCoverHeight);

            var buttonBarWired = false,
                menuOpen = false,
                hover = false;


            var wire_button_bar = function() {
                //build and insert buttonbar into dom
                var buttons      = buttons_template.clone(),
                    like_button  = like_button_template.clone(),
                    info_button  = info_button_template.clone(),
                    share_button = share_button_template.clone();

                like_button.attr( 'data-zzid', o.albumId );
                buttons.append(share_button).append(like_button).append(info_button);
                button_bar.append(buttons);
                self.topOfStack.append(button_bar);

                // wire info button
                var info_menu_template = null;
                if (o.infoMenuTemplateResolver) {
                    info_menu_template = o.infoMenuTemplateResolver(o.album);
                }
                if(info_menu_template){
                    info_button.click(function(){
                        zz.infomenu.show_in_picon(info_button, info_menu_template, self,
                            function(){
                                menuOpen = true;
                            },
                            function(){
                                menuOpen = false;
                                checkCloseToolbar();
                        });
                    });
                }else{
                    info_button.hide();
                }

                //wire share button
                share_button.click(function(){
                    zz.sharemenu.show_in_picon( share_button, self,
                        function() {
                            menuOpen = true;
                        },
                        function() {
                            menuOpen = false;
                            checkCloseToolbar();
                        });
                });

                // wire like button
                zz.like.draw_tag(like_button);
            };

            var checkCloseToolbar = function() {
              _.defer(function(){
                if (!menuOpen && !hover) {
                    self.topOfStack.css({height: self.closedHeight});
                    button_bar.hide();
                }
              });
            };

            // bind the hover handlers
            var mouse_in = function() {
                hover = true;
                if(! zz.buy.is_buy_mode_active()){
                    if (!menuOpen &&  !self.isEditingCaption) {
                        if (!buttonBarWired) {
                            buttonBarWired = true;
                            wire_button_bar();
                        }
                        //display toolbar
                        self.topOfStack.css({height: self.openHeight});
                        button_bar.show();
                    }
                }
            };
            var mouse_out = function() {
                hover = false;
                checkCloseToolbar();
            };

            //load cover photos and display menus
            if( !o.coverUrl || o.coverUrl.length <= 0) {
                o.coverUrl = zz.routes.image_url('/images/photo_placeholder.png');
             }

            // load the image and resize when ready
            zz.image_utils.pre_load_image(o.coverUrl, function(image) {
                var scaledSize = zz.image_utils.scale(image, {width: o.maxCoverWidth, height: o.maxCoverHeight});
                self._resize(scaledSize.width, scaledSize.height);
                cover_photo.attr('src', image.src);
                el.hover(mouse_in, mouse_out);
            });
        },

        _resize: function(coverWidth, coverHeight) {
            var self = this,
                o = self.options;

            self.template.find('.cover-photo').css({
                height: coverHeight,
                width: coverWidth
            });

            var containerWidth  = ( o.containerWidth ?  o.containerWidth : self.element.width() );
            var containerHeight = ( o.containerHeight ?  o.containerHeight : self.element.height() );

            self.template.find('.stacked-image').css({
                height: coverHeight + 10,
                width: coverWidth + 10
            }).center_xy({
                             top: 40,
                             left: 0,
                             width: containerWidth, //save room for caption
                             height: containerHeight - ( o.captionHeight + 40)
                         });
            self.closedHeight = self.topOfStack.height();
            self.openHeight   = self.closedHeight + 30;
        },

        _setupCaptionEditing: function(){
                    //edit caption
                    var self = this;
                    var o = self.options;
                    self.isEditingCaption = false;
                    if (o.allowEditCaption) {
                        self.captionElement.unbind('click');
                        self.captionElement.click(function(event) {
                            self.editCaption();
                        });
                    }

        },

        editCaption: function() {
            var self = this;
            if (!self.isEditingCaption) {
                self.isEditingCaption = true;

                var captionEditor = $('<div class="edit-caption-border"><input type="text"><div id="spin-here" class="caption-ok-button">OK</div></div>');
                self.captionElement.html(captionEditor);
                self.element.trigger('mouseout');

                var textBoxElement = captionEditor.find('input');
                var okButton = captionEditor.find('.caption-ok-button');

                var resetCaption = function( caption ){
                    self.captionElement.text(self._ellipsis(caption));
                    // for some reason, the .ellipsis() call messes up the caption click handler on IE
                    // so we need to set up again...
                    self._setupCaptionEditing();
                    self.isEditingCaption = false;
                    self.element.trigger('mouseout');
                }

                var commitChanges = function() {
                    disarmCaptionEditor();
                    ZZAt.track('albumframe.title.click');
                    var newCaption = $.trim( textBoxElement.val() );
                    if (newCaption !== self.options.caption && newCaption.length <= MAX_NAME) {
                      self.options.onChangeCaption(newCaption,
                            function(data){ //onSuccess
                                self.options.caption = newCaption;
                                resetCaption(self.options.caption);
                            },
                            function(){ //onError
                                armCaptionEditor();
                            });
                    } else {
                        resetCaption( self.options.caption );
                    }
                };


                var armCaptionEditor = function(){
                    textBoxElement.val(self.options.caption);

                    okButton.click(function(event) {
                        commitChanges();
                        event.stopPropagation();
                        return false;
                    });
                    textBoxElement.blur(function(eventObject) {
                        commitChanges();
                        return false;
                    })
                        .keydown(function(e) {
                        var text = $(this).val();
                        if(text.length > MAX_NAME ){
                            alert("Album name cannot exceed "+MAX_NAME+" characters");
                            var new_text = text.substr(0, MAX_NAME);
                            $(this).val(new_text);
                            $(this).selectRange( MAX_NAME,MAX_NAME);
                        }else{
                            if (e.keyCode == 13 || e.keyCode == 9) {  //enter or tab
                                commitChanges();
                                return false;
                            } else if( e.keyCode == 27 ){  //escape
                                resetCaption( self.options.caption );
                            }
                        }
                    }).focus().select();
                }

                var disarmCaptionEditor = function(){
                    okButton.unbind('click');
                    textBoxElement.unbind( 'keydown')
                        .unbind('keyup')
                        .unbind('blur');
                }

                armCaptionEditor();
            }

        },

        _ellipsis: function( text ){
          if( text.length > 30){
            return text.substr(0,24) + '...';
          }else{
              return text;
          }
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });

})(jQuery);




