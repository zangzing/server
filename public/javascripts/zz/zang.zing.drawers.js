/* Wizard Drawer objects 
--------------------------------------------------------------------------- */
zz.drawers = {


  /* Create ***PERSONAL*** Album 
  ------------------------------------------------------------------------- */      
  personal_album: {
  
    // set up the album variables
    first: 'add', // first item in the object
    last: 'share', // last item in the object
    list_element: 'indicator', // 'indicator' : #indicator-4, #indicator-5, etc
    next_element: '#next-step', // alternately, 'none' shows no next/done btn
    numbers: 1, // 1 = show the number images, 0 = don't
    percent: 0.0, // how far to fade the page contents when opening the drawer
    style: 'create', // create or edit
    time: 600, // how fast to open the drawer
    redirect: '/albums/$$/photos', // where do we go when we're done
    redirect_type: 'album', // replace $$ w/the id of the album or user
 
    // set up the wizard steps
    steps: {
    
      add: { 
        next: 'name', // next in line
        title: 'Add Photos', // link text
        type: 'full', // drawer position - full(y open) or partial(ly open)
        url: '/albums/$$/add_photos', // url of the drawer template
        url_type: 'album', // replace $$ w/the id of the album or user

        init: function(){ // run when loading the drawer up
          filechooser.init(); 
          setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
          $('#user-info').css('display', 'none');
          setTimeout("$('#album-info').css('display', 'inline-block')", 200);
        },
        
        bounce: function(){ // run before you leave
          $('#added-pictures-tray').fadeOut('fast');
        }
      
      }, //end zz.drawers.personal_album.steps.add
    
      name: {
        next: 'edit',
        title: 'Name Album',
        type: 'full',
        url: '/albums/$$/name_album',
        url_type: 'album',
        
        init: function(){
         //Set The Album Name at the top of the screen
          $('h2#album-header-title').html($('#album_name').val());   
          $('#album_name').keypress( function(){
            setTimeout(function(){ $('#album-header-title').html( $('#album_name').val() ) }, 10);
          });
        },
        
        bounce: function(){
           zz.wizard.album_update();
        }
      
      }, //end zz.drawers.personal_album.steps.name

      edit: {
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

      }, //end zz.drawers.personal_album.steps.edit
      
      privacy: {
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
        
      }, //end zz.drawers.personal_album.steps.privacy
    
      share: {
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


  /* Create ***GROUP*** Album 
  ------------------------------------------------------------------------- */ 
  group_album: {
 
    // set up the album variables
    first: 'add',
    last: 'share',
    list_element: 'indicator',
    next_element: '#next-step',
    numbers: 1,
    percent: 0.0,
    style: 'create',
    time: 600,
    redirect: '/albums/$$/photos',
    redirect_type: 'album',

    // set up the wizard steps
    steps: {
    
      add: {
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
            id: 'name',
            next: 'edit',
            title: 'Name Album',
            type: 'full',
            url: '/albums/$$/name_album',
            url_type: 'album',
            init: function(){
                //Set The Album Name at the top of the screen
                $('h2#album-header-title').html($('#album_name').val());
                $('#album_name').keypress( function(){
                setTimeout(function(){ $('#album-header-title').html( $('#album_name').val() ) }, 10);
                });
            },
            bounce: function(){
               zz.wizard.album_update(); //post edit-album form
            }
      
      }, //end zz.drawers.group_album.steps.name
      
      edit: {
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

      }, //end zz.drawers.group_album.steps.edit
      
      privacy: {
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
      
      }, //end zz.drawers.group_album.steps.privacy
      
      contributors: {
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
      
      }, //end zz.drawers.group_album.steps.contributors
      
      share: {
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
      
      } //end zz.drawers.group_album.steps.share
      
    } // end zz.drawers.group_album.steps

  } // end zz.drawers.group_album

}; // end zz.drawers