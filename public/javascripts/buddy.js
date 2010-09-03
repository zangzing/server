var temp;var temp_width;var temp_height;var temp_top;var temp_left; 
var content_url;var serialized;var temp_top_new;var temp_left_new;
var value;

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
  
    new_post_share: {
      element: '#new_post_share',
      submitHandler: function() {
        serialized = $('#new_post_share').serialize();
        $.post('/albums/'+zz.zang.album_id+'/shares', serialized, function(data){
          zz.zang.reload_share();
        });
      }
      
    }, // end zz.validation.new_post_share
    
    new_email_share: {
      element: '#new_email_share',
      submitHandler: function() {
        serialized = $('#new_email_share').serialize();
        $.post('/albums/'+zz.zang.album_id+'/shares', serialized, function(data){
          zz.zang.reload_share();
        });
      }
      
    }, // end zz.validation.new_post_share    
    
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
        // console.log('selected_photo: undefined');      
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
    screen_gap: 150,
        
    open_drawer: function(time, percent){

      zz.zang.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zz.zang.drawer_height = zz.zang.screen_height - zz.zang.screen_gap; 

      if (typeof percent == 'number') {
        temp = percent;
      } else {
        temp = 0;
      }
      
      // fade out the grid
      $('article').animate({ opacity: temp }, time/2 ).html('');
      
      // pull out the drawer
      $('div#drawer').animate({ height: zz.zang.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zz.zang.drawer_height - 52) + 'px'}, time );
      
      zz.zang.drawer_open = 1; // remember position of the drawer in 

    }, // end zz.zang.open_drawer()
    
    resize_drawer: function(time){
      
      zz.zang.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zz.zang.drawer_height = zz.zang.screen_height - zz.zang.screen_gap; 
      
      $('div#drawer').animate({ height: zz.zang.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zz.zang.drawer_height - 52) + 'px'}, time );
      $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});

    }, // end zz.zang.resize_drawer()
    
    close_drawer: function(time){
      
      // close the drawer
      $('div#drawer').animate({ height: '20px'}, time );
      $('div#drawer-content').animate({ height: 0}, time );
      
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zz.zang.drawer_open = 2; // remember position of the drawer in 

    }, // end zz.zang.close_drawer()
    
    slam_drawer: function(time){

      $('#indicator').fadeOut('fast');
      
      // close the drawer
      $('div#drawer').animate({ height: 0, top: '10px' }, time );
      $('div#drawer-content').animate({ height: 0, top: '10px' }, time );
      
      // fade in the grid
      $('article').animate({ opacity: 1 }, time * 1.1 );
      
      zz.zang.drawer_open = 0; // remember position of the drawer in 

    }, // end zz.zang.slam_drawer()
    
    tray_zoom_in: function(element){
      $('#'+element).stop().animate({ height: '100px', width: '100px', bottom: '0px' }, 500);   
    }, // end zz.zang.tray_zoom_in()
    
    tray_zoom_out: function(element){
      $('#'+element).stop().animate({ height: '30px', width: '30px', bottom: '0px' }, 500);   
    },  // end zz.zang.tray_zoom_out()  
    
    image_pop: function(element){
      temp = $('#'+element).css('margin-top').split('px')[0];
      $('#traversing').remove();
      temp_top = $('#'+element).offset().top - temp;
      temp_left = $('#'+element).offset().left;

      //todo: this element doesn't exist the first time. should check and set top and left to ~0
      temp_top_new = $('#added-pictures-tray li:last').offset().top - temp;
      temp_left_new = $('#added-pictures-tray li:last').offset().left + 20;
      
      $('#'+element).clone()
                    .attr({id: 'traversing'})
                    .css({position: 'absolute', zIndex: 2000, left: temp_left, top: temp_top})
                    .appendTo('body');
      
      $('#traversing').animate({ 
        width: '20px',
        height: '20px',
        top: (temp_top_new - 2) +'px',
        left: (temp_left_new + 3) +'px'
      }, 500);
      
                           

    }, // end zz.zang.image_pop

    /* New Album - 4 part
    ------------------------------------------------------------------------- */
    
    indicator_step: 0,
    indicator: 'undefined',
    
    choose_album_type: function(){
      //  open the drawer
      zz.zang.open_drawer(995);

      //switch to show album badge       
      $('#album-info').css('display', 'inline-block');
      $('#user-info').css('display', 'none');



      $('#drawer-content').load('/users/'+zz.zang.user_id+'/albums/new', function(){
        $('#personal_album_link').click(zz.zang.create_album);
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 70) + 'px'});
      });      
    },
    
    create_album: function(){
      $.post('/users/'+zz.zang.user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
        zz.zang.album_id = data;

        zz.zang.add_photos();
        $('#user-info').fadeOut('fast');
        $('#indicator').fadeIn('slow');


      });
    },

    add_photos: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/add_photos', function(){                
        // fire up the filechooser
        filechooser.init(); 
        setTimeout("$('#album-info').css('display', 'inline-block')", 200);
        setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});
        
        zz.zang.indicator_step = 1;  
        zz.zang.indicator = 'step-add';
      });      
    },

    name_album: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/name_album', function(){                        
        zz.zang.indicator_step = 2;  
        zz.zang.indicator = 'step-name';
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});


        //todo: move this into the "name_album" layout
        //setup change handler on text box
        $('#album_name').keypress(function(){setTimeout(function(){ $('#album-header-title').html($('#album_name').val())}, 10)});

      }); 
    },
    
    preview_album: function(){
      $('#drawer-content').empty();
      $('article').empty().load('/albums/'+zz.zang.album_id+'/edit', function(data){                        
        zz.zang.close_drawer();
        zz.zang.indicator_step = 3;  
        zz.zang.indicator = 'step-edit';

        //console.log(json);
        temp = jQuery.parseJSON(json).photos;
          
        var onStartLoadingImage = function(id, src) {
          $('#' + id).attr('src', '/images/loading.gif');
        };
          
        var onImageLoaded = function(id, src, width, height) {
          var new_size = 120;
          //console.log('id: #'+id+', src: '+src+', width: '+width+', height: '+height);
        
          if (height > width) {
            //console.log('tall');
            //tall
            var ratio = width / height; 
            $('#' + id).attr('src', src).css({height: new_size+'px', width: (ratio * new_size) + 'px' });
            
            
            var guuu = $('#'+id).attr('id').split('photo-')[1];
            $('#' + id).parent('li').attr({id: 'photo-'+guuu});              
            $('li#photo-'+ guuu +'-li figure').css({bottom: '0px', width: (new_size * ratio) + 'px', left: $('#' + id).position()['left'] + 'px' });
            $('li#photo-'+ guuu +'-li a.delete img').css({top: '-16px', right: (150 - $('#' + id).outerWidth() - 20) / 2  +'px'} );
      
          } else {
            //wide
            //console.log('wide');
      
            var ratio = height / width; 
            $('#' + id).attr('src', src).attr('src', src).css({height: (ratio * new_size) + 'px', width: new_size+'px', marginTop: ((new_size - (ratio * new_size)) / 2) + 'px' });
      
            var guuu = $('#'+id).attr('id').split('photo-')[1];
            //$('li#photo-'+ guuu +'-li a.delete img').css({top: ($('#' + id).position()['top'] - 26), right: '-26px'});
            $('li#photo-'+ guuu +'-li figure').css({width: new_size + 'px', bottom:  0, left: (140 - new_size) / 2 +'px'});
            //console.log(guuu);
          }
    
        };
    
        var imageloader = new ImageLoader(onStartLoadingImage, onImageLoaded);
    
        for(var i in temp){
            var id = 'photo-' + temp[i].id;
            var url = null
            if (temp[i].state == 'ready') {
                url = temp[i].thumb_url;
            } else {
                url = temp[i].source_thumb_url;
            }
    
            if (url.indexOf('http://localhost') === 0) {
                url += '?session=' + $.cookie('user_credentials')
            }
    
            imageloader.add(id, url);
    
        }
    
        imageloader.start(5)
        
      }).css({marginTop: '60px', opacity: 1}); 
    },

    reload_share: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/shares/new', function(){                        
        zz.zang.indicator_step = 4;  
        zz.zang.indicator = 'step-share';
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});
        $('.social-share').click(zz.zang.social_share);
        $('.email-share').click(zz.zang.email_share);
        $('.album_privacy').change(zz.zang.album_update);
      });
    },

    share_album: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/shares/new', function(){                        
        zz.zang.indicator_step = 4;  
        zz.zang.indicator = 'step-share';
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});
        $('.social-share').click(zz.zang.social_share);
        $('.email-share').click(zz.zang.email_share);
        $('.album_privacy').change(zz.zang.album_update);
      }); 
    },

    social_share: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/shares/newpost', function(){                        
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});
        $('#new_post_share').validate(zz.validation.new_post_share);
        $('#cancel-share').click(zz.zang.reload_share);
      });     
    },
    
    email_id: 0,
    
    email_share: function(){
      $('#drawer-content').empty().load('/albums/'+zz.zang.album_id+'/shares/newemail', function(){                        
        $('div#drawer-content div#scroll-body').css({height: (zz.zang.drawer_height - 170) + 'px'});
        $('#the-list').click(function(){
          $('#you-complete-me').focus();
        });
          $('#you-complete-me').autocompleteArray(google_contacts, {
            onItemSelect: function(data){
              temp = $(data).html().split('&')[0];
              console.log('Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
              zz.zang.email_id++;
              $('#you-complete-me').val('');
              $('#clone-added').clone()
                               .attr({id: 'm-'+zz.zang.email_id})
                               .prependTo('#the-recipients');
              
              $('#m-'+zz.zang.email_id+' span').empty().html(temp);
              $('#m-'+zz.zang.email_id).fadeIn('fast');
              
            },
            width: 700,
            position_element: 'dd#the-list',
            append: 'div.body'
          });
        $('#new_email_share').validate(zz.validation.new_email_share);
        $('#cancel-share').click(zz.zang.reload_share);
      });     
    
    },

    album_update: function(){
        $.post('/albums/'+zz.zang.album_id, $(".edit_album").serialize());
    },


    change_step: function(element){
      if (element == zz.zang.indicator) {
        //nothing to do - same step clicked
      } else if (zz.zang.indicator_step == 1) {
        //hide the tray
        $('#added-pictures-tray').fadeOut('fast');
  
      } else if (zz.zang.indicator_step == 2) {
        //post form
        serialized = $(".edit_album").serialize();
        value = $('#album_name').val();
        $('h2#album-header-title').html(value);
        $.post('/albums/'+zz.zang.album_id, serialized, function(data){ 
          
        });
      } else if (zz.zang.indicator_step == 3) {
        //re-open the drawer
        zz.zang.open_drawer();
      } else if (zz.zang.indicator_step == 4) {
        //post form
      } else {
        //error
      }
      
      if (element == 'step-add') {
        zz.zang.add_photos();
        temp = 1;
      } else if (element == 'step-name') {
        zz.zang.name_album();
        temp = 2;
      } else if (element == 'step-edit') {
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
          element = 'step-edit';
        } else if (zz.zang.indicator_step == 3) {
          zz.zang.share_album();
          temp = 4;
          element = 'step-share';
        } else if (zz.zang.indicator_step == 4) {
          zz.zang.slam_drawer(400);
          setTimeout('window.location = "/albums/'+zz.zang.album_id+'"', 500);
        }

      }
  
      if (zz.zang.indicator_step == temp) {
      
      } else {
        $('#indicator').removeClass('step-'+zz.zang.indicator_step).addClass('step-'+temp);
        $('#'+zz.zang.indicator).removeClass('on');
        $('#'+element).addClass('on');

      }
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
        //gow scroll body
      }
      // TODO: check for selected photo - move caption position
    },
    
    
    
    tray: function(){
    
    }        
  
  } // end zz.init

};
