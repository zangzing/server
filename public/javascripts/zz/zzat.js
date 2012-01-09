/*!
 * zza.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */

(function() {
    function loadScript(src, sslSrc, callback) {
        var script = document.createElement('script');
        script.type = 'text/javascript';

        if (script.readyState) {  //IE
            script.onreadystatechange = function() {
                if (script.readyState == 'loaded' || script.readyState == 'complete') {
                    script.onreadystatechange = null;
                    if (callback) {
                        callback();
                    }
                }
            };
        }
        else {  //Others
            script.onload = function() {
                if (callback) {
                    callback();
                }
            };
        }

        script.src = ('https:' == document.location.protocol ? sslSrc : src);
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(script, firstScriptTag);
    }


    function initGoogle() {
        window._gaq = window._gaq || [];
        window._gaq.push(['_setAccount', zz.zza_config.GOOGLE_ANALYTICS_TOKEN]);
        window._gaq.push(['_trackPageview']);
        $(document).ready(function() {
            loadScript('http://www.google-analytics.com/ga.js', 'https://ssl.google-analytics.com/ga.js', function() {
            });
        });
    }


    function initMixpanel() {
        window.mpq = window.mpq || [];
        window.mpq.push(['init', zz.zza_config.MIXPANEL_TOKEN]);
        window.mpq.push(['register', 'referrer', document.referrer]);
        $(document).ready(function() {
            loadScript('http://api.mixpanel.com/site_media/js/api/mixpanel.js', 'https://api.mixpanel.com/site_media/js/api/mixpanel.js', function() {
            });
        });
    }


    function initZZA() {

        $(window).bind('beforeunload', function() {
            window._zza.close();
        });

        window._zza = new ZZA(zz.zza_config.ZZA_ID, zz.zza_config.user_id, true);
        _zza.init();


        // ZZA wrapper
        window.ZZAt = {
            track: function(event, properties) {

                if (typeof(properties) == 'undefined') {
                    _zza.track_event2(event, null);

                    if (typeof(console) != 'undefined') {
                        console.log('ZZA event: ' + event);
                    }
                }
                else {
                    _zza.track_event2(event, properties);

                    if (typeof(console) != 'undefined') {
                        console.log('ZZA event: ' + event);
                        console.log('ZZA properties: ' + properties);
                    }
                }
            }
        };


        // have zza track all js errors
        window.onerror = function(message, url, line) {
            try {
                if (url.indexOf('http://localhost:30777') == -1 && url.indexOf('http://localhost:30778') == -1) {
                    ZZAt.track('js.error', {message: message, url: url, line: line});
                    if (typeof(console) != 'undefined') {
                        console.log('ZZ Javascript error: ' + message + ' on: '+url+':'+line);
                    }

                    // if we are not running on production, then show error alert
                    // so that we see the problem
                    if(zz.config && zz.config.rails_env != 'photos_production'){
                        alert('unexpected javascript error:\n' + message + '\n' + url + '\n' + line);
                    }
                }

            }
            catch (err) {
            }
            return true;
        };
    }

    initZZA();
    initGoogle();
    initMixpanel();

})();


ZZAt.track('page.visit', {ua: navigator.userAgent});




