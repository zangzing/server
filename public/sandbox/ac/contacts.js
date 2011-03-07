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
            url: '/users/userId/contacts.json',
            minChars: 1
        }, options);

        //load contacts
        $.ajax({
               type: 'GET',
               url: zzcontacts.settings.url,
               dataType: 'json',
               success: function(json){
                  zzcontacts.data = json;
                  zzcontacts.ready = true;
                  onSuccess();
               },
               error: function(){
                  onError();
               }
        });
    },

    find: function( q ){
		if (!zzcontacts.ready || !q) return null;
        var regex = new RegExp(q,"gi");
        var results = [];
        for(var service in zzcontacts.data ){
            var service_results = jQuery.grep( zzcontacts.data[service].contacts, function(element){
                //     ( name.match(regex)       || email.match( regex ) )
                return ( element[1].match(regex) || element[2].match( regex ) );
            });
            results = results.concat( service_results );
        }
	    return zzcontacts._format_results( results );
    },

    _format_results: function( results ){
        var formatted_results = [];
        for( var i in results ){
            // The fields for the arrays in the results  are [ id, name, email ]
            var x = results[i];
            var id = x[0];
            var name  = x[1];
            var email = x[2];
            var token = name;
            var display_name = name;
            if( display_name.length >0 ){
                display_name += ' &lt;'+email+'&gt;';
            } else {
                token = email;
                display_name = email;
            }
            formatted_results[i] = { id: id, name: display_name, token_text: token};
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
            $.ajax({
                dataType: 'json',
                url: '/'+service+'/contacts/import',
                success: function(json){
                    zzcontacts.data[service]= {};
                    zzcontacts.data[service].contacts    = json;
                    zzcontacts.data[service].last_import = 'A moment ago'; //+new Date();
                    success();
                },
                error: function(jqXHR, textStatus){
                    failure( 'import', textStatus);
                }
            });
        };

        //if not already authorized, authorize
        if( !zzcontacts.data[service] ){
            oauthmanager.login('/'+service+'/sessions/new',  import_service );
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
                    import_success();
                },
                error: function( options, textStatus ){
                    import_failure('agent-yes', textStatus)
                }
            });
           } else {
                  import_failure('agent-NOT', 'Agent is not present!');
           }
       };
       agent.isAvailable(  get_local_contacts );
    },

    is_service_linked: function( service ){
        return zzcontacts.ready && typeof( zzcontacts.data[service] ) != 'undefined';
    }
};

