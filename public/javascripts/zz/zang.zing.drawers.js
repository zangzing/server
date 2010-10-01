/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {


  /* Create PERSONAL Album 
  ------------------------------------------------------------------------- */      
  personal_album: {
    // set up the album variables
    style: 'create', // or edit
    first: 'add',
    last: 'share',
    list_element: 'indicator', // 'indicator' becomes #indicator-5 etc
    next_element: 'none',
    percent: 0.0,
    time: 600,
    redirect: '/albums/$$/photos',
    redirect_type: 'album',
 
    // set up the wizard steps
    steps: {
    
      add: {  //personal album
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
    
      name: {  //personal album
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
           zz.wizard.album_update()
        }
      
      },

      edit: {  //personal album
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
      
      privacy: {  //personal album
        next: 'share',
        title: 'Album Privacy',
        type: 'full',
        url: '/albums/$$/privacy',
        url_type: 'album',
        
        init: function(){
          $('.album_privacy').change(zz.wizard.album_update);
        },
        
        bounce: function(){          
        }      
      },
    
      share: {   //personal album
        next: 0,
        title: 'Share Album',
        type: 'full',
        url: '/albums/$$/shares/new',
        url_type: 'album',
        
        init: function(){
          $('.social-share').click(zz.wizard.social_share);
          $('.email-share').click(zz.wizard.email_share);
        },
        bounce: function(){
        }
      } //end zz.drawers.personal_album.steps.share
    
    } // end zz.drawers.personal_album.steps
    
  }, // end zz.drawers.personal_album


  /* Create GROUP Album 
  ------------------------------------------------------------------------- */ 
  group_album: {
 
    // set up the album variables
    first: 'add',
    last: 'share',
    list_element: 'indicator', // 'indicator' becomes #indicator-5 etc
    next_element: '#next-step',
    percent: 0.0,
    time: 600,
    redirect: '/albums/$$/photos',
    redirect_type: 'album',

    // set up the wizard steps
    steps: {
    
      add: {  //group album
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
      
      name: {  //group album
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
           zz.wizard.album_update(); //post edit-album form
            }
      
      },
      
      edit: {    //group album
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
      
      privacy: {   //group album
        next: 'contributors',
        title: 'Privacy',
        type: 'full',
        url: '/albums/$$/privacy',
        url_type: 'album',
       
        init: function(){
            $('.album_privacy').change(zz.wizard.album_update);
        },
      
        bounce: function(){
        }
      
      },
      
      contributors: { // group album
        next: 'share',
        title: 'Contributors',
        type: 'full',
        url: '/albums/$$/contributors/new',
        url_type: 'album',
      
        init: function(){
            setTimeout(function(){zz.wizard.email_autocomplete()}, 500);
            $(z.validate.new_contributors.element).validate(z.validate.new_contributors);
            $('#the-list').click(function(){ $('#you-complete-me').focus();});
        },
      
        bounce: function() {
        }
      
      },
      
      share: {  // group album 
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
      
    } // end zz.drawers.group_album.steps

  } // end zz.drawers.group_album

}; // end zz.drawers