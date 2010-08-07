/* Core Functions 
------------------------------------------------------------------------------ */
var zz = {
  
  /* Tracking Function - Allows us to track *everything* easily 
  ------------------------------------------------------------------------------ */

  tracker: function(tracked){
    //TODO: Connect to ZZ's stats provider
    //console.log('Tracked: ' + tracked);
  },// end zz.tracker
  
  /* Better AJAX - extends jQuery.ajax() w/retries & error/success functions
  ------------------------------------------------------------------------------ */
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
  }, // end zz.new_ajax
  
  /* Better Load - extends jQuery(obj).load(); w/retries & error/success fns 
  ------------------------------------------------------------------------------ */
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
  }, // end zz.new_load
    
  /* Form Validation objects 
  ------------------------------------------------------------------------------ */
  validation: {
  
    /* The Sign Up Form 
    ------------------------------------------------------------------------------ */
    sign_up: {
      element: '#sign-up',
      rules: {
        first_name: { required: true, minlength: 2 },  
        last_name: { required: true, minlength: 3 },  
        email: { required: true, email: true }, 
        password: { required: true, minlength: 6 },
        terms: { required: true }
      },
      messages: {
        first_name: { 
          required: '', 
          minlength: '' 
        },  
        last_name: { 
          required: '', 
          minlength: '' 
        },  
        email: { 
          required: '', 
          email: '' 
        }, 
        password: { 
          required: '', 
          minlength: '' 
        },
        terms: { 
          required: '' 
        }  
      }
      
    } // end zz.validation.sign_up
        
  }, // end zz.validation
    
  /* ZangZing Functions and Vars 
  ------------------------------------------------------------------------------ */
  
  zang: {
    
    selected_photo: 'undefined',
    drawer_open: 'no',
    highlight_selected: function(id){
    
      if (zz.zang.selected_photo != 'undefined') {
        // the old photo is no longer selected
        $('li#'+zz.zang.selected_photo).removeClass('selected');
      } else {
        //console.log('selected_photo: undefined');      
      }
      
      $('#'+id).addClass('selected'); // select the new photo
      zz.zang.selected_photo = id; // update our constant
      zz.tracker('select-photo/'+id); // track the action
    } // end zz.zang.highlight_selected()
    
  }, // end zz.zang

  /* INITs 
  ------------------------------------------------------------------------------ */
  
  init: {
  
    base: function(){
    
      /* Click Handlers
      -------------------------------------------------------------------------- */
      
      // highlight a selected photo
      $('ul#grid-view li').click(function(){
        zz.zang.new_photo = $(this).attr('id');
        zz.zang.highlight_selected(zz.zang.new_photo);
      });
      
      // open drawer demo
      $('#nav-new-album').click(function(){
        
        zz.zang.screen_height = $(window).height(); // measure the screen height
        zz.zang.drawer_height = zz.zang.screen_height - 200; // adjust for out top and bottom bar, the gradient padding of 40 on the drawer and a margin
        // fade out the grid
        $('article').fadeOut('slow');
        
        // pull out the drawer
        $('div#drawer').animate({ 
          height: zz.zang.drawer_height + 'px'
        }, 1800 );
        
      });
    },
  
  } // end zz.init

};