var pages = {}

pages.album_add_photos_tab = {
    init: function(){
        filechooser.init();
        setTimeout('$("#added-pictures-tray").fadeIn("fast")', 300);
    },

    bounce: function(){
        $('#added-pictures-tray').fadeOut('fast');
    }
}



pages.album_name_tab = {
    init: function(){
        //Set The Album Name at the top of the screen
        $('h2#album-header-title').html($('#album_name').val());
//        $('#album_email').val( zz.wizard.dashify($('#album_name').val()));
        $('#album_name').keypress( function(){
            setTimeout(function(){
                $('#album-header-title').html( $('#album_name').val() );
//                $('#album_email').val( zz.wizard.dashify($('#album_name').val()) );
            }, 10);
        });
        setTimeout(function(){$('#album_name').select();},100);


        //setup album cover picker
        $.ajax({
            dataType: 'json',
            url: '/albums/' + zz.album_id + '/photos.json',
            success: function(json){
                var selectedIndex=-1;
                var currentId = $('#album_cover_photo').val();
                var photos = $.map(json, function(element, index){
                    var id = element.id;

                    if(id == currentId){
                        selectedIndex = index;
                    }
                    var src;
                    if(element.state === 'ready'){
                        src = element.thumb_url;
                    }
                    else{
                        src = element.source_thumb_url;
                    }

                    if (agent.isAgentUrl(src)){
                        src = agent.buildAgentUrl(src);
                    }

                    return {id:id, src:src};
                });

                $("#album-cover-picker").zz_thumbtray({
                       photos:photos,
                       showSelection:true,
                       selectedIndex:selectedIndex,
                       onSelectPhoto: function(index, photo){
                           var photo_id = '';
                           if(index!==-1){
                              photo_id = photo.id
                           }
                           $('#album_cover_photo').val(photo_id);
                       }
                  });
            }
        });

    },

    bounce: function(){
        zz.wizard.update_album();
    }
}


pages.edit_album_tab = {
    init: function(){
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

    bounce: function(){
        zz.open_drawer();
    }

}

pages.album_privacy_tab = {
    init: function(){
        $('#privacy-public').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                $('#privacy-public img.select-button').attr('src', '/images/btn-round-selected-on.png');
            });
        });
        $('#privacy-hidden').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
            $('#privacy-hidden img.select-button').attr('src', '/images/btn-round-selected-on.png');
        });
        $('#privacy-password').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
            $('#privacy-password img.select-button').attr('src', '/images/btn-round-selected-on.png');
        });
    },

    bounce: function(){

    }
}

pages.album_privacy_tab = {
    init: function(){
        $('#privacy-public').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=public', function(){
                $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
                $('#privacy-public img.select-button').attr('src', '/images/btn-round-selected-on.png');
            });
        });
        $('#privacy-hidden').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=hidden');
            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
            $('#privacy-hidden img.select-button').attr('src', '/images/btn-round-selected-on.png');
        });
        $('#privacy-password').click(function(){
            $.post('/albums/'+zz.album_id, '_method=put&album%5Bprivacy%5D=password');
            $('img.select-button').attr('src', '/images/btn-round-selected-off.png');
            $('#privacy-password img.select-button').attr('src', '/images/btn-round-selected-on.png');
        });
    },

    bounce: function(){

    }
}

pages.album_share_tab = {
    init: function(){
        $('.social-share').click(function(){zz.wizard.social_share(zz.drawers.personal_album, 'share')});
        $('.email-share').click(function(){zz.wizard.email_share(zz.drawers.personal_album, 'share')});
    }, 

    bounce: function(){

    }


}

pages.album_contributors_tab = {
    init: function(){
        $('#add-contributors-btn').click(function(){zz.wizard.show_new_contributors();});
    },

    bounce: function(){

    }

}