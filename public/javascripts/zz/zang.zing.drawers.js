/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {
    
  personal_album: {
  
    first: 'add',
    next_element: '#next-button',
    percent: 0.0,
    time: 600,
 
    steps: {
    
      add: {
        id: 'add',
        next: 'name',
        element: '#wizard-add',
        info: 'Add Photo Step',
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
        element: '#wizard-name',
        info: 'Name Step',
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
        element: '#wizard-edit',
        info: 'Edit Step',
        type: 'partial',
        
        init: function(){
          zz.wizard.load_images();
        },
        
        bounce: function() {
          zz.open_drawer();
        }

      },
    
      share: {
        id: 'share',
        next: 0,
        id: 4,
        element: '#wizard-share',
        info: 'Share Step',
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