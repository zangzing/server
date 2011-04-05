///*!
// * imageloader.js
// *
// * Copyright 2011, ZangZing LLC. All rights reserved.
// */
//
//
//var image_preloader = {
//
//    images : [],
//
//
//    load_image : function(src){
//        //logger.debug('loading image: ' + src);
//
//        var image = new Image();
//        image.src = src;
//        image_preloader.images.push(image);
//    }
//
//};
//
//
////function ImageLoader(onStartLoadingImage, onImageLoadedHandler){
////    this.queue = [];
////    this.stopped = false;
////    this.onStartLoadingImage = onStartLoadingImage;
////    this.onImageLoadedHandler = onImageLoadedHandler;
////}
////
////
////ImageLoader.prototype = {
////
////    add : function(id, src){
////        var props = {};
////        props['id'] = id;
////        props['src'] = src;
////        this.queue[this.queue.length] = props;
////    },
////
////
////    start : function(batchsize){
////        this.index = -1;
////
////        if(!batchsize)
////        {
////            this.next();
////        }
////        else
////        {
////            for(var i=0;i<batchsize;i++)
////            {
////                this.next();
////            }
////        }
////    },
////
////
////    stop : function(){
////        this.stopped = true;
////    },
////
////
////    next : function(){
////        this.index += 1
////
////        if(this.stopped){
////            return;
////        }
////
////
////        if(this.index > this.queue.length-1){
////            return;
////        }
////
////        var props = this.queue[this.index];
////        var img = new Image();
////        props['img'] = img;
////
////
////        this.onStartLoadingImage(props['id'], props['src'])
////
////
////        var me = this;
////        img.onload = function(){
////            me.handleImageLoaded(props['id'], props['src'], img.width, img.height)
////            me.next();
////        }
////
////        img.onerror = function(){
////            //todo: call error callback
////            me.next();
////        }
////
////        img.src = props['src']
////    },
////
////    handleImageLoaded : function(id, src, width, height){
////        this.onImageLoadedHandler(id, src, width, height);
////    }
////};
////
////
////
////
