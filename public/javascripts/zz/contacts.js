/*
    2011 Copyright ZangZing LLC.
 */

zzcontacts ={
    ready: false,
    data : [],
    search_tree: [],
    settings: {},

    init: function(userId, options, onSuccess, onError){
        var self = this;
        self.settings = $.extend({
            url: zz.path_prefix + '/users/'+userId+'/contacts.json'
        }, options);

        //load contacts
        $.ajax({
               type: 'GET',
               url: zzcontacts.settings.url,
               dataType: 'json',
               success: function(json){
                  zzcontacts.data = json;
                  zzcontacts.ready = true;
                  zzcontacts.init_buttons();
                  if( $.isFunction(onSuccess)) onSuccess();
               },
               error: function(){
                  if( $.isFunction( onError) ) onError();
               }
        });
    },

    find: function( q ){
		if (!zzcontacts.ready || !q) return null;
        var regex = new RegExp(q,"gi");
        var results = [];
        for(var service in zzcontacts.data ){
            var service_results = jQuery.grep( zzcontacts.data[service].contacts, function(element){
                return ( element[0].match(regex) || element[1].match( regex ) );
            });
            results = results.concat( service_results );
        }
	    return zzcontacts._format_results( results );
    },

    _format_results: function( results ){
        var formatted_results = [];
        for( var i in results ){
            // The fields for the arrays in the results  are [ name, email ]
            var x = results[i];
            //var id = x[0];
            var name  = x[0];
            var email = x[1];
            
            var token_text = name;
            var searched_text = name;
            if( searched_text.length >0 ){
                searched_text += ' &lt;'+email+'&gt;';
            } else {
                token_text = email;
                searched_text = email;
            }
            formatted_results[i] = { id: email, name: searched_text, token_text: token_text};
        }
        return formatted_results;
    },

    import_contacts: function( service, success, failure ){
        if( !service ) return null;

        if( service == 'local'){
            zzcontacts._import_local_contacts( success, failure );
            return;
        }

        var oauth_succeeded = false;

        var import_service = function(){

            oauth_succeeded = true;

            var url = zz.path_prefix + '/'+service+'/contacts/import';
            var on_success = function(json){
                zzcontacts.data[service]= {};
                zzcontacts.data[service].contacts = json;
                zzcontacts.data[service].last_import = 'A moment ago';
                success();
            };

            var on_failure = function(jqXHR, textStatus){
                    failure( 'import', textStatus);

            };


            async_ajax.get(url, on_success, on_failure);


        };

        //if not already authorized, authorize
        if( !zzcontacts.data[service] ){
            oauthmanager.login(zz.path_prefix + '/'+service+'/sessions/new',  import_service );
            setTimeout( function(){
                if( !oauth_succeeded ){
                    // 30 seconds went by and no oauthsuccess, call error and forget it
                    failure('oauth', "OAuth authorization not possible");
                }
            },20000);
        } else {
            import_service();
        }
    },

    _import_local_contacts: function( import_success, import_failure ){
       var get_local_contacts = function( agent_present ){
           if( agent_present ){
            var url = agent.buildAgentUrl('/contacts/import');
            $.jsonp({
                url: url,
                success: function( response ){
                    zzcontacts.data['local'] = {};
                    zzcontacts.data['local'].contacts    = response.body;
                    zzcontacts.data['local'].last_import = 'A moment ago.'; //+new Date();
                    if( $.isFunction( import_success) )  import_success();
                },
                error: function( options, textStatus ){
                    if( $.isFunction( import_failure) ) import_failure('agent', textStatus);
                }
            });
           } else {
               pages.no_agent.dialog( function(){
                   agent.isAvailable( function( agent_present ){
                       if( agent_present ){
                            zzcontacts.import_contacts( 'local', import_success, import_failure );
                       } else {
                            if( $.isFunction( import_failure) ) import_failure('agent', "Please install agent.");
                       }
                   });
               });
           }
       };
       agent.isAvailable(  get_local_contacts );
    },

    is_service_linked: function( service ){
        return zzcontacts.ready && typeof( zzcontacts.data[service] ) != 'undefined';
    },

    init_buttons :function(){
        $(".contacts-btn").each( function( index, button ){
            var b = $(button);
            var service = b.attr('data-service');
            if( service === 'local' && $.client.os === 'Mac' ){
                b.find('span').html( '<div class="off"></div>Mac Address Book');
            }
            if( zzcontacts.is_service_linked(service)){
                b.find('div').removeClass('off sync error').addClass('on');
                b.attr( 'title', 'Last import on:'+zzcontacts.data[service].last_import);
            }else{
                b.attr( 'title', 'Click to import your contacts from this service');
            }
            b.click( function(e){
                e.preventDefault();
                b.attr('disabled', 'disabled');
                b.find('div').removeClass('off on error').addClass('sync');
                var onSuccess = function(){
                    b.find('div').removeClass('off sync error').addClass('on');
                    b.attr( 'title', 'Last imported a moment ago.');
                    b.removeAttr('disabled');
                };
                var onError = function(error_src,error_msg){
                    b.find('div').removeClass('off sync on').addClass('error');
                    b.attr( 'title', 'There was an error: '+error_msg+'.');
                    b.removeAttr('disabled');
                };
                zzcontacts.import_contacts(service, onSuccess, onError);
            });
        });
    }
};

