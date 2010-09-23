var temp;var temp_width;var temp_height;var temp_top;var temp_left; 
var temp_id;var temp_url;var content_url;var serialized;var temp_top_new;
var temp_left_new;var value;

/* Welcome to ZangZing
----------------------------------------------------------------------------- */

var zang = {
  
  /* Tracking Function - Allows us to track *everything* easily 
  --------------------------------------------------------------------------- */

  tracker: function(tracked){
    //TODO: Connect to zang's stats provider
    //console.log('Tracked: ' + tracked);
  },// end zang.tracker
  
  /* Better AJAX - extends jQuery.ajax() w/retries & error/success functions
  --------------------------------------------------------------------------- */
  new_ajax: function(obj) {
  
    $.ajax({
      data: (!obj.params) ? '' : obj.params,
      dataType: (!obj.data_type) ? 'json' : obj.data_type,
      error: function(data, textStatus) {
        
        if (!obj.attempt) {
          obj.attempt = 0;
        }
        
        if (!obj.maxtries) {
          obj.maxtries = 3;
        }          
        
        if (obj.attempt == obj.maxtries) {
          if(typeof obj.onerror == 'function'){
            obj.onerror(obj);
          }
          return;
        } else {
          obj.attempt++;
          setTimeout(function(){
            bl.new_ajax(obj);
            }, (obj.wait * obj.attempt));
          return;
        }
      },
      success: function(data, textStatus) {

        if(typeof obj.onsuccess == 'function'){
          obj.onsuccess(data);
        }
      },
      type: obj.action,
      url: obj.url
    });
  
  }, // end zang.new_ajax
  
  /* Better Load - extends jQuery(obj).load(); w/retries & error/success fns 
  --------------------------------------------------------------------------- */
  new_load: function(obj){
  
    $(obj.element).load(obj.url, function(responseText, textStatus, XMLHttpRequest){
      if (textStatus == 'error') {
        if (obj.attempt == obj.maxtries) {
          if(typeof obj.onerror == 'function'){
            obj.onerror(obj);
          }
          return;
        } else {
          obj.attempt++;
          setTimeout(function(){
            bl.new_load(obj);
          }, (obj.wait * obj.attempt));
          return;
        }
      } else {
        if(typeof obj.onsuccess == 'function'){
          obj.onsuccess();
        }
      }
    });
  
  }, // end zang.new_load
  
  zing: {
  
    view: 'undefined',

    /* Select Photo
    ------------------------------------------------------------------------- */  
    
    selected_photo: 'undefined',
    
    highlight_selected: function(id){
    
      if (zang.zing.selected_photo != 'undefined') {
        // the old photo is no longer selected
        $('li#'+zang.zing.selected_photo).removeClass('selected');
      } else {
        // console.log('selected_photo: undefined');      
      }
      
      temp_width = $('#'+ id +' img').width() - 10;
      temp_height = $('#'+ id +' img').height();
      temp_top = $('#'+ id +' img').position()['top'] + temp_height - 20;
      temp_left = $('#'+ id +' img').position()['left'] + 5;      
  
      $('#'+ id +' figure').css({position: 'absolute', top: temp_top + 'px', left: temp_left + 'px', width: temp_width});
      
      $('#'+id).addClass('selected'); // select the new photo
      zang.zing.selected_photo = id; // update our constant
      zang.tracker('select-photo/'+id); // track the action
  
    }, // end zang.zing.highlight_selected()
    
    /* Drawer Animations
    ------------------------------------------------------------------------- */       
    
    drawer_open: 0,
    screen_gap: 150,
        
    open_drawer: function(time, percent){
  
      zang.zing.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zang.zing.drawer_height = zang.zing.screen_height - zang.zing.screen_gap; 
  
      if (typeof percent == 'number') {
        temp = percent;
      } else {
        temp = 0;
      }
      
      // fade out the grid
      $('article').animate({ opacity: temp }, time/2 ).html('');
      
      // pull out the drawer
      $('div#drawer').animate({ height: zang.zing.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zang.zing.drawer_height - 14) + 'px'}, time );
      
      zang.zing.drawer_open = 1; // remember position of the drawer in 
  
    }, // end zang.zing.open_drawer()
    
    resize_drawer: function(time){
      
      zang.zing.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zang.zing.drawer_height = zang.zing.screen_height - zang.zing.screen_gap; 
      
      $('div#drawer').animate({ height: zang.zing.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zang.zing.drawer_height - 14) + 'px'}, time );
      $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 131) + 'px'});
  
    }, // end zang.zing.resize_drawer()
    
    close_drawer: function(time){
      
      // close the drawer
      $('div#drawer').animate({ height: '20px'}, time );
      $('div#drawer-content').animate({ height: 0}, time );
      
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zang.zing.drawer_open = 2; // remember position of the drawer in 
  
    }, // end zang.zing.close_drawer()
    
    slam_drawer: function(time){
  
      $('#indicator').fadeOut('fast');
      
      // close the drawer
      $('div#drawer').animate({ height: 0, top: '10px' }, time );
      $('div#drawer-content').animate({ height: 0, top: '10px' }, time );
      
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zang.zing.drawer_open = 0; // remember position of the drawer in 
  
    }, // end zang.zing.slam_drawer()
    
    easy_drawer: function(time, opacity, url, funct) {
      // time - how fast to animate the drawer
      // opacity - how much to fade out the article contents
      // url - partial to load into the drawer...
      // fn gets loaded on callback
      zang.zing.open_drawer(time, opacity);
      
      $('#drawer-content').empty().load(url, function(){
        funct();
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 131) + 'px'});
      });     
    },
  
    /* Tray Animation
    ------------------------------------------------------------------------- */       
    
    image_pop: function(element, callback){
      temp = $('#'+element).css('margin-top').split('px')[0];
      $('#traversing').remove();
      temp_top = $('#'+element).offset().top - temp;
      temp_left = $('#'+element).offset().left;
  
  
      if($('#added-pictures-tray li:last').offset() !== null){
          temp_top_new = $('#added-pictures-tray li:last').offset().top - temp;
          temp_left_new = $('#added-pictures-tray li:last').offset().left + 20;
      }
      else{
          temp_top_new = $('#added-pictures-tray').offset().top - temp;
          temp_left_new = $('#added-pictures-tray').offset().left;
  
      }
  
      $('#'+element).clone()
                    .attr({id: 'traversing'})
                    .css({position: 'absolute', zIndex: 2000, left: temp_left, top: temp_top})
                    .appendTo('body');
      
      $('#traversing').animate({ 
        width: '30px',
        height: '30px',
        top: (temp_top_new + 2) +'px',
        left: (temp_left_new + 13) +'px'
      }, 500, 'swing', callback);
      
                           
  
    } // end zang.zing.image_pop
    
  } // end zang.zing

};
var z = zang;
var zz = zang.zing;