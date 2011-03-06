/*
    2011 Copyright ZangZing LLC.
 */

zzcontacts ={
    ready: false,
    raw_data : [],
    search_tree: [],
    settings: {},

    init: function(userId, options){
        var self = this;
        self.settings = $.extend({
            url: '/users/userId/contacts.json',
            minChars: 1
        }, options);
        self.load_contacts();
    },

    load_contacts: function(){
        $.ajax({
               type: 'GET',
               url: zzcontacts.settings.url,
               dataType: 'json',
               success: function(json){
                  zzcontacts.raw_data = json;
                  zzcontacts.ready = true;
               },
               error: function(){}
        });
    },

    /*
    create_search_tree: function( contact_array ){
        zzcontacts.search_tree = [];
        for( var i in contact_array ){
            var contact = contact_array[i];
            // The fields for the rows in the contact array  are [ id, name, email ]
            // Use the first minChars of the name and the email as the index for the search tree
            name_idx  = contact[1].substring(0, zzcontacts.settings.minChars).toLowerCase();
            email_idx = contact[2].substring(0, zzcontacts.settings.minChars).toLowerCase();

             // if the results array for this index does not exist, create it now
            if( name_idx.length > 0 ){
                if( !zzcontacts.search_tree[name_idx] ){  zzcontacts.search_tree[name_idx] = [];}
                zzcontacts.search_tree[name_idx].push(contact);
            }

            // If the name_idx and email_idx are the same, add the contact to the
            // results array for this index once (done above), otherwise add it once by name_idx and
            // once by email_idx (below). This allows searches by name or email
            if( email_idx.length > 0 && name_idx != email_idx ){
                if( !zzcontacts.search_tree[email_idx] ){  zzcontacts.search_tree[email_idx] = [];}
                zzcontacts.search_tree[email_idx].push(contact);
            }
        }
    },


    find: function( q ){
		if (!q) return null;
		if (zzcontacts.search_tree[q]) return zzcontacts.format_results( zzcontacts.search_tree[q]);
        
        //If there was not a direct match, try to match subsets of q
	    for (var i = q.length - 1; i >= zzcontacts.settings.minChars; i--) {
			var qs = q.substr(0, i);
			var results = zzcontacts.search_tree[qs];
			if (results) {
				var csub = [];
				for (var j = 0; j < results.length; j++) {
                    // The fields for the arrays in the results  are [ id, name, email ]
					var x = results[j];
					var name = x[1];
                    var email = x[2];
					if( zzcontacts.match_subset(name, q) || zzcontacts.match_subset( email, q) ){
						csub[csub.length] = x;
					}
				}
				return zzcontacts.format_results( csub );
			}
		}
		return null;
    },


    match_subset: function(s, sub) {
		s = s.toLowerCase();
		var i = s.indexOf(sub);
		if (i == -1) return false;
		return i == 0;
	},

*/

    find: function( q ){
		if (!zzcontacts.ready || !q) return null;
        var regex = new RegExp(q,"gi");
        var results = jQuery.grep( zzcontacts.raw_data, function(element){
            //     ( name.match(regex)       || email.match( regex ) )
            return ( element[1].match(regex) || element[2].match( regex ) );
        });
	    return zzcontacts.format_results( results );
    },


    format_results: function( results ){
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
    }
};

