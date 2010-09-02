var sharecontacts = {
    setup : function(hasGoogleId, googleLastImport, hasYahooId, yahooLastImport) {
         //console.lob("in contacts setup");
        if (hasGoogleId) {
            $("#gmail-sync").click(sharecontacts.call_google_import);
            $("#gmail-sync").attr({title: 'Last import on: '+googleLastImport, src: '/images/btn-gmail-on.png'});
        } else {
            $("#gmail-sync").click(sharecontacts.call_new_google_session);
            $("#gmail-sync").attr('title', 'Authorize access to your gmail account and import contacts');
        }

        if (hasYahooId) {
            $("#yahoo-sync").click(sharecontacts.call_yahoo_import);
            $("#yahoo-sync").attr({title: 'Last import on:'+yahooLastImport, src: '/images/btn-gmail-on.png'});
        } else {
            $("#yahoo-sync").click(sharecontacts.call_new_yahoo_session);
            $("#yahoo-sync").attr('title', 'Authorize access to your yahoo account and import contacts');
        }
        //reloadAutocompleter()
    },

    // ------ GOOGLE C ---------
    call_new_google_session : function() {
        //console.lob("in call new google session");
        $("#gmail-sync").attr('disabled', 'disabled');
        oauthmanager.login('/google/sessions/new', sharecontacts.google_login_success);
    },

    google_login_success : function() {
        //console.lob("in call google login success");
        $("#gmail-sync").unbind("click");
        $("#gmail-sync").click(sharecontacts.call_google_import);
        sharecontacts.call_google_import();
    },
    call_google_import : function() {
        //console.lob("in call google import");  
        $("#gmail-sync").attr({disabled: 'disabled', src: '/images/btn-gmail-sync.png', title: 'Refreshing...'});
        $.ajax({
            dataType: 'json',
            url: '/google/contacts/import',
            success: sharecontacts.import_google_success,
            error: sharecontacts.import_google_failure
        });
    },
    import_google_success :  function(cts) {
        //console.lob('inside google import succes');
        var full_address;
        google_contacts = [];
        for (var i = 0; i < cts.length; i++) {
            full_address = '<' + cts[i].name + '> ' + cts[i].address
            google_contacts.push([ cts[i].name, full_address]);
            google_contacts.push([ cts[i].address, full_address]);
        }
        //reloadAutocompleter();
        $("#gmail-sync").attr('disabled', '');
        $("#gmail-sync").attr('title', 'Last imported a second ago.');
        $("#gmail-sync").attr('src', '/images/btn-gmail-on.png');
    },
    import_google_failure : function(errors) {
        alert("Unable to refresh google contacts at the moment. Please try later");
        $("#gmail-sync").attr({disabled: '', src: '/images/btn-gmail-error.png', title: 'Unable to refresh gmail contacts at the moment. Please try later'});
    },

    // ------ YAHOO CONTACTS ---------
    call_new_yahoo_session : function() {
        $("#yahoo-sync").attr('disabled', 'disabled');
        oauthmanager.login('/yahoo/sessions/new', sharecontacts.yahoo_login_success);
    },
    yahoo_login_success : function() {
        $("#yahoo-sync").unbind("click");        
        $("#yahoo-sync").click(sharecontacts.call_yahoo_import);
        sharecontacts.call_yahoo_import();
    },
    call_yahoo_import : function() {
        $("#yahoo-sync").attr({disabled: 'disabled', src: '/images/btn-yahoo-sync.png', title: 'Refreshing...'});
        $.ajax({
            dataType: 'json',
            url: '/yahoo/contacts/import',
            success: sharecontacts.import_yahoo_success,
            error: sharecontacts.import_yahoo_failure
        });
    },
    import_yahoo_success : function(cts) {
        var full_address;
        yahoo_contacts = [];
        for (var i = 0; i < cts.length; i++) {
            full_address = '<' + cts[i].name + '> ' + cts[i].address;
            yahoo_contacts.push([ cts[i].name, full_address]);
            yahoo_contacts.push([ cts[i].address, full_address]);
        }
        //reloadAutocompleter()
        $("#yahoo-sync").attr('disabled', '');
        $("#yahoo-sync").attr('title', 'Last imported a second ago.');
        $("#yahoo-sync").attr('src', '/images/btn-yahoo-on.png');
    },
    import_yahoo_failure : function( errors ){
        alert('Unable to refresh yahoo contacts at the moment. Please try later');
        $("#yahoo-sync").attr({disabled: '', src: '/images/btn-yahoo-error.png', title: 'Unable to refresh yahoo contacts at the moment. Please try later'});

    }
};
var google_contacts = [ "ZZangZZing"];
var yahoo_contacts = [ "ZZZangZZZing" ];

