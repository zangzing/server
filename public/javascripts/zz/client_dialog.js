var zz = zz || {};

zz.client_dialog = {
    show: function(alert_dialog_url) {
        if (typeof(alert_dialog_url) != 'undefined') {
            $.ajax({
                type: 'GET',
                url: alert_dialog_url,
                success: function(html) {
                    $('body').append(html);
                }
            });
        }
    }
};