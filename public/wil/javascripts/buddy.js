var temp;var temp_width;var temp_height;var temp_top;var temp_left;     
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
    
    // Select Photo var & fn
    selected_photo: 'undefined',
    highlight_selected: function(id){
    
      if (zz.zang.selected_photo != 'undefined') {
        // the old photo is no longer selected
        $('li#'+zz.zang.selected_photo).removeClass('selected');
      } else {
        //console.log('selected_photo: undefined');      
      }
      
      temp_width = $('#'+ id +' img').width() - 10;
      temp_height = $('#'+ id +' img').height();
      temp_top = $('#'+ id +' img').position()['top'] + temp_height - 20;
      temp_left = $('#'+ id +' img').position()['left'] + 5;      

      $('#'+ id +' figure').css({position: 'absolute', top: temp_top+'px', left: temp_left+'px', width: temp_width});
      
      $('#'+id).addClass('selected'); // select the new photo
      zz.zang.selected_photo = id; // update our constant
      zz.tracker('select-photo/'+id); // track the action

    }, // end zz.zang.highlight_selected()
    
    
    // Open/close drawer var & fns
    drawer_open: 0,
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

      //$('#indicator').fadeOut('fast');
      // close the drawer
      $('div#drawer').animate({ height: '20px'}, time );
      $('div#drawer-content').animate({ height: 0}, time );
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zz.zang.drawer_open = 2; // remember position of the drawer in 

    }, // end zz.zang.open_drawer()
    slam_drawer: function(time){

      $('#indicator').fadeOut('fast');
      // close the drawer
      $('div#drawer').animate({ height: 0, top: '10px' }, time );
      $('div#drawer-content').animate({ height: 0, top: '10px' }, time );
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zz.zang.drawer_open = 0; // remember position of the drawer in 

    }, // end zz.zang.open_drawer()
    
    // Step swap vars and fns
    indicator_step: 1,
    indicator: 'step-add',
    step_switch: function(element){
    
      if (element == 'step-btn') {

        if (zz.zang.indicator_step == 1) {
          element = 'step-style';
        } else if (zz.zang.indicator_step == 2) {
          element = 'step-edit';        
        } else if (zz.zang.indicator_step == 3) {
          element = 'step-share';        
        } else if (zz.zang.indicator_step == 4) {
          zz.zang.slam_drawer(995);
          return;
        }
      
      }

      if (zz.zang.indicator != element) {
      
        if (element == 'step-add') {
          temp = 1;
        } else if (element == 'step-style') {
          temp = 2;        
        } else if (element == 'step-edit') {
          temp = 3; 
          zz.zang.close_drawer(995);
        } else if (element == 'step-share') {
          temp = 4;        
        }
        
        if (zz.zang.indicator_step == 3) {
          zz.zang.open_drawer(995);        
        }
      
        $('#indicator').addClass('step-'+temp).removeClass('step-'+zz.zang.indicator_step);
        $('#'+element).addClass('on');
        $('#'+zz.zang.indicator).removeClass('on');
        zz.zang.indicator = element;
        zz.zang.indicator_step = temp;
                
      }
        
    }  // end zz.zang.step_switch()
    
    
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
          zz.zang.slam_drawer(880);
        }
                
      });
      
      $('#indicator li').click(function(){
        temp = $(this).attr('id');
        zz.zang.step_switch(temp);
      });
      
    },
    
    loaded: function(){
    
    },
    
    resized: function(){
      
    }        
  
  } // end zz.init

};