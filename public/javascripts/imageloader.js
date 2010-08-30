

function ImageLoader(onStartLoadingImage, onImageLoadedHandler){
    this.queue = [];
    this.stopped = false;
    this.onStartLoadingImage = onStartLoadingImage;
    this.onImageLoadedHandler = onImageLoadedHandler;
};


ImageLoader.prototype = {

    add : function(id, src){
        var props = {};
        props['id'] = id;
        props['src'] = src;
        this.queue[this.queue.length] = props;
    },


    start : function(batchsize){
        this.index = -1;

        if(!batchsize)
        {
            this.next();
        }
        else
        {
            for(var i=0;i<batchsize;i++)
            {
                this.next();
            }
        }
    },


    stop : function(){
        this.stopped = true;
    },


    next : function(){
        this.index += 1

        if(this.stopped){
            return;
        }


        if(this.index > this.queue.length-1){
            return;
        }

        var props = this.queue[this.index];
        var img = new Image();
        props['img'] = img;


//        this.onStartLoadingImage(props['id'], props['src'])


        var me = this;
        img.onload = function(){
            me.handleImageLoaded(props['id'], props['src'], img.width, img.height)
            me.next();
            
        var new_size = 110;
      
        if (img.height > img.width) {
          //tall
          var ratio = img.width / img.height; 
          $('#'+props['id']).css({height: new_size+'px', width: (ratio * new_size) + 'px' });

          var guuu = $('#'+props['id']).attr('id').split('-')[3];
          $('li#photo-'+ guuu +' figure').css({bottom: '0px', width: ((ratio * new_size) + 10)+'px', marginLeft: (((new_size - (ratio * new_size)) / 2 ) + 2)+ 'px'});
          
          
        } else {
          //wide

          var ratio = img.height / img.width; 
          $('#'+props['id']).css({height: (ratio * new_size) + 'px', width: new_size+'px', marginTop: ((new_size - (ratio * new_size)) / 2) + 'px' });

          var guuu = $('#'+props['id']).attr('id').split('-')[3];
          $('li#photo-'+ guuu +' figure').css({bottom: ((new_size - (ratio * new_size)) / 2) - 1+'px'});
        }
          
            
        };

        img.src = props['src']
    },

    handleImageLoaded : function(id, src, width, height){
        this.onImageLoadedHandler(id, src, width, height);
    }
}




