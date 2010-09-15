/* AJAX 'obj' objects  -- NOT YET IN USE TODO
--------------------------------------------------------------------------- */
zang.ajax: {
  
  //makes ajax calls purdy: zang.new_ajax(zang.ajax_obj.sample_a);
  
  sample_a: {
    params: 'format=json',
    type: 'GET',
    url: '/get/json/data.js',
    maxtries: 4,
    onsuccess: function(data){
      // zang.zang.some.function();
    },
    onerror: function(data) {
      // zang.zang.some.function();
    }
  },
  
  sample_l: {
    url: '/get/html/output',
    maxtries: 4,
    onsuccess: function(data){
      // zang.zang.some.function();
    },
    onerror: function(data) {
      // zang.zang.some.function();
    }
  }

};