/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {
    
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