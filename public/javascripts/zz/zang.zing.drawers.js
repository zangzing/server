/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {

  sample: {
    first: 'test', // steps.id of the first step
    last: 'test', // steps.id of the last step
    next_element: '#next',
    percent: 0.0,
    time: 600,
 
    steps: {
    
      test: {
        id: 'test', // nav target = 'wizard-' + id
        next: 0, // next button
        info: 'Sample Wizard Step', //not used, just for context
        type: 'full', // 'full' to load the partial in the drawer, 'partial' to load into the article
        url: '/albums/'+ zz.album_id +'/add_photos',  // first step url

        init: function(){ // run this after the partial has loaded
          filechooser.init(); 
          setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
          $('#user-info').css('display', 'none');
          setTimeout("$('#album-info').css('display', 'inline-block')", 200);
        },
        
        bounce: function(){ // run this before loading the next view
          $('#added-pictures-tray').fadeOut('fast');
        }
      
      }
      
    }
     
  },
      
  personal_album: {
  
    first: 'add',
    last: 'share',
    next_element: '#wizard-next',
    percent: 0.0,
    time: 600,
 
    steps: {
    
      add: {
        id: 'add',
        next: 'name',
        title: 'Add Photos',
        type: 'full',
        url: '/albums/'+ zz.album_id +'/add_photos',

        init: function(){
          filechooser.init(); 
          setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
          $('#user-info').css('display', 'none');
          setTimeout("$('#album-info').css('display', 'inline-block')", 200);
        },
        
        bounce: function(){
          $('#added-pictures-tray').fadeOut('fast');
        }
      
      },
    
      name: {
        id: 'name',
        next: 'edit',
        title: 'Name Album',
        type: 'full',

        init: function(){
          $('#album_name').keypress( function(){
            setTimeout(function(){ $('#album-header-title').html( $('#album_name').val() ) }, 10);
          });
        },
        
        bounce: function(){
          //post form
          serialized = $(".edit_album").serialize();
          value = $('#album_name').val();
          $('h2#album-header-title').html(value);
          $.post('/albums/'+zz.album_id, serialized);
        }

      },
    
      edit: {
        id: 'edit',        
        next: 'share',
        title: 'Edit Album',
        type: 'partial',
        
        init: function(){
          zz.wizard.load_images();
        },
        
        bounce: function() {
          zz.open_drawer();
        }

      },
      
      privacy: {
        id: 'privacy',
        next: 'share',
        title: 'Album Privacy',
        type: 'full',

        init: function(){

        },
        
        bounce: function(){

        }      
      },
    
      share: {
        id: 'share',
        next: 0,
        title: 'Share Album',
        type: 'full',

        init: function(){
          $('.social-share').click(zz.wizard.social_share);
          $('.email-share').click(zz.wizard.email_share);
          $('.album_privacy').change(zz.wizard.album_update);        
        },
        
        bounce: function(){
        
        }

      }
    }
  }

};