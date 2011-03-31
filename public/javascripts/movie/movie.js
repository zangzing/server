/**
 * @preserve
 * ----------
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */


// Custom Simple Fade Gallery
(function($) {
    $.CustomSimpleFade = {

        /**
         * Slideshow initialization
         */
        init: function(configs) {

            this.clearResources();


            //*** IDENTIFIERS ***\\

            // generic canvas identifier
            this.canvasIdentifier = null,

                // preloader identifier
                    this.preloaderIdentifier = null,

                // timeout id's
                    this.timeoutResources = [],
                    this.hideElements = [],
                    this.resizeTimeout = null,

                // call stack shows how many times embed canvas was initialized
                    this.callStack = 0;

            // instance number shows the number of template class initialization
            this.instanceNO = 0,


                //*** CUSTOMIZATION DEFAULTS ***\\

                // Auto hide controls property
                    this.autoHideControls = false,

                // Auto slideshow property
                    this.autoSlideShow = true,

                // The text of the exit button
                    this.backButtonLabel = 'Back to album';

            // The color of the background displayed by the album
            this.backgroundColor = '#000000',

                // The URL or file path and name of an image displayed as the background of the album
                    this.backgroundImage = '',

                // Background visible property
                    this.backgroundVisible = true,

                // Border color value
                    this.borderColor = '#ffffff',

                // Border size value
                    this.borderSize = 5,

                //control bar opened or closed
                    this.controlBarState = 'opened';

            // Controls hide speed value
            this.controlsHideSpeed = 2,

                // Show exit button property
                    this.backButton = true,

                // The URL or file path and name of an image displayed as the exit button
                    this.backButtonURL = '',

                // Control bar icons URL
                    this.iconsURL = 'icons/',

                // Load original images property
                    this.loadOriginalImages = false,

                // Scale background property
                    this.scaleBackground = true,

                // Scale mode type
                    this.scaleMode = 'scaleCrop',

                // Shadow color value
                    this.shadowColor = '#000000',

                // Shadow distance value
                    this.shadowDistance = 5,

                // Slideshow speed value
                    this.slideShowSpeed = 6,

                // Transition speed value
                    this.transitionSpeed = 0.4,

                // Transition type
                    this.transitionType = 'fade',


                //*** SETTINGS ***\\

                // canvas width in normal screen mode - defined by setWidth method
                    this.defaultCanvasWidth = null,

                // curent canvas width
                    this.canvasWidth = null,

                // slideshow display width 
                    this.displayWidth = null,

                // canvas height in normal screen mode - defined by setHeight method
                    this.defaultCanvasHeight = null,

                // curent canvas height
                    this.canvasHeight = null,

                // slideshow display height
                    this.displayHeight = null,

                // preloader animation speed, lower = faster
                    this.preloaderSpeed = 80,

                //source type json or xml
                    this.sourceType = 'json';

            // images xml path
            this.source = null,

                // xml json object containing images
                    this.xml,

                // preload After or Before
                    this.preload = 'after';

            //*** FLAGS ***\\

            // fix css flag
            this.flagFixCss = true,

                // frozen engine
                    this.flagFrozen = false,

                // resize handler
                    this.flagResizeHandler = false,

                // fullscreen flag
                    this.fullScreenMode = true;

            //*** GO ON ***\\

            if (!this.parseConfigs(configs)) {
                return;
            }

            if (!this.generateIdentifier()) {
                return;
            }

            this.fixCSS();

            if (typeof configs.appendToID != 'undefined' && configs.appendToID.length > 0) {
                $('<div />').attr('id', this.canvasIdentifier + '_GP')
                        .css({width:this.defaultCanvasWidth + 'px',height:this.defaultCanvasHeight + 'px'})
                        .appendTo('#' + configs.appendToID);

            } else if (typeof configs.insertAfterID != 'undefined' && configs.insertAfterID.length > 0) {
                $('<div />').attr('id', this.canvasIdentifier + '_GP')
                        .css({width:this.defaultCanvasWidth + 'px',height:this.defaultCanvasHeight + 'px'})
                        .insertAfter('#' + configs.insertAfterID);
            }

            $('<div />').attr('id', this.canvasIdentifier).appendTo('#' + this.canvasIdentifier + '_GP');

            this.preloaderIdentifier = this.canvasIdentifier + '_preloader';

            eval('$(document).ready(function(){window.'
                    + this.canvasIdentifier + '.loadTemplateXml(' + this.callStack + ')})');
        },

        /**
         * clear timeout resources
         */
        clearResources: function() {
            if (typeof this.timeoutResources != 'undefined') {
                while (this.timeoutResources.length > 0) {
                    clearTimeout(this.timeoutResources[0]);
                    this.timeoutResources.splice(0, 1);
                }
            }
            if (typeof this.timeoutResources != 'undefined') {
                while (this.hideElements.length > 0) {
                    $('#' + this.hideElements[0]).hide();
                    this.hideElements.splice(0, 1);
                }
            }
        },

        /**
         * Parse user configs
         */
        parseConfigs: function(configs) {
            if (typeof configs.width != 'number' || configs.width <= 0
                    || typeof configs.height != 'number' || configs.height <= 0
                    || typeof configs.source != 'string' || configs.source.length <= 0
                    ||
                    (
                            (typeof configs.appendToID != 'string' || configs.appendToID.length <= 0)
                                    &&
                                    (typeof configs.insertAfterID != 'string' || configs.insertAfterID.length <= 0)
                            )) {
                return false;
            }

            // source
            this.source = configs.source;

            // width and height
            this.defaultCanvasWidth = parseInt(configs.width);
            this.defaultCanvasHeight = parseInt(configs.height);

            // fix css
            if (typeof configs.fixCss != 'undefined') {
                if (configs.fixCss.toString().toLowerCase() == 'true') {
                    this.flagFixCss = true;
                } else if (configs.fixCss.toString().toLowerCase() == 'false') {
                    this.flagFixCss = false;
                }
            }

            // autoHideControls
            if (typeof configs.autoHideControls != 'undefined') {
                if (configs.autoHideControls.toString().toLowerCase() == 'true') {
                    this.autoHideControls = true;
                } else if (configs.autoHideControls.toString().toLowerCase() == 'false') {
                    this.autoHideControls = false;
                }
            }

            // autoSlideShow
            if (typeof configs.autoSlideShow != 'undefined') {
                if (configs.autoSlideShow.toString().toLowerCase() == 'true') {
                    this.autoSlideShow = true;
                } else if (configs.autoSlideShow.toString().toLowerCase() == 'false') {
                    this.autoSlideShow = false;
                }
            }
            // backButtonLabel
            if (typeof configs.backButtonLabel != 'undefined' && configs.backButtonLabel.length > 0) {
                this.backButtonLabel = configs.backButtonLabel;
            }
            // backgroundColor
            if (typeof configs.backgroundColor != 'undefined' && configs.backgroundColor.length > 0) {
                this.backgroundColor = configs.backgroundColor;
            }

            // backgroundImage
            if (typeof configs.backgroundImage != 'undefined' && configs.backgroundImage.length > 0) {
                this.backgroundImage = configs.backgroundImage;
            }

            // backgroundVisible
            if (typeof configs.backgroundVisible != 'undefined') {
                if (configs.backgroundVisible.toString().toLowerCase() == 'true') {
                    this.backgroundVisible = true;
                } else if (configs.backgroundVisible.toString().toLowerCase() == 'false') {
                    this.backgroundVisible = false;
                }
            }

            // borderColor
            if (typeof configs.borderColor != 'undefined' && configs.borderColor.length > 0) {
                this.borderColor = configs.borderColor;
            }

            // borderSize
            if (typeof configs.borderSize != 'undefined' && configs.borderSize >= 0) {
                this.borderSize = parseInt(configs.borderSize);
            }

            // control bar state
            if (typeof configs.controlBarState != 'undefined') {
                if (configs.controlBarState.toString().toLowerCase() == 'opened') {
                    this.controlBarState = 'opened';
                } else if (configs.controlBarState.toString().toLowerCase() == 'closed') {
                    this.controlBarState = 'closed';
                }
            }

            // controlsHideSpeed
            if (typeof configs.controlsHideSpeed != 'undefined' && configs.controlsHideSpeed >= 0) {
                this.controlsHideSpeed = parseFloat(configs.controlsHideSpeed) * 1000;
            }

            // backButton
            if (typeof configs.backButton != 'undefined') {
                if (configs.backButton.toString().toLowerCase() == 'true') {
                    this.backButton = true;
                } else if (configs.backButton.toString().toLowerCase() == 'false') {
                    this.backButton = false;
                }
            }

            // backButtonURL
            if (typeof configs.backButtonURL != 'undefined' && configs.backButtonURL.length > 0) {
                this.backButtonURL = configs.backButtonURL;
            }

            // iconsURL
            if (typeof configs.iconsURL != 'undefined' && configs.iconsURL.length > 0) {
                this.iconsURL = configs.iconsURL;
            }

            // loadOriginalImages
            if (typeof configs.loadOriginalImages != 'undefined') {
                if (configs.loadOriginalImages.toString().toLowerCase() == 'true') {
                    this.loadOriginalImages = true;
                } else if (configs.loadOriginalImages.toString().toLowerCase() == 'false') {
                    this.loadOriginalImages = false;
                }
            }

            // scaleBackground
            if (typeof configs.scaleBackground != 'undefined') {
                if (configs.scaleBackground.toString().toLowerCase() == 'true') {
                    this.scaleBackground = true;
                } else if (configs.scaleBackground.toString().toLowerCase() == 'false') {
                    this.scaleBackground = false;
                }
            }
            // scaleMode
            if (typeof configs.scaleMode != 'undefined') {
                if (configs.scaleMode.toString().toLowerCase() == 'scale') {
                    this.scaleMode = 'scale';
                } else if (configs.scaleMode.toString().toLowerCase() == 'scalecrop') {
                    this.scaleMode = 'scalecrop';
                }
            }

            // shadowColor
            if (typeof configs.shadowColor != 'undefined' && configs.shadowColor.length > 0) {
                this.shadowColor = configs.shadowColor;
            }

            // shadowDistance
            if (typeof configs.shadowDistance != 'undefined' && configs.shadowDistance >= 0) {
                this.shadowDistance = parseInt(configs.shadowDistance);
            }

            // slideShowSpeed
            if (typeof configs.slideShowSpeed != 'undefined' && configs.slideShowSpeed >= 0) {
                this.slideShowSpeed = parseFloat(configs.slideShowSpeed) * 1000;
            }

            // transitionSpeed
            if (typeof configs.transitionSpeed != 'undefined' && configs.transitionSpeed >= 0) {
                this.transitionSpeed = parseFloat(configs.transitionSpeed) * 1000;
            }

            // transitionType
            if (typeof configs.transitionType != 'undefined') {
                if (configs.transitionType.toString().toLowerCase() == 'fade') {
                    this.transitionType = 'fade';
                } else if (configs.transitionType.toString().toLowerCase() == 'slide') {
                    this.transitionType = 'slide';
                }
            }

            // chaching parameters
            if (typeof configs.preloadAfter != 'undefined' && configs.preloadAfter >= 0) {
                this.preloadAfter = parseInt(configs.preloadAfter);
            }
            if (typeof configs.preloadBefore != 'undefined' && configs.preloadBefore >= 0) {
                this.preloadBefore = parseInt(configs.preloadBefore);
            }

            //sourceType json or xml
            if (typeof configs.sourceType != 'undefined') {
                if (configs.sourceType.toString().toLowerCase() == 'xml') {
                    this.sourceType = 'xml';
                } else if (configs.sourceType.toString().toLowerCase() == 'json') {
                    this.sourceType = 'json';
                }
            }
            return true;
        },

        /**
         * Globally Unique Identifier Generator for current slideshow
         */
        generateIdentifier: function() {
            var i = 1;
            while ((document.getElementById('CustomSimpleFadeContainer' + i) != null
                    || eval('typeof window.CustomSimpleFadeContainer' + i) != 'undefined')
                    && i < 1000) {
                i++;
            }
            this.canvasIdentifier = 'CustomSimpleFadeContainer' + i;
            this.callStack = i;
            eval('window.' + this.canvasIdentifier + '=this');

            return true;
        },

        /**
         * Fix CSS
         */
        fixCSS: function() {
            if (this.flagFixCss == false) {
                return;
            }
            var err;
            try {
                $.tocssRule(
                        '#' + this.canvasIdentifier + '_GP, #' + this.canvasIdentifier + '_GP * {' +
                                'background:none fixed transparent left top no-repeat;' +
                                'border:none;' +
                                'bottom:auto;' +
                                'clear:none;' +
                                'cursor:auto;' +
                                'direction:ltr;' +
                                'display:block;' +
                                'float:none;' +
                                'font-family:"Lucida Grande","Lucida Sans Unicode","Lucida Sans",' +
                                'Verdana,Arial,Helvetica,sans-serif;' +
                                'font-size:10px;' +
                                'font-size-adjust:none;' +
                                'font-stretch:normal;' +
                                'font-style:normal;' +
                                'font-variant:normal;' +
                                'font-weight:normal;' +
                                'height:auto;' +
                                'layout-flow:horizontal;' +
                                'layout-grid:none;' +
                                'left:0px;' +
                                'letter-spacing:normal;' +
                                'line-break:normal;' +
                                'line-height:normal;' +
                                'list-style:disc outside none;' +
                                'margin:0px 0px 0px 0px;' +
                                'max-height:none;' +
                                'max-width:none;' +
                                'min-height:0px;' +
                                'min-width:0px;' +
                                '-moz-border-radius:0;' +
                                'outline-color:invert;' +
                                'outline-style:none;' +
                                'outline-width:medium;' +
                                'overflow:visible;' +
                                'padding:0px 0px 0px 0px;' +
                                'position:static;' +
                                'right:auto;' +
                                'text-align:left;' +
                                'text-decoration:none;' +
                                'text-indent:0px;' +
                                'text-shadow:none;' +
                                'text-transform:none;' +
                                'top:0px;' +
                                'vertical-align:baseline;' +
                                'visibility:visible;' +
                                'width:auto;' +
                                'word-spacing:normal;' +
                                'z-index:1;' +
                                'zoom:1;' +
                                '}'
                        );
            } catch(err) {
            }
            ;
        },

        /**
         * Load Album Template XML, store data in xml var and run canvas setup function
         */
        loadTemplateXml: function(callStack) {
            if (this.callStack != callStack) {
                return;
            }
            var obj = this;
            if (this.sourceType == 'xml') {
                $.get(this.source, function(data) {
                    obj.xml = $.xml2json(data);
                    if (typeof obj.xml.items.item[0] == 'undefined') {
                        if (typeof obj.xml.items.item.largeImagePath != 'undefined') {
                            obj.xml.items.item = [obj.xml.items.item];
                        } else {
                            return false;
                        }
                    }
                    obj.canvasSetup(callStack);
                });
            }
            if (this.sourceType == 'json') {
                $.getJSON(this.source, function(data) {
                    obj.xml = {items:{item:[]}};
                    var element;
                    if (data.length == 0) {
                        return false;
                    }
                    for (i = 0; i < data.length; i++) {
                        element = {fullScreenImagePath:data[i].full_screen_url, largeImagePath:data[i].screen_url, description:data[i].caption};
                        obj.xml.items.item.push(element);
                    }
                    obj.canvasSetup(callStack);
                });
            }
        },

        /**
         * Canvas Master Setup
         */
        canvasSetup: function(callStack) {
            if (typeof callStack == 'undefined') {
                var callStack = this.callStack;
            } else if (this.callStack != callStack) {
                return;
            }
            var instanceNO = ++this.instanceNO;
            this.setFrozenFlagOn();


            var obj = this;

            if (this.fullScreenMode == true) {
                if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
                    $('#' + this.canvasIdentifier).css({
                        position:'absolute',
                        marginTop:'auto',
                        marginLeft:'auto'
                    });

                    var elemOffset = $('#' + this.canvasIdentifier).offset();

                    $('#' + this.canvasIdentifier).css({
                        position:'absolute',
                        marginTop:(-1 * elemOffset.top + $(window).scrollTop()) + 'px',
                        marginLeft:(-1 * elemOffset.left + $(window).scrollLeft()) + 'px',
                        width:$(window).width() + 'px',
                        height:$(window).height() + 'px',
                        overflow:'hidden',
                        backgroundColor:this.backgroundColor
                    });

                    $(window).scroll(function () {
                        if (obj.fullScreenMode == true) {
                            $('#' + obj.canvasIdentifier).css({
                                marginTop:(-1 * elemOffset.top + $(window).scrollTop()) + 'px',
                                marginLeft:(-1 * elemOffset.left + $(window).scrollLeft()) + 'px'
                            });
                        }
                    });
                } else {
                    $('#' + this.canvasIdentifier).css({
                        position:'fixed',
                        top:'0px',
                        left:'0px',
                        width:$(window).width() + 'px',
                        height:$(window).height() + 'px',
                        overflow:'hidden',
                        backgroundColor:this.backgroundColor
                    });
                }

                /* in the js version there is only fullscreen mode
                 if ($.browser.msie && $.browser.version < 7) {
                 $(document).keypress(function(event) {
                 if (event.keyCode == '27' && obj.fullScreenMode == true && !obj.isFrozen()) {
                 obj.showNormalScreen();
                 return false;
                 }
                 });
                 } else {
                 $(document).keydown(function(event) {
                 if (event.keyCode == '27' && obj.fullScreenMode == true && !obj.isFrozen()) {
                 obj.showNormalScreen();
                 return false;
                 }
                 });
                 }
                 */

                this.canvasWidth = $('#' + this.canvasIdentifier).width();
                this.canvasHeight = $('#' + this.canvasIdentifier).height();
            } else {
                $('#' + this.canvasIdentifier).css({
                    position:'relative',
                    width:this.defaultCanvasWidth + 'px',
                    height:this.defaultCanvasHeight + 'px',
                    overflow:'hidden'
                });
                this.canvasWidth = this.defaultCanvasWidth;
                this.canvasHeight = this.defaultCanvasHeight;
            }

            if (this.backgroundVisible) {
                $('#' + this.canvasIdentifier).css({backgroundColor:this.backgroundColor});
            } else {
                $('#' + this.canvasIdentifier).css({backgroundColor:'transparent'});
            }

            this.displayHeight = this.canvasHeight;
            this.displayWidth = this.canvasWidth;

            this.generatePreloader(this.preloaderIdentifier,
                    'window.' + this.canvasIdentifier + '.showPreloader(' + callStack + ')');

            if ($('#' + this.canvasIdentifier).is(':visible')) {
                this.setBackgroundImage(callStack);
                this.initiateTemplateJS(callStack, instanceNO);
            } else {
                $('#' + this.canvasIdentifier).fadeIn('fast', function() {
                    obj.setBackgroundImage(callStack);
                    obj.initiateTemplateJS(callStack, instanceNO);
                });
            }
        },

        /**
         * Check if canvas is in frozen state
         */
        isFrozen: function() {
            return this.flagFrozen == true;
        },

        /**
         * Unfroze canvas
         */
        setFrozenFlagOff: function() {
            this.flagFrozen = false;
        },

        /**
         * Froze canvas
         */
        setFrozenFlagOn: function() {
            this.flagFrozen = true;
        },

        /**
         * Run fullscreen mode
         */
        showFullScreen: function() {
            if (this.isFrozen()) {
                return;
            }
            this.clearResources();
            this.fullScreenMode = true;
            this.autoSlideShow = undefined;

            var localScope = this;
            if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
                $('#' + this.canvasIdentifier).empty();
                $('embed, object, select').css({ 'visibility' : 'visible' });
                if (!localScope.flagResizeHandler) {
                    localScope.flagResizeHandler = true;
                    $(window).resize(function() {
                        if (localScope.fullScreenMode == true) {
                            window.clearTimeout(localScope.resizeTimeout);
                            localScope.resizeTimeout = window.setTimeout(
                                    'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
                        }
                    });
                }
                localScope.canvasSetup();
            } else {
                $('#' + this.canvasIdentifier).fadeOut('fast', function() {
                    $(this).empty();
                    $('embed, object, select').css({ 'visibility' : 'visible' });
                    if (!localScope.flagResizeHandler) {
                        localScope.flagResizeHandler = true;
                        $(window).resize(function() {
                            if (localScope.fullScreenMode == true) {
                                window.clearTimeout(localScope.resizeTimeout);
                                localScope.resizeTimeout = window.setTimeout(
                                        'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
                            }
                        });
                    }
                    localScope.canvasSetup();
                });
            }
        },

        /**
         * Run normal screen mode
         */
        showNormalScreen: function() {
            if (this.isFrozen()) {
                return;
            }
            this.clearResources();
            this.fullScreenMode = false;
            this.autoSlideShow = undefined;

            var localScope = this;

            if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
                $('#' + this.canvasIdentifier).empty();
                $('embed, object, select').css({ 'visibility' : 'visible' });
                $('#' + localScope.canvasIdentifier).css({marginTop:'auto',marginLeft:'auto'});
                localScope.canvasSetup();
            } else {
                $('#' + this.canvasIdentifier).fadeOut('fast', function() {
                    $(this).empty();
                    $('embed, object, select').css({ 'visibility' : 'visible' });
                    localScope.canvasSetup();
                });
            }
        },

        /**
         * Convert hex to rgba colors
         */
        hexToRgb: function (color, alpha) {
            if (typeof color === 'undefined' || (color.length !== 4 && color.length !== 7)) {
                return false;
            }
            if (color.length === 4) {
                color = ('#' + color.substring(1, 2)) + color.substring(1, 2) + color.substring(2, 3) + color.substring(2, 3) + color.substring(3, 4) + color.substring(3, 4);
            }
            var r = parseInt(color.substring(1, 7).substring(0, 2), 16);
            var g = parseInt(color.substring(1, 7).substring(2, 4), 16);
            var b = parseInt(color.substring(1, 7).substring(4, 6), 16);
            return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
        },

        /**
         * Set Background Image
         */
        setBackgroundImage: function(callStack) {
            if (this.callStack != callStack) {
                return;
            }
            var localScope = this;
            if (this.backgroundVisible && this.backgroundImage.length > 0) {
                var obj = this;
                var bgImg = this.canvasIdentifier + '_backgroundImage';
                $('<img>').load(
                        function() {
                            $(this).unbind('load').hide().attr('id', bgImg).appendTo('#' + obj.canvasIdentifier);
                            if (localScope.scaleBackground) {
                                var cH = $(this).height();
                                var cW = $(this).width();
                                var canvasProp = obj.displayWidth / obj.displayHeight;
                                var imageProp = cW / cH;

                                if (cH != obj.displayHeight || cW != obj.displayWidth) {
                                    if (canvasProp > imageProp) {
                                        $(this).width(obj.displayWidth)
                                                .height(Math.ceil(cH * obj.displayWidth / cW))
                                            // max-width -> fix for chrome and safari
                                                .css('max-width', obj.displayWidth);
                                    } else {
                                        $(this).height(obj.displayHeight)
                                                .width(Math.ceil(cW * obj.displayHeight / cH))
                                            // max-width -> fix for chrome and safari
                                                .css('max-width', Math.ceil(cW * obj.displayHeight / cH));
                                    }
                                }
                            }
                            $(this).css({position:'absolute', zIndex:0,
                                marginTop:(obj.canvasHeight - $(this).height()) / 2 + 'px',
                                marginLeft:(obj.canvasWidth - $(this).width()) / 2 + 'px'})
                                    .fadeIn('fast');
                        }).attr('src', this.backgroundImage);
            }
        },

        /**
         * Rotate preloader
         */
        rotatePreloaderTick: function(func, preloader, preloaderSpeed) {
            return function() {
                var o;
                $(preloader).clearRect([-15, -15], {width: 30, height: 30});
                $(preloader).rotate(Math.PI / 6);
                for (var i = 0; i < 12; i++) {
                    o = ((i > 10) ? 10 : i) / 10;
                    $(preloader).style({
                        fillStyle: 'rgba(255, 255, 255, ' + o + ')',
                        strokeStyle: 'rgba(0, 0, 0, ' + o + ')',
                        lineWidth: .5
                    });
                    $(preloader).strokeRect([-1.5, 7], {width: 3, height: 7});
                    $(preloader).fillRect([-1.5, 7], {width: 3, height: 7});
                    $(preloader).rotate(Math.PI / 6);
                }
                setTimeout(func.call(this, func, preloader, preloaderSpeed), preloaderSpeed);
            };
        },

        /**
         * Generate preloader
         */
        generatePreloader: function(id, callback) {
            var obj = this;

            var preloader = $('<div/>').attr('id', id).css({
                width: 30, minWidth: 30,
                height: 30, minHeight: 30
            }).appendTo('#' + this.canvasIdentifier).canvas();

            var tick, ticks = [];
            $(preloader).translate(15, 15);
            setTimeout(this.rotatePreloaderTick(this.rotatePreloaderTick, preloader, this.preloaderSpeed), this.preloaderSpeed);

            if (typeof callback === 'string') {
                setTimeout(callback, 0); // eval calls too quickly? - the above css() doesn't seem to get executed fast enough so the width/height is not set
            }
        },

        /**
         * Show generic preloader
         */
        showPreloader: function(callStack) {
            if (typeof callStack != 'undefined' && this.callStack != callStack) {
                return;
            }
            $('#' + this.preloaderIdentifier).css({position:'absolute', zIndex:50,
                marginTop:((this.displayHeight - $('#' + this.preloaderIdentifier).height()) / 2) + 'px',
                marginLeft:((this.displayWidth - $('#' + this.preloaderIdentifier).width()) / 2) + 'px'
            }).show();
        },

        /**
         * Hide generic preloader
         */
        hidePreloader: function(callback) {
            $('#' + this.preloaderIdentifier).hide();

            if (typeof callback === 'string') {
                eval(callback);
            }
        },

        /**
         * Slideshow initialization
         */
        initiateTemplateJS: function(callStack, instanceNO) {
            if (this.callStack != callStack) {
                return;
            }

            if (this.instanceNO <= 1) {
                this.setGlobals();

            } else if (this.instanceNO != instanceNO) {
                return;
            }

            this.setFrozenFlagOff();

            this.infoBarIdentifier = this.canvasIdentifier + '_infoBar';
            this.imageIdentifier = this.canvasIdentifier + '_template_img';
            this.oldImageIdentifier = this.canvasIdentifier + '_template_img_old';
            this.controlBarIdentifier = this.canvasIdentifier + '_controlBar';
            this.shadowBgCanvas = this.canvasIdentifier + '_shadowBgCanvas';
            this.imgContainer = this.canvasIdentifier + '_imgContainer';

            this.inCanvas = false;
            this.controlBarFocused = false;
            this.oldImage = this.currentImage;
            this.firstLoad = true;
            clearTimeout(this.slideTimeout);

            if (this.loadControls(callStack)) {
                this.startSlideShow(callStack);
            }
        },

        /**
         * Control bar visibility controler
         */
        cbControl: function() {
            if (this.controlBarVisible) {
                this.controlBarVisible = false;
                $('#' + this.controlBarIdentifier).stop(true, true);
                $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, true);
                this.rollDownCB();
            } else {
                this.controlBarVisible = true;
                $('#' + this.controlBarIdentifier).stop(true, true);
                $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, true);
                this.rollUpCB();
            }
        },

        /**
         * Next image
         */
        nextControl: function() {
            this.nextImage();
        },

        /**
         * Previous image
         */
        prevControl: function() {
            this.prevImage();
        },

        /**
         * Exit button control
         */
        exitControl: function() {
            window.location = this.backButtonURL;
        },

        /**
         * caption button control
         */
        captionControl: function() {
            this.captionVisible = !this.captionVisible;
            if (this.captionVisible) {
                this.showCaption('normal');
            } else {
                this.hideCaption('normal');
            }
        },

        /**
         * Play/Pause button control
         */
        ppControl: function(callStack) {
            if (this.autoSlideShow) {
                this.pauseControl(callStack);
            } else {
                this.playControl(callStack);
            }
            if (this.autoSlideShow) {
                var pp_pos = '44px 0px';
            } else {
                var pp_pos = '0px 0px';
            }
            $('#' + this.controlBarIdentifier + '_ctrl4').css({
                backgroundPosition:pp_pos
            });
        },

        /**
         * Start autoplay
         */
        playControl: function(callStack) {
            if (this.isFrozen(callStack)) {
                return;
            }
            this.autoSlideShow = true;
            this.slideTimeout = setTimeout('window.' + this.canvasIdentifier + '.nextImage()',
                    this.slideShowSpeed);
            this.timeoutResources.push(this.slideTimeout);
        },

        /**
         * Stop autoplay
         */
        pauseControl: function(callStack) {
            if (this.isFrozen()) {
                return;
            }
            this.autoSlideShow = false;
            clearTimeout(this.slideTimeout);
        },

        /**
         * Fullscreen/Normal screen button control
         */
        screenControl: function() {
            if (this.fullScreenMode) {
                this.normalScreenControl();
            } else {
                this.fullScreenControl();
            }
            if (this.fullScreenMode) {
                var screen_pos = '21px 0px';
            } else {
                var screen_pos = '0px 0px';
            }
            $('#' + this.controlBarIdentifier + '_ctrl6').css({
                backgroundPosition:screen_pos
            });
        },

        /**
         * Show in full screen
         */
        fullScreenControl: function() {
            if (this.isBusy() || this.isFrozen()) {
                return;
            }
            this.setBusyFlagOn();
            clearTimeout(this.slideTimeout);
            this.showFullScreen();
        },

        /**
         * Show in normal screen
         */
        normalScreenControl: function() {
            if (this.isBusy() || this.isFrozen()) {
                return;
            }
            this.setBusyFlagOn();
            clearTimeout(this.slideTimeout);
            this.showNormalScreen();
        },

        /**
         * Check if browser is IE
         */
        isIE: function() {
            return '\v' == 'v';
        },

        /**
         * Set global vars to default value
         */
        setGlobals: function() {

            //*** RESOURCES ***\\

            //canvas offset
            this.canvasOffs = null;

            // images array
            this.images = [];

            // current image index
            this.currentImage = 0;

            // old image index
            this.oldImage = 0;

            // slide timeout resource
            this.slideTimeout = null;

            // control bar timer 
            this.autohidetimerID = null;

            //img max size for resize
            this.imgMaxWidth = 0;
            this.imgMaxHeight = 0;

            this.cbHeight = 75;
            this.cbWidth = 256;

            //control buttons margin left param
            this.cbML = 0;
            this.cbMT = 0;


            //*** FLAGS ***\\

            // slideshow busy flag
            this.flagBusy = false;

            // mouse-ul este in canvas sau nu
            this.inCanvas = false;

            //control bar status
            this.controlBarVisible = false;

            // if control bar focused - not hide 
            this.controlBarFocused = false;

            //description visible
            this.captionVisible = true;
            this.captionCounter = 1;

            //first load
            this.firstLoad = true;

            //next button or not
            this.nextSlide = false;

            //shadow canvas
            this.sbg1 = null;
            this.sbg2 = null;
        },

        calculateImageMaxSize: function() {
            this.imgMaxWidth = Math.floor(this.displayWidth * 0.9 - 2 * this.borderSize);
            this.imgMaxHeight = Math.floor((this.displayHeight - (this.cbHeight + 46)) * 0.9 - 2 * this.borderSize);
        },

        /**
         * loading controls
         */
        loadControls: function(callStack) {
            if (this.callStack != callStack) {
                return;
            }

            var instanceNO = this.instanceNO;

            this.calculateImageMaxSize();
            this.cbML = Math.floor((this.displayWidth - this.cbWidth) / 2);
            this.cbMT = this.displayHeight - this.cbHeight;

            // generate images array
            this.images = [];
            for (var i = 0, j = 0; i < this.xml.items.item.length; i++) {
                if (typeof this.xml.items.item[i].largeImagePath != 'undefined'
                        && this.xml.items.item[i].largeImagePath != '') {
                    this.images[j] = {};
                    this.images[j].largeImagePath = this.xml.items.item[i].largeImagePath;
                    if (typeof this.xml.items.item[i].fullScreenImagePath != 'undefined' &&
                            this.xml.items.item[i].fullScreenImagePath.length > 0) {
                        this.images[j].fullScreenImagePath = this.xml.items.item[i].fullScreenImagePath;
                    } else {
                        this.images[j].fullScreenImagePath = this.xml.items.item[i].largeImagePath;
                    }
                    if (typeof this.xml.items.item[i].description != 'undefined') {
                        this.images[j].description = this.xml.items.item[i].description.replace(/\r\n/g, '<br />').replace(/\n/g, '<br />').replace(/\r/g, '<br />');
                    } else {
                        this.images[j].description = '';
                    }
                    this.images[j].loaded = 0;
                    j++;
                }
            }

            if (this.images.length == 0) {
                return false;
            }

            var localScope = this;

            this.sbg1 = $('<div />').attr('id', this.shadowBgCanvas + '1')
                    .css({
                             position: 'absolute',
                             height: this.displayHeight,
                             minHeight: this.displayHeight,
                             width: this.displayWidth,
                             minWidth: this.displayWidth,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.canvasIdentifier);
            this.sbg2 = $('<div />').attr('id', this.shadowBgCanvas + '2')
                    .css({
                             position: 'absolute',
                             height: this.displayHeight,
                             minHeight: this.displayHeight,
                             width: this.displayWidth,
                             minWidth: this.displayWidth,
                             marginLeft:this.displayWidth,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.imgContainer + '1')
                    .css({
                             position: 'absolute',
                             marginLeft:this.displayWidth,
                             border: this.borderSize + 'px solid ' + this.borderColor,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '1');

            $('<div />').attr('id', this.imgContainer + '2')
                    .css({
                             position: 'absolute',
                             marginLeft:this.displayWidth,
                             border: this.borderSize + 'px solid ' + this.borderColor,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '2');

            if (localScope.shadowDistance != 0) {
                $('<div />').attr('id', this.imgContainer + '1')
                        .css({
                                 '-moz-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 '-webkit-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 'box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)'
                             });
                $('<div />').attr('id', this.imgContainer + '2')
                        .css({
                                 '-moz-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 '-webkit-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 'box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)'
                             });
            }

            //caption
            $('<div />').attr('id', this.infoBarIdentifier + '1').hide()
                    .css({
                             zIndex:12,
                             position:'absolute'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '1');
            $('<div />').attr('id', this.infoBarIdentifier + '1_bg')
                    .css({
                             position:'absolute',
                             zIndex:12,
                             backgroundColor:'#000000',
                             opacity:0.5
                         })
                    .appendTo('#' + this.infoBarIdentifier + '1');
            $('<div />').attr('id', this.infoBarIdentifier + '1_iDescription')
                    .css({
                             position:'absolute',
                             zIndex:13,
                             color:'#ffffff',
                             fontSize: '18px',
                             fontFamily:'Lucida Sans Unicode',
                             marginTop:'0px',
                             marginLeft:'5px',
                             paddingTop:'3px',
                             lineHeight: '27px',
                             textAlign:'center',
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.infoBarIdentifier + '1');

            //caption 2
            $('<div />').attr('id', this.infoBarIdentifier + '2').hide()
                    .css({
                             zIndex:12,
                             position:'absolute'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '2');
            $('<div />').attr('id', this.infoBarIdentifier + '2_bg')
                    .css({
                             position:'absolute',
                             zIndex:12,
                             backgroundColor:'#000000',
                             opacity:0.5
                         })
                    .appendTo('#' + this.infoBarIdentifier + '2');
            $('<div />').attr('id', this.infoBarIdentifier + '2_iDescription')
                    .css({
                             position:'absolute',
                             zIndex:13,
                             color:'#ffffff',
                             fontSize: '18px',
                             fontFamily:'Lucida Sans Unicode',
                             marginTop:'0px',
                             marginLeft:'5px',
                             paddingTop:'3px',
                             lineHeight: '27px',
                             textAlign:'center',
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.infoBarIdentifier + '2');

            // gesture for touchscreen
            $('#' + localScope.canvasIdentifier).touchwipe({
                wipeLeft: function() {
                    localScope.nextControl();
                },
                wipeRight: function() {
                    localScope.prevControl();
                }
            });

            //control bar
            $('<div />').attr('id', this.controlBarIdentifier).hide()
                    .css({
                             position: 'absolute',
                             height: this.cbHeight,
                             width: this.cbWidth,
                             marginTop:this.cbMT,
                             marginLeft:this.cbML,
                             zIndex:12,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.controlBarIdentifier + '_bg')
                    .css({
                             position:'absolute',
                             height:this.cbHeight,
                             width: this.cbWidth,
                             background:'url("' + this.iconsURL + 'cb.png")',
                             zIndex:13
                         })
                    .hover(function() {
                localScope.controlBarFocused = true;
            }, function() {
                localScope.controlBarFocused = false;
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //control bar up/down button
            var updownML = this.cbML + Math.floor((this.cbWidth - 46) / 2);

            if (this.controlBarState == 'opened') {
                this.controlBarVisible = true;
            } else if (this.controlBarState == 'closed') {
                this.controlBarVisible = false;
            }

            if (this.controlBarVisible) {
                var updownMT = this.cbMT;
                var bg_position = '46px 0px';
            } else {
                var updownMT = this.displayHeight - 12;
                var bg_position = '0px 0px';
            }

            $('<div />').attr('id', this.controlBarIdentifier + '_updown_bt')
                    .appendTo('#' + this.canvasIdentifier)
                    .css({
                             position: 'absolute',
                             cursor: 'pointer',
                             width:'46px',
                             height:'12px',
                             marginLeft:updownML,
                             marginTop:updownMT,
                             background:'url("' + this.iconsURL + 'cb_control.png")',
                             backgroundPosition: bg_position,
                             zIndex:20
                         })
                    .bind('click', function() {
                localScope.cbControl()
            })
                    .hover(function() {
                localScope.controlBarFocused = true;
                $(this).css({
                    opacity:0.8
                });
            }, function() {
                localScope.controlBarFocused = false;
                $(this).css({
                    opacity:1
                });
            });

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'15px',
                             marginLeft:'15px',
                             height:31,
                             minHeight:31,
                             zIndex:20
                         })
                    .bind('click', function() {
                localScope.exitControl()
            })
                    .mouseover(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -31px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px 0px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px 0px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = false;
            })
                    .mousedown(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -62px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -62px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -62px'
                });
            })
                    .mouseup(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -31px'
                });
            })
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1_left')
                    .css({
                             position:'absolute',
                             height:'31px',
                             width:'15px',
                             cursor:'pointer',
                             background:'url("' + this.iconsURL + 'exit_left.png")',
                             backgroundPosition:'0px 0px',
                             zIndex: 21
                         })
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            $('<span />').attr('id', this.controlBarIdentifier + '_ctrl1_text')
                    .css({
                             position:'absolute',
                             height:'24px',
                             paddingTop: '7px',
                             paddingRight:'1px',
                             marginLeft:'14px',
                             cursor:'pointer',
                             fontSize:14,
                             fontFamily:'Arial',
                             //lineHeight:'29px',
                             fontWeight:'bold',
                             color:'#333333',
                             background:'url("' + this.iconsURL + 'exit_mid.png")',
                             backgroundPosition:'0px 0px',
                             whiteSpace:'nowrap',
                             zIndex: 21
                         })
                    .html(localScope.backButtonLabel)
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1_right')
                    .css({
                             position:'absolute',
                             height:'31px',
                             width:'8px',
                             cursor:'pointer',
                             background:'url("' + this.iconsURL + 'exit_right.png")',
                             backgroundPosition:'0px 0px',
                             zIndex: 21
                         })
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            //left + mid + right .... mid+right = 23
            var exit_width = parseInt($('#' + localScope.controlBarIdentifier + '_ctrl1_text')[0].offsetWidth) + 23;

            $('#' + this.controlBarIdentifier + '_ctrl1').css({
                width: exit_width,
                minWidth: exit_width
            });
            $('#' + this.controlBarIdentifier + '_ctrl1_right').css({
                marginLeft:exit_width - 10
            });

            //caption button
            if (this.captionVisible) {
                var capt_pos = '0px -44px';
            } else {
                var capt_pos = '0px 0px';
            }

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl2')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'32px',
                             marginLeft:'16px',
                             width:25,
                             minWidth:25,
                             height:22,
                             minHeight:22,
                             background:'url("' + this.iconsURL + 'caption.png")',
                             backgroundPosition:capt_pos,
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.captionControl(callStack);
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -22px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                if (localScope.captionVisible) {
                    var capt_pos = '0px -44px';
                } else {
                    var capt_pos = '0px 0px';
                }
                $(this).css({
                    backgroundPosition:capt_pos
                });
                localScope.controlBarFocused = false;
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //prev and next button
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl3')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'35px',
                             marginLeft:'66px',
                             width:17,
                             minWidth:17,
                             height:16,
                             minHeight:16,
                             background:'url("' + this.iconsURL + 'prev.png")',
                             backgroundPosition:'0px 0px',
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.prevControl(callStack);
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -32px'
                });
            })
                    .mouseup(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl5')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'35px',
                             marginLeft:'173px',
                             width:17,
                             minWidth:17,
                             height:16,
                             minHeight:16,
                             background:'url("' + this.iconsURL + 'next.png")',
                             backgroundPosition:'0px 0px',
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.nextControl();
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -32px'
                });
            })
                    .mouseup(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //play and pause button
            if (this.autoSlideShow) {
                var pp_pos = '44px 0px';
            } else {
                var pp_pos = '0px 0px';
            }
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl4')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'21px',
                             marginLeft:'106px',
                             width:44,
                             minWidth:44,
                             height:44,
                             minHeight:44,
                             background:'url("' + this.iconsURL + 'pp.png")',
                             backgroundPosition:pp_pos,
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.ppControl(callStack);
            })
                    .mouseover(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px -44px';
                } else {
                    var pp_pos = '0px -44px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px 0px';
                } else {
                    var pp_pos = '0px 0px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px -88px';
                } else {
                    var pp_pos = '0px -88px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //full/normal screen
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl6')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'33px',
                             marginLeft:'218px',
                             width:20,
                             minWidth:20,
                             height:20,
                             minHeight:20,
                             background:'url("' + this.iconsURL + 'close.png")',
                             backgroundPosition:'0px 0px',
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.exitControl()
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -20px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -40px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            this.showControlBar(instanceNO, callStack);

            this.canvasOffs = $('#' + this.canvasIdentifier).offset();

            $(document).keydown(function(e) {
                if (localScope.isFrozen() ||
                        instanceNO != localScope.instanceNO ||
                        callStack != localScope.callStack) {
                    return;
                }
                var KeyID = (window.event) ? event.keyCode : e.keyCode;
                switch (KeyID) {
                    case 32:
                        localScope.ppControl(callStack);
                        break;
                    case 37:
                        localScope.prevControl();
                        break;
                    case 39:
                        localScope.nextControl();
                        break;
                }
            });

            $(document).mousemove(function(e) {
                if (localScope.isFrozen() ||
                        instanceNO != localScope.instanceNO ||
                        callStack != localScope.callStack) {
                    return;
                }
                if (localScope.autoHideControls) {
                    if (( e.pageX < localScope.canvasOffs.left ) || ( e.pageY < localScope.canvasOffs.top ) || ( e.pageX > localScope.canvasOffs.left + localScope.canvasWidth ) || ( e.pageY > localScope.canvasOffs.top + localScope.canvasHeight )) {
                        if (localScope.inCanvas) {
                            localScope.autoHideControlBar();
                            localScope.inCanvas = false;
                        }
                    } else {
                        localScope.inCanvas = true;
                        clearTimeout(localScope.autohidetimerID);
                        if (!localScope.controlBarFocused) {
                            localScope.autohidetimerID = setTimeout('window.' + localScope.canvasIdentifier + '.autoHideControlBar()', localScope.controlsHideSpeed);
                        }
                    }
                }
            });

            $(window).resize(function() {
                if (localScope.fullScreenMode == true) {
                    window.clearTimeout(localScope.resizeTimeout);
                    localScope.resizeTimeout = window.setTimeout(
                            'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
                }
            });
            return true;
        },

        /**
         * Auto hide control bar
         */
        autoHideControlBar : function () {
            this.controlBarVisible = false;
            $('#' + this.controlBarIdentifier).stop(true, false);
            $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, false);
            this.rollDownCB();
        },

        /**
         * Start slideshow command
         */
        startSlideShow: function(callStack) {
            if (this.callStack != callStack) {
                return;
            }
            if (typeof this.currentImage != 'number') {
                this.currentImage = 0;
            }
            this.setFrozenFlagOff();
            this.setBusyFlagOff();
            this.showCurrentImage(this.instanceNo, callStack);
        },

        /**
         * Image preloader
         */
        preLoadImage: function(id, callback, fullscreenmode) {
            if (this.isFrozen()) {
                return;
            }
            if (this.fullScreenMode == true) {
                if (this.images[id].error1 == 1) {
                    this.images[id].src = this.images[id]['largeImagePath'];
                } else {
                    this.images[id].src = this.images[id]['fullScreenImagePath'];
                }
            } else {
                this.images[id].src = this.images[id]['largeImagePath'];
            }
            this.images[id].cacheImage = document.createElement('img');

            var localScope = this;

            $(this.images[id].cacheImage).load(
                    function () {
                        $(this).unbind('load');
                        localScope.images[this.lang]['loaded'] = 1;
                        if (typeof callback != 'undefined' && !localScope.isFrozen()) {
                            eval(callback);
                        }
                    }).error(function () {
                if (localScope.images[id].src != localScope.images[id].largeImagePath) {
                    localScope.images[id].error1 = 1;
                    localScope.preLoadImage(id, callback, fullscreenmode);
                    return;
                }
                $(this).unbind('error');
                localScope.images[this.lang].error = 1;
                if (typeof callback != 'undefined' && !localScope.isFrozen()) {
                    eval(callback);
                }
            });
            this.images[id].cacheImage.lang = id;
            this.images[id].cacheImage.src = this.images[id].src;
        },

        resizeCurrentImage: function() {
            if (this.loadOriginalImages) {
                return;
            }
            if (this.images[this.currentImage].error == 1) return;

            if (this.isIE()) {
                var cH = $(this.images[this.currentImage].cacheImage).height();
                var cW = $(this.images[this.currentImage].cacheImage).width();
            } else {
                var cH = $(this.images[this.currentImage].cacheImage).attr('height');
                var cW = $(this.images[this.currentImage].cacheImage).attr('width');
            }
            if (cH <= this.imgMaxHeight && cW <= this.imgMaxWidth) return;
            var canvasProp = this.imgMaxWidth / this.imgMaxHeight;
            var imageProp = cW / cH;

            var perc = 0;

            switch (this.scaleMode) {
                case 'scale':
                    if (canvasProp > imageProp) {
                        if (cH < this.imgMaxHeight) {
                            ref = cH;
                        } else {
                            ref = this.imgMaxHeight;
                        }
                        $(this.images[this.currentImage].cacheImage)
                                .height(ref)
                                .width(Math.ceil(cW * ref / cH));
                    } else {
                        if (cW < this.imgMaxWidth) {
                            ref = cW;
                        } else {
                            ref = this.imgMaxWidth;
                        }
                        $(this.images[this.currentImage].cacheImage)
                                .width(ref)
                                .height(Math.ceil(cH * ref / cW));
                    }
                    break;
                case 'scaleCrop':
                default:
                    if (canvasProp > imageProp) {
                        if (cW < this.imgMaxWidth) {
                            ref = cW;
                        } else {
                            ref = this.imgMaxWidth;
                        }
                        $(this.images[this.currentImage].cacheImage)
                                .width(ref)
                                .height(Math.ceil(cH * ref / cW));
                    } else {
                        if (cH < this.imgMaxHeight) {
                            ref = cH;
                        } else {
                            ref = this.imgMaxHeight;
                        }
                        $(this.images[this.currentImage].cacheImage)
                                .height(ref)
                                .width(Math.ceil(cW * ref / cH));
                    }
                    break;
            }
        },

        /**
         * show current image
         */
        showCurrentImage: function(instanceNO, callStack) {
            if (this.isFrozen()) {
                return;
            }
            if (typeof instanceNO == 'undefined') {
                var instanceNO = this.instanceNO;
            } else if (instanceNO != this.instanceNO) {
                return;
            }
            if (typeof callStack == 'undefined') {
                var callStack = this.callStack;
            } else if (callStack != this.callStack) {
                return;
            }

            clearTimeout(this.slideTimeout);

            if (this.images[this.currentImage].loaded != 1 && this.images[this.currentImage].error != 1) {
                this.showPreloader();
                this.preLoadImage(this.currentImage, 'window.' + this.canvasIdentifier + '.showCurrentImage(' + instanceNO + ', ' + callStack + ')');
                return;
            }
            this.hidePreloader();
            if (this.firstLoad) {
                this.preloadA();
                this.preloadB();
            } else {
                if (this.preload == 'after') {
                    this.preloadA();
                }
                if (this.preload == 'before') {
                    this.preloadB();
                }
            }

            if (this.oldImage != this.currentImage) {
                if (this.captionCounter == 1) {
                    var prev_caption_nr = 2;
                } else {
                    var prev_caption_nr = 1;
                }
            } else {
                var prev_caption_nr = this.captionCounter;
            }

            if (this.oldImage != this.currentImage) {
                $(this.images[this.oldImage].cacheImage).attr('id', this.oldImageIdentifier)
                        .appendTo('#' + this.imgContainer + this.captionCounter)
                        .css({
                                 position:'absolute',
                                 zIndex:10
                             });
                var oic_h = $('#' + this.oldImageIdentifier).height();
                var oic_mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - (oic_h + 2 * this.borderSize)) / 2) + 46;
                var oic_w = $('#' + this.oldImageIdentifier).width();
                var oic_ml = Math.floor((this.displayWidth - (oic_w + 2 * this.borderSize)) / 2);
                $('#' + this.imgContainer + this.captionCounter)
                        .css({
                                 width:oic_w,
                                 height:oic_h,
                                 marginTop:oic_mt,
                                 marginLeft:oic_ml
                             });
                var oi_mt = Math.floor((oic_h - $('#' + this.oldImageIdentifier).height()) / 2);
                var oi_ml = Math.floor((oic_w - $('#' + this.oldImageIdentifier).width()) / 2);
                $('#' + this.oldImageIdentifier)
                        .css({
                                 marginTop:oi_mt,
                                 marginLeft:oi_ml
                             });
            }

            $('#' + this.shadowBgCanvas + prev_caption_nr).css({
                marginLeft:0
            });
            var localScope = this;
            $(this.images[this.currentImage].cacheImage).hide()
                    .appendTo('#' + this.imgContainer + prev_caption_nr)
                    .attr('id', this.imageIdentifier)
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             zIndex:10
                         })
                    .bind('click', function() {
                localScope.nextControl()
            });

            this.resizeCurrentImage();

            var ic_h = $('#' + this.imageIdentifier).height();
            var ic_mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - (ic_h + 2 * this.borderSize)) / 2) + 46;
            var ic_w = $('#' + this.imageIdentifier).width();
            var ic_ml = Math.floor((this.displayWidth - (ic_w + 2 * this.borderSize)) / 2);
            $('#' + this.imgContainer + prev_caption_nr)
                    .css({
                             width:ic_w,
                             height:ic_h,
                             marginTop:ic_mt,
                             marginLeft:ic_ml
                         });

            var i_mt = Math.floor((ic_h - $('#' + this.imageIdentifier).height()) / 2);
            var i_ml = Math.floor((ic_w - $('#' + this.imageIdentifier).width()) / 2);
            $('#' + this.imageIdentifier)
                    .css({
                             marginTop:i_mt + 'px',
                             marginLeft:i_ml + 'px'
                         });
            this.imageTransition();
        },

        /**
         * Hide caption
         */
        hideCaption : function() {
            //hide caption
            $('#' + this.infoBarIdentifier + this.captionCounter).fadeOut('normal');
        },

        /**
         * Show caption
         */
        showCaption : function (t_speed) {
            this.actualizeCaption();
            $('#' + this.infoBarIdentifier + this.captionCounter).fadeIn(t_speed);
        },

        /**
         * Actualize caption
         */
        actualizeCaption: function() {
            var ciH = parseInt($('#' + this.imgContainer + this.captionCounter).css('height'));
            var ciW = parseInt($('#' + this.imgContainer + this.captionCounter).css('width'));
            var mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - ciH) / 2) + 46;
            var ml = Math.floor((this.displayWidth - ciW) / 2);
            $('#' + this.infoBarIdentifier + this.captionCounter + '_iDescription')
                    .css({width:((ciW) - 10)})
                    .html(this.images[this.currentImage].description);

            $('#' + this.infoBarIdentifier + this.captionCounter).show();
            var descH = $('#' + this.infoBarIdentifier + this.captionCounter + '_iDescription').height();
            $('#' + this.infoBarIdentifier + this.captionCounter).hide();
            if (descH > 0) {
                descH += 8;
            }

            if (descH >= (this.imgMaxHeight - 23))
                return;

            $('#' + this.infoBarIdentifier + this.captionCounter + '_bg')
                    .css({
                             width: ciW + 'px',
                             height: descH + 'px'
                         });

            $('#' + this.infoBarIdentifier + this.captionCounter)
                    .css({
                             width: ciW + 'px',
                             height:descH + 'px',
                             marginTop: (ciH - descH) + mt,
                             marginLeft: ml
                         });
        },

        /**
         * Image transition
         */
        imageTransition: function() {
            var localScope = this;
            if (this.transitionType == 'fade') {
                if (this.firstLoad) {
                    $('#' + this.imageIdentifier)
                            .show();
                    this.actualizeCaption();
                    if (this.captionVisible) {
                        $('#' + this.infoBarIdentifier + this.captionCounter).show();
                    }
                    this.firstLoad = false;
                    this.onTransitionComplete();
                } else {
                    if (this.oldImage != this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)) {
                        $('#' + this.shadowBgCanvas + this.captionCounter).fadeOut(this.transitionSpeed, function() {
                            $(this).css({marginLeft:localScope.displayWidth}).show();
                            $('#' + localScope.oldImageIdentifier).unbind().hide();
                            $('#' + localScope.oldImageIdentifier).remove();
                        });
                    }
                    $('#' + this.imageIdentifier)
                            .css({
                                     opacity:1
                                 })
                            .hide().show();
                    this.actualizeCounter();
                    this.actualizeCaption();
                    if (this.captionVisible) {
                        this.showCaption(this.transitionSpeed);
                    }
                    $('#' + this.shadowBgCanvas + this.captionCounter)
                            .css({marginLeft:0});

                    $('#' + this.imgContainer + this.captionCounter).css({opacity:0}).animate({opacity:1}, localScope.transitionSpeed, function() {
                        localScope.onTransitionComplete();
                    });
                    $('#' + this.shadowBgCanvas + this.captionCounter + ' canvas').css({opacity:0}).animate({opacity:1}, this.transitionSpeed);
                }
            } else {
                if (this.transitionType == 'slide') {
                    if (this.firstLoad) {
                        $('#' + this.imageIdentifier)
                                .show();
                        this.actualizeCaption();
                        if (this.captionVisible) {
                            $('#' + this.infoBarIdentifier + this.captionCounter).show();
                        }
                        this.firstLoad = false;
                        this.onTransitionComplete();

                    } else {
                        if (this.oldImage != this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)) {
                            var sbg_ml = 0;
                            if (this.nextSlide) {
                                sbg_ml -= this.displayWidth;
                            } else {
                                sbg_ml += this.displayWidth;
                            }

                            $('#' + this.shadowBgCanvas + this.captionCounter).animate({
                                marginLeft:sbg_ml
                            }, localScope.transitionSpeed, function() {
                                $('#' + localScope.oldImageIdentifier).unbind().hide();
                                $('#' + localScope.oldImageIdentifier).remove();
                            });
                        }

                        $('#' + this.imageIdentifier).show();

                        this.actualizeCounter();
                        this.actualizeCaption();
                        if (this.captionVisible) {
                            $('#' + this.infoBarIdentifier + this.captionCounter).show();
                        }

                        if (this.nextSlide) {
                            var sbg_ml = this.displayWidth;
                        } else {
                            var sbg_ml = -1 * this.displayWidth;
                        }
                        $('#' + this.shadowBgCanvas + this.captionCounter)
                                .css({marginLeft:sbg_ml})
                                .animate({marginLeft:0}, this.transitionSpeed, function() {
                            localScope.onTransitionComplete();
                        });
                    }
                }
            }
        },

        /**
         * Transition complete callback
         */
        onTransitionComplete: function() {
            this.setBusyFlagOff();

            if (this.autoSlideShow == true) {
                this.slideTimeout = setTimeout('window.' + this.canvasIdentifier + '.nextImage()',
                        this.slideShowSpeed);
                this.timeoutResources.push(this.slideTimeout);
            }
        },

        /**
         * Actualize counter
         */
        actualizeCounter: function() {
            if (this.captionCounter == 2) {
                this.captionCounter = 1;
            } else {
                this.captionCounter = 2;
            }
        },

        /**
         * Show control bar
         */
        showControlBar: function(instanceNO, callStack) {
            if (this.isFrozen()) {
                return;
            }
            if (instanceNO != this.instanceNO || callStack != this.callStack) {
                return;
            }

            if (!this.controlBarVisible) {
                $('#' + this.controlBarIdentifier)
                        .css({marginTop:this.displayHeight - 12});
                $('#' + this.controlBarIdentifier + '_ctrl1').hide();
            }

            $('#' + this.controlBarIdentifier).show();
        },

        /**
         * check if busy flag is on
         */
        isBusy: function() {
            return this.flagBusy == true;
        },

        /**
         * Set busy flag off
         */
        setBusyFlagOff: function() {
            this.flagBusy = false;
        },

        /**
         * Set busy flag on
         */
        setBusyFlagOn: function() {
            this.flagBusy = true;
        },

        /**
         * Roll down control bar
         */
        rollDownCB: function() {
            $('#' + this.controlBarIdentifier)
                    .animate({marginTop:this.displayHeight - 12}, 300);
            $('#' + this.controlBarIdentifier + '_updown_bt')
                    .css({
                             backgroundPosition:'0px 0px'
                         })
                    .animate({marginTop:this.displayHeight - 12}, 300);
            $('#' + this.controlBarIdentifier + '_ctrl1').fadeOut('300');
        },

        /**
         * Roll up control bar
         */
        rollUpCB: function() {
            $('#' + this.controlBarIdentifier)
                    .animate({marginTop:this.cbMT}, 300);
            $('#' + this.controlBarIdentifier + '_updown_bt')
                    .css({
                             backgroundPosition:'46px 0px'
                         })
                    .animate({marginTop:this.cbMT}, 300);
            $('#' + this.controlBarIdentifier + '_ctrl1').fadeIn('300');
        },

        preloadA: function() {
            for (var i = 1; i <= this.preloadAfter; i++) {
                if (this.currentImage + i <= this.images.length - 1) {
                    var c_id = this.currentImage + i;
                } else {
                    var c_id = (this.currentImage + i) - this.images.length;
                }
                if (this.images[c_id].loaded != 1 && this.images[c_id].error != 1) {
                    this.preLoadImage(c_id);
                }
            }
        },

        preloadB: function() {
            for (var i = 1; i <= this.preloadBefore; i++) {
                if (this.currentImage - i >= 0) {
                    var c_id = this.currentImage - i;
                } else {
                    var c_id = this.images.length + (this.currentImage - i)
                }
                if (this.images[c_id].loaded != 1 && this.images[c_id].error != 1) {
                    this.preLoadImage(c_id);
                }
            }
        },

        /**
         * Show next image
         */
        nextImage: function() {
            if (this.isBusy() || this.isFrozen()) {
                return;
            }
            this.setBusyFlagOn();
            this.oldImage = this.currentImage;
            if (this.currentImage < this.images.length - 1) {
                this.currentImage++;
            } else {
                this.currentImage = 0;
            }
            this.nextSlide = true;
            this.preload = 'after';
            this.showCurrentImage();
        },

        /**
         * Show previous image
         */
        prevImage: function() {
            if (this.isBusy() || this.isFrozen()) {
                return;
            }
            this.setBusyFlagOn();
            this.oldImage = this.currentImage;
            if (this.currentImage > 0) {
                this.currentImage--;
            } else {
                this.currentImage = this.images.length - 1;
            }
            this.nextSlide = false;
            this.preload = 'before';
            this.showCurrentImage();
        }
    };

})(jQuery);
