zang.zing = {
    
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
      $('div#drawer-content').animate({ height: (zang.zing.drawer_height - 52) + 'px'}, time );
      
      zang.zing.drawer_open = 1; // remember position of the drawer in 

    }, // end zang.zing.open_drawer()
    
    resize_drawer: function(time){
      
      zang.zing.screen_height = $(window).height(); // measure the screen height
      // adjust for out top and bottom bar, the gradient padding and a margin
      zang.zing.drawer_height = zang.zing.screen_height - zang.zing.screen_gap; 
      
      $('div#drawer').animate({ height: zang.zing.drawer_height + 'px', top: '50px' }, time );
      $('div#drawer-content').animate({ height: (zang.zing.drawer_height - 52) + 'px'}, time );
      $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});

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
    
    tray_zoom_in: function(element){
      $('#'+element).stop().animate({ height: '100px', width: '100px', bottom: '0px' }, 500);   
    }, // end zang.zing.tray_zoom_in()
    
    tray_zoom_out: function(element){
      $('#'+element).stop().animate({ height: '30px', width: '30px', bottom: '0px' }, 500);   
    },  // end zang.zing.tray_zoom_out()  
    
    image_pop: function(element){
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
        top: (temp_top_new ) +'px',
        left: (temp_left_new + 13) +'px'
      }, 500);
      
                           

    }, // end zang.zing.image_pop

    /* New Album - 4 part
    ------------------------------------------------------------------------- */
    
    indicator_step: 0,
    indicator: 'undefined',
    
    choose_album_type: function(){
      //  open the drawer
      zang.zing.open_drawer(995);

      //switch to show album badge       
      $('#album-info').css('display', 'inline-block');
      $('#user-info').css('display', 'none');
      $('#drawer-content').load('/users/'+zang.zing.user_id+'/albums/new', function(){
        $('#personal_album_link').click(zang.zing.create_album);
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 70) + 'px'});
      });      
    },
    
    create_album: function(){
      $.post('/users/'+zang.zing.user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
        zang.zing.album_id = data;
        zang.zing.add_photos();
        $('#user-info').fadeOut('fast');
        $('#indicator').fadeIn('slow');
      });
    },

    add_photos: function(){
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/add_photos', function(){                
        // fire up the filechooser
        filechooser.init(); 
        setTimeout("$('#album-info').css('display', 'inline-block')", 200);
        setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});
        
        zang.zing.indicator_step = 1;  
        zang.zing.indicator = 'step-add';
      });      
    },

    name_album: function(){
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/name_album', function(){                        
        zang.zing.indicator_step = 2;  
        zang.zing.indicator = 'step-name';
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});


        //todo: move this into the "name_album" layout
        //setup change handler on text box
        $('#album_name').keypress(function(){setTimeout(function(){ $('#album-header-title').html($('#album_name').val())}, 10)});

      }); 
    },
    
    preview_album: function(){
      $('#drawer-content').empty();
      $('article').empty().load('/albums/'+zang.zing.album_id+'/edit', function(data){                        
        zang.zing.close_drawer();
        zang.zing.indicator_step = 3;  
        zang.zing.indicator = 'step-edit';

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
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/shares/new', function(){                        
        zang.zing.indicator_step = 4;  
        zang.zing.indicator = 'step-share';
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});
        $('.social-share').click(zang.zing.social_share);
        $('.email-share').click(zang.zing.email_share);
        $('.album_privacy').change(zang.zing.album_update);
      });
    },

    share_album: function(){
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/shares/new', function(){                        
        zang.zing.indicator_step = 4;  
        zang.zing.indicator = 'step-share';
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});
        $('.social-share').click(zang.zing.social_share);
        $('.email-share').click(zang.zing.email_share);
        $('.album_privacy').change(zang.zing.album_update);
      }); 
    },

    social_share: function(){
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/shares/newpost', function(){                        
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});
        $(zang.validation.new_post_share.element).validate(zang.validation.new_post_share);
        $('#cancel-share').click(zang.zing.reload_share);
      });     
    },
    
    delete_btn: 0,
    email_id: 0,

    add_recipient: function(comma){
      if (comma == 1) {
        value = $('#you-complete-me').val();
        value = value.split(',')[0];
        $('#you-complete-me').val('');
      } else {
        value = $('#you-complete-me').val();
        $('#you-complete-me').val('');
      
      }
      
      zang.zing.email_id++;
      //console.log('ID: '+ zang.zing.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
      $('#m-clone-added').clone()
                       .attr({id: 'm-'+zang.zing.email_id})
                       .insertAfter('#the-recipients li.rounded:last');
      
      $('#m-'+zang.zing.email_id+' span').empty().html(value);
      $('#m-'+zang.zing.email_id+' input').attr({name: 'i-' + zang.zing.email_id, checked: 'checked'}).val(value);
      $('#m-'+zang.zing.email_id).fadeIn('fast');
      $('#m-'+zang.zing.email_id+' img').attr('id', 'img-'+zang.zing.email_id);
      $('li.rounded img').click(function(){
        $(this).parent('li').fadeOut('fast').remove();
      });
      console.log(value);
      zang.zing.build_address_list('add', value);            
    },

    clone_recipient: function(data){
      temp = $(data).html().split('&')[0];
      value = $(data).html();
      console.log(value);
      console.log(data);

      zang.zing.email_id++;
      //console.log('ID: '+ zang.zing.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
      $('#you-complete-me').val('');
      $('#m-clone-added').clone()
                       .attr({id: 'm-'+zang.zing.email_id})
                       .insertAfter('#the-recipients li.rounded:last');
      
      $('#m-'+zang.zing.email_id+' span').empty().html(temp);
      $('#m-'+zang.zing.email_id+' input').attr({name: 'i-' + zang.zing.email_id, checked: 'checked'}).val(value);
      $('#m-'+zang.zing.email_id).fadeIn('fast');
      $('#m-'+zang.zing.email_id+' img').attr('id', 'img-'+zang.zing.email_id);
      $('li.rounded img').click(function(){
        $(this).parent('li').fadeOut('fast').remove();
      });
      zang.zing.build_address_list('clone', data);  
    },

    autocompleter: 0,
    //address_list: 0,
    email_autocomplete: function(){
      zang.zing.autocompleter = $('#you-complete-me').autocompleteArray(
          google_contacts.concat( yahoo_contacts.concat( local_contacts ) ),
          {
              width: 700,
              position_element: 'dd#the-list',
              append: 'div.body',
              onItemSelect: zang.zing.clone_recipient, 
              onFindValue: zang.zing.build_address_list
          }
          );
        //zang.zing.address_list = '';
    },

    email_autocompleter_reload: function(){
        zang.zing.autocompleter[0].autocompleter.setData(google_contacts.concat( yahoo_contacts.concat( local_contacts ) ));
    },

    build_address_list: function(type, li) {
	    if(li == null) return;
      if (type == 'clone') {
        if( !!li.extra ) {
          var sValue = li.extra[0];        
        } else {
          var sValue = li.selectValue;
        }
      
      } else if (type == 'add') {
      
        var sValue = li;
      
      }
        
      var recipients = $('#email_share_recipients').val();
      if( recipients.length > 0 )
          recipients+=(';');
      recipients += sValue;
      $('#email_share_recipients').val(recipients);
    },


    email_share: function(){
      $('#drawer-content').empty().load('/albums/'+zang.zing.album_id+'/shares/newemail', function(){                        
        $('div#drawer-content div#scroll-body').css({height: (zang.zing.drawer_height - 170) + 'px'});
           setTimeout(zang.zing.email_autocomplete, 500);
        $(zang.validation.new_email_share.element).validate(zang.validation.new_email_share);
        $('#cancel-share').click(zang.zing.reload_share);
        $('#the-list').click(function(){
          $('#you-complete-me').focus();
        });
      });     
    
    },

    album_update: function(){
        $.post('/albums/'+zang.zing.album_id, $(".edit_album").serialize());
    },


    change_step: function(element){
      if (element == zang.zing.indicator) {
        //nothing to do - same step clicked
      } else if (zang.zing.indicator_step == 1) {
        //hide the tray
        $('#added-pictures-tray').fadeOut('fast');
  
      } else if (zang.zing.indicator_step == 2) {
        //post form
        serialized = $(".edit_album").serialize();
        value = $('#album_name').val();
        $('h2#album-header-title').html(value);
        $.post('/albums/'+zang.zing.album_id, serialized, function(data){ 
          
        });
      } else if (zang.zing.indicator_step == 3) {
        //re-open the drawer
        zang.zing.open_drawer();
      } else if (zang.zing.indicator_step == 4) {
        //post form
      } else {
        //error
      }
      
      if (element == 'step-add') {
        zang.zing.add_photos();
        temp = 1;
      } else if (element == 'step-name') {
        zang.zing.name_album();
        temp = 2;
      } else if (element == 'step-edit') {
        zang.zing.preview_album();
        temp = 3;
      } else if (element == 'step-share') {
        zang.zing.share_album();
        temp = 4;
      } else if (element == 'step-btn') {

        if (zang.zing.indicator_step == 1) {
          zang.zing.name_album();
          temp = 2;
          element = 'step-name';
        } else if (zang.zing.indicator_step == 2) {
          zang.zing.preview_album();
          temp = 3;
          element = 'step-edit';
        } else if (zang.zing.indicator_step == 3) {
          zang.zing.share_album();
          temp = 4;
          element = 'step-share';
        } else if (zang.zing.indicator_step == 4) {
          zang.zing.slam_drawer(400);
          setTimeout('window.location = "/albums/'+zang.zing.album_id+'"', 500);
        }

      }
  
      if (zang.zing.indicator_step == temp) {
      
      } else {
        $('#indicator').removeClass('step-'+zang.zing.indicator_step).addClass('step-'+temp);
        $('#'+zang.zing.indicator).removeClass('on');
        $('#'+element).addClass('on');

      }
    }



}; // end zang.zing