var zz = zz || {};

zz.welcome = {
    show_welcome_dialog: function() {
        $('<iframe frameborder="0" height="450" width="780" border="0" src="/static/welcome_dialog/index.html"></iframe>').zz_dialog({
            height: 420,
            width: 750,
            modal: true,
            autoOpen: true
        });
    }
};
