/*!
 * zza.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */




function loadScript(src, sslSrc, callback){
    var script = document.createElement('script');
    script.type = 'text/javascript';

    if (script.readyState){  //IE
        script.onreadystatechange = function(){
            if (script.readyState == "loaded" || script.readyState == "complete"){
                script.onreadystatechange = null;
                if(callback){
                    callback();
                }
            }
        };
    }
    else {  //Others
        script.onload = function(){
            if(callback){
                callback();
            }
        };
    }

    script.src = ('https:' == document.location.protocol ? sslSrc : src);
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(script, firstScriptTag);
}


function initGoogle(){
    // google analytics
    loadScript('http://www.google-analytics.com/ga.js','https://ssl.google-analytics.com/ga.js', function(){
        window._gaq = window._gaq || [];
        window._gaq.push(['_setAccount', zza_config_GOOGLE_ANALYTICS_TOKEN]);
        window._gaq.push(['_trackPageview']);
    });

}


function initMixpanel(){
    loadScript('http://api.mixpanel.com/site_media/js/api/mixpanel.js','https://api.mixpanel.com/site_media/js/api/mixpanel.js', function(){
        try {
            window.mpmetrics = new MixpanelLib(zza_config_MIXPANEL_TOKEN);
            mpmetrics.register({'referrer': document.referrer});
            _zza.mixpanel_ready();
        } catch(err) {
            var null_fn = function () {};
            window.mpmetrics = {  track: null_fn,  track_funnel: null_fn,  register: null_fn,  register_once: null_fn, register_funnel: null_fn };
        }
    });
}



function initZZA(){

    $(window).bind('beforeunload', function() {
        window._zza.close();
    });

    window._zza = new ZZA(zza_config_ZZA_ID, zuserid, true);
    _zza.init();

    
    // ZZA wrapper
    window.ZZAt = {
        track : function(event, properties){

            if(typeof(properties) == 'undefined'){
                _zza.track_event2(event, null);

                // google
                if(typeof(_gaq) != 'undefined'){
                    _gaq.push(['_trackPageview', '/event/' + event]);
                    _gaq.push(['_trackEvent', 'potd', event])
                }
                if(typeof(console) != 'undefined'){
                    console.log('ZZA event: ' + event)
                }
            }
            else{
                _zza.track_event2(event, properties);

                // google
                if(typeof(_gaq) != 'undefined'){
                    var query_string = '?'
                    for (var name in properties){
                        query_string += name + '=' + properties[name] + '&';
                    }
                    query_string = query_string.substring(0,query_string.length-1); //remove trailing '&'

                    _gaq.push(['_trackPageview', '/event/' + event + query_string]);
                    _gaq.push(['_trackEvent', 'potd', event])
                }


                if(typeof(console) != 'undefined'){
                    console.log('ZZA event: ' + event)
                    console.log('ZZA properties: ' + properties)
                }
            }
        }
    };

    ZZAt.track('page.visit',{ua: navigator.userAgent});

    // have zza track all js errors
    window.onerror = function(message, url, line) {
        try{
            if(url.indexOf('http://localhost:30777') == -1){
                ZZAt.track('js.error',{message: message, url:url, line:line});
            }

        }
        catch(err){
        }
        return true;
    };
}

//init zza inline
initZZA();

//load the rest after all document ready handlers
$(document).ready(function(){
    setTimeout(function(){
        initGoogle();
        initMixpanel();
    },1);
});




