/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {
      
  personal_album: {
  
    first: 'add',
    last: 'share',
    next_element: '#next-step',
    percent: 0.0,
    time: 600,
    redirect: '/albums/$$',
    redirect_type: 'album',
 
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
        next: 'share',
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
    }
  }

};