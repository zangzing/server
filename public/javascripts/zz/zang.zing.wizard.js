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
      console.log('set up the url');
      if (obj.steps[obj.first].url_type == 'album') {
        console.log('album');    
        temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.album_id + obj.steps[obj.first].url.split('$$')[1];          
        console.log(temp);    
      } else if (obj.steps[obj.first].url_type == 'user') {
        console.log('user');    
        temp = 'http://' + zz.base + obj.steps[obj.first].url.split('$$')[0] + zz.user_id + obj.steps[obj.first].url.split('$$')[1];                    
        console.log(temp);    
      }

      $('#drawer-content').empty().load(temp, function(){

        zz.wizard.build_nav(obj, obj.first);              
        zz.wizard.rebind(obj, obj.first);              
        obj.steps[obj.first].init();

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
        zz.wizard.rebind(obj, id);  
      
      });
    
    } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 2) {
      $('article').empty().load(url, function(data){
              
        obj.steps[id].init();         
        zz.wizard.build_nav(obj, id);  
        zz.wizard.rebind(obj, id);
        
      });
    } else if (obj.steps[id].type == 'full' && zz.drawer_open != 1) {
      zz.open_drawer(obj.time);
      $('#drawer-content').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
        zz.wizard.rebind(obj, id);
  
      });      
    } else if (obj.steps[id].type == 'full' && zz.drawer_open == 1) {
      $('#drawer-content').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
        zz.wizard.rebind(obj, id);
  
      });      
    } else if (obj.steps[id].type == 'partial' && zz.drawer_open == 0) {
      zz.open_drawer(80, obj.percent);
      zz.close_drawer(obj.time);
      $('article').empty().load(url, function(data){
        obj.steps[id].init();
        zz.wizard.build_nav(obj, id);  
        zz.wizard.rebind(obj, id);
      });
    } else {
      console.warn('This should never happen. Context: zz.wizard.change_step, Type: '+obj.steps[id].type+', Drawer State: '+zz.drawer_open);
    }
  
    
  },
  
  build_nav: function(obj, id){
  
    temp_id = 1;
    temp = '';
    $.each(obj.steps, function(i, item) { 
      if (item.id == id) {
        value = temp_id;
        temp += '<li id="wizard-'+ item.id + '" class="on">';
        temp += '<img src="/images/wiz-num-'+temp_id+'-on.png" class="num"> '+ item.title +'</li>';   
      } else {
        temp += '<li id="wizard-'+ item.id + '">';
        temp += '<img src="/images/wiz-num-'+temp_id+'.png" class="num"> '+ item.title +'</li>';       
      }
      
      temp_id++;
                    
    });
    
    if (obj.steps[id].next == 0) {
      temp += '<li id="step-btn"><img id="next-step" src="/images/btn-wizard-done.png" /></li>';    
    } else {
      temp += '<li id="step-btn"><img id="next-step" src="/images/btn-steps-next.png" /></li>';  
    }
    
    //console.log(temp);
  
    $('#clone-indicator').clone().attr('id', 'indicator').addClass('step-'+value+'-5').html(temp).prependTo('#drawer-content');
  
  },
  
  
  rebind: function(obj, id){
    $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});        

    $.each(obj.steps, function(i, item) {        
      $('#indicator li#wizard-'+ item.id).click(function(e){
        e.preventDefault();
        obj.steps[id].bounce();
        temp_id = $(this).attr('id').split('wizard-')[1];

      console.log('set up the url');
      if (obj.steps[id].url_type == 'album') {
        console.log('album');    
        temp_url = 'http://' + zz.base + obj.steps[item.id].url.split('$$')[0] + zz.album_id;          
        console.log(temp);    
      } else if (obj.steps[id].url_type == 'user') {
        console.log('user');    
        temp_url = 'http://' + zz.base + obj.steps[item.id].url.split('$$')[0] + zz.user_id;                    
        console.log(temp);    
      }
  
        zz.wizard.change_step(temp_id, temp_url, obj);           
      });


              
    });
    
    if (obj.last == id) {
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

        console.log('id: '+temp_id+', url: '+temp_url);
        zz.wizard.change_step(temp_id, temp_url, obj);   
    
      });  
    }
  },
  
  
  
  

  /* Wizard Object Functions - used to make special things happen
    ------------------------------------------------------------------------- */
  
  delete_btn: 1,
  email_id: 0,
  autocompleter: 0,
  
  create_album: function(){
    $.post('/users/'+zz.user_id+'/albums', { album_type: "PersonalAlbum" }, function(data){
      zz.album_id = data;
      zz.wizard.make_drawer(zz.drawers.personal_album);
    });
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

        if (url.indexOf('http://localhost') === 0) {
            url += '?session=' + $.cookie('user_credentials')
        }

        imageloader.add(id, url);

    }

    imageloader.start(5);

  },

  // loads the status message post form in place of the type switcher on the share step
  social_share: function(){
    $('div#share-body').empty().load('/albums/'+zz.album_id+'/shares/newpost', function(){
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});
      $(z.validate.new_post_share.element).validate(z.validate.new_post_share);
      $('#cancel-share').click(zz.wizard.reload_share);
    });     
  },
  
  // loads the email post form in place of the type switcher on the share step
  email_share: function(){
    $('div#share-body').empty().load('/albums/'+zz.album_id+'/shares/newemail', function(){                        
      $('div#drawer-content div#scroll-body').css({height: (zz.drawer_height - 170) + 'px'});
      setTimeout(function(){zz.wizard.email_autocomplete()}, 500);
      $(z.validate.new_email_share.element).validate(z.validate.new_email_share);
      $('#cancel-share').click(zz.wizard.reload_share);
      $('#the-list').click(function(){
        $('#you-complete-me').focus();
      });
    });     
  
  },
  
  // reloads the main share part in place of the type switcher on the share step
  reload_share: function(){
      $('#drawer-content').empty().load('/albums/'+zz.album_id+'/shares/new', function(){                        
        zz.wizard.rebind(zz.drawers.personal_album, 'share');  
        zz.drawers.personal_album.steps.share.init();                      
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

  album_update: function(){
    $.post('/albums/'+zz.album_id, $(".edit_album").serialize());
  },

  delete_identity: function(){
         //if ( confirm('Are you sure you want to delete this identity?')){
             $.post(this.value, {"_method": "delete"}, function(data){
                 $("#drawer-content").html("").html( data );
                });
         //}
  },
  update_user: function(){
             $.post(this.value, $("#update-user-form").serialize, function(data){
                 $("#drawer-content").html("").html( data );
                });
  }
};