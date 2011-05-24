var simple_uploader = {

    open_in_dialog: function(album_id, on_close){
        var template = $('<div class="simpleuploader-container"></div>');
        var widget;

        $('<div id="simpleuploader-dialog"></div>').html( template ).zz_dialog({
            height: $(document).height() - 350,
            width: 800,
            modal: true,
            autoOpen: true,
            open: function(){
                widget = template.zz_simpleuploader({album_id: album_id}).data().zz_simpleuploader;
            },

            beforeclose: function(){
                if(widget.uploads_in_progress()){
                    return confirm('Are you sure you want to cancel the uploads still in progress?');
                }
                else{
                    return true;
                }
            },

            close: function(event, ui){
                if(on_close){
                    on_close();
                }
            }
        });
        template.height( $(document).height() - 192 );

    }

};

(function( $, undefined ) {

    $.widget( "ui.zz_simpleuploader", {
        options: {
            album_id:null
        },

        _create: function() {
            var self = this;

            var template = '<div class="simpleuploader">' +
                    '<div class="title">Upload photos to ZangZing</div>' +
                    '<div class="queue"></div>' +
                    '<a class="add-photos-button green-add-button"><span>Add Photos</span></a>' +
                    '<div class="add-button-wrapper"><div id="simpleuploader-add-button"></div></div>' +
                    '</div>';

            var queued_file_template = '<div class="queued-file">' +
                    '<div class="status"></div>' +
                    '<div class="name"></div>' +
                    '<div class="progress-container"><div class="progress-bar"></div></div>' +
                    '<div class="cancel-button"></div>' +
                    '</div>';


            self.element.html(template);

            self.queue_element = self.element.find('.queue');

            if(navigator.appVersion.indexOf("Mac")!=-1){
                var photo_source = 'simple.osx'
            }
            else{
                var photo_source = 'simple.win'
            }


            self.uploader = new SWFUpload({
                // Backend Settings
                upload_url: "/service/albums/" + self.options.album_id + "/upload",
                post_params: {"source" : photo_source},

                // File Upload Settings
                file_size_limit : "102400",	// 100MB
                file_types : "*.jpg;*.jpeg;*.png;*.gif;*.tiff;*.bmp",
                file_types_description : "Image Files",
                file_upload_limit : "100",
                file_queue_limit : "0",

                // Event Handler Settings (all my handlers are in the Handler.js file)
                file_dialog_start_handler : function(){

                },

                file_queued_handler : function(file){
                    var queued_file = $(queued_file_template);
                    queued_file.find('.name').text(file.name);
                    queued_file.attr('id', file.id);
                    self.queue_element.append(queued_file);

                    queued_file.find('.cancel-button').click(function(){
                        self.uploader.cancelUpload(file.id, false)
                        queued_file.fadeOut('fast');
                    });

                },

                file_queue_error_handler : function(file, errorCode, message){

                },

                file_dialog_complete_handler : function(numFilesSelected, numFilesQueued){
                    self.uploader.startUpload();
                },

                upload_start_handler : function(file){
                },

                upload_progress_handler : function(file, bytesLoaded, bytesTotal){
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').css('width', Math.floor(100* bytesLoaded / bytesTotal) + "%")

                },
                upload_error_handler : function(file, errorCode, message){
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .status').addClass('error');
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').hide();
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .cancel-button').hide();
                },
                upload_success_handler : function(file, serverData){
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .status').addClass('done');
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .progress-bar').hide();
                    $('.simpleuploader .queue .queued-file#' + file.id + ' .cancel-button').hide();
                },

                upload_complete_handler : function(file){

                },

                // Button Settings
                button_width: 100,
                button_height: 29,
                button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
                button_cursor: SWFUpload.CURSOR.HAND,
                button_placeholder_id: "simpleuploader-add-button",

                // Flash Settings
                flash_url : "/static/swf/swfupload.swf",




                // Debug Settings
                debug: true,
                debug_handler: function(message){
                    logger.debug(message);
                }
            });






        },

        uploads_in_progress : function(){
            return this.uploader.getStats().in_progress;
        },

        destroy: function() {
            $.Widget.prototype.destroy.apply( this, arguments );
        }
    });
})( jQuery );