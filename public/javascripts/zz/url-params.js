var zz = zz || {};

zz.page = zz.page || {};
zz.page.url_params = {};


// from: http://stackoverflow.com/questions/901115/get-query-string-values-in-javascript

(function () {
    var e,
        a = /\+/g,  // Regex for replacing addition symbol with a space
        r = /([^&=]+)=?([^&]*)/g,
        d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
        q = window.location.search.substring(1);

    while (e = r.exec(q))
       zz.page.url_params[d(e[1])] = d(e[2]);
})();