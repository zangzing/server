(function( $ ){
  $.fn.rowLeft = function() {
      var top = this.position().top;
      var sibling = this.prev();
      var list = [];
      while(sibling.length > 0 && sibling.position().top === top){
          list.push(sibling[0]);
          sibling = sibling.prev();
      }
      return $(list);
  };

  $.fn.rowRight = function() {
      var top = this.position().top;
      var sibling = this.next();
      var list = [];

      while(sibling.length > 0 && sibling.position().top === top){
          list.push(sibling[0]);
          sibling = sibling.next();
      }
      return $(list);
  };

  $.fn.animateRelative = function(x, y, duration, easing){
      $.each(this, function(index, element){
          var el = $(element);


          el.animate({
              left: parseInt(el.css('left')) + x,
              top:  parseInt(el.css('top')) + y

          }, duration, easing);
      });
  };
})( jQuery );