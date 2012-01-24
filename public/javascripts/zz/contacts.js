var zz = zz || {};

zz.contact_list =  {};

(function(){

    var MAX_SEARCH_RESULTS = 8;

    // from from jquery.validate.js
    var EMAIL_REGEX_SHORT = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i;

    // matches long email addresses, with display name. essentially: .*<EMAIL_REGEX_SHORT>
    var EMAIL_REGEX_LONG = /^.*<((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?>$/i;


    var current_list_element = null;

    zz.contact_list.create = function(user_id, list_element, import_buttons) {
        current_list_element = list_element;

        var self = this;

        zz.contacts.init(user_id);


        $(list_element).tokenInput(zz.contacts.find, {
            allowNewValues: true,
            hintText: 'Enter email address',
            searchDelay: 0,
            validate: function(value) {
                value = $.trim(value);
                return EMAIL_REGEX_SHORT.test(value) || EMAIL_REGEX_LONG.test(value);
            },
            classes: {
                tokenList: 'token-input-list-facebook',
                token: 'token-input-token-facebook',
                tokenDelete: 'token-input-delete-token-facebook',
                selectedToken: 'token-input-selected-token-facebook',
                highlightedToken: 'token-input-highlighted-token-facebook',
                dropdown: 'token-input-dropdown-facebook',
                dropdownItem: 'token-input-dropdown-item-facebook',
                dropdownItem2: 'token-input-dropdown-item2-facebook',
                selectedDropdownItem: 'token-input-selected-dropdown-item-facebook',
                inputToken: 'token-input-input-token-facebook'
            }
        });
    };

    zz.contact_list.has_errors = function(){
        return $('li.token-input-token-facebook.error').length > 0;
    };

    zz.contact_list.get_email_addresses = function(){
        var email_list = current_list_element.val()
        if(email_list == ""){
            return [];
        }
        else{
            return email_list.split(',');
        }
    };

    zz.contact_list.clear = function(){
        current_list_element.data().tokeninput.list.empty()
    };



})();


(function(){

    zz.contacts = {
        ready: false,
        data: [],
        search_tree: [],
        settings: {},

        init: function(userId, options, onSuccess, onError) {
            var self = this;
            self.settings = $.extend({
                url: zz.routes.path_prefix + '/users/' + userId + '/contacts.json'
            }, options);

            //load contacts
            $.ajax({
                type: 'GET',
                url: zz.contacts.settings.url,
                dataType: 'json',
                success: function(json) {
                    zz.contacts.data = json;
                    zz.contacts.ready = true;
                    zz.contacts.init_buttons();
                    if ($.isFunction(onSuccess)) onSuccess();
                },
                error: function() {
                    if ($.isFunction(onError)) onError();
                }
            });
        },

        find: function(q) {
            if (!zz.contacts.ready || !q) return null;
            var regex = new RegExp(q, 'gi');
            var results = [];
            for (var service in zz.contacts.data) {
                var service_results = jQuery.grep(zz.contacts.data[service].contacts, function(element) {
                    return (element[0].match(regex) || element[1].match(regex));
                });
                results = results.concat(service_results);
            }

            var formatted_results = [];
            for (var i in results) {
                // The fields for the arrays in the results  are [ name, email ]
                var x = results[i];
                var name = x[0];
                var email = x[1];

//            var token_text = name + " <" + email + ">";
//            var searched_text = name;
//            if( searched_text.length >0 ){
//                searched_text += ' &lt;'+email+'&gt;';
//            } else {
//                token_text = email;
//                searched_text = email;
//            }
                formatted_results[i] = { id: email, name: name + ' &lt;' + email + '&gt;' };

                if (i == zz.contact_list.MAX_SEARCH_RESULTS) {
                    break;
                }
            }
            return formatted_results;
        },

        import_contacts: function(service, success, failure) {
            if (!service) return null;

            if (service == 'local') {
                zz.contacts._import_local_contacts(success, failure);
                return;
            }

            var oauth_succeeded = false;

            var import_service = function() {

                oauth_succeeded = true;

                var dialog = zz.dialog.show_progress_dialog('Importing contacts...');


                var url = zz.routes.path_prefix + '/' + service + '/contacts/import';
                var on_success = function(json) {
                    zz.contacts.data[service] = {};
                    zz.contacts.data[service].contacts = json;
                    zz.contacts.data[service].last_import = 'A moment ago';
                    dialog.close();
                    success();
                };

                var on_failure = function(jqXHR, textStatus) {
                    dialog.close();
                    failure('import', textStatus);
                };


                zz.async_ajax.get(url, on_success, on_failure);


            };

            //if not already authorized, authorize
            if (!zz.contacts.data[service]) {
                zz.oauthmanager.login(zz.routes.path_prefix + '/' + service + '/sessions/new', import_service);
                setTimeout(function() {
                    if (!oauth_succeeded) {
                        // 30 seconds went by and no oauthsuccess, call error and forget it
                        failure('oauth', 'OAuth authorization not possible');
                    }
                }, 20000);
            } else {
                import_service();
            }
        },

        _import_local_contacts: function(import_success, import_failure) {
            var dialog = zz.dialog.show_progress_dialog('Importing contacts...');


            zz.agent.getStatus(function(status) {
                if (status == zz.agent.STATUS.READY) {
                    var url = zz.agent.buildAgentUrl('/contacts/import');
                    $.jsonp({
                        url: url,
                        success: function(response) {
                            zz.contacts.data['local'] = {};
                            zz.contacts.data['local'].contacts = response.body;
                            zz.contacts.data['local'].last_import = 'A moment ago.'; //+new Date();
                            dialog.close();
                            if ($.isFunction(import_success)) import_success();
                        },
                        error: function(options, textStatus) {
                            if ($.isFunction(import_failure)) import_failure('agent', textStatus);
                            dialog.close();
                        }
                    });
                }
                else {
                    dialog.close();

                    zz.pages.download_agent.dialog(function() {
                        zz.agent.getStatus(function(status) {
                            if (status == zz.agent.STATUS.READY) {
                                zz.contacts.import_contacts('local', import_success, import_failure);
                            }
                            else {
                                if ($.isFunction(import_failure)) {
                                    import_failure('agent', 'Please install agent.');
                                }
                            }
                        });
                    });
                }
            });

        },

        is_service_linked: function(service) {
            return zz.contacts.ready && typeof(zz.contacts.data[service]) != 'undefined';
        },

        init_contact_button: function(b) {
            var service = b.attr('data-service');
            if (service === 'local') {
                if ($.client.os === 'Mac') {
                    b.find('span').html('<div class="off"></div>Mac Address Book');
                }
                else {
                    b.find('span').html('<div class="off"></div>Outlook Address Book');
                }
            }

            if (zz.contacts.is_service_linked(service)) {
                b.find('div').removeClass('off sync error').addClass('on');
                b.attr('title', 'Last import on:' + zz.contacts.data[service].last_import);
            } else {
                b.attr('title', 'Click to import your contacts from this service');
            }
            b.click(function(e) {
                e.preventDefault();
                b.attr('disabled', 'disabled');
                b.find('div').removeClass('off on error').addClass('sync');

//            var dialog = zz.contacts.show_importing_contacts_dialog();

                var onSuccess = function() {
                    b.find('div').removeClass('off sync error').addClass('on');
                    b.attr('title', 'Last imported a moment ago.');
                    b.removeAttr('disabled');
//                dialog.close();
                };
                var onError = function(error_src, error_msg) {
                    b.find('div').removeClass('off sync on').addClass('error');
                    b.attr('title', 'There was an error: ' + error_msg + '.');
                    b.removeAttr('disabled');
//                dialog.close();
                };


                zz.contacts.import_contacts(service, onSuccess, onError);
            });

        },

        init_buttons: function() {
            $('.contacts-btn').each(function(index, button) {
                var b = $(button);
                zz.contacts.init_contact_button(b);
            });
        }



    };

})();
