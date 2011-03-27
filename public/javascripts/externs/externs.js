//var zz = {};
//
//
//zz.current_user_id = {};
//zz.current_user_name = {};
//zz.displayed_user_id = {};
//zz.album_id = {};
//zz.album_type = {};
//zz.album_lastmod = {};
//zz.album_type = {};
//zz.album_base_url = {};
//zz.album_name = {};
//zz.rails_controller_name = {};
//zz.rails_action_name = {};
//zz.rails_authenticity_token = {};



var ZZA = function(){};
ZZA.init = function(){};
ZZA.track_event = function(){};
ZZA.track_event2 = function(){};
ZZA.track_event_from_user = function(){};
ZZA.track_event_from_visitor = function(){};
ZZA.close = function(){};
ZZA.count = function(){};
ZZA.pushed_count = function(){};


/*
* Copyright 2010 The Closure Compiler Authors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/**
* @fileoverview Externs for jQuery 1.4.4.
* Note that some functions use different return types depending on the number
* of parameters passed in. In these cases, you may need to annotate the type
* of the result in your code, so the JSCompiler understands which type you're
* expecting. For example:
*    <code>var elt = /** @type {Element} * / (foo.get(0));</code>
* @see http://api.jquery.com/
* @externs
*/

/** @typedef {(Window|Document|Element|Array.<Element>|string|jQueryObject)} */
var jQuerySelector;

/**
 * @param {(jQuerySelector|Element|Array|Object|string|function())=} arg1
 * @param {(Element|jQueryObject|Document|Object)=} arg2
 * @return {jQueryObject}
 */
function $(arg1, arg2) {};

/**
 * @param {(jQuerySelector|Element|Array|Object|string|function())=} arg1
 * @param {(Element|jQueryObject|Document|Object)=} arg2
 * @return {jQueryObject}
 */
function jQuery(arg1, arg2) {};

/**
 * @param {Object.<string,*>} settings
 * @return {XMLHttpRequest}
 */
jQuery.ajax = function(settings) {};

/** @param {Object.<string,*>} options */
jQuery.ajaxSetup = function(options) {};

/** @type {boolean} */
jQuery.boxModel;

/** @type {Object.<string,*>} */
jQuery.browser;

/** @type {string} */
jQuery.browser.version;

/**
 * @param {Element} container
 * @param {Element} contained
 * @return {boolean}
 */
jQuery.contains = function(container, contained) {};

/**
 * @param {Element} elem
 * @param {string=} key
 * @param {Object=} value
 * @return {(jQueryObject|Object)}
 */
jQuery.data = function(elem, key, value) {};

/**
 * @param {Element} elem
 * @param {string=} queueName
 * @return {jQueryObject}
 */
jQuery.dequeue = function(elem, queueName) {};

/**
 * @param {Object} collection
 * @param {function(number,*)} callback
 * @return {Object}
 */
jQuery.each = function(collection, callback) {};

/** @param {string} message */
jQuery.error = function(message) {};

/**
 * @constructor
 * @param {string} eventType
 */
jQuery.event = function(eventType) {};

/** @type {Element} */
jQuery.event.prototype.currentTarget;

/** @type {*} */
jQuery.event.prototype.data;

/** @return {boolean} */
jQuery.event.prototype.isDefaultPrevented = function() {};

/** @return {boolean} */
jQuery.event.prototype.isImmediatePropagationStopped = function() {};

/** @return {boolean} */
jQuery.event.prototype.isPropagationStopped = function() {};

/** @type {string} */
jQuery.event.prototype.namespace;

/** @type {number} */
jQuery.event.prototype.pageX;

/** @type {number} */
jQuery.event.prototype.pageY;

/** @return {undefined} */
jQuery.event.prototype.preventDefault = function() {};

/** @type {Element} */
jQuery.event.prototype.relatedTarget;

/** @type {Object} */
jQuery.event.prototype.result;

/** @return {undefined} */
jQuery.event.prototype.stopImmediatePropagation = function() {};

/** @return {undefined} */
jQuery.event.prototype.stopPropagation = function() {};

/** @type {Element} */
jQuery.event.prototype.target;

/** @type {number} */
jQuery.event.prototype.timeStamp;

/** @type {string} */
jQuery.event.prototype.type;

/** @type {number} */
jQuery.event.prototype.which;

/**
 * @param {(Object|boolean)=} arg1
 * @param {Object=} arg2
 * @param {Object=} arg3
 * @param {Object=} objectN
 * @return {Object}
 */
jQuery.extend = function(arg1, arg2, arg3, objectN) {};

jQuery.fx = {};

/** @type {number} */
jQuery.fx.interval;

/** @type {boolean} */
jQuery.fx.off;

/**
 * @param {string} url
 * @param {(Object.<string,*>|string)=} data
 * @param {function(string,string,XMLHttpRequest)=} callback
 * @param {string=} dataType
 * @return {XMLHttpRequest}
 */
jQuery.get = function(url, data, callback, dataType) {};

/**
 * @param {string} url
 * @param {Object.<string,*>=} data
 * @param {function(string,string,XMLHttpRequest)=} callback
 * @return {XMLHttpRequest}
 */
jQuery.getJSON = function(url, data, callback) {};

/**
 * @param {string} url
 * @param {function(string,string)=} success
 * @return {XMLHttpRequest}
 */
jQuery.getScript = function(url, success) {};

/** @param {string} code */
jQuery.globalEval = function(code) {};

/**
 * @param {Array} arr
 * @param {function(*,number)} fnc
 * @param {boolean=} invert
 * @return {Array}
 */
jQuery.grep = function(arr, fnc, invert) {};

/**
 * @param {*} value
 * @param {Array} arr
 * @return {number}
 */
jQuery.inArray = function(value, arr) {};

/**
 * @param {Object} obj
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isArray = function(obj) {};

/**
 * @param {Object} obj
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isEmptyObject = function(obj) {};

/**
 * @param {Object} obj
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isFunction = function(obj) {};

/**
 * @param {Object} obj
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isPlainObject = function(obj) {};

/**
 * @param {Object} obj
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isWindow = function(obj) {};

/**
 * @param {Element} node
 * @return {boolean}
 * @nosideeffects
 */
jQuery.isXMLDoc = function(node) {};

/**
 * @param {Object} obj
 * @return {Array}
 */
jQuery.makeArray = function(obj) {};

/**
 * @param {Array} arr
 * @param {function(*,number)} callback
 * @return {Array}
 */
jQuery.map = function(arr, callback) {};

/**
 * @param {Array} first
 * @param {Array} second
 * @return {Array}
 */
jQuery.merge = function(first, second) {};

/**
 * @param {boolean=} removeAll
 * @return {Object}
 */
jQuery.noConflict = function(removeAll) {};

/**
 * @return {function()}
 * @nosideeffects
 */
jQuery.noop = function() {};

/**
 * @param {(Array|Object)} obj
 * @param {boolean=} traditional
 * @return {string}
 */
jQuery.param = function(obj, traditional) {};

/**
 * @param {string} json
 * @return {Object}
 */
jQuery.parseJSON = function(json) {};

/**
 * @param {string} url
 * @param {(Object.<string,*>|string)=} data
 * @param {function(string,string,XMLHttpRequest)=} success
 * @param {string=} dataType
 * @return {XMLHttpRequest}
 */
jQuery.post = function(url, data, success, dataType) {};

/**
 * @param {(function()|Object)} arg1
 * @param {(Object|string)} arg2
 * @return {function()}
 */
jQuery.proxy = function(arg1, arg2) {};

/**
 * @param {Element} elem
 * @param {string=} queueName
 * @param {(Array|function())=} arg3
 * @return {(Array|jQueryObject)}
 */
jQuery.queue = function(elem, queueName, arg3) {};

/**
 * @param {Element} elem
 * @param {string=} name
 * @return {jQueryObject}
 */
jQuery.removeData = function(elem, name) {};

/** @type {Object} */
jQuery.support;

/**
 * @param {string} str
 * @return {string}
 * @nosideeffects
 */
jQuery.trim = function(str) {};

/**
 * @param {Object} obj
 * @return {string}
 * @nosideeffects
 */
jQuery.type = function(obj) {};

/**
 * @param {Array} arr
 * @return {Array}
 */
jQuery.unique = function(arr) {};

/**
 * @constructor
 * @private
 */
function jQueryObject() { };

/**
 * @param {(jQuerySelector|Array.<Element>|string)} arg1
 * @param {Element=} context
 * @return {jQueryObject}
 */
jQueryObject.prototype.add = function(arg1, context) {};

/**
 * @param {(string|function(number,string))} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.addClass = function(arg1) {};

/**
 * @param {(string|Element|jQueryObject|function(number))} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.after = function(arg1) {};

/**
 * @param {function(jQuery.event,XMLHttpRequest,Object.<string, *>)} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxComplete = function(handler) {};

/**
 * @param {function(jQuery.event,XMLHttpRequest,Object.<string, *>,*)} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxError = function(handler) {};

/**
 * @param {function(jQuery.event,XMLHttpRequest,Object.<string, *>)} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxSend = function(handler) {};

/**
 * @param {function()} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxStart = function(handler) {};

/**
 * @param {function()} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxStop = function(handler) {};

/**
 * @param {function(jQuery.event,XMLHttpRequest,Object.<string, *>)} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ajaxSuccess = function(handler) {};

/** @return {jQueryObject} */
jQueryObject.prototype.andSelf = function() {};

/**
 * @param {Object.<string,*>} properties
 * @param {(string|number|Object.<string,*>)=} arg2
 * @param {string=} easing
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.animate
    = function(properties, arg2, easing, callback) {};

/**
 * @param {(string|Element|jQueryObject|function(number,string))} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.append = function(arg1) {};

/**
 * @param {(jQuerySelector|Element|jQueryObject)} target
 * @return {jQueryObject}
 */
jQueryObject.prototype.appendTo = function(target) {};

/**
 * @param {(string|Object.<string,*>)} arg1
 * @param {(string|number|function(number,string))=} arg2
 * @return {(string|jQueryObject)}
 */
jQueryObject.prototype.attr = function(arg1, arg2) {};

/**
 * @param {(string|Element|jQueryObject|function())} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.before = function(arg1) {};

/**
 * @param {(string|Object)} arg1
 * @param {Object=} eventData
 * @param {(function(jQuery.event)|boolean)=} arg3
 * @return {jQueryObject}
 */
jQueryObject.prototype.bind = function(arg1, eventData, arg3) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.blur = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.change = function(arg1, handler) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.children = function(selector) {};

/**
 * @param {string=} queueName
 * @return {jQueryObject}
 */
jQueryObject.prototype.clearQueue = function(queueName) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.click = function(arg1, handler) {};

/**
 * @param {boolean=} withDataAndEvents
 * @return {jQueryObject}
 */
jQueryObject.prototype.clone = function(withDataAndEvents) {};

/**
 * @param {(jQuerySelector|Array)} arg1
 * @param {Element=} context
 * @return {(jQueryObject|Array)}
 */
jQueryObject.prototype.closest = function(arg1, context) {};

/** @return {jQueryObject} */
jQueryObject.prototype.contents = function() {};

/** @type {Element} */
jQueryObject.prototype.context;

/**
 * @param {(string|Object.<string,*>)} arg1
 * @param {(string|number|function(number,*))=} arg2
 * @return {(string|jQueryObject)}
 */
jQueryObject.prototype.css = function(arg1, arg2) {};

/**
 * @param {(string|Object)=} arg1
 * @param {Object=} value
 * @return {(jQueryObject|Object)}
 */
jQueryObject.prototype.data = function(arg1, value) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.dblclick = function(arg1, handler) {};

/**
 * @param {number} duration
 * @param {string=} queueName
 * @return {jQueryObject}
 */
jQueryObject.prototype.delay = function(duration, queueName) {};

/**
 * @param {string} selector
 * @param {string} eventType
 * @param {(function()|Object)} arg3
 * @param {function()=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.delegate
    = function(selector, eventType, arg3, handler) {};

/**
 * @param {string=} queueName
 * @return {jQueryObject}
 */
jQueryObject.prototype.dequeue = function(queueName) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.detach = function(selector) {};

/**
 * @param {string=} eventType
 * @param {string=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.die = function(eventType, handler) {};

/**
 * @param {function(number,Element)} fnc
 * @return {jQueryObject}
 */
jQueryObject.prototype.each = function(fnc) {};

/** @return {jQueryObject} */
jQueryObject.prototype.empty = function() {};

/** @return {jQueryObject} */
jQueryObject.prototype.end = function() {};

/**
 * @param {number} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.eq = function(arg1) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.error = function(arg1, handler) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.fadeIn = function(duration, arg2, callback) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.fadeOut = function(duration, arg2, callback) {};

/**
 * @param {(string|number)=} duration
 * @param {number=} opacity
 * @param {(function()|string)=} arg3
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.fadeTo = function(duration, opacity, arg3, callback) {};

/**
 * @param {(string|number)=} duration
 * @param {string=} easing
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.fadeToggle = function(duration, easing, callback) {};

/**
 * @param {(jQuerySelector|function(number)|Element|Object)} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.filter = function(arg1) {};

/**
 * @param {jQuerySelector} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.find = function(selector) {};

/** @return {jQueryObject} */
jQueryObject.prototype.first = function() {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.focus = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.focusin = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.focusout = function(arg1, handler) {};

/**
 * @param {number=} index
 * @return {(Element|Array)}
 * @nosideeffects
 */
jQueryObject.prototype.get = function(index) {};

/**
 * @param {(string|Element)} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.has = function(arg1) {};

/**
 * @param {string} className
 * @return {boolean}
 */
jQueryObject.prototype.hasClass = function(className) {};

/**
 * @param {(string|number|function(number,number))=} arg1
 * @return {(number|jQueryObject)}
 * @nosideeffects
 */
jQueryObject.prototype.height = function(arg1) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.hide = function(duration, arg2, callback) {};

/**
 * @param {function(jQuery.event)} arg1
 * @param {function(jQuery.event)=} handlerOut
 * @return {jQueryObject}
 */
jQueryObject.prototype.hover = function(arg1, handlerOut) {};

/**
 * @param {(string|function(number,string))=} arg1
 * @return {(string|jQueryObject)}
 */
jQueryObject.prototype.html = function(arg1) {};

/**
 * @param {(jQuerySelector|Element|jQueryObject)=} arg1
 * @return {number}
 */
jQueryObject.prototype.index = function(arg1) {};

/**
 * @return {number}
 * @nosideeffects
 */
jQueryObject.prototype.innerHeight = function() {};

/**
 * @return {number}
 * @nosideeffects
 */
jQueryObject.prototype.innerWidth = function() {};

/**
 * @param {(jQuerySelector|Element|jQueryObject)} target
 * @return {jQueryObject}
 */
jQueryObject.prototype.insertAfter = function(target) {};

/**
 * @param {(jQuerySelector|Element|jQueryObject)} target
 * @return {jQueryObject}
 */
jQueryObject.prototype.insertBefore = function(target) {};

/**
 * @param {jQuerySelector} selector
 * @return {boolean}
 * @nosideeffects
 */
jQueryObject.prototype.is = function(selector) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.keydown = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.keypress = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.keyup = function(arg1, handler) {};

/** @return {jQueryObject} */
jQueryObject.prototype.last = function() {};

/** @type {number} */
jQueryObject.prototype.length;

/**
 * @param {string} eventType
 * @param {(function()|Object)} arg2
 * @param {function()=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.live = function(eventType, arg2, handler) {};

/**
 * @param {(function(jQuery.event)|Object|string)=} arg1
 * @param {(function(jQuery.event)|Object.<string,*>|string)=} arg2
 * @param {function(string,string,XMLHttpRequest)=} complete
 * @return {jQueryObject}
 */
jQueryObject.prototype.load = function(arg1, arg2, complete) {};

/**
 * @param {function(number,Element)} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.map = function(callback) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mousedown = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mouseenter = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mouseleave = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mousemove = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mouseout = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mouseover = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.mouseup = function(arg1, handler) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.next = function(selector) {};

/**
 * @param {string=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.nextAll = function(selector) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.nextUntil = function(selector) {};

/**
 * @param {(jQuerySelector|Array.<Element>|function(number))} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.not = function(arg1) {};

/**
 * @param {(Object|function(number,{top:number,left:number}))=} arg1
 * @return {(Object|jQueryObject)}
 * @nosideeffects
 */
jQueryObject.prototype.offset = function(arg1) {};

/** @return {jQueryObject} */
jQueryObject.prototype.offsetParent = function() {};

/**
 * @param {string} eventType
 * @param {Object=} eventData
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.one = function(eventType, eventData, handler) {};

/**
 * @param {boolean=} includeMargin
 * @return {number}
 * @nosideeffects
 */
jQueryObject.prototype.outerHeight = function(includeMargin) {};

/**
 * @param {boolean=} includeMargin
 * @return {number}
 * @nosideeffects
 */
jQueryObject.prototype.outerWidth = function(includeMargin) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.parent = function(selector) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.parents = function(selector) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.parentsUntil = function(selector) {};

/**
 * @return {Object}
 * @nosideeffects
 */
jQueryObject.prototype.position = function() {};

/**
 * @param {(string|Element|jQueryObject|function(number,string))} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.prepend = function(arg1) {};

/**
 * @param {(jQuerySelector|Element|jQueryObject)} target
 * @return {jQueryObject}
 */
jQueryObject.prototype.prependTo = function(target) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.prev = function(selector) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.prevAll = function(selector) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.prevUntil = function(selector) {};

/**
 * @param {Array} elements
 * @param {string=} name
 * @param {Array=} args
 * @return {jQueryObject}
 */
jQueryObject.prototype.pushStack = function(elements, name, args) {};

/**
 * @param {string=} queueName
 * @param {(Array|function(function()))=} arg2
 * @return {(Array|jQueryObject)}
 */
jQueryObject.prototype.queue = function(queueName, arg2) {};

/**
 * @param {function()} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.ready = function(handler) {};

/**
 * @param {string=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.remove = function(selector) {};

/**
 * @param {string} attributeName
 * @return {jQueryObject}
 */
jQueryObject.prototype.removeAttr = function(attributeName) {};

/**
 * @param {(string|function(number,string))=} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.removeClass = function(arg1) {};

/**
 * @param {string=} name
 * @return {jQueryObject}
 */
jQueryObject.prototype.removeData = function(name) {};

/** @return {jQueryObject} */
jQueryObject.prototype.replaceAll = function() {};

/**
 * @param {(string|Element|jQueryObject|function())} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.replaceWith = function(arg1) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.resize = function(arg1, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.scroll = function(arg1, handler) {};

/**
 * @param {number=} value
 * @return {(number|jQueryObject)}
 */
jQueryObject.prototype.scrollLeft = function(value) {};

/**
 * @param {number=} value
 * @return {(number|jQueryObject)}
 */
jQueryObject.prototype.scrollTop = function(value) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.select = function(arg1, handler) {};

/** @type {string} */
jQueryObject.prototype.selector;

/** @return {string} */
jQueryObject.prototype.serialize = function() {};

/** @return {Array} */
jQueryObject.prototype.serializeArray = function() {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.show = function(duration, arg2, callback) {};

/**
 * @param {jQuerySelector=} selector
 * @return {jQueryObject}
 */
jQueryObject.prototype.siblings = function(selector) {};

/** @return {number} */
jQueryObject.prototype.size = function() {};

/**
 * @param {number} start
 * @param {number=} end
 * @return {jQueryObject}
 */
jQueryObject.prototype.slice = function(start, end) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.slideDown = function(duration, arg2, callback) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.slideToggle = function(duration, arg2, callback) {};

/**
 * @param {(string|number)=} duration
 * @param {(function()|string)=} arg2
 * @param {function()=} callback
 * @return {jQueryObject}
 */
jQueryObject.prototype.slideUp = function(duration, arg2, callback) {};

/**
 * @param {boolean=} clearQueue
 * @param {boolean=} jumpToEnd
 * @return {jQueryObject}
 */
jQueryObject.prototype.stop = function(clearQueue, jumpToEnd) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.submit = function(arg1, handler) {};

/**
 * @param {(string|function(number,string))=} arg1
 * @return {(string|jQueryObject)}
 */
jQueryObject.prototype.text = function(arg1) {};

/** @return {Array} */
jQueryObject.prototype.toArray = function() {};

/**
 * @param {(function(jQuery.event)|string|number|boolean)=} arg1
 * @param {(function(jQuery.event)|string)=} arg2
 * @param {function(jQuery.event)=} arg3
 * @return {jQueryObject}
 */
jQueryObject.prototype.toggle = function(arg1, arg2, arg3) {};

/**
 * @param {(string|function(number,string))} arg1
 * @param {boolean=} flag
 * @return {jQueryObject}
 */
jQueryObject.prototype.toggleClass = function(arg1, flag) {};

/**
 * @param {(string|jQuery.event)} arg1
 * @param {Array=} extraParameters
 * @return {jQueryObject}
 */
jQueryObject.prototype.trigger = function(arg1, extraParameters) {};

/**
 * @param {string} eventType
 * @param {Array} extraParameters
 * @return {Object}
 */
jQueryObject.prototype.triggerHandler = function(eventType, extraParameters) {};

/**
 * @param {(string|Object)=} arg1
 * @param {(function(jQuery.event)|boolean)=} arg2
 * @return {jQueryObject}
 */
jQueryObject.prototype.unbind = function(arg1, arg2) {};

/**
 * @param {string=} selector
 * @param {string=} eventType
 * @param {function()=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.undelegate = function(selector, eventType, handler) {};

/**
 * @param {(function(jQuery.event)|Object)=} arg1
 * @param {function(jQuery.event)=} handler
 * @return {jQueryObject}
 */
jQueryObject.prototype.unload = function(arg1, handler) {};

/** @return {jQueryObject} */
jQueryObject.prototype.unwrap = function() {};

/**
 * @param {(string|function(number,*))=} arg1
 * @return {(string|Array|jQueryObject)}
 */
jQueryObject.prototype.val = function(arg1) {};

/**
 * @param {(string|number|function(number,number))=} arg1
 * @return {(number|jQueryObject)}
 * @nosideeffects
 */
jQueryObject.prototype.width = function(arg1) {};

/**
 * @param {(string|jQuerySelector|Element|jQueryObject|function())} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.wrap = function(arg1) {};

/**
 * @param {(string|jQuerySelector|Element|jQueryObject)} wrappingElement
 * @return {jQueryObject}
 */
jQueryObject.prototype.wrapAll = function(wrappingElement) {};

/**
 * @param {(string|function())} arg1
 * @return {jQueryObject}
 */
jQueryObject.prototype.wrapInner = function(arg1) {};


//
//var jQuery = {
//    "fn": {
//        "init": function () {},
//        "selector": {},
//        "jquery": {},
//        "size": function () {},
//        "get": function () {},
//        "pushStack": function () {},
//        "setArray": function () {},
//        "each": function () {},
//        "index": function () {},
//        "attr": function () {},
//        "css": function () {},
//        "text": function () {},
//        "wrapAll": function () {},
//        "wrapInner": function () {},
//        "wrap": function () {},
//        "append": function () {},
//        "prepend": function () {},
//        "before": function () {},
//        "after": function () {},
//        "end": function () {},
//        "push": function () {},
//        "sort": function () {},
//        "splice": function () {},
//        "find": function () {},
//        "clone": function () {},
//        "filter": function () {},
//        "closest": function () {},
//        "not": function () {},
//        "add": function () {},
//        "is": function () {},
//        "hasClass": function () {},
//        "val": function () {},
//        "html": function () {},
//        "replaceWith": function () {},
//        "eq": function () {},
//        "slice": function () {},
//        "map": function () {},
//        "andSelf": function () {},
//        "domManip": function () {},
//        "extend": function () {},
//        "parent": function () {},
//        "parents": function () {},
//        "next": function () {},
//        "prev": function () {},
//        "nextAll": function () {},
//        "prevAll": function () {},
//        "siblings": function () {},
//        "children": function () {},
//        "contents": function () {},
//        "appendTo": function () {},
//        "prependTo": function () {},
//        "insertBefore": function () {},
//        "insertAfter": function () {},
//        "replaceAll": function () {},
//        "removeAttr": function () {},
//        "addClass": function () {},
//        "removeClass": function () {},
//        "toggleClass": function () {},
//        "remove": function () {},
//        "empty": function () {},
//        "data": function () {},
//        "removeData": function () {},
//        "queue": function () {},
//        "dequeue": function () {},
//        "bind": function () {},
//        "one": function () {},
//        "unbind": function () {},
//        "trigger": function () {},
//        "triggerHandler": function () {},
//        "toggle": function () {},
//        "hover": function () {},
//        "ready": function () {},
//        "live": function () {},
//        "die": function () {},
//        "blur": function () {},
//        "focus": function () {},
//        "load": function () {},
//        "resize": function () {},
//        "scroll": function () {},
//        "unload": function () {},
//        "click": function () {},
//        "dblclick": function () {},
//        "mousedown": function () {},
//        "mouseup": function () {},
//        "mousemove": function () {},
//        "mouseover": function () {},
//        "mouseout": function () {},
//        "mouseenter": function () {},
//        "mouseleave": function () {},
//        "change": function () {},
//        "select": function () {},
//        "submit": function () {},
//        "keydown": function () {},
//        "keypress": function () {},
//        "keyup": function () {},
//        "error": function () {},
//        "_load": function () {},
//        "serialize": function () {},
//        "serializeArray": function () {},
//        "ajaxStart": function () {},
//        "ajaxStop": function () {},
//        "ajaxComplete": function () {},
//        "ajaxError": function () {},
//        "ajaxSuccess": function () {},
//        "ajaxSend": function () {},
//        "show": function () {},
//        "hide": function () {},
//        "_toggle": function () {},
//        "fadeTo": function () {},
//        "animate": function () {},
//        "stop": function () {},
//        "slideDown": function () {},
//        "slideUp": function () {},
//        "slideToggle": function () {},
//        "fadeIn": function () {},
//        "fadeOut": function () {},
//        "offset": function () {},
//        "position": function () {},
//        "offsetParent": function () {},
//        "scrollLeft": function () {},
//        "scrollTop": function () {},
//        "innerHeight": function () {},
//        "outerHeight": function () {},
//        "height": function () {},
//        "innerWidth": function () {},
//        "outerWidth": function () {},
//        "width": function () {}
//    },
//    "extend": function () {},
//    "noConflict": function () {},
//    "isFunction": function () {},
//    "isArray": function () {},
//    "isXMLDoc": function () {},
//    "globalEval": function () {},
//    "nodeName": function () {},
//    "each": function () {},
//    "prop": function () {},
//    "className": {
//        "add": function () {},
//        "remove": function () {},
//        "has": function () {}
//    },
//    "swap": function () {},
//    "css": function () {},
//    "curCSS": function () {},
//    "clean": function () {},
//    "attr": function () {},
//    "trim": function () {},
//    "makeArray": function () {},
//    "inArray": function () {},
//    "merge": function () {},
//    "unique": function () {},
//    "grep": function () {},
//    "map": function () {},
//    "browser": {
//        "version": {},
//        "safari": {},
//        "opera": {},
//        "msie": {},
//        "mozilla": {}
//    },
//    "cache": {
//        "1": {
//            "events": {
//                "unload": {
//                    "1": function () {}
//                },
//                "load": {
//                    "2": function () {}
//                }
//            },
//            "handle": function () {}
//        },
//        "2": function () {}
//    },
//    "data": function () {},
//    "removeData": function () {},
//    "queue": function () {},
//    "dequeue": function () {},
//    "find": function () {},
//    "filter": function () {},
//    "expr": {
//        "order": {
//            "0": {},
//            "1": {},
//            "2": {},
//            "3": {}
//        },
//        "match": {
//            "ID": {},
//            "CLASS": {},
//            "NAME": {},
//            "ATTR": {},
//            "TAG": {},
//            "CHILD": {},
//            "POS": {},
//            "PSEUDO": {}
//        },
//        "attrMap": {
//            "class": {},
//            "for": {}
//        },
//        "attrHandle": {
//            "href": function () {}
//        },
//        "relative": {
//            "+": function () {},
//            ">": function () {},
//            "": function () {},
//            "~": function () {}
//        },
//        "find": {
//            "ID": function () {},
//            "NAME": function () {},
//            "TAG": function () {},
//            "CLASS": function () {}
//        },
//        "preFilter": {
//            "CLASS": function () {},
//            "ID": function () {},
//            "TAG": function () {},
//            "CHILD": function () {},
//            "ATTR": function () {},
//            "PSEUDO": function () {},
//            "POS": function () {}
//        },
//        "filters": {
//            "enabled": function () {},
//            "disabled": function () {},
//            "checked": function () {},
//            "selected": function () {},
//            "parent": function () {},
//            "empty": function () {},
//            "has": function () {},
//            "header": function () {},
//            "text": function () {},
//            "radio": function () {},
//            "checkbox": function () {},
//            "file": function () {},
//            "password": function () {},
//            "submit": function () {},
//            "image": function () {},
//            "reset": function () {},
//            "button": function () {},
//            "input": function () {},
//            "hidden": function () {},
//            "visible": function () {},
//            "animated": function () {}
//        },
//        "setFilters": {
//            "first": function () {},
//            "last": function () {},
//            "even": function () {},
//            "odd": function () {},
//            "lt": function () {},
//            "gt": function () {},
//            "nth": function () {},
//            "eq": function () {}
//        },
//        "filter": {
//            "PSEUDO": function () {},
//            "CHILD": function () {},
//            "ID": function () {},
//            "TAG": function () {},
//            "CLASS": function () {},
//            "ATTR": function () {},
//            "POS": function () {}
//        },
//        ":": {
//            "enabled": function () {},
//            "disabled": function () {},
//            "checked": function () {},
//            "selected": function () {},
//            "parent": function () {},
//            "empty": function () {},
//            "has": function () {},
//            "header": function () {},
//            "text": function () {},
//            "radio": function () {},
//            "checkbox": function () {},
//            "file": function () {},
//            "password": function () {},
//            "submit": function () {},
//            "image": function () {},
//            "reset": function () {},
//            "button": function () {},
//            "input": function () {},
//            "hidden": function () {},
//            "visible": function () {},
//            "animated": function () {}
//        }
//    },
//    "multiFilter": function () {},
//    "dir": function () {},
//    "nth": function () {},
//    "sibling": function () {},
//    "event": {
//        "add": function () {},
//        "guid": {},
//        "global": {
//            "unload": {},
//            "load": {}
//        },
//        "remove": function () {},
//        "trigger": function () {},
//        "handle": function () {},
//        "props": {
//            "0": {},
//            "1": {},
//            "2": {},
//            "3": {},
//            "4": {},
//            "5": {},
//            "6": {},
//            "7": {},
//            "8": {},
//            "9": {},
//            "10": {},
//            "11": {},
//            "12": {},
//            "13": {},
//            "14": {},
//            "15": {},
//            "16": {},
//            "17": {},
//            "18": {},
//            "19": {},
//            "20": {},
//            "21": {},
//            "22": {},
//            "23": {},
//            "24": {},
//            "25": {},
//            "26": {},
//            "27": {},
//            "28": {},
//            "29": {},
//            "30": {},
//            "31": {},
//            "32": {},
//            "33": {}
//        },
//        "fix": function () {},
//        "proxy": function () {},
//        "special": {
//            "ready": {
//                "setup": function () {},
//                "teardown": function () {}
//            },
//            "mouseenter": {
//                "setup": function () {},
//                "teardown": function () {}
//            },
//            "mouseleave": {
//                "setup": function () {},
//                "teardown": function () {}
//            }
//        },
//        "specialAll": {
//            "live": {
//                "setup": function () {},
//                "teardown": function () {}
//            }
//        },
//        "triggered": {}
//    },
//    "Event": function () {},
//    "isReady": {},
//    "readyList": function () {},
//    "ready": function () {},
//    "support": {
//        "leadingWhitespace": {},
//        "tbody": {},
//        "objectAll": {},
//        "htmlSerialize": {},
//        "style": {},
//        "hrefNormalized": {},
//        "opacity": {},
//        "cssFloat": {},
//        "scriptEval": {},
//        "noCloneEvent": {},
//        "boxModel": {}
//    },
//    "props": {
//        "for": {},
//        "class": {},
//        "float": {},
//        "cssFloat": {},
//        "styleFloat": {},
//        "readonly": {},
//        "maxlength": {},
//        "cellspacing": {},
//        "rowspan": {},
//        "tabindex": {}
//    },
//    "get": function () {},
//    "getScript": function () {},
//    "getJSON": function () {},
//    "post": function () {},
//    "ajaxSetup": function () {},
//    "ajaxSettings": {
//        "url": {},
//        "global": {},
//        "type": {},
//        "contentType": {},
//        "processData": {},
//        "async": {},
//        "xhr": function () {},
//        "accepts": {
//            "xml": {},
//            "html": {},
//            "script": {},
//            "json": {},
//            "text": {},
//            "_default": {}
//        }
//    },
//    "lastModified": function () {},
//    "ajax": function () {},
//    "handleError": function () {},
//    "active": {},
//    "httpSuccess": function () {},
//    "httpNotModified": function () {},
//    "httpData": function () {},
//    "param": function () {},
//    "speed": function () {},
//    "easing": {
//        "linear": function () {},
//        "swing": function () {}
//    },
//    "timers": function () {},
//    "fx": function () {},
//    "offset": {
//        "initialize": function () {},
//        "bodyOffset": function () {}
//    },
//    "xLazyLoader": function () {},
//    "boxModel": {}
//};


var $ = jQuery;



//jquery ui
var $ = {
    "$": {
        "fn": {
            "init": function () {},
            "selector": {},
            "jquery": {},
            "size": function () {},
            "get": function () {},
            "pushStack": function () {},
            "setArray": function () {},
            "each": function () {},
            "index": function () {},
            "attr": function () {},
            "css": function () {},
            "text": function () {},
            "wrapAll": function () {},
            "wrapInner": function () {},
            "wrap": function () {},
            "append": function () {},
            "prepend": function () {},
            "before": function () {},
            "after": function () {},
            "end": function () {},
            "push": function () {},
            "sort": function () {},
            "splice": function () {},
            "find": function () {},
            "clone": function () {},
            "filter": function () {},
            "closest": function () {},
            "not": function () {},
            "add": function () {},
            "is": function () {},
            "hasClass": function () {},
            "val": function () {},
            "html": function () {},
            "replaceWith": function () {},
            "eq": function () {},
            "slice": function () {},
            "map": function () {},
            "andSelf": function () {},
            "domManip": function () {},
            "extend": function () {},
            "parent": function () {},
            "parents": function () {},
            "next": function () {},
            "prev": function () {},
            "nextAll": function () {},
            "prevAll": function () {},
            "siblings": function () {},
            "children": function () {},
            "contents": function () {},
            "appendTo": function () {},
            "prependTo": function () {},
            "insertBefore": function () {},
            "insertAfter": function () {},
            "replaceAll": function () {},
            "removeAttr": function () {},
            "addClass": function () {},
            "removeClass": function () {},
            "toggleClass": function () {},
            "remove": function () {},
            "empty": function () {},
            "data": function () {},
            "removeData": function () {},
            "queue": function () {},
            "dequeue": function () {},
            "bind": function () {},
            "one": function () {},
            "unbind": function () {},
            "trigger": function () {},
            "triggerHandler": function () {},
            "toggle": function () {},
            "hover": function () {},
            "ready": function () {},
            "live": function () {},
            "die": function () {},
            "blur": function () {},
            "focus": function () {},
            "load": function () {},
            "resize": function () {},
            "scroll": function () {},
            "unload": function () {},
            "click": function () {},
            "dblclick": function () {},
            "mousedown": function () {},
            "mouseup": function () {},
            "mousemove": function () {},
            "mouseover": function () {},
            "mouseout": function () {},
            "mouseenter": function () {},
            "mouseleave": function () {},
            "change": function () {},
            "select": function () {},
            "submit": function () {},
            "keydown": function () {},
            "keypress": function () {},
            "keyup": function () {},
            "error": function () {},
            "_load": function () {},
            "serialize": function () {},
            "serializeArray": function () {},
            "ajaxStart": function () {},
            "ajaxStop": function () {},
            "ajaxComplete": function () {},
            "ajaxError": function () {},
            "ajaxSuccess": function () {},
            "ajaxSend": function () {},
            "show": function () {},
            "hide": function () {},
            "_toggle": function () {},
            "fadeTo": function () {},
            "animate": function () {},
            "stop": function () {},
            "slideDown": function () {},
            "slideUp": function () {},
            "slideToggle": function () {},
            "fadeIn": function () {},
            "fadeOut": function () {},
            "offset": function () {},
            "position": function () {},
            "offsetParent": function () {},
            "scrollLeft": function () {},
            "scrollTop": function () {},
            "innerHeight": function () {},
            "outerHeight": function () {},
            "height": function () {},
            "innerWidth": function () {},
            "outerWidth": function () {},
            "width": function () {},
            "_focus": function () {},
            "scrollParent": function () {},
            "zIndex": function () {},
            "disableSelection": function () {},
            "enableSelection": function () {},
            "mouse": function () {},
            "draggable": function () {},
            "droppable": function () {},
            "resizable": function () {},
            "selectable": function () {},
            "sortable": function () {},
            "_addClass": function () {},
            "_removeClass": function () {},
            "_toggleClass": function () {},
            "switchClass": function () {},
            "effect": function () {},
            "_show": function () {},
            "_hide": function () {},
            "__toggle": function () {},
            "cssUnit": function () {},
            "accordion": function () {},
            "autocomplete": function () {},
            "menu": function () {},
            "button": function () {},
            "buttonset": function () {},
            "datepicker": function () {},
            "dialog": function () {},
            "progressbar": function () {},
            "slider": function () {},
            "tabs": function () {},

            "widget": function () {}

        }
    }
};
