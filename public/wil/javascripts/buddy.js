var zz = {
  
  /* Tracking Function - Allows us to track *everything* easily 
  --------------------------------------------------------------------------- */

  tracker: function(tracked){
    //TODO: Connect to ZZ's stats provider
    //console.log('Tracked: ' + tracked);
  },// end zz.tracker
  
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
  
  }, // end zz.new_ajax
  
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
  
  }, // end zz.new_load
    
  /* AJAX 'obj' objects 
  --------------------------------------------------------------------------- */
  ajax_obj: {
    
    //makes ajax calls purdy: zz.new_ajax(zz.ajax_obj.sample_a);
    
    sample_a: {
      params: 'format=json',
      type: 'GET',
      url: '/get/json/data.js',
      maxtries: 4,
      onsuccess: function(data){
        // zz.zang.some.function();
      },
      onerror: function(data) {
        // zz.zang.some.function();
      }
    },
    
    sample_l: {
      url: '/get/html/output',
      maxtries: 4,
      onsuccess: function(data){
        // zz.zang.some.function();
      },
      onerror: function(data) {
        // zz.zang.some.function();
      }
    }

  }, 

  /* Form Validation objects 
  --------------------------------------------------------------------------- */
  validation: {
  
    sample_sign_up: {
      element: '#sample-sign-up',
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
      
    } // end zz.validation.sample_sign_up
        
  }, // end zz.validation
    
  /* ZangZing Functions and Vars 
  --------------------------------------------------------------------------- */
  
  zang: {
    
    selected_photo: 'undefined',
    drawer_open: 0,
    indicator_step: 1,
    indicator: 'step-add',
    
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

    }, // end zz.zang.highlight_selected()
    
    open_drawer: function(time){

      zz.zang.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zz.zang.drawer_height = zz.zang.screen_height - 180; 

      // fade out the grid
      $('article').animate({ opacity: 0.3 }, time/2 );
      // pull out the drawer
      $('div#drawer').animate({ height: zz.zang.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zz.zang.drawer_height + 20) + 'px'}, time );
      $('#indicator').fadeIn('slow');
      
      zz.zang.drawer_open = 1; // remember position of the drawer in 

    }, // end zz.zang.open_drawer()

    close_drawer: function(time){

      $('#indicator').fadeOut('fast');
      // close the drawer
      $('div#drawer').animate({ height: 0, top: '10px' }, time );
      $('div#drawer-content').animate({ height: 0, top: '10px' }, time );
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zz.zang.drawer_open = 0; // remember position of the drawer in 

    } // end zz.zang.open_drawer()
    
    
  }, // end zz.zang
  
  /* INITs 
  --------------------------------------------------------------------------- */
  
  init: {
  
    template: function(){
    
      /* Click Handlers
      ----------------------------------------------------------------------- */
      
      // highlight a selected photo
      $('ul#grid-view li').click(function(){
        zz.zang.new_photo = $(this).attr('id');
        zz.zang.highlight_selected(zz.zang.new_photo);
      });
      
      // open drawer demo
      $('#nav-new-album').click(function(){
      
        if (zz.zang.drawer_open === 0) {
          zz.zang.open_drawer(990);
        } else {
          zz.zang.close_drawer(880);
        }
                
      });
      
      $('#step-style').click(function(){
        zz.zang.indicator = $('.on').val('id');
        if (zz.zang.indicator == 'step-style') {
          return;
        } else {
          $('#indicator').addClass('step-2').removeClass('step-'+zz.zang.indicator_step);
          $(this).addClass('on');
          $('#'+zz.zang.indicator).removeClass('on');
          zz.zang.indicator = 'step-style';
          zz.zang.indicator_step = 2;
        }
        
      });
      
      $('#step-edit').click(function(){
        zz.zang.indicator = $('.on').val('id');
        if (zz.zang.indicator == 'step-edit') {
          return;
        } else {
          $('#indicator').addClass('step-3').removeClass('step-'+zz.zang.indicator_step);
          $(this).addClass('on');
          $('#'+zz.zang.indicator).removeClass('on');
          zz.zang.indicator = 'step-edit';
          zz.zang.indicator_step = 3;
        }
        
      });
      
      $('#step-share').click(function(){
        zz.zang.indicator = $('.on').val('id');
        if (zz.zang.indicator == 'step-share') {
          return;
        } else {
          $('#indicator').addClass('step-4').removeClass('step-'+zz.zang.indicator_step);
          $(this).addClass('on');
          $('#'+zz.zang.indicator).removeClass('on');
          zz.zang.indicator = 'step-share';
          zz.zang.indicator_step = 4;
        }
        
      });
      
      $('#step-add').click(function(){
        zz.zang.indicator = $('.on').val('id');
        if (zz.zang.indicator == 'step-add') {
          return;
        } else {
          $('#indicator').addClass('step-1').removeClass('step-'+zz.zang.indicator_step);
          $(this).addClass('on');
          $('#'+zz.zang.indicator).removeClass('on');
          zz.zang.indicator = 'step-add';
          zz.zang.indicator_step = 1;
        }
        
      });      
      
      
    },
    
    loaded: function(){
    
    },
    
    resized: function(){
      
    }        
  
  } // end zz.init

};