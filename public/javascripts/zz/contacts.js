/*
 2011 Copyright ZangZing LLC.
 */

var contact_list = {
    create: function(user_id, list_element, import_buttons){
        zzcontacts.init(user_id);

        $(list_element).tokenInput( zzcontacts.find, {
            allowNewValues: true,
            hintText: "Enter email address...",
            classes: {
                tokenList: "token-input-list-facebook",
                token: "token-input-token-facebook",
                tokenDelete: "token-input-delete-token-facebook",
                selectedToken: "token-input-selected-token-facebook",
                highlightedToken: "token-input-highlighted-token-facebook",
                dropdown: "token-input-dropdown-facebook",
                dropdownItem: "token-input-dropdown-item-facebook",
                dropdownItem2: "token-input-dropdown-item2-facebook",
                selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                inputToken: "token-input-input-token-facebook"
            }
        });
    }
};



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

        var formatted_results = [];
        for( var i in results ){
            // The fields for the arrays in the results  are [ name, email ]
            var x = results[i];
            var name  = x[0];
            var email = x[1];

//            var token_text = name + " <" + email + ">";
//            var searched_text = name;
//            if( searched_text.length >0 ){
//                searched_text += ' &lt;'+email+'&gt;';
//            } else {
//                token_text = email;
//                searched_text = email;
//            }
            formatted_results[i] = { id: email, name: name + ' &lt;'+email+'&gt;' };
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
        agent.getStatus(function(status){
            if( status == agent.STATUS.READY){
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
            }
            else{
                pages.download_agent.dialog( function(){
                    agent.getStatus(function(status){
                        if(status == agent.STATUS.READY){
                            zzcontacts.import_contacts( 'local', import_success, import_failure );
                        }
                        else{
                            if( $.isFunction( import_failure) ){
                                import_failure('agent', "Please install agent.");
                            }
                        }
                    });
                });
            }
        });

    },

    is_service_linked: function( service ){
        return zzcontacts.ready && typeof( zzcontacts.data[service] ) != 'undefined';
    },

    init_contact_button: function(b){
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

//            var dialog = zzcontacts.show_importing_contacts_dialog();

            var onSuccess = function(){
                b.find('div').removeClass('off sync error').addClass('on');
                b.attr( 'title', 'Last imported a moment ago.');
                b.removeAttr('disabled');
//                dialog.close();
            };
            var onError = function(error_src,error_msg){
                b.find('div').removeClass('off sync on').addClass('error');
                b.attr( 'title', 'There was an error: '+error_msg+'.');
                b.removeAttr('disabled');
//                dialog.close();
            };


            zzcontacts.import_contacts(service, onSuccess, onError);
        });

    },

    init_buttons :function(){
        $(".contacts-btn").each( function( index, button ){
            var b = $(button);
            zzcontacts.init_contact_button(b);
        });
    },

    show_importing_contacts_dialog: function(){
        var template = '<span class="processing-photos-dialog-content"><img src="{{src}}">Importing contacts...</span>'.replace('{{src}}', path_helpers.image_url('/images/loading.gif'));
        var dialog = zz_dialog.show_dialog(template, { width:300, height: 100, modal: true, autoOpen: true, cancelButton: false });
        return dialog;
    }

};

