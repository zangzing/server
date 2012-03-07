var zz = zz || {};

zz.simple_uploader = {

    //creates simple uploader button by injecting invisible flash
    //button movie into the 'wrapper_element'. 'on_done' callback
    //accepts number of photos uploaded
    instance: function(wrapper_element, album_id, on_done, user_credentials) {

        wrapper_element.html('<div id="replace-with-swfupload"></div>').zz_simpleuploader({
            button_placeholder_id: 'replace-with-swfupload',
            album_id: album_id,
            on_done: on_done,
            user_credentials: user_credentials
        });
    }
};

(function($, undefined) {

    $.widget('ui.zz_simpleuploader', {
        options: {
            album_id: null,
            on_done: function(uploads_completed) {
            },
            button_placeholder_id: null,
            user_credentials: null
        },

        _create: function() {
            var self = this;

            var template = $('<div id="simpleuploader-dialog">' +
                    '<div class="simpleuploader-container">' +
                    '<div class="simpleuploader">' +
                    '<div class="title">Uploading photos to ZangZing</div>' +
                    '<div class="queue"></div>' +
                    '</div>' +
                    '<a class="done-button black-button"><span>Done</span></a>' +
                    '</div>' +
                    '</div>');

            var queued_file_template = $('<div class="queued-file">' +
                    '<div class="status"></div>' +
                    '<div class="name"></div>' +
                    '<div class="progress-container"><div class="progress-bar"></div></div>' +
                    '<div class="cancel-button"></div>' +
                    '</div>');


            if (navigator.appVersion.indexOf('Mac') != -1) {
                var photo_source = 'simple.osx';
            }
            else {
                var photo_source = 'simple.win';
            }


            var confirm_close = function() {
                if (self.uploads_in_progress()) {
                    if (confirm('Are you sure you want to cancel the uploads still in progress?')) {
                        ZZAt.track('simpleuploader.cancel_with_pending');
                        return true;
                    }
                    else {
                        return false;
                    }
                }
                else {
                    return true;
                }
            };

            var uploads_completed = 0;


            var open_progress_dialog = function() {


                self.queue_element = template.find('.queue');

                var dialog = zz.dialog.show_dialog(template, {
                    height: $(document).height() - 350,
                    width: 800,
                    modal: true,
                    autoOpen: true,

                    beforeclose: confirm_close,

                    close: function(event, ui) {
                        self.options.on_done(uploads_completed);
                    }
                });


                template.find('.done-button').click(function() {
                    dialog.close();
                });

                template.height($(document).height() - 192);

                ZZAt.track('simpleuploader.photos.added');
            };


            var upload_started = false;

            self.uploader = new SWFUpload({
                // Backend Settings
                upload_url: '/service/albums/' + self.options.album_id + '/upload',
                //post_params: {'source' : photo_source},
                post_params: {'source' : photo_source, 'user_credentials': self.options.user_credentials},

                // File Upload Settings
                file_size_limit: '102400',    // 100MB
                file_types: '*.jpg;*.jpeg;*.png;*.gif;*.tiff;*.JPG;*.JPEG;*.PNG;*.GIF;*.TIFF',
                file_types_description: 'Image Files',
                file_upload_limit: '0',
                file_queue_limit: '0',


                prevent_swf_caching: $.client.browser == 'Explorer',

                file_dialog_start_handler: function() {
                    ZZAt.track('simpleuploader.button.click');
                },

                file_queued_handler: function(file) {

                    if (!upload_started) {
                        open_progress_dialog();
                        self.uploader.startUpload();
                        console.debug(self.uploader);
                        upload_started = true;
                    }


                    var queued_file = queued_file_template.clone();
                    queued_file.find('.name').text(file.name);
                    queued_file.attr('id', file.id);
                    self.queue_element.append(queued_file);

                    queued_file.find('.cancel-button').click(function() {
                        self.uploader.cancelUpload(file.id, false);
                        queued_file.fadeOut('fast');
                        ZZAt.track('simpleuploader.photo.cancel');

                    });


                },

                file_queue_error_handler: function(file, errorCode, message) {
                    console.debug("error: " + errorCode + " : " + message);
                },

                file_dialog_complete_handler: function(numFilesSelected, numFilesQueued) {

                },

                upload_start_handler: function(file) {

                },

                upload_progress_handler: function(file, bytesLoaded, bytesTotal) {
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').css('width', Math.floor(100 * bytesLoaded / bytesTotal) + '%');

                },
                upload_error_handler: function(file, errorCode, message) {
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .status').addClass('error');
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').hide();
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .cancel-button').hide();
                    ZZAt.track('simpleuploader.photo.error', {errorCode: errorCode, errorMessage: message});

                },
                upload_success_handler: function(file, serverData) {
                    uploads_completed++;

                    $('.simpleuploader .queue .queued-file#' + file.id + ' .status').addClass('done');
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').hide();
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .cancel-button').hide();
                    ZZAt.track('simpleuploader.photo.uploaded');

                },

                upload_complete_handler: function(file) {

                },

                // Button Settings
                button_width: 158,
                button_height: 29,
                button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
                button_cursor: SWFUpload.CURSOR.HAND,
                button_placeholder_id: self.options.button_placeholder_id,

                // Flash Settings
                flash_url: '/static/swf/swfupload.swf',




                // Debug Settings
                debug: false,
                debug_handler: function(message) {
                    zz.logger.debug(message);
                }
            });


        },

        uploads_in_progress: function() {
            return this.uploader.getStats().in_progress;
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply(this, arguments);
        }
    });
})(jQuery);
