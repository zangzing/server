var zz = zz || {};
zz.local_storage = zz.local_storage || {};

(function(){

    var cache = {};

    zz.local_storage.set = function(name, value){
        cache[name] = value;
        window.localStorage.setItem(name, JSON.stringify(value));
    };

    zz.local_storage.get = function(name){
        if(!cache[name]){
            var value = window.localStorage.getItem(name);
            if (value == ""){
                value = null;
            }
            try{
                cache[name] = JSON.parse(value);
            }
            catch(err){
                cache[name] = value;  // must be raw value not json
            }
        }
        return cache[name];
    };

    zz.local_storage.remove = function(name){
        cache[name] = null;
        window.localStorage.removeItem(name);
    };

    zz.local_storage.clear = function(){
        cache = {};
        window.localStorage.clear();
    };

    zz.local_storage.debug = function(){
        return cache;
    };

    zz.local_storage.set_album_sort = function( album_id, sort ){
        zz.local_storage.set( 'sort_'+album_id, sort);
    };

    zz.local_storage.get_album_sort = function( album_id ){
        var sort = zz.local_storage.get( 'sort_'+album_id );

        if( sort ){
            return sort;
        }else{
            return 'date-asc';
        }
    }
})();

