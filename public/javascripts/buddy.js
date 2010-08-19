var temp;var temp_width;var temp_height;var temp_top;var temp_left; 
var content_url;var serialized;

/* Welcome to ZangZing
----------------------------------------------------------------------------- */

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
    
    /* Select Photo
    ------------------------------------------------------------------------- */  
    
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

      $('#'+ id +' figure').css({position: 'absolute', top: temp_top + 'px', left: temp_left + 'px', width: temp_width});
      
      $('#'+id).addClass('selected'); // select the new photo
      zz.zang.selected_photo = id; // update our constant
      zz.tracker('select-photo/'+id); // track the action

    }, // end zz.zang.highlight_selected()
    
    /* Drawer Animations
    ------------------------------------------------------------------------- */       
    
    drawer_open: 0,
        
    open_drawer: function(time){

      zz.zang.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zz.zang.drawer_height = zz.zang.screen_height - 180; 

      // fade out the grid
      $('article').animate({ opacity: 0.3 }, time/2 );
      
      // pull out the drawer
      $('div#drawer').animate({ height: zz.zang.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zz.zang.drawer_height - 52) + 'px'}, time );
      
      zz.zang.drawer_open = 1; // remember position of the drawer in 

    }, // end zz.zang.open_drawer()
    
    resize_drawer: function(time){
      
      zz.zang.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zz.zang.drawer_height = zz.zang.screen_height - 180; 
      
      $('div#drawer').animate({ height: zz.zang.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zz.zang.drawer_height - 52) + 'px'}, time );
    
    }, // end zz.zang.resize_drawer()
    
    close_drawer: function(time){
      
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
    

    /* New Album - 4 part
    ------------------------------------------------------------------------- */
    
    indicator_step: 0,
    indicator: 'undefined',
    
    choose_album_type: function(){
      //  open the drawer
      zz.zang.open_drawer(995);

      $('#drawer-content').load('/users/'+zz.zang.user_id+'/albums/new', function(){
        $('#personal_album_link').click(zz.zang.create_album);
      });      
    },
    
    create_album: function(){
      $.post('/users/'+zz.zang.user_id+'/albums/new', { album_type: "PersonalAlbum" }, function(data){
        zz.zang.album_id = data;

        zz.zang.add_photos();
        $('#indicator').fadeIn('slow');
      });
    },

    add_photos: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/wizard?step=1', function(){                
        // fire up the filechooser
        filechooser.init(); 
        
        zz.zang.indicator_step = 1;  
        zz.zang.indicator = 'step-add';
      });      
    },

    name_album: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/wizard?step=2', function(){                        
        zz.zang.indicator_step = 2;  
        zz.zang.indicator = 'step-name';
      }); 
    },
    
    preview_album: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/wizard?step=3', function(){                        
        zz.zang.indicator_step = 3;  
        zz.zang.indicator = 'step-preview';
      }); 
    },

    share_album: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/wizard?step=5', function(){                        
        zz.zang.indicator_step = 4;  
        zz.zang.indicator = 'step-share';
      }); 
    },
    
    change_step: function(element){
      if (element == zz.zang.indicator) {
        //nothing to do - same step clicked
      } else if (zz.zang.indicator_step == 1) {
        //dont post
      } else if (zz.zang.indicator_step == 2) {
        //post form
        serialized = $(".edit_album").serialize();
        $.post('/albums/'+zz.zang.album_id+'/wizard?step=2', serialized, function(data){
          alert(data);
        });

      } else if (zz.zang.indicator_step == 3) {
        //nothing for now
      } else if (zz.zang.indicator_step == 4) {
        //post form
      } else {
        //error
      }
      
      if (element == zz.zang.indicator) {
        //nothing to do - same step clicked
      } else if (element == 'step-add') {
        zz.zang.add_photos();
        temp = 1;
      } else if (element == 'step-name') {
        zz.zang.name_album();
        temp = 2;
      } else if (element == 'step-preview') {
        zz.zang.preview_album();
        temp = 3;
      } else if (element == 'step-share') {
        zz.zang.share_album();
        temp = 4;
      } else if (element == 'step-btn') {

        if (zz.zang.indicator_step == 1) {
          zz.zang.name_album();
          temp = 2;
          element = 'step-name';
        } else if (zz.zang.indicator_step == 2) {
          zz.zang.preview_album();
          temp = 3;
          element = 'step-preview';
        } else if (zz.zang.indicator_step == 3) {
          zz.zang.share_album();
          temp = 4;
          element = 'step-share';
        } else if (zz.zang.indicator_step == 4) {
          zz.zang.slam_drawer(400);
          setTimeout('window.location = "/albums/'+zz.zang.album_id+'"', 500);
        }

      }

      $('#indicator').addClass('step-'+temp).removeClass('step-'+zz.zang.indicator_step);
      $('#'+element).addClass('on');
      $('#'+zz.zang.indicator).removeClass('on');

    }
        
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
          console.log('new album fired');
          zz.zang.choose_album_type();
        } else {
          //zz.zang.slam_drawer(880);
        }
      });
      
      $('#indicator li').click(function(){
        temp = $(this).attr('id');
        zz.zang.change_step(temp);
      });
      
    },
    
    loaded: function(){
    
    },
    
    resized: function(){
      if (zz.zang.drawer_open == 1) {
        zz.zang.resize_drawer(250);
      }
      // TODO: check for selected photo - move caption position
    }        
  
  } // end zz.init

};