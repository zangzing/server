/*!
 * logging.js
 *
 * Copyright 2011, ZangZing LLC. All rights reserved.
 */


var logger = {

    debug: function(message)
    {
        if(typeof(console) != "undefined")
        {
            console.log(message)
        }

    }
}

