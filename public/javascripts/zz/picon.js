/*
 *
 */

(function($, undefined) {

    $.widget('ui.zz_picon', {
        options: {
            caption: '',
            coverUrl: '',
            albumUrl: null,
            albumId: null,
            onClick: $.noop,
            onLike: $.noop,
            onDelete: $.noop,
            allowDelete: false,
            maxCoverWidth: 180,
            maxCoverHeight: 150,
            captionHeight: 80,
            stackAngles: [
                [-6, -3],
                [-3, 3],
                [6, 3]
            ]
        },

        _create: function() {
            var self = this,
                    el = self.element,
                    o = self.options;

            self.template = $('<div class="picon">');
            var caption = $('<div class="caption">'),
                    stacked_image_0 = $('<div class="stacked-image">'),
                    stacked_image_1 = $('<div class="stacked-image">'),
                    cover_photo = $('<img class="cover-photo" src="' + zz.routes.image_url('/images/photo_placeholder.png') + '">'),
                    button_bar = $('<div class="button-bar">'),
                    buttons = $('<div class="buttons">'),
                    share_button = $('<div class="button share-button">'),
                    like_button = $('<div class="button like-button zzlike" data-zzid="' + o.albumId + '" data-zztype="album"><div class="zzlike-icon thumbdown">'),
                    delete_button = $('<div class="button delete-button">');

            self.topOfStack = $('<div class="stacked-image">').append(cover_photo);

            self.template.append(caption)
                    .append(stacked_image_0)
                    .append(stacked_image_1)
                    .append(self.topOfStack);

            // insert picon into DOM
            this.element.append(self.template);

            //for selenium tests...
            el.find('.picon').attr('id', 'picon-' + o.caption.replace(/[\W]+/g, '-'));

            //rotate stack
            var stackOption = Math.floor(Math.random() * o.stackAngles.length);
            stacked_image_0.rotate(o.stackAngles[stackOption][0]);
            stacked_image_1.rotate(o.stackAngles[stackOption][1]);

            //set caption
            caption.text(o.caption);

            //wire click
            cover_photo.click(function() {
                o.onClick();
            });

            //calculate size
            self._resize(o.maxCoverWidth, o.maxCoverHeight);

            var buttonBarWired = false;
            var menuOpen = false;
            var hover = false;
            var height;

            var wire_button_bar = function() {
                //build and insert buttonbar into dom
                buttons.append(share_button).append(like_button);
                if (o.allowDelete) {
                    buttons.append(delete_button);
                    delete_button.click(function() {
                        o.onDelete();
                    });
                }
                button_bar.append(buttons);
                self.topOfStack.append(button_bar);

                // wire share button
                share_button.zz_menu(
                { subject_id: o.albumId,
                    subject_type: 'album',
                    container: $('#article'),
                    zza_context: 'frame',
                    style: 'auto',
                    bind_click_open: true,
                    append_to_element: true, //use the element zzindex so the overflow goes under the bottom toolbar
                    menu_template: zz.sharemenu.template,
                    click: zz.sharemenu.click_handler,
                    open: function() {
                        menuOpen = true;
                    },
                    close: function() {
                        menuOpen = false;
                        checkCloseToolbar();
                    }
                });

                // wire like button
                zz.like.draw_tag(like_button);
            };

            var checkCloseToolbar = function() {
                if (!menuOpen && !hover) {
                    self.topOfStack.css({height: height});
                    button_bar.hide();
                }
            };

            var mouse_in = function() {
                hover = true;
                if (!menuOpen) {
                    if (!buttonBarWired) {
                        wire_button_bar();
                        buttonBarWired = true;
                    }
                    //display toolbar
                    height = self.topOfStack.height();
                    self.topOfStack.css({height: height + 30});
                    button_bar.show();
                }
            };

            var mouse_out = function() {
                hover = false;
                checkCloseToolbar();
            };

            //load cover photos and display menus
            if (o.coverUrl) {
                var onload = function(image) {
                    var scaledSize = zz.image_utils.scale(image, {width: o.maxCoverWidth, height: o.maxCoverHeight});
                    self._resize(scaledSize.width, scaledSize.height);
                    cover_photo.attr('src', image.src);
                    el.hover(mouse_in, mouse_out);
                };
                var onerror = function(image) {
                    el.hover(mouse_in, mouse_out);
                };
                zz.image_utils.pre_load_image(o.coverUrl, onload, onerror);
            } else {
                el.hover(mouse_in, mouse_out);
            }
        },

        _resize: function(coverWidth, coverHeight) {
            var self = this;
            self.template.find('.cover-photo').css({
                height: coverHeight,
                width: coverWidth
            });
            self.template.find('.stacked-image').css({
                height: coverHeight + 10,
                width: coverWidth + 10
            }).center_xy({
                             top: 40,
                             left: 0,
                             width: self.element.width(), //save room for caption
                             height: self.element.height() - (self.options.captionHeight + 40)
                         });
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });

})(jQuery);




