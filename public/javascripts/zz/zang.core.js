var temp;var temp_width;var temp_height;var temp_top;var temp_left; 
var content_url;var serialized;var temp_top_new;var temp_left_new;
var value;

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
    view: 'undefined' // not in use anywhere, yet - but zang.zing has children, do not delete.
  } // end zang.zing

};