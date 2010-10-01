/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {
      
  personal_album: {
  
    // set up the album variables
    style: 'create', // or edit
    first: 'add',
    last: 'share',
    next_element: '#next-step',
    percent: 0.0,
    time: 600,
    redirect: '/albums/$$/photos',
    redirect_type: 'album',
 
    // set up the wizard steps
    steps: {
    
      add: {
        id: 'add',
        next: 'name',
        title: 'Add Photos',
        type: 'full',
        url: '/albums/$$/add_photos',
        url_type: 'album',

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
        url: '/albums/$$/name_album',
        url_type: 'album',

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
        next: 'privacy',
        title: 'Edit Album',
        type: 'partial',
        url: '/albums/$$/edit',
        url_type: 'album',
                
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
        url: '/albums/$$/privacy',
        url_type: 'album',
        
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
        url: '/albums/$$/shares/new',
        url_type: 'album',
        
        init: function(){
          $('.social-share').click(zz.wizard.social_share);
          $('.email-share').click(zz.wizard.email_share);
          $('.album_privacy').change(zz.wizard.album_update);        
        },
        
        bounce: function(){
        
        }

      } 
    
    } // end zz.drawers.personal_album.steps
    
  } // end zz.drawers.personal_album


}; // end zz.drawers