/*!
 * zza.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */


var zjs = document.createElement('script');
zjs.setAttribute("type","text/javascript");
zjs.setAttribute("src", "http://zza.zangzing.com/zza.js");
if (typeof zjs != "undefined")
  document.getElementsByTagName("head")[0].appendChild(zjs);

// google analytics
var _gaq = _gaq || [];
_gaq.push(['_setAccount', zza_config_GOOGLE_ANALYTICS_TOKEN]);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

// mixpanel
var mp_protocol = (("https:" == document.location.protocol) ? "https://" : "http://");
document.write(unescape("%3Cscript src='" + mp_protocol + "api.mixpanel.com/site_media/js/api/mixpanel.js' type='text/javascript'%3E%3C/script%3E"));


try {
    var mpmetrics = new MixpanelLib(zza_config_MIXPANEL_TOKEN);
} catch(err) {
    null_fn = function () {};
    var mpmetrics = {  track: null_fn,  track_funnel: null_fn,  register: null_fn,  register_once: null_fn, register_funnel: null_fn };
}

// mixpanel super properties
mpmetrics.register({'referrer': document.referrer});

// ZZA
_zza = new ZZA(zza_config_ZZA_ID, null, true);
_zza.init();

$(window).bind('beforeunload', function() {
	_zza.close();
});

// ZZA wrapper
var ZZAT = {
    track : function(event, properties){

        if(typeof(properties) == 'undefined'){
			_zza.track_event2(event, null);

			// google
            _gaq.push(['_trackPageview', '/event/' + event]);
            _gaq.push(['_trackEvent', 'potd', event])

            if(typeof(console) != 'undefined'){
                console.log('ZZA event: ' + event)
            }
        }
        else{
			_zza.track_event2(event, properties);

			// google
            var query_string = '?'
            for (var name in properties){
                query_string += name + '=' + properties[name] + '&';
            }
            query_string = query_string.substring(0,query_string.length-1); //remove trailing '&'

            _gaq.push(['_trackPageview', '/event/' + event + query_string]);
            _gaq.push(['_trackEvent', 'potd', event])

            if(typeof(console) != 'undefined'){
                console.log('ZZA event: ' + event)
                console.log('ZZA properties: ' + properties)
            }
        }
    }
}
ZZAT.track('page.visit',{ua: navigator.userAgent});

/*
$("#facebook_b").click(function(){
ZZA.track('button.facebook.click');
});
*/

