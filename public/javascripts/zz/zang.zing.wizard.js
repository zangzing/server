zz.wizard = {

  /* Wizard Functions
    ------------------------------------------------------------------------- */
    
  make_drawer: function(obj, step){
    /* obj contains: obj.next_element, obj.done_redirect, obj.steps.step.id, 
                     obj.steps.step.element, obj.steps.step.info, 
                     obj.steps.step.type, obj.steps.step.init, 
                     obj.steps.step.bounce */
    
    if (zz.drawer_open == 0) {
      zz.open_drawer(obj.time, obj.percent);  
    }
    
    if (!step) { 
      //console.log('set up the url');
      if (obj.steps[obj.first].url_type == 'album') {
        //console.log('album');
        temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.album_id + obj.steps[obj.first].url.split('$$')[1];          
        //console.log(temp);
      } else if (obj.steps[obj.first].url_type == 'user') {
        //console.log('user');
        temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.user_id + obj.steps[obj.first].url.split('$$')[1];                    
        //console.log(temp);    
      }

      $('#drawer-content').empty().load(temp, function(){

        zz.wizard.build_nav(obj, obj.first);              
        obj.steps[obj.first].init();

      });  
    } else {
    
      if (obj.steps[step].url_type == 'album') {
        //console.log('album');
        temp = 'http://' + zz.base + obj.steps[step].url.split('$$')[0] + zz.album_id + obj.steps[step].url.split('$$')[1];          
        //console.log(temp);
      } else if (obj.steps[step].url_type == 'user') {
        //console.log('user');
        temp = 'http://' + zz.base + obj.steps[step].url.split('$$')[0] + zz.user_id + obj.steps[step].url.split('$$')[1];                    
        //console.log(temp);    
      }

      $('#drawer-content').empty().load(temp, function(){

        zz.wizard.build_nav(obj, step);              
        obj.steps[step].init();

      });  

      
    }
    
    $('body').addClass('drawer');
 
  },
  
  change_step: function(id, url, obj){
  
    //console.log('URL: '+obj.url+', Next: '+obj.steps[id].next+', Drawer: '+zz.drawer_open);
    
    if (obj.steps[id].type == 'partial' && zz.drawer_open == 1) {
      
      //console.log('oh snap, were gonna have to ditch the drawer for this');
      $('#drawer-content').empty();
      zz.close_drawer(obj.time);
      
      //console.log('drawer: emptied and closing... empty the article and load our partial');
      $('article').empty().load(url, function(data){
        //console.log('clone the indicator');
        
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
      
      });
    
    } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 2) {
      $('article').empty().load(url, function(data){
              
        obj.steps[id].init();         
        zz.wizard.build_nav(obj, id);  
        
      });
    } else if (obj.steps[id].type == 'full' && zz.drawer_open != 1) {
      zz.open_drawer(obj.time);
      $('#drawer-content').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
  
      });      
    } else if (obj.steps[id].type == 'full' && zz.drawer_open == 1) {
      $('#drawer-content').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
  
      });      
    } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 0) {
      zz.open_drawer(80, obj.percent);
      zz.close_drawer(obj.time);
      $('article').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
      });
    } else {
      console.warn('This should never happen. Context: zz.wizard.change_step, Type: '+obj.steps[id].type+', Drawer State: '+zz.drawer_open);
    }
  
    
  },
  
  build_nav: function(obj, id){
  
    temp_id = 1;
    temp = '';
    $.each(obj.steps, function(i, item) { 
      if (i == id && obj.numbers == 1) {
        value = temp_id;
        temp += '<li id="wizard-'+ i + '" class="on">';
        temp += '<img src="/images/wiz-num-'+temp_id+'-on.png" class="num"> '+ item.title +'</li>';   
      } else if (i == id) {
        value = temp_id;
        temp += '<li id="wizard-'+ i + '" class="on">'+ item.title +'</li>';   
      } else if (obj.numbers == 1) {
        temp += '<li id="wizard-'+ i + '">';
        temp += '<img src="/images/wiz-num-'+temp_id+'.png" class="num"> '+ item.title +'</li>';             
      } else {
        temp += '<li id="wizard-'+ i + '">'+ item.title +'</li>';       
      }
      temp_id++;
                    
    });
    
    // the last time we incrimented it didn't load a step - we use this to know the length of the list below
    temp_id--;
    
    if (obj.next_element == 'none') {
      // no next button neded
    } else if (obj.steps[id].next == 0 || obj.style == 'edit') {
      temp += '<li id="step-btn"><img id="next-step" src="/images/btn-wizard-done.png" /></li>';    
    } else {
      temp += '<li id="step-btn"><img id="next-step" src="/images/btn-steps-next.png" /></li>';  
    }    
    
    //console.log(temp);
    if (obj.style == 'edit') {
      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('edit-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');    
    } else {
      $('#clone-indicator').clone().attr('id', obj.list_element+'-'+temp_id).addClass('step-'+value+'-'+temp_id).html(temp).prependTo('#drawer-content');
    }
    
    zz.wizard.rebind(obj, id, temp_id); //now that we've built the nav let's bind all the nav events
  
  },
  
  
  rebind: function(obj, id, num_steps){
    $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});        

    $.each(obj.steps, function(i, item) {        
      $('li#wizard-'+ i).click(function(e){
        e.preventDefault();
        obj.steps[id].bounce();
        temp_id = $(this).attr('id').split('wizard-')[1];

      //console.log('set up the url');
      if (obj.steps[id].url_type == 'album') {
        //console.log('album');
        temp_url = 'http://' + zz.base + obj.steps[i].url.split('$$')[0] + zz.album_id + obj.steps[i].url.split('$$')[1];          
        //console.log(temp);
      } else if (obj.steps[id].url_type == 'user') {
        //console.log('user');
        temp_url = 'http://' + zz.base + obj.steps[i].url.split('$$')[0] + zz.user_id + obj.steps[i].url.split('$$')[1];                    
        //console.log(temp);    
      }
  
        zz.wizard.change_step(temp_id, temp_url, obj);           
      });


              
    });
    
    if (obj.next_element == 'none') {
      // no next button neded
    } else if (obj.last == id || obj.style == 'edit') {
      //console.log('last');
      $(obj.next_element).click(function(e){
        $('#drawer .body').fadeOut('fast');
        zz.slam_drawer(400);
        if (obj.redirect_type == 'album') {
          temp_url = 'http://' + zz.base + obj.redirect.split('$$')[0] + zz.album_id + obj.redirect.split('$$')[1];          
        } else if (obj.redirect_type == 'user') {
          temp_url = 'http://' + zz.base + obj.redirect.split('$$')[0] + zz.user_id + obj.redirect.split('$$')[1];                    
        }
        setTimeout('window.location = "'+temp_url+'"', 500);
      });
    } else {
      //console.log('NOT last');
      $(obj.next_element).click(function(e){
        e.preventDefault();
        obj.steps[id].bounce();
        temp_id = obj.steps[id].next;

        if (obj.steps[obj.steps[id].next].url_type == 'album') {
          temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.album_id + obj.steps[obj.steps[id].next].url.split('$$')[1];          
        } else if (obj.steps[obj.steps[id].next].url_type == 'user') {
          temp_url = 'http://' + zz.base + obj.steps[obj.steps[id].next].url.split('$$')[0] + zz.user_id + obj.steps[obj.steps[id].next].url.split('$$')[1];                    
        }

        zz.wizard.change_step(temp_id, temp_url, obj);   
    
      });  
    }
  },
  
  
  
  

  /* Wizard Object Functions - used to make special things happen
    ------------------------------------------------------------------------- */
  
  delete_btn: 1,
  email_id: 0,
  autocompleter: 0,
  contributor_count: 0,  
  
  create_personal_album: function(){
    $.post('/users/'+zz.user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
      zz.album_id = data;
      zz.wizard.make_drawer(zz.drawers.personal_album);
    });
  },

  create_group_album: function(){
    $.post('/users/'+zz.user_id+'/albums', { album_type: "GroupAlbum" }, function(data){
      zz.album_id = data;
      zz.wizard.make_drawer(zz.drawers.group_album);
    });
  },

  open_edit_album_wizard: function( step ){
    switch(  zz.album_type ){
        case 'personal':
            if( typeof(zz.drawers.edit_personal_album) == "undefined" ){
                zz.drawers.edit_personal_album = zz.drawers.personal_album;
                zz.drawers.edit_personal_album.style='edit'
             }
             zz.wizard.make_drawer(zz.drawers.edit_personal_album, step);
            break;
        case 'group':
             if( typeof(zz.drawers.edit_group_album) == "undefined" ){
                zz.drawers.edit_group_album = zz.drawers.group_album;
                zz.drawers.edit_group_album.style='edit'
             }
             zz.wizard.make_drawer(zz.drawers.edit_group_album, step );
            break;
      }
  },  

  // load_images is used to build the grid view of an album using json results
  load_images: function(){
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
        $('#' + id).attr('src', src).css({height: (ratio * new_size) + 'px', width: new_size+'px', marginTop: ((new_size - (ratio * new_size)) / 2) + 'px' });
  
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

        if (agent.isAgentUrl(url)) {
            url = agent.buildAgentUrl(url);
        }

        imageloader.add(id, url);

    }

    imageloader.start(5);

  },

  // loads the status message post form in place of the type switcher on the share step
  social_share: function(obj, id){
    $('div#share-body').empty().load('/albums/'+zz.album_id+'/shares/newpost', function(){
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});
      oauthmanager.init_social();
      $(z.validate.new_post_share.element).validate(z.validate.new_post_share);
      $('#cancel-share').click(function(){
        zz.wizard.reload_share(obj, id);
      });
    });     
  },
  
  // loads the email post form in place of the type switcher on the share step
  email_share: function(obj, id){
    $('div#share-body').empty().load('/albums/'+zz.album_id+'/shares/newemail', function(){                        
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});
      setTimeout(function(){zz.wizard.email_autocomplete()}, 500);
      $(z.validate.new_email_share.element).validate(z.validate.new_email_share);
      $('#cancel-share').click(function(){
        zz.wizard.reload_share(obj, id);
      });
      $('#the-list').click(function(){
        $('#you-complete-me').focus();
      });
    });     
  
  },
  
  // reloads the main share part in place of the type switcher on the share step
  reload_share: function(obj, id){
      $('#drawer-content').empty().load('/albums/'+zz.album_id+'/shares/new', function(){                        
        zz.wizard.build_nav(obj, id);  
        obj.steps[id].init();                      
      });
    },

    

  // adds a recipient to the autocomplete area on keypress
  add_recipient: function(comma){
    if (comma == 1) {
      value = $('#you-complete-me').val();
      value = value.split(',')[0];
      $('#you-complete-me').val('');
    } else {
      value = $('#you-complete-me').val();
      $('#you-complete-me').val('');
    
    }
    
    if (value.length < 6) {
      
    } else {

    
      zz.wizard.email_id++;
      //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
      $('#m-clone-added').clone()
                       .attr({id: 'm-'+zz.wizard.email_id})
                       .insertAfter('#the-recipients li.rounded:last');
      
      $('#m-'+zz.wizard.email_id+' span').empty().html(value);
      //$('#m-'+zz.wizard.email_id+' input').attr({name: 'i-' + zz.wizard.email_id, checked: 'checked'}).val(value);
      $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);       
      $('#m-'+zz.wizard.email_id).fadeIn('fast');
      $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
      $('li.rounded img').click(function(){
        $(this).parent('li').fadeOut('fast').remove();
      });
      //console.log(value);
    }
  },

  // clones a recipient from the selection list
  clone_recipient: function(data){
    if (data.length < 6) {
      
    } else {
      //console.log(data);     
      temp = $(data).html().split('&')[0];
        if( !!data.extra )
            var value = data.extra[0];
        else
            var value = $(data).html();
      //console.log(value);  



      zz.wizard.email_id++;
      //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
      $('#you-complete-me').val('');
      $('#m-clone-added').clone()
                       .attr({id: 'm-'+zz.wizard.email_id})
                       .insertAfter('#the-recipients li.rounded:last');
      
      $('#m-'+zz.wizard.email_id+' span').empty().html(temp);
     // $('#m-'+zz.wizard.email_id+' input').attr({name: 'i-' + zz.wizard.email_id, checked: 'checked'}).val(value);
      $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);

      $('#m-'+zz.wizard.email_id).fadeIn('fast');
      $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
      $('li.rounded img').click(function(){
        $(this).parent('li').fadeOut('fast').remove();
      });
    }
  },


 insert_contributor_bubble: function(label,value){
	zz.wizard.email_id++;
 	$('#m-clone-added').clone()
                  .attr({id: 'm-'+zz.wizard.email_id})
                  .insertAfter('#the-recipients li.rounded:last');
 	$('#m-'+zz.wizard.email_id+' span').empty().html(label);
 	$('#m-'+zz.wizard.email_id).fadeIn('fast');
 	$('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
    $('#m-'+zz.wizard.email_id+' input').attr({name: 'delete-url', checked: 'checked'}).val(value);
 	$('#m-'+zz.wizard.email_id+' img').click(function(){
        $.post($(this).siblings('input').val(), {"_method": "delete"}, function(data){ });
   		$(this).parent('li').fadeOut('fast').remove();
 	});
 },

 // loads the form to add contibutors on the contributors drawer
  show_new_contributors: function(){
    //console.log("Loading new contributors...") ;
    $('div#contributors-body').empty().load('/albums/'+zz.album_id+'/contributors/new', function(){
      //zz.wizard.build_nav(zz.drawers.group_album, 'contributors');
      //zz.drawers.group_album.steps['contributors'].init();
      //console.log("Initializing new contributors...") ;
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});
      setTimeout(function(){zz.wizard.email_autocomplete()}, 500);
      $(z.validate.new_contributors.element).validate(z.validate.new_contributors);
      $('#the-list').click(function(){
        $('#you-complete-me').focus();
      });  
      $('#cancel-new-contributors').click(function(){
          //console.log("Canceling new contributors...") ;      
          $('#drawer-content').empty().load('/albums/'+zz.album_id+'/contributors', function(){
                zz.wizard.build_nav(zz.drawers.group_album, 'contributors');  
                zz.drawers.group_album.steps['contributors'].init();
           });
      });
    });
  },

 
  //set up email autocomplete
  email_autocomplete: function(){
    zz.autocompleter = $('#you-complete-me').autocompleteArray(
        google_contacts.concat( yahoo_contacts.concat( local_contacts ) ),
        {
            width: 700,
            position_element: 'dd#the-list',
            append: 'div.body',
            onItemSelect: zz.wizard.clone_recipient
        }
        );
      //zz.address_list = '';
  },

  // reloads the autocompletetion data
  email_autocompleter_reload: function(){
      zz.autocompleter[0].autocompleter.setData(google_contacts.concat( yahoo_contacts.concat( local_contacts ) ));
  },

  delete_identity: function(){
         //if ( confirm('Are you sure you want to delete this identity?')){
             $.post(this.value, {"_method": "delete"}, function(data){
                 $("#drawer-content").html("").html( data );
                });
         //}
  },

  update_album: function(){
    $.post('/albums/'+zz.album_id,$(".edit_album").serialize() );
  },  

  update_user: function(){
             $.post(this.value, $("#update-user-form").serialize, function(data){
                 $("#drawer-content").html("").html( data );
                });
  },

  dashify: function(s){
      return   s
              .toLowerCase() // change everything to lowercase
              .replace(/^\s+|\s+$/g, "") // trim leading and trailing spaces
              .replace(/[_|\s]+/g, "-") // change all spaces and underscores to a hyphen
              .replace(/[^a-z0-9-]+/g, "") // remove all non-alphanumeric characters except the hyphen
              .replace(/[-]+/g, "-") // replace multiple instances of the hyphen with a single instance
              .replace(/^-+|-+$/g, "") // trim leading and trailing hyphens
              ;             
  },

  init_add_tab: function( album_type ){
       filechooser.init();
       setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
       $('#user-info').css('display', 'none');
       setTimeout("$('#album-info').css('display', 'inline-block')", 200);
      zz.album_type = album_type;
  },  

  init_name_tab: function(){
      //Set The Album Name at the top of the screen
      $('h2#album-header-title').html($('#album_name').val());
      $('#album_email').val( zz.wizard.dashify($('#album_name').val()));
      $('#album_name').keypress( function(){
         setTimeout(function(){ $('#album-header-title').html( $('#album_name').val() );
                                $('#album_email').val( zz.wizard.dashify($('#album_name').val()) );
                              }, 10);
       });
  },

  display_flashes: function( request, delay ){
      var data = request.getResponseHeader('X-Flash');
       if( data && data.length>0 ){
            var flash = (new Function( "return( " + data + " );" ))();  //parse json using function contstructor
            setTimeout(function(){$('#flashes-notice').html(flash.notice).show();},delay);
            setTimeout(function(){$('#flashes-notice').fadeOut('fast', function(){$('#flashes-notice').html('    ');})}, delay+4000);
       }

       //For the timeline album view more button




  }

};