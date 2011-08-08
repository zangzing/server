/*!
 * logging.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */
var zz = zz || {};

zz.logger = {

    debug: function(message) {
        if (typeof(console) != 'undefined') {
            console.log(message);
        }

    }
};

