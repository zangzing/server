var zz = zz || {};
zz.local_storage = zz.local_storage || {};

(function(){

    zz.local_storage.set = function(name, value){
        window.localStorage.setItem(name, value);
    };

    zz.local_storage.get = function(name){
        return window.localStorage.getItem(name);
    };

    zz.local_storage.remove = function(name){
        window.localStorage.removeItem(name);
    };

})();

