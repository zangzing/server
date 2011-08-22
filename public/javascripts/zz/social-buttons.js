var zz = zz || {};


(function(){

    zz.social_buttons = {};

    var TWITTER_TEMPLATE = '<iframe allowtransparency="true" frameborder="0" scrolling="no" src="http://platform.twitter.com/widgets/tweet_button.html?count=horizontal&related=ZangZing&url={{url}}&text={{text}}" style="width:130px; height:50px;"></iframe>'

    var FACEBOOK_TEMPLATE = '<iframe src="http://www.facebook.com/plugins/like.php?app_id={{app_id}}&amp;href={{url}}&amp;send=false&amp;layout=button_count&amp;width=450&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:130px; height:21px;" allowTransparency="true"></iframe>'

    zz.social_buttons.create_twitter_button_for_photo = function(url){
        var message = 'Check out this photo on ZangZing';
        var template = TWITTER_TEMPLATE.replace('{{url}}', encodeURIComponent(url)).replace('{{text}}', encodeURIComponent(message));
        return $(template);
    };


    zz.social_buttons.create_facebook_button_for_photo = function(url){
        var template = FACEBOOK_TEMPLATE.replace('{{url}}', encodeURIComponent(url)).replace('{{app_id}}', zz.config.facebook_app_id);
        return $(template);
    };


})();
