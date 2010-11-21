function ThumbTray(element_id, orientation){

    this.element_id = element_id;
    this.orientation = orientation;
    this.photos = [];

    



}

ThumbTray.prototype = {

    add : function(src){
        this.photos.push(src);
    },

    repaint : function(){
        var html='';
        for(var i in this.photos){
            html += '<img src=""'
        }


        $(this.element_id).
    }
}
