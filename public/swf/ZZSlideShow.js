// jQuery JavaScript Library v1.4.2
(function(A,w){function ma(){if(!c.isReady){try{s.documentElement.doScroll("left")}catch(a){setTimeout(ma,1);return}c.ready()}}function Qa(a,b){b.src?c.ajax({url:b.src,async:false,dataType:"script"}):c.globalEval(b.text||b.textContent||b.innerHTML||"");b.parentNode&&b.parentNode.removeChild(b)}function X(a,b,d,f,e,j){var i=a.length;if(typeof b==="object"){for(var o in b)X(a,o,b[o],f,e,d);return a}if(d!==w){f=!j&&f&&c.isFunction(d);for(o=0;o<i;o++)e(a[o],b,f?d.call(a[o],o,e(a[o],b)):d,j);return a}return i?e(a[0],b):w}function J(){return(new Date).getTime()}function Y(){return false}function Z(){return true}function na(a,b,d){d[0].type=a;return c.event.handle.apply(b,d)}function oa(a){var b,d=[],f=[],e=arguments,j,i,o,k,n,r;i=c.data(this,"events");if(!(a.liveFired===this||!i||!i.live||a.button&&a.type==="click")){a.liveFired=this;var u=i.live.slice(0);for(k=0;k<u.length;k++){i=u[k];i.origType.replace(O,"")===a.type?f.push(i.selector):u.splice(k--,1)}j=c(a.target).closest(f,a.currentTarget);n=0;for(r=j.length;n<r;n++)for(k=0;k<u.length;k++){i=u[k];if(j[n].selector===i.selector){o=j[n].elem;f=null;if(i.preType==="mouseenter"||i.preType==="mouseleave")f=c(a.relatedTarget).closest(i.selector)[0];if(!f||f!==o)d.push({elem:o,handleObj:i})}}n=0;for(r=d.length;n<r;n++){j=d[n];a.currentTarget=j.elem;a.data=j.handleObj.data;a.handleObj=j.handleObj;if(j.handleObj.origHandler.apply(j.elem,e)===false){b=false;break}}return b}}function pa(a,b){return"live."+(a&&a!=="*"?a+".":"")+b.replace(/\./g,"`").replace(/ /g,"&")}function qa(a){return!a||!a.parentNode||a.parentNode.nodeType===11}function ra(a,b){var d=0;b.each(function(){if(this.nodeName===(a[d]&&a[d].nodeName)){var f=c.data(a[d++]),e=c.data(this,f);if(f=f&&f.events){delete e.handle;e.events={};for(var j in f)for(var i in f[j])c.event.add(this,j,f[j][i],f[j][i].data)}}})}function sa(a,b,d){var f,e,j;b=b&&b[0]?b[0].ownerDocument||b[0]:s;if(a.length===1&&typeof a[0]==="string"&&a[0].length<512&&b===s&&!ta.test(a[0])&&(c.support.checkClone||!ua.test(a[0]))){e=true;if(j=c.fragments[a[0]])if(j!==1)f=j}if(!f){f=b.createDocumentFragment();c.clean(a,b,f,d)}if(e)c.fragments[a[0]]=j?f:1;return{fragment:f,cacheable:e}}function K(a,b){var d={};c.each(va.concat.apply([],va.slice(0,b)),function(){d[this]=a});return d}function wa(a){return"scrollTo"in a&&a.document?a:a.nodeType===9?a.defaultView||a.parentWindow:false}var c=function(a,b){return new c.fn.init(a,b)},Ra=A.jCSFG,Sa=A.$,s=A.document,T,Ta=/^[^<]*(<[\w\W]+>)[^>]*$|^#([\w-]+)$/,Ua=/^.[^:#\[\.,]*$/,Va=/\S/,Wa=/^(\s|\u00A0)+|(\s|\u00A0)+$/g,Xa=/^<(\w+)\s*\/?>(?:<\/\1>)?$/,P=navigator.userAgent,xa=false,Q=[],L,$=Object.prototype.toString,aa=Object.prototype.hasOwnProperty,ba=Array.prototype.push,R=Array.prototype.slice,ya=Array.prototype.indexOf;c.fn=c.prototype={init:function(a,b){var d,f;if(!a)return this;if(a.nodeType){this.context=this[0]=a;this.length=1;return this}if(a==="body"&&!b){this.context=s;this[0]=s.body;this.selector="body";this.length=1;return this}if(typeof a==="string")if((d=Ta.exec(a))&&(d[1]||!b))if(d[1]){f=b?b.ownerDocument||b:s;if(a=Xa.exec(a))if(c.isPlainObject(b)){a=[s.createElement(a[1])];c.fn.attr.call(a,b,true)}else a=[f.createElement(a[1])];else{a=sa([d[1]],[f]);a=(a.cacheable?a.fragment.cloneNode(true):a.fragment).childNodes}return c.merge(this,a)}else{if(b=s.getElementById(d[2])){if(b.id!==d[2])return T.find(a);this.length=1;this[0]=b}this.context=s;this.selector=a;return this}else if(!b&&/^\w+$/.test(a)){this.selector=a;this.context=s;a=s.getElementsByTagName(a);return c.merge(this,a)}else return!b||b.jCSFG?(b||T).find(a):c(b).find(a);else if(c.isFunction(a))return T.ready(a);if(a.selector!==w){this.selector=a.selector;this.context=a.context}return c.makeArray(a,this)},selector:"",jCSFG:"1.4.2",length:0,size:function(){return this.length},toArray:function(){return R.call(this,0)},get:function(a){return a==null?this.toArray():a<0?this.slice(a)[0]:this[a]},pushStack:function(a,b,d){var f=c();c.isArray(a)?ba.apply(f,a):c.merge(f,a);f.prevObject=this;f.context=this.context;if(b==="find")f.selector=this.selector+(this.selector?" ":"")+d;else if(b)f.selector=this.selector+"."+b+"("+d+")";return f},each:function(a,b){return c.each(this,a,b)},ready:function(a){c.bindReady();if(c.isReady)a.call(s,c);else Q&&Q.push(a);return this},eq:function(a){return a===-1?this.slice(a):this.slice(a,+a+1)},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},slice:function(){return this.pushStack(R.apply(this,arguments),"slice",R.call(arguments).join(","))},map:function(a){return this.pushStack(c.map(this,function(b,d){return a.call(b,d,b)}))},end:function(){return this.prevObject||c(null)},push:ba,sort:[].sort,splice:[].splice};c.fn.init.prototype=c.fn;c.extend=c.fn.extend=function(){var a=arguments[0]||{},b=1,d=arguments.length,f=false,e,j,i,o;if(typeof a==="boolean"){f=a;a=arguments[1]||{};b=2}if(typeof a!=="object"&&!c.isFunction(a))a={};if(d===b){a=this;--b}for(;b<d;b++)if((e=arguments[b])!=null)for(j in e){i=a[j];o=e[j];if(a!==o)if(f&&o&&(c.isPlainObject(o)||c.isArray(o))){i=i&&(c.isPlainObject(i)||c.isArray(i))?i:c.isArray(o)?[]:{};a[j]=c.extend(f,i,o)}else if(o!==w)a[j]=o}return a};c.extend({noConflict:function(a){A.$=Sa;if(a)A.jCSFG=Ra;return c},isReady:false,ready:function(){if(!c.isReady){if(!s.body)return setTimeout(c.ready,13);c.isReady=true;if(Q){for(var a,b=0;a=Q[b++];)a.call(s,c);Q=null}c.fn.triggerHandler&&c(s).triggerHandler("ready")}},bindReady:function(){if(!xa){xa=true;if(s.readyState==="complete")return c.ready();if(s.addEventListener){s.addEventListener("DOMContentLoaded",L,false);A.addEventListener("load",c.ready,false)}else if(s.attachEvent){s.attachEvent("onreadystatechange",L);A.attachEvent("onload",c.ready);var a=false;try{a=A.frameElement==null}catch(b){}s.documentElement.doScroll&&a&&ma()}}},isFunction:function(a){return $.call(a)==="[object Function]"},isArray:function(a){return $.call(a)==="[object Array]"},isPlainObject:function(a){if(!a||$.call(a)!=="[object Object]"||a.nodeType||a.setInterval)return false;if(a.constructor&&!aa.call(a,"constructor")&&!aa.call(a.constructor.prototype,"isPrototypeOf"))return false;var b;for(b in a);return b===w||aa.call(a,b)},isEmptyObject:function(a){for(var b in a)return false;return true},error:function(a){throw a;},parseJSON:function(a){if(typeof a!=="string"||!a)return null;a=c.trim(a);if(/^[\],:{}\s]*$/.test(a.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,"")))return A.JSON&&A.JSON.parse?A.JSON.parse(a):(new Function("return "+a))();else c.error("Invalid JSON: "+a)},noop:function(){},globalEval:function(a){if(a&&Va.test(a)){var b=s.getElementsByTagName("head")[0]||s.documentElement,d=s.createElement("script");d.type="text/javascript";if(c.support.scriptEval)d.appendChild(s.createTextNode(a));else d.text=a;b.insertBefore(d,b.firstChild);b.removeChild(d)}},nodeName:function(a,b){return a.nodeName&&a.nodeName.toUpperCase()===b.toUpperCase()},each:function(a,b,d){var f,e=0,j=a.length,i=j===w||c.isFunction(a);if(d)if(i)for(f in a){if(b.apply(a[f],d)===false)break}else for(;e<j;){if(b.apply(a[e++],d)===false)break}else if(i)for(f in a){if(b.call(a[f],f,a[f])===false)break}else for(d=a[0];e<j&&b.call(d,e,d)!==false;d=a[++e]);return a},trim:function(a){return(a||"").replace(Wa,"")},makeArray:function(a,b){b=b||[];if(a!=null)a.length==null||typeof a==="string"||c.isFunction(a)||typeof a!=="function"&&a.setInterval?ba.call(b,a):c.merge(b,a);return b},inArray:function(a,b){if(b.indexOf)return b.indexOf(a);for(var d=0,f=b.length;d<f;d++)if(b[d]===a)return d;return-1},merge:function(a,b){var d=a.length,f=0;if(typeof b.length==="number")for(var e=b.length;f<e;f++)a[d++]=b[f];else for(;b[f]!==w;)a[d++]=b[f++];a.length=d;return a},grep:function(a,b,d){for(var f=[],e=0,j=a.length;e<j;e++)!d!==!b(a[e],e)&&f.push(a[e]);return f},map:function(a,b,d){for(var f=[],e,j=0,i=a.length;j<i;j++){e=b(a[j],j,d);if(e!=null)f[f.length]=e}return f.concat.apply([],f)},guid:1,proxy:function(a,b,d){if(arguments.length===2)if(typeof b==="string"){d=a;a=d[b];b=w}else if(b&&!c.isFunction(b)){d=b;b=w}if(!b&&a)b=function(){return a.apply(d||this,arguments)};if(a)b.guid=a.guid=a.guid||b.guid||c.guid++;return b},uaMatch:function(a){a=a.toLowerCase();a=/(webkit)[ \/]([\w.]+)/.exec(a)||/(opera)(?:.*version)?[ \/]([\w.]+)/.exec(a)||/(msie) ([\w.]+)/.exec(a)||!/compatible/.test(a)&&/(mozilla)(?:.*? rv:([\w.]+))?/.exec(a)||[];return{browser:a[1]||"",version:a[2]||"0"}},browser:{}});P=c.uaMatch(P);if(P.browser){c.browser[P.browser]=true;c.browser.version=P.version}if(c.browser.webkit)c.browser.safari=true;if(ya)c.inArray=function(a,b){return ya.call(b,a)};T=c(s);if(s.addEventListener)L=function(){s.removeEventListener("DOMContentLoaded",L,false);c.ready()};else if(s.attachEvent)L=function(){if(s.readyState==="complete"){s.detachEvent("onreadystatechange",L);c.ready()}};(function(){c.support={};var a=s.documentElement,b=s.createElement("script"),d=s.createElement("div"),f="script"+J();d.style.display="none";d.innerHTML="   <link/><table></table><a href='/a' style='color:red;float:left;opacity:.55;'>a</a><input type='checkbox'/>";var e=d.getElementsByTagName("*"),j=d.getElementsByTagName("a")[0];if(!(!e||!e.length||!j)){c.support={leadingWhitespace:d.firstChild.nodeType===3,tbody:!d.getElementsByTagName("tbody").length,htmlSerialize:!!d.getElementsByTagName("link").length,style:/red/.test(j.getAttribute("style")),hrefNormalized:j.getAttribute("href")==="/a",opacity:/^0.55$/.test(j.style.opacity),cssFloat:!!j.style.cssFloat,checkOn:d.getElementsByTagName("input")[0].value==="on",optSelected:s.createElement("select").appendChild(s.createElement("option")).selected,parentNode:d.removeChild(d.appendChild(s.createElement("div"))).parentNode===null,deleteExpando:true,checkClone:false,scriptEval:false,noCloneEvent:true,boxModel:null};b.type="text/javascript";try{b.appendChild(s.createTextNode("window."+f+"=1;"))}catch(i){}a.insertBefore(b,a.firstChild);if(A[f]){c.support.scriptEval=true;delete A[f]}try{delete b.test}catch(o){c.support.deleteExpando=false}a.removeChild(b);if(d.attachEvent&&d.fireEvent){d.attachEvent("onclick",function k(){c.support.noCloneEvent=false;d.detachEvent("onclick",k)});d.cloneNode(true).fireEvent("onclick")}d=s.createElement("div");d.innerHTML="<input type='radio' name='radiotest' checked='checked'/>";a=s.createDocumentFragment();a.appendChild(d.firstChild);c.support.checkClone=a.cloneNode(true).cloneNode(true).lastChild.checked;c(function(){var k=s.createElement("div");k.style.width=k.style.paddingLeft="1px";s.body.appendChild(k);c.boxModel=c.support.boxModel=k.offsetWidth===2;s.body.removeChild(k).style.display="none"});a=function(k){var n=s.createElement("div");k="on"+k;var r=k in n;if(!r){n.setAttribute(k,"return;");r=typeof n[k]==="function"}return r};c.support.submitBubbles=a("submit");c.support.changeBubbles=a("change");a=b=d=e=j=null}})();c.props={"for":"htmlFor","class":"className",readonly:"readOnly",maxlength:"maxLength",cellspacing:"cellSpacing",rowspan:"rowSpan",colspan:"colSpan",tabindex:"tabIndex",usemap:"useMap",frameborder:"frameBorder"};var G="jCSFG"+J(),Ya=0,za={};c.extend({cache:{},expando:G,noData:{embed:true,object:true,applet:true},data:function(a,b,d){if(!(a.nodeName&&c.noData[a.nodeName.toLowerCase()])){a=a==A?za:a;var f=a[G],e=c.cache;if(!f&&typeof b==="string"&&d===w)return null;f||(f=++Ya);if(typeof b==="object"){a[G]=f;e[f]=c.extend(true,{},b)}else if(!e[f]){a[G]=f;e[f]={}}a=e[f];if(d!==w)a[b]=d;return typeof b==="string"?a[b]:a}},removeData:function(a,b){if(!(a.nodeName&&c.noData[a.nodeName.toLowerCase()])){a=a==A?za:a;var d=a[G],f=c.cache,e=f[d];if(b){if(e){delete e[b];c.isEmptyObject(e)&&c.removeData(a)}}else{if(c.support.deleteExpando)delete a[c.expando];else a.removeAttribute&&a.removeAttribute(c.expando);delete f[d]}}}});c.fn.extend({data:function(a,b){if(typeof a==="undefined"&&this.length)return c.data(this[0]);else if(typeof a==="object")return this.each(function(){c.data(this,a)});var d=a.split(".");d[1]=d[1]?"."+d[1]:"";if(b===w){var f=this.triggerHandler("getData"+d[1]+"!",[d[0]]);if(f===w&&this.length)f=c.data(this[0],a);return f===w&&d[1]?this.data(d[0]):f}else return this.trigger("setData"+d[1]+"!",[d[0],b]).each(function(){c.data(this,a,b)})},removeData:function(a){return this.each(function(){c.removeData(this,a)})}});c.extend({queue:function(a,b,d){if(a){b=(b||"fx")+"queue";var f=c.data(a,b);if(!d)return f||[];if(!f||c.isArray(d))f=c.data(a,b,c.makeArray(d));else f.push(d);return f}},dequeue:function(a,b){b=b||"fx";var d=c.queue(a,b),f=d.shift();if(f==="inprogress")f=d.shift();if(f){b==="fx"&&d.unshift("inprogress");f.call(a,function(){c.dequeue(a,b)})}}});c.fn.extend({queue:function(a,b){if(typeof a!=="string"){b=a;a="fx"}if(b===w)return c.queue(this[0],a);return this.each(function(){var d=c.queue(this,a,b);a==="fx"&&d[0]!=="inprogress"&&c.dequeue(this,a)})},dequeue:function(a){return this.each(function(){c.dequeue(this,a)})},delay:function(a,b){a=c.fx?c.fx.speeds[a]||a:a;b=b||"fx";return this.queue(b,function(){var d=this;setTimeout(function(){c.dequeue(d,b)},a)})},clearQueue:function(a){return this.queue(a||"fx",[])}});var Aa=/[\n\t]/g,ca=/\s+/,Za=/\r/g,$a=/href|src|style/,ab=/(button|input)/i,bb=/(button|input|object|select|textarea)/i,cb=/^(a|area)$/i,Ba=/radio|checkbox/;c.fn.extend({attr:function(a,b){return X(this,a,b,true,c.attr)},removeAttr:function(a){return this.each(function(){c.attr(this,a,"");this.nodeType===1&&this.removeAttribute(a)})},addClass:function(a){if(c.isFunction(a))return this.each(function(n){var r=c(this);r.addClass(a.call(this,n,r.attr("class")))});if(a&&typeof a==="string")for(var b=(a||"").split(ca),d=0,f=this.length;d<f;d++){var e=this[d];if(e.nodeType===1)if(e.className){for(var j=" "+e.className+" ",i=e.className,o=0,k=b.length;o<k;o++)if(j.indexOf(" "+b[o]+" ")<0)i+=" "+b[o];e.className=c.trim(i)}else e.className=a}return this},removeClass:function(a){if(c.isFunction(a))return this.each(function(k){var n=c(this);n.removeClass(a.call(this,k,n.attr("class")))});if(a&&typeof a==="string"||a===w)for(var b=(a||"").split(ca),d=0,f=this.length;d<f;d++){var e=this[d];if(e.nodeType===1&&e.className)if(a){for(var j=(" "+e.className+" ").replace(Aa," "),i=0,o=b.length;i<o;i++)j=j.replace(" "+b[i]+" "," ");e.className=c.trim(j)}else e.className=""}return this},toggleClass:function(a,b){var d=typeof a,f=typeof b==="boolean";if(c.isFunction(a))return this.each(function(e){var j=c(this);j.toggleClass(a.call(this,e,j.attr("class"),b),b)});return this.each(function(){if(d==="string")for(var e,j=0,i=c(this),o=b,k=a.split(ca);e=k[j++];){o=f?o:!i.hasClass(e);i[o?"addClass":"removeClass"](e)}else if(d==="undefined"||d==="boolean"){this.className&&c.data(this,"__className__",this.className);this.className=this.className||a===false?"":c.data(this,"__className__")||""}})},hasClass:function(a){a=" "+a+" ";for(var b=0,d=this.length;b<d;b++)if((" "+this[b].className+" ").replace(Aa," ").indexOf(a)>-1)return true;return false},val:function(a){if(a===w){var b=this[0];if(b){if(c.nodeName(b,"option"))return(b.attributes.value||{}).specified?b.value:b.text;if(c.nodeName(b,"select")){var d=b.selectedIndex,f=[],e=b.options;b=b.type==="select-one";if(d<0)return null;var j=b?d:0;for(d=b?d+1:e.length;j<d;j++){var i=e[j];if(i.selected){a=c(i).val();if(b)return a;f.push(a)}}return f}if(Ba.test(b.type)&&!c.support.checkOn)return b.getAttribute("value")===null?"on":b.value;return(b.value||"").replace(Za,"")}return w}var o=c.isFunction(a);return this.each(function(k){var n=c(this),r=a;if(this.nodeType===1){if(o)r=a.call(this,k,n.val());if(typeof r==="number")r+="";if(c.isArray(r)&&Ba.test(this.type))this.checked=c.inArray(n.val(),r)>=0;else if(c.nodeName(this,"select")){var u=c.makeArray(r);c("option",this).each(function(){this.selected=c.inArray(c(this).val(),u)>=0});if(!u.length)this.selectedIndex=-1}else this.value=r}})}});c.extend({attrFn:{val:true,css:true,html:true,text:true,data:true,width:true,height:true,offset:true},attr:function(a,b,d,f){if(!a||a.nodeType===3||a.nodeType===8)return w;if(f&&b in c.attrFn)return c(a)[b](d);f=a.nodeType!==1||!c.isXMLDoc(a);var e=d!==w;b=f&&c.props[b]||b;if(a.nodeType===1){var j=$a.test(b);if(b in a&&f&&!j){if(e){b==="type"&&ab.test(a.nodeName)&&a.parentNode&&c.error("type property can't be changed");a[b]=d}if(c.nodeName(a,"form")&&a.getAttributeNode(b))return a.getAttributeNode(b).nodeValue;if(b==="tabIndex")return(b=a.getAttributeNode("tabIndex"))&&b.specified?b.value:bb.test(a.nodeName)||cb.test(a.nodeName)&&a.href?0:w;return a[b]}if(!c.support.style&&f&&b==="style"){if(e)a.style.cssText=""+d;return a.style.cssText}e&&a.setAttribute(b,""+d);a=!c.support.hrefNormalized&&f&&j?a.getAttribute(b,2):a.getAttribute(b);return a===null?w:a}return c.style(a,b,d)}});var O=/\.(.*)$/,db=function(a){return a.replace(/[^\w\s\.\|`]/g,function(b){return"\\"+b})};c.event={add:function(a,b,d,f){if(!(a.nodeType===3||a.nodeType===8)){if(a.setInterval&&a!==A&&!a.frameElement)a=A;var e,j;if(d.handler){e=d;d=e.handler}if(!d.guid)d.guid=c.guid++;if(j=c.data(a)){var i=j.events=j.events||{},o=j.handle;if(!o)j.handle=o=function(){return typeof c!=="undefined"&&!c.event.triggered?c.event.handle.apply(o.elem,arguments):w};o.elem=a;b=b.split(" ");for(var k,n=0,r;k=b[n++];){j=e?c.extend({},e):{handler:d,data:f};if(k.indexOf(".")>-1){r=k.split(".");k=r.shift();j.namespace=r.slice(0).sort().join(".")}else{r=[];j.namespace=""}j.type=k;j.guid=d.guid;var u=i[k],z=c.event.special[k]||{};if(!u){u=i[k]=[];if(!z.setup||z.setup.call(a,f,r,o)===false)if(a.addEventListener)a.addEventListener(k,o,false);else a.attachEvent&&a.attachEvent("on"+k,o)}if(z.add){z.add.call(a,j);if(!j.handler.guid)j.handler.guid=d.guid}u.push(j);c.event.global[k]=true}a=null}}},global:{},remove:function(a,b,d,f){if(!(a.nodeType===3||a.nodeType===8)){var e,j=0,i,o,k,n,r,u,z=c.data(a),C=z&&z.events;if(z&&C){if(b&&b.type){d=b.handler;b=b.type}if(!b||typeof b==="string"&&b.charAt(0)==="."){b=b||"";for(e in C)c.event.remove(a,e+b)}else{for(b=b.split(" ");e=b[j++];){n=e;i=e.indexOf(".")<0;o=[];if(!i){o=e.split(".");e=o.shift();k=new RegExp("(^|\\.)"+c.map(o.slice(0).sort(),db).join("\\.(?:.*\\.)?")+"(\\.|$)")}if(r=C[e])if(d){n=c.event.special[e]||{};for(B=f||0;B<r.length;B++){u=r[B];if(d.guid===u.guid){if(i||k.test(u.namespace)){f==null&&r.splice(B--,1);n.remove&&n.remove.call(a,u)}if(f!=null)break}}if(r.length===0||f!=null&&r.length===1){if(!n.teardown||n.teardown.call(a,o)===false)Ca(a,e,z.handle);delete C[e]}}else for(var B=0;B<r.length;B++){u=r[B];if(i||k.test(u.namespace)){c.event.remove(a,n,u.handler,B);r.splice(B--,1)}}}if(c.isEmptyObject(C)){if(b=z.handle)b.elem=null;delete z.events;delete z.handle;c.isEmptyObject(z)&&c.removeData(a)}}}}},trigger:function(a,b,d,f){var e=a.type||a;if(!f){a=typeof a==="object"?a[G]?a:c.extend(c.Event(e),a):c.Event(e);if(e.indexOf("!")>=0){a.type=e=e.slice(0,-1);a.exclusive=true}if(!d){a.stopPropagation();c.event.global[e]&&c.each(c.cache,function(){this.events&&this.events[e]&&c.event.trigger(a,b,this.handle.elem)})}if(!d||d.nodeType===3||d.nodeType===8)return w;a.result=w;a.target=d;b=c.makeArray(b);b.unshift(a)}a.currentTarget=d;(f=c.data(d,"handle"))&&f.apply(d,b);f=d.parentNode||d.ownerDocument;try{if(!(d&&d.nodeName&&c.noData[d.nodeName.toLowerCase()]))if(d["on"+e]&&d["on"+e].apply(d,b)===false)a.result=false}catch(j){}if(!a.isPropagationStopped()&&f)c.event.trigger(a,b,f,true);else if(!a.isDefaultPrevented()){f=a.target;var i,o=c.nodeName(f,"a")&&e==="click",k=c.event.special[e]||{};if((!k._default||k._default.call(d,a)===false)&&!o&&!(f&&f.nodeName&&c.noData[f.nodeName.toLowerCase()])){try{if(f[e]){if(i=f["on"+e])f["on"+e]=null;c.event.triggered=true;f[e]()}}catch(n){}if(i)f["on"+e]=i;c.event.triggered=false}}},handle:function(a){var b,d,f,e;a=arguments[0]=c.event.fix(a||A.event);a.currentTarget=this;b=a.type.indexOf(".")<0&&!a.exclusive;if(!b){d=a.type.split(".");a.type=d.shift();f=new RegExp("(^|\\.)"+d.slice(0).sort().join("\\.(?:.*\\.)?")+"(\\.|$)")}e=c.data(this,"events");d=e[a.type];if(e&&d){d=d.slice(0);e=0;for(var j=d.length;e<j;e++){var i=d[e];if(b||f.test(i.namespace)){a.handler=i.handler;a.data=i.data;a.handleObj=i;i=i.handler.apply(this,arguments);if(i!==w){a.result=i;if(i===false){a.preventDefault();a.stopPropagation()}}if(a.isImmediatePropagationStopped())break}}}return a.result},props:"altKey attrChange attrName bubbles button cancelable charCode clientX clientY ctrlKey currentTarget data detail eventPhase fromElement handler keyCode layerX layerY metaKey newValue offsetX offsetY originalTarget pageX pageY prevValue relatedNode relatedTarget screenX screenY shiftKey srcElement target toElement view wheelDelta which".split(" "),fix:function(a){if(a[G])return a;var b=a;a=c.Event(b);for(var d=this.props.length,f;d;){f=this.props[--d];a[f]=b[f]}if(!a.target)a.target=a.srcElement||s;if(a.target.nodeType===3)a.target=a.target.parentNode;if(!a.relatedTarget&&a.fromElement)a.relatedTarget=a.fromElement===a.target?a.toElement:a.fromElement;if(a.pageX==null&&a.clientX!=null){b=s.documentElement;d=s.body;a.pageX=a.clientX+(b&&b.scrollLeft||d&&d.scrollLeft||0)-(b&&b.clientLeft||d&&d.clientLeft||0);a.pageY=a.clientY+(b&&b.scrollTop||d&&d.scrollTop||0)-(b&&b.clientTop||d&&d.clientTop||0)}if(!a.which&&(a.charCode||a.charCode===0?a.charCode:a.keyCode))a.which=a.charCode||a.keyCode;if(!a.metaKey&&a.ctrlKey)a.metaKey=a.ctrlKey;if(!a.which&&a.button!==w)a.which=a.button&1?1:a.button&2?3:a.button&4?2:0;return a},guid:1E8,proxy:c.proxy,special:{ready:{setup:c.bindReady,teardown:c.noop},live:{add:function(a){c.event.add(this,a.origType,c.extend({},a,{handler:oa}))},remove:function(a){var b=true,d=a.origType.replace(O,"");c.each(c.data(this,"events").live||[],function(){if(d===this.origType.replace(O,""))return b=false});b&&c.event.remove(this,a.origType,oa)}},beforeunload:{setup:function(a,b,d){if(this.setInterval)this.onbeforeunload=d;return false},teardown:function(a,b){if(this.onbeforeunload===b)this.onbeforeunload=null}}}};var Ca=s.removeEventListener?function(a,b,d){a.removeEventListener(b,d,false)}:function(a,b,d){a.detachEvent("on"+b,d)};c.Event=function(a){if(!this.preventDefault)return new c.Event(a);if(a&&a.type){this.originalEvent=a;this.type=a.type}else this.type=a;this.timeStamp=J();this[G]=true};c.Event.prototype={preventDefault:function(){this.isDefaultPrevented=Z;var a=this.originalEvent;if(a){a.preventDefault&&a.preventDefault();a.returnValue=false}},stopPropagation:function(){this.isPropagationStopped=Z;var a=this.originalEvent;if(a){a.stopPropagation&&a.stopPropagation();a.cancelBubble=true}},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=Z;this.stopPropagation()},isDefaultPrevented:Y,isPropagationStopped:Y,isImmediatePropagationStopped:Y};var Da=function(a){var b=a.relatedTarget;try{for(;b&&b!==this;)b=b.parentNode;if(b!==this){a.type=a.data;c.event.handle.apply(this,arguments)}}catch(d){}},Ea=function(a){a.type=a.data;c.event.handle.apply(this,arguments)};c.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(a,b){c.event.special[a]={setup:function(d){c.event.add(this,b,d&&d.selector?Ea:Da,a)},teardown:function(d){c.event.remove(this,b,d&&d.selector?Ea:Da)}}});if(!c.support.submitBubbles)c.event.special.submit={setup:function(){if(this.nodeName.toLowerCase()!=="form"){c.event.add(this,"click.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="submit"||d==="image")&&c(b).closest("form").length)return na("submit",this,arguments)});c.event.add(this,"keypress.specialSubmit",function(a){var b=a.target,d=b.type;if((d==="text"||d==="password")&&c(b).closest("form").length&&a.keyCode===13)return na("submit",this,arguments)})}else return false},teardown:function(){c.event.remove(this,".specialSubmit")}};if(!c.support.changeBubbles){var da=/textarea|input|select/i,ea,Fa=function(a){var b=a.type,d=a.value;if(b==="radio"||b==="checkbox")d=a.checked;else if(b==="select-multiple")d=a.selectedIndex>-1?c.map(a.options,function(f){return f.selected}).join("-"):"";else if(a.nodeName.toLowerCase()==="select")d=a.selectedIndex;return d},fa=function(a,b){var d=a.target,f,e;if(!(!da.test(d.nodeName)||d.readOnly)){f=c.data(d,"_change_data");e=Fa(d);if(a.type!=="focusout"||d.type!=="radio")c.data(d,"_change_data",e);if(!(f===w||e===f))if(f!=null||e){a.type="change";return c.event.trigger(a,b,d)}}};c.event.special.change={filters:{focusout:fa,click:function(a){var b=a.target,d=b.type;if(d==="radio"||d==="checkbox"||b.nodeName.toLowerCase()==="select")return fa.call(this,a)},keydown:function(a){var b=a.target,d=b.type;if(a.keyCode===13&&b.nodeName.toLowerCase()!=="textarea"||a.keyCode===32&&(d==="checkbox"||d==="radio")||d==="select-multiple")return fa.call(this,a)},beforeactivate:function(a){a=a.target;c.data(a,"_change_data",Fa(a))}},setup:function(){if(this.type==="file")return false;for(var a in ea)c.event.add(this,a+".specialChange",ea[a]);return da.test(this.nodeName)},teardown:function(){c.event.remove(this,".specialChange");return da.test(this.nodeName)}};ea=c.event.special.change.filters}s.addEventListener&&c.each({focus:"focusin",blur:"focusout"},function(a,b){function d(f){f=c.event.fix(f);f.type=b;return c.event.handle.call(this,f)}c.event.special[b]={setup:function(){this.addEventListener(a,d,true)},teardown:function(){this.removeEventListener(a,d,true)}}});c.each(["bind","one"],function(a,b){c.fn[b]=function(d,f,e){if(typeof d==="object"){for(var j in d)this[b](j,f,d[j],e);return this}if(c.isFunction(f)){e=f;f=w}var i=b==="one"?c.proxy(e,function(k){c(this).unbind(k,i);return e.apply(this,arguments)}):e;if(d==="unload"&&b!=="one")this.one(d,f,e);else{j=0;for(var o=this.length;j<o;j++)c.event.add(this[j],d,i,f)}return this}});c.fn.extend({unbind:function(a,b){if(typeof a==="object"&&!a.preventDefault)for(var d in a)this.unbind(d,a[d]);else{d=0;for(var f=this.length;d<f;d++)c.event.remove(this[d],a,b)}return this},delegate:function(a,b,d,f){return this.live(b,d,f,a)},undelegate:function(a,b,d){return arguments.length===0?this.unbind("live"):this.die(b,null,d,a)},trigger:function(a,b){return this.each(function(){c.event.trigger(a,b,this)})},triggerHandler:function(a,b){if(this[0]){a=c.Event(a);a.preventDefault();a.stopPropagation();c.event.trigger(a,b,this[0]);return a.result}},toggle:function(a){for(var b=arguments,d=1;d<b.length;)c.proxy(a,b[d++]);return this.click(c.proxy(a,function(f){var e=(c.data(this,"lastToggle"+a.guid)||0)%d;c.data(this,"lastToggle"+a.guid,e+1);f.preventDefault();return b[e].apply(this,arguments)||false}))},hover:function(a,b){return this.mouseenter(a).mouseleave(b||a)}});var Ga={focus:"focusin",blur:"focusout",mouseenter:"mouseover",mouseleave:"mouseout"};c.each(["live","die"],function(a,b){c.fn[b]=function(d,f,e,j){var i,o=0,k,n,r=j||this.selector,u=j?this:c(this.context);if(c.isFunction(f)){e=f;f=w}for(d=(d||"").split(" ");(i=d[o++])!=null;){j=O.exec(i);k="";if(j){k=j[0];i=i.replace(O,"")}if(i==="hover")d.push("mouseenter"+k,"mouseleave"+k);else{n=i;if(i==="focus"||i==="blur"){d.push(Ga[i]+k);i+=k}else i=(Ga[i]||i)+k;b==="live"?u.each(function(){c.event.add(this,pa(i,r),{data:f,selector:r,handler:e,origType:i,origHandler:e,preType:n})}):u.unbind(pa(i,r),e)}}return this}});c.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error".split(" "),function(a,b){c.fn[b]=function(d){return d?this.bind(b,d):this.trigger(b)};if(c.attrFn)c.attrFn[b]=true});A.attachEvent&&!A.addEventListener&&A.attachEvent("onunload",function(){for(var a in c.cache)if(c.cache[a].handle)try{c.event.remove(c.cache[a].handle.elem)}catch(b){}});(function(){function a(g){for(var h="",l,m=0;g[m];m++){l=g[m];if(l.nodeType===3||l.nodeType===4)h+=l.nodeValue;else if(l.nodeType!==8)h+=a(l.childNodes)}return h}function b(g,h,l,m,q,p){q=0;for(var v=m.length;q<v;q++){var t=m[q];if(t){t=t[g];for(var y=false;t;){if(t.sizcache===l){y=m[t.sizset];break}if(t.nodeType===1&&!p){t.sizcache=l;t.sizset=q}if(t.nodeName.toLowerCase()===h){y=t;break}t=t[g]}m[q]=y}}}function d(g,h,l,m,q,p){q=0;for(var v=m.length;q<v;q++){var t=m[q];if(t){t=t[g];for(var y=false;t;){if(t.sizcache===l){y=m[t.sizset];break}if(t.nodeType===1){if(!p){t.sizcache=l;t.sizset=q}if(typeof h!=="string"){if(t===h){y=true;break}}else if(k.filter(h,[t]).length>0){y=t;break}}t=t[g]}m[q]=y}}}var f=/((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^[\]]*\]|['"][^'"]*['"]|[^[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g,e=0,j=Object.prototype.toString,i=false,o=true;[0,0].sort(function(){o=false;return 0});var k=function(g,h,l,m){l=l||[];var q=h=h||s;if(h.nodeType!==1&&h.nodeType!==9)return[];if(!g||typeof g!=="string")return l;for(var p=[],v,t,y,S,H=true,M=x(h),I=g;(f.exec(""),v=f.exec(I))!==null;){I=v[3];p.push(v[1]);if(v[2]){S=v[3];break}}if(p.length>1&&r.exec(g))if(p.length===2&&n.relative[p[0]])t=ga(p[0]+p[1],h);else for(t=n.relative[p[0]]?[h]:k(p.shift(),h);p.length;){g=p.shift();if(n.relative[g])g+=p.shift();t=ga(g,t)}else{if(!m&&p.length>1&&h.nodeType===9&&!M&&n.match.ID.test(p[0])&&!n.match.ID.test(p[p.length-1])){v=k.find(p.shift(),h,M);h=v.expr?k.filter(v.expr,v.set)[0]:v.set[0]}if(h){v=m?{expr:p.pop(),set:z(m)}:k.find(p.pop(),p.length===1&&(p[0]==="~"||p[0]==="+")&&h.parentNode?h.parentNode:h,M);t=v.expr?k.filter(v.expr,v.set):v.set;if(p.length>0)y=z(t);else H=false;for(;p.length;){var D=p.pop();v=D;if(n.relative[D])v=p.pop();else D="";if(v==null)v=h;n.relative[D](y,v,M)}}else y=[]}y||(y=t);y||k.error(D||g);if(j.call(y)==="[object Array]")if(H)if(h&&h.nodeType===1)for(g=0;y[g]!=null;g++){if(y[g]&&(y[g]===true||y[g].nodeType===1&&E(h,y[g])))l.push(t[g])}else for(g=0;y[g]!=null;g++)y[g]&&y[g].nodeType===1&&l.push(t[g]);else l.push.apply(l,y);else z(y,l);if(S){k(S,q,l,m);k.uniqueSort(l)}return l};k.uniqueSort=function(g){if(B){i=o;g.sort(B);if(i)for(var h=1;h<g.length;h++)g[h]===g[h-1]&&g.splice(h--,1)}return g};k.matches=function(g,h){return k(g,null,null,h)};k.find=function(g,h,l){var m,q;if(!g)return[];for(var p=0,v=n.order.length;p<v;p++){var t=n.order[p];if(q=n.leftMatch[t].exec(g)){var y=q[1];q.splice(1,1);if(y.substr(y.length-1)!=="\\"){q[1]=(q[1]||"").replace(/\\/g,"");m=n.find[t](q,h,l);if(m!=null){g=g.replace(n.match[t],"");break}}}}m||(m=h.getElementsByTagName("*"));return{set:m,expr:g}};k.filter=function(g,h,l,m){for(var q=g,p=[],v=h,t,y,S=h&&h[0]&&x(h[0]);g&&h.length;){for(var H in n.filter)if((t=n.leftMatch[H].exec(g))!=null&&t[2]){var M=n.filter[H],I,D;D=t[1];y=false;t.splice(1,1);if(D.substr(D.length-1)!=="\\"){if(v===p)p=[];if(n.preFilter[H])if(t=n.preFilter[H](t,v,l,p,m,S)){if(t===true)continue}else y=I=true;if(t)for(var U=0;(D=v[U])!=null;U++)if(D){I=M(D,t,U,v);var Ha=m^!!I;if(l&&I!=null)if(Ha)y=true;else v[U]=false;else if(Ha){p.push(D);y=true}}if(I!==w){l||(v=p);g=g.replace(n.match[H],"");if(!y)return[];break}}}if(g===q)if(y==null)k.error(g);else break;q=g}return v};k.error=function(g){throw"Syntax error, unrecognized expression: "+g;};var n=k.selectors={order:["ID","NAME","TAG"],match:{ID:/#((?:[\w\u00c0-\uFFFF-]|\\.)+)/,CLASS:/\.((?:[\w\u00c0-\uFFFF-]|\\.)+)/,NAME:/\[name=['"]*((?:[\w\u00c0-\uFFFF-]|\\.)+)['"]*\]/,ATTR:/\[\s*((?:[\w\u00c0-\uFFFF-]|\\.)+)\s*(?:(\S?=)\s*(['"]*)(.*?)\3|)\s*\]/,TAG:/^((?:[\w\u00c0-\uFFFF\*-]|\\.)+)/,CHILD:/:(only|nth|last|first)-child(?:\((even|odd|[\dn+-]*)\))?/,POS:/:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^-]|$)/,PSEUDO:/:((?:[\w\u00c0-\uFFFF-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/},leftMatch:{},attrMap:{"class":"className","for":"htmlFor"},attrHandle:{href:function(g){return g.getAttribute("href")}},relative:{"+":function(g,h){var l=typeof h==="string",m=l&&!/\W/.test(h);l=l&&!m;if(m)h=h.toLowerCase();m=0;for(var q=g.length,p;m<q;m++)if(p=g[m]){for(;(p=p.previousSibling)&&p.nodeType!==1;);g[m]=l||p&&p.nodeName.toLowerCase()===h?p||false:p===h}l&&k.filter(h,g,true)},">":function(g,h){var l=typeof h==="string";if(l&&!/\W/.test(h)){h=h.toLowerCase();for(var m=0,q=g.length;m<q;m++){var p=g[m];if(p){l=p.parentNode;g[m]=l.nodeName.toLowerCase()===h?l:false}}}else{m=0;for(q=g.length;m<q;m++)if(p=g[m])g[m]=l?p.parentNode:p.parentNode===h;l&&k.filter(h,g,true)}},"":function(g,h,l){var m=e++,q=d;if(typeof h==="string"&&!/\W/.test(h)){var p=h=h.toLowerCase();q=b}q("parentNode",h,m,g,p,l)},"~":function(g,h,l){var m=e++,q=d;if(typeof h==="string"&&!/\W/.test(h)){var p=h=h.toLowerCase();q=b}q("previousSibling",h,m,g,p,l)}},find:{ID:function(g,h,l){if(typeof h.getElementById!=="undefined"&&!l)return(g=h.getElementById(g[1]))?[g]:[]},NAME:function(g,h){if(typeof h.getElementsByName!=="undefined"){var l=[];h=h.getElementsByName(g[1]);for(var m=0,q=h.length;m<q;m++)h[m].getAttribute("name")===g[1]&&l.push(h[m]);return l.length===0?null:l}},TAG:function(g,h){return h.getElementsByTagName(g[1])}},preFilter:{CLASS:function(g,h,l,m,q,p){g=" "+g[1].replace(/\\/g,"")+" ";if(p)return g;p=0;for(var v;(v=h[p])!=null;p++)if(v)if(q^(v.className&&(" "+v.className+" ").replace(/[\t\n]/g," ").indexOf(g)>=0))l||m.push(v);else if(l)h[p]=false;return false},ID:function(g){return g[1].replace(/\\/g,"")},TAG:function(g){return g[1].toLowerCase()},CHILD:function(g){if(g[1]==="nth"){var h=/(-?)(\d*)n((?:\+|-)?\d*)/.exec(g[2]==="even"&&"2n"||g[2]==="odd"&&"2n+1"||!/\D/.test(g[2])&&"0n+"+g[2]||g[2]);g[2]=h[1]+(h[2]||1)-0;g[3]=h[3]-0}g[0]=e++;return g},ATTR:function(g,h,l,m,q,p){h=g[1].replace(/\\/g,"");if(!p&&n.attrMap[h])g[1]=n.attrMap[h];if(g[2]==="~=")g[4]=" "+g[4]+" ";return g},PSEUDO:function(g,h,l,m,q){if(g[1]==="not")if((f.exec(g[3])||"").length>1||/^\w/.test(g[3]))g[3]=k(g[3],null,null,h);else{g=k.filter(g[3],h,l,true^q);l||m.push.apply(m,g);return false}else if(n.match.POS.test(g[0])||n.match.CHILD.test(g[0]))return true;return g},POS:function(g){g.unshift(true);return g}},filters:{enabled:function(g){return g.disabled===false&&g.type!=="hidden"},disabled:function(g){return g.disabled===true},checked:function(g){return g.checked===true},selected:function(g){return g.selected===true},parent:function(g){return!!g.firstChild},empty:function(g){return!g.firstChild},has:function(g,h,l){return!!k(l[3],g).length},header:function(g){return/h\d/i.test(g.nodeName)},text:function(g){return"text"===g.type},radio:function(g){return"radio"===g.type},checkbox:function(g){return"checkbox"===g.type},file:function(g){return"file"===g.type},password:function(g){return"password"===g.type},submit:function(g){return"submit"===g.type},image:function(g){return"image"===g.type},reset:function(g){return"reset"===g.type},button:function(g){return"button"===g.type||g.nodeName.toLowerCase()==="button"},input:function(g){return/input|select|textarea|button/i.test(g.nodeName)}},setFilters:{first:function(g,h){return h===0},last:function(g,h,l,m){return h===m.length-1},even:function(g,h){return h%2===0},odd:function(g,h){return h%2===1},lt:function(g,h,l){return h<l[3]-0},gt:function(g,h,l){return h>l[3]-0},nth:function(g,h,l){return l[3]-0===h},eq:function(g,h,l){return l[3]-0===h}},filter:{PSEUDO:function(g,h,l,m){var q=h[1],p=n.filters[q];if(p)return p(g,l,h,m);else if(q==="contains")return(g.textContent||g.innerText||a([g])||"").indexOf(h[3])>=0;else if(q==="not"){h=h[3];l=0;for(m=h.length;l<m;l++)if(h[l]===g)return false;return true}else k.error("Syntax error, unrecognized expression: "+q)},CHILD:function(g,h){var l=h[1],m=g;switch(l){case "only":case "first":for(;m=m.previousSibling;)if(m.nodeType===1)return false;if(l==="first")return true;m=g;case "last":for(;m=m.nextSibling;)if(m.nodeType===1)return false;return true;case "nth":l=h[2];var q=h[3];if(l===1&&q===0)return true;h=h[0];var p=g.parentNode;if(p&&(p.sizcache!==h||!g.nodeIndex)){var v=0;for(m=p.firstChild;m;m=m.nextSibling)if(m.nodeType===1)m.nodeIndex=++v;p.sizcache=h}g=g.nodeIndex-q;return l===0?g===0:g%l===0&&g/l>=0}},ID:function(g,h){return g.nodeType===1&&g.getAttribute("id")===h},TAG:function(g,h){return h==="*"&&g.nodeType===1||g.nodeName.toLowerCase()===h},CLASS:function(g,h){return(" "+(g.className||g.getAttribute("class"))+" ").indexOf(h)>-1},ATTR:function(g,h){var l=h[1];g=n.attrHandle[l]?n.attrHandle[l](g):g[l]!=null?g[l]:g.getAttribute(l);l=g+"";var m=h[2];h=h[4];return g==null?m==="!=":m==="="?l===h:m==="*="?l.indexOf(h)>=0:m==="~="?(" "+l+" ").indexOf(h)>=0:!h?l&&g!==false:m==="!="?l!==h:m==="^="?l.indexOf(h)===0:m==="$="?l.substr(l.length-h.length)===h:m==="|="?l===h||l.substr(0,h.length+1)===h+"-":false},POS:function(g,h,l,m){var q=n.setFilters[h[2]];if(q)return q(g,l,h,m)}}},r=n.match.POS;for(var u in n.match){n.match[u]=new RegExp(n.match[u].source+/(?![^\[]*\])(?![^\(]*\))/.source);n.leftMatch[u]=new RegExp(/(^(?:.|\r|\n)*?)/.source+n.match[u].source.replace(/\\(\d+)/g,function(g,h){return"\\"+(h-0+1)}))}var z=function(g,h){g=Array.prototype.slice.call(g,0);if(h){h.push.apply(h,g);return h}return g};try{Array.prototype.slice.call(s.documentElement.childNodes,0)}catch(C){z=function(g,h){h=h||[];if(j.call(g)==="[object Array]")Array.prototype.push.apply(h,g);else if(typeof g.length==="number")for(var l=0,m=g.length;l<m;l++)h.push(g[l]);else for(l=0;g[l];l++)h.push(g[l]);return h}}var B;if(s.documentElement.compareDocumentPosition)B=function(g,h){if(!g.compareDocumentPosition||!h.compareDocumentPosition){if(g==h)i=true;return g.compareDocumentPosition?-1:1}g=g.compareDocumentPosition(h)&4?-1:g===h?0:1;if(g===0)i=true;return g};else if("sourceIndex"in s.documentElement)B=function(g,h){if(!g.sourceIndex||!h.sourceIndex){if(g==h)i=true;return g.sourceIndex?-1:1}g=g.sourceIndex-h.sourceIndex;if(g===0)i=true;return g};else if(s.createRange)B=function(g,h){if(!g.ownerDocument||!h.ownerDocument){if(g==h)i=true;return g.ownerDocument?-1:1}var l=g.ownerDocument.createRange(),m=h.ownerDocument.createRange();l.setStart(g,0);l.setEnd(g,0);m.setStart(h,0);m.setEnd(h,0);g=l.compareBoundaryPoints(Range.START_TO_END,m);if(g===0)i=true;return g};(function(){var g=s.createElement("div"),h="script"+(new Date).getTime();g.innerHTML="<a name='"+h+"'/>";var l=s.documentElement;l.insertBefore(g,l.firstChild);if(s.getElementById(h)){n.find.ID=function(m,q,p){if(typeof q.getElementById!=="undefined"&&!p)return(q=q.getElementById(m[1]))?q.id===m[1]||typeof q.getAttributeNode!=="undefined"&&q.getAttributeNode("id").nodeValue===m[1]?[q]:w:[]};n.filter.ID=function(m,q){var p=typeof m.getAttributeNode!=="undefined"&&m.getAttributeNode("id");return m.nodeType===1&&p&&p.nodeValue===q}}l.removeChild(g);l=g=null})();(function(){var g=s.createElement("div");g.appendChild(s.createComment(""));if(g.getElementsByTagName("*").length>0)n.find.TAG=function(h,l){l=l.getElementsByTagName(h[1]);if(h[1]==="*"){h=[];for(var m=0;l[m];m++)l[m].nodeType===1&&h.push(l[m]);l=h}return l};g.innerHTML="<a href='#'></a>";if(g.firstChild&&typeof g.firstChild.getAttribute!=="undefined"&&g.firstChild.getAttribute("href")!=="#")n.attrHandle.href=function(h){return h.getAttribute("href",2)};g=null})();s.querySelectorAll&&function(){var g=k,h=s.createElement("div");h.innerHTML="<p class='TEST'></p>";if(!(h.querySelectorAll&&h.querySelectorAll(".TEST").length===0)){k=function(m,q,p,v){q=q||s;if(!v&&q.nodeType===9&&!x(q))try{return z(q.querySelectorAll(m),p)}catch(t){}return g(m,q,p,v)};for(var l in g)k[l]=g[l];h=null}}();(function(){var g=s.createElement("div");g.innerHTML="<div class='test e'></div><div class='test'></div>";if(!(!g.getElementsByClassName||g.getElementsByClassName("e").length===0)){g.lastChild.className="e";if(g.getElementsByClassName("e").length!==1){n.order.splice(1,0,"CLASS");n.find.CLASS=function(h,l,m){if(typeof l.getElementsByClassName!=="undefined"&&!m)return l.getElementsByClassName(h[1])};g=null}}})();var E=s.compareDocumentPosition?function(g,h){return!!(g.compareDocumentPosition(h)&16)}:function(g,h){return g!==h&&(g.contains?g.contains(h):true)},x=function(g){return(g=(g?g.ownerDocument||g:0).documentElement)?g.nodeName!=="HTML":false},ga=function(g,h){var l=[],m="",q;for(h=h.nodeType?[h]:h;q=n.match.PSEUDO.exec(g);){m+=q[0];g=g.replace(n.match.PSEUDO,"")}g=n.relative[g]?g+"*":g;q=0;for(var p=h.length;q<p;q++)k(g,h[q],l);return k.filter(m,l)};c.find=k;c.expr=k.selectors;c.expr[":"]=c.expr.filters;c.unique=k.uniqueSort;c.text=a;c.isXMLDoc=x;c.contains=E})();var eb=/Until$/,fb=/^(?:parents|prevUntil|prevAll)/,gb=/,/;R=Array.prototype.slice;var Ia=function(a,b,d){if(c.isFunction(b))return c.grep(a,function(e,j){return!!b.call(e,j,e)===d});else if(b.nodeType)return c.grep(a,function(e){return e===b===d});else if(typeof b==="string"){var f=c.grep(a,function(e){return e.nodeType===1});if(Ua.test(b))return c.filter(b,f,!d);else b=c.filter(b,f)}return c.grep(a,function(e){return c.inArray(e,b)>=0===d})};c.fn.extend({find:function(a){for(var b=this.pushStack("","find",a),d=0,f=0,e=this.length;f<e;f++){d=b.length;c.find(a,this[f],b);if(f>0)for(var j=d;j<b.length;j++)for(var i=0;i<d;i++)if(b[i]===b[j]){b.splice(j--,1);break}}return b},has:function(a){var b=c(a);return this.filter(function(){for(var d=0,f=b.length;d<f;d++)if(c.contains(this,b[d]))return true})},not:function(a){return this.pushStack(Ia(this,a,false),"not",a)},filter:function(a){return this.pushStack(Ia(this,a,true),"filter",a)},is:function(a){return!!a&&c.filter(a,this).length>0},closest:function(a,b){if(c.isArray(a)){var d=[],f=this[0],e,j={},i;if(f&&a.length){e=0;for(var o=a.length;e<o;e++){i=a[e];j[i]||(j[i]=c.expr.match.POS.test(i)?c(i,b||this.context):i)}for(;f&&f.ownerDocument&&f!==b;){for(i in j){e=j[i];if(e.jCSFG?e.index(f)>-1:c(f).is(e)){d.push({selector:i,elem:f});delete j[i]}}f=f.parentNode}}return d}var k=c.expr.match.POS.test(a)?c(a,b||this.context):null;return this.map(function(n,r){for(;r&&r.ownerDocument&&r!==b;){if(k?k.index(r)>-1:c(r).is(a))return r;r=r.parentNode}return null})},index:function(a){if(!a||typeof a==="string")return c.inArray(this[0],a?c(a):this.parent().children());return c.inArray(a.jCSFG?a[0]:a,this)},add:function(a,b){a=typeof a==="string"?c(a,b||this.context):c.makeArray(a);b=c.merge(this.get(),a);return this.pushStack(qa(a[0])||qa(b[0])?b:c.unique(b))},andSelf:function(){return this.add(this.prevObject)}});c.each({parent:function(a){return(a=a.parentNode)&&a.nodeType!==11?a:null},parents:function(a){return c.dir(a,"parentNode")},parentsUntil:function(a,b,d){return c.dir(a,"parentNode",d)},next:function(a){return c.nth(a,2,"nextSibling")},prev:function(a){return c.nth(a,2,"previousSibling")},nextAll:function(a){return c.dir(a,"nextSibling")},prevAll:function(a){return c.dir(a,"previousSibling")},nextUntil:function(a,b,d){return c.dir(a,"nextSibling",d)},prevUntil:function(a,b,d){return c.dir(a,"previousSibling",d)},siblings:function(a){return c.sibling(a.parentNode.firstChild,a)},children:function(a){return c.sibling(a.firstChild)},contents:function(a){return c.nodeName(a,"iframe")?a.contentDocument||a.contentWindow.document:c.makeArray(a.childNodes)}},function(a,b){c.fn[a]=function(d,f){var e=c.map(this,b,d);eb.test(a)||(f=d);if(f&&typeof f==="string")e=c.filter(f,e);e=this.length>1?c.unique(e):e;if((this.length>1||gb.test(f))&&fb.test(a))e=e.reverse();return this.pushStack(e,a,R.call(arguments).join(","))}});c.extend({filter:function(a,b,d){if(d)a=":not("+a+")";return c.find.matches(a,b)},dir:function(a,b,d){var f=[];for(a=a[b];a&&a.nodeType!==9&&(d===w||a.nodeType!==1||!c(a).is(d));){a.nodeType===1&&f.push(a);a=a[b]}return f},nth:function(a,b,d){b=b||1;for(var f=0;a;a=a[d])if(a.nodeType===1&&++f===b)break;return a},sibling:function(a,b){for(var d=[];a;a=a.nextSibling)a.nodeType===1&&a!==b&&d.push(a);return d}});var Ja=/ jCSFG\d+="(?:\d+|null)"/g,V=/^\s+/,Ka=/(<([\w:]+)[^>]*?)\/>/g,hb=/^(?:area|br|col|embed|hr|img|input|link|meta|param)$/i,La=/<([\w:]+)/,ib=/<tbody/i,jb=/<|&#?\w+;/,ta=/<script|<object|<embed|<option|<style/i,ua=/checked\s*(?:[^=]|=\s*.checked.)/i,Ma=function(a,b,d){return hb.test(d)?a:b+"></"+d+">"},F={option:[1,"<select multiple='multiple'>","</select>"],legend:[1,"<fieldset>","</fieldset>"],thead:[1,"<table>","</table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],col:[2,"<table><tbody></tbody><colgroup>","</colgroup></table>"],area:[1,"<map>","</map>"],_default:[0,"",""]};F.optgroup=F.option;F.tbody=F.tfoot=F.colgroup=F.caption=F.thead;F.th=F.td;if(!c.support.htmlSerialize)F._default=[1,"div<div>","</div>"];c.fn.extend({text:function(a){if(c.isFunction(a))return this.each(function(b){var d=c(this);d.text(a.call(this,b,d.text()))});if(typeof a!=="object"&&a!==w)return this.empty().append((this[0]&&this[0].ownerDocument||s).createTextNode(a));return c.text(this)},wrapAll:function(a){if(c.isFunction(a))return this.each(function(d){c(this).wrapAll(a.call(this,d))});if(this[0]){var b=c(a,this[0].ownerDocument).eq(0).clone(true);this[0].parentNode&&b.insertBefore(this[0]);b.map(function(){for(var d=this;d.firstChild&&d.firstChild.nodeType===1;)d=d.firstChild;return d}).append(this)}return this},wrapInner:function(a){if(c.isFunction(a))return this.each(function(b){c(this).wrapInner(a.call(this,b))});return this.each(function(){var b=c(this),d=b.contents();d.length?d.wrapAll(a):b.append(a)})},wrap:function(a){return this.each(function(){c(this).wrapAll(a)})},unwrap:function(){return this.parent().each(function(){c.nodeName(this,"body")||c(this).replaceWith(this.childNodes)}).end()},append:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.appendChild(a)})},prepend:function(){return this.domManip(arguments,true,function(a){this.nodeType===1&&this.insertBefore(a,this.firstChild)})},before:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,this)});else if(arguments.length){var a=c(arguments[0]);a.push.apply(a,this.toArray());return this.pushStack(a,"before",arguments)}},after:function(){if(this[0]&&this[0].parentNode)return this.domManip(arguments,false,function(b){this.parentNode.insertBefore(b,this.nextSibling)});else if(arguments.length){var a=this.pushStack(this,"after",arguments);a.push.apply(a,c(arguments[0]).toArray());return a}},remove:function(a,b){for(var d=0,f;(f=this[d])!=null;d++)if(!a||c.filter(a,[f]).length){if(!b&&f.nodeType===1){c.cleanData(f.getElementsByTagName("*"));c.cleanData([f])}f.parentNode&&f.parentNode.removeChild(f)}return this},empty:function(){for(var a=0,b;(b=this[a])!=null;a++)for(b.nodeType===1&&c.cleanData(b.getElementsByTagName("*"));b.firstChild;)b.removeChild(b.firstChild);return this},clone:function(a){var b=this.map(function(){if(!c.support.noCloneEvent&&!c.isXMLDoc(this)){var d=this.outerHTML,f=this.ownerDocument;if(!d){d=f.createElement("div");d.appendChild(this.cloneNode(true));d=d.innerHTML}return c.clean([d.replace(Ja,"").replace(/=([^="'>\s]+\/)>/g,'="$1">').replace(V,"")],f)[0]}else return this.cloneNode(true)});if(a===true){ra(this,b);ra(this.find("*"),b.find("*"))}return b},html:function(a){if(a===w)return this[0]&&this[0].nodeType===1?this[0].innerHTML.replace(Ja,""):null;else if(typeof a==="string"&&!ta.test(a)&&(c.support.leadingWhitespace||!V.test(a))&&!F[(La.exec(a)||["",""])[1].toLowerCase()]){a=a.replace(Ka,Ma);try{for(var b=0,d=this.length;b<d;b++)if(this[b].nodeType===1){c.cleanData(this[b].getElementsByTagName("*"));this[b].innerHTML=a}}catch(f){this.empty().append(a)}}else c.isFunction(a)?this.each(function(e){var j=c(this),i=j.html();j.empty().append(function(){return a.call(this,e,i)})}):this.empty().append(a);return this},replaceWith:function(a){if(this[0]&&this[0].parentNode){if(c.isFunction(a))return this.each(function(b){var d=c(this),f=d.html();d.replaceWith(a.call(this,b,f))});if(typeof a!=="string")a=c(a).detach();return this.each(function(){var b=this.nextSibling,d=this.parentNode;c(this).remove();b?c(b).before(a):c(d).append(a)})}else return this.pushStack(c(c.isFunction(a)?a():a),"replaceWith",a)},detach:function(a){return this.remove(a,true)},domManip:function(a,b,d){function f(u){return c.nodeName(u,"table")?u.getElementsByTagName("tbody")[0]||u.appendChild(u.ownerDocument.createElement("tbody")):u}var e,j,i=a[0],o=[],k;if(!c.support.checkClone&&arguments.length===3&&typeof i==="string"&&ua.test(i))return this.each(function(){c(this).domManip(a,b,d,true)});if(c.isFunction(i))return this.each(function(u){var z=c(this);a[0]=i.call(this,u,b?z.html():w);z.domManip(a,b,d)});if(this[0]){e=i&&i.parentNode;e=c.support.parentNode&&e&&e.nodeType===11&&e.childNodes.length===this.length?{fragment:e}:sa(a,this,o);k=e.fragment;if(j=k.childNodes.length===1?(k=k.firstChild):k.firstChild){b=b&&c.nodeName(j,"tr");for(var n=0,r=this.length;n<r;n++)d.call(b?f(this[n],j):this[n],n>0||e.cacheable||this.length>1?k.cloneNode(true):k)}o.length&&c.each(o,Qa)}return this}});c.fragments={};c.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(a,b){c.fn[a]=function(d){var f=[];d=c(d);var e=this.length===1&&this[0].parentNode;if(e&&e.nodeType===11&&e.childNodes.length===1&&d.length===1){d[b](this[0]);return this}else{e=0;for(var j=d.length;e<j;e++){var i=(e>0?this.clone(true):this).get();c.fn[b].apply(c(d[e]),i);f=f.concat(i)}return this.pushStack(f,a,d.selector)}}});c.extend({clean:function(a,b,d,f){b=b||s;if(typeof b.createElement==="undefined")b=b.ownerDocument||b[0]&&b[0].ownerDocument||s;for(var e=[],j=0,i;(i=a[j])!=null;j++){if(typeof i==="number")i+="";if(i){if(typeof i==="string"&&!jb.test(i))i=b.createTextNode(i);else if(typeof i==="string"){i=i.replace(Ka,Ma);var o=(La.exec(i)||["",""])[1].toLowerCase(),k=F[o]||F._default,n=k[0],r=b.createElement("div");for(r.innerHTML=k[1]+i+k[2];n--;)r=r.lastChild;if(!c.support.tbody){n=ib.test(i);o=o==="table"&&!n?r.firstChild&&r.firstChild.childNodes:k[1]==="<table>"&&!n?r.childNodes:[];for(k=o.length-1;k>=0;--k)c.nodeName(o[k],"tbody")&&!o[k].childNodes.length&&o[k].parentNode.removeChild(o[k])}!c.support.leadingWhitespace&&V.test(i)&&r.insertBefore(b.createTextNode(V.exec(i)[0]),r.firstChild);i=r.childNodes}if(i.nodeType)e.push(i);else e=c.merge(e,i)}}if(d)for(j=0;e[j];j++)if(f&&c.nodeName(e[j],"script")&&(!e[j].type||e[j].type.toLowerCase()==="text/javascript"))f.push(e[j].parentNode?e[j].parentNode.removeChild(e[j]):e[j]);else{e[j].nodeType===1&&e.splice.apply(e,[j+1,0].concat(c.makeArray(e[j].getElementsByTagName("script"))));d.appendChild(e[j])}return e},cleanData:function(a){for(var b,d,f=c.cache,e=c.event.special,j=c.support.deleteExpando,i=0,o;(o=a[i])!=null;i++)if(d=o[c.expando]){b=f[d];if(b.events)for(var k in b.events)e[k]?c.event.remove(o,k):Ca(o,k,b.handle);if(j)delete o[c.expando];else o.removeAttribute&&o.removeAttribute(c.expando);delete f[d]}}});var kb=/z-?index|font-?weight|opacity|zoom|line-?height/i,Na=/alpha\([^)]*\)/,Oa=/opacity=([^)]*)/,ha=/float/i,ia=/-([a-z])/ig,lb=/([A-Z])/g,mb=/^-?\d+(?:px)?$/i,nb=/^-?\d/,ob={position:"absolute",visibility:"hidden",display:"block"},pb=["Left","Right"],qb=["Top","Bottom"],rb=s.defaultView&&s.defaultView.getComputedStyle,Pa=c.support.cssFloat?"cssFloat":"styleFloat",ja=function(a,b){return b.toUpperCase()};c.fn.css=function(a,b){return X(this,a,b,true,function(d,f,e){if(e===w)return c.curCSS(d,f);if(typeof e==="number"&&!kb.test(f))e+="px";c.style(d,f,e)})};c.extend({style:function(a,b,d){if(!a||a.nodeType===3||a.nodeType===8)return w;if((b==="width"||b==="height")&&parseFloat(d)<0)d=w;var f=a.style||a,e=d!==w;if(!c.support.opacity&&b==="opacity"){if(e){f.zoom=1;b=parseInt(d,10)+""==="NaN"?"":"alpha(opacity="+d*100+")";a=f.filter||c.curCSS(a,"filter")||"";f.filter=Na.test(a)?a.replace(Na,b):b}return f.filter&&f.filter.indexOf("opacity=")>=0?parseFloat(Oa.exec(f.filter)[1])/100+"":""}if(ha.test(b))b=Pa;b=b.replace(ia,ja);if(e)f[b]=d;return f[b]},css:function(a,b,d,f){if(b==="width"||b==="height"){var e,j=b==="width"?pb:qb;function i(){e=b==="width"?a.offsetWidth:a.offsetHeight;f!=="border"&&c.each(j,function(){f||(e-=parseFloat(c.curCSS(a,"padding"+this,true))||0);if(f==="margin")e+=parseFloat(c.curCSS(a,"margin"+this,true))||0;else e-=parseFloat(c.curCSS(a,"border"+this+"Width",true))||0})}a.offsetWidth!==0?i():c.swap(a,ob,i);return Math.max(0,Math.round(e))}return c.curCSS(a,b,d)},curCSS:function(a,b,d){var f,e=a.style;if(!c.support.opacity&&b==="opacity"&&a.currentStyle){f=Oa.test(a.currentStyle.filter||"")?parseFloat(RegExp.$1)/100+"":"";return f===""?"1":f}if(ha.test(b))b=Pa;if(!d&&e&&e[b])f=e[b];else if(rb){if(ha.test(b))b="float";b=b.replace(lb,"-$1").toLowerCase();e=a.ownerDocument.defaultView;if(!e)return null;if(a=e.getComputedStyle(a,null))f=a.getPropertyValue(b);if(b==="opacity"&&f==="")f="1"}else if(a.currentStyle){d=b.replace(ia,ja);f=a.currentStyle[b]||a.currentStyle[d];if(!mb.test(f)&&nb.test(f)){b=e.left;var j=a.runtimeStyle.left;a.runtimeStyle.left=a.currentStyle.left;e.left=d==="fontSize"?"1em":f||0;f=e.pixelLeft+"px";e.left=b;a.runtimeStyle.left=j}}return f},swap:function(a,b,d){var f={};for(var e in b){f[e]=a.style[e];a.style[e]=b[e]}d.call(a);for(e in b)a.style[e]=f[e]}});if(c.expr&&c.expr.filters){c.expr.filters.hidden=function(a){var b=a.offsetWidth,d=a.offsetHeight,f=a.nodeName.toLowerCase()==="tr";return b===0&&d===0&&!f?true:b>0&&d>0&&!f?false:c.curCSS(a,"display")==="none"};c.expr.filters.visible=function(a){return!c.expr.filters.hidden(a)}}var sb=J(),tb=/<script(.|\s)*?\/script>/gi,ub=/select|textarea/i,vb=/color|date|datetime|email|hidden|month|number|password|range|search|tel|text|time|url|week/i,N=/=\?(&|$)/,ka=/\?/,wb=/(\?|&)_=.*?(&|$)/,xb=/^(\w+:)?\/\/([^\/?#]+)/,yb=/%20/g,zb=c.fn.load;c.fn.extend({load:function(a,b,d){if(typeof a!=="string")return zb.call(this,a);else if(!this.length)return this;var f=a.indexOf(" ");if(f>=0){var e=a.slice(f,a.length);a=a.slice(0,f)}f="GET";if(b)if(c.isFunction(b)){d=b;b=null}else if(typeof b==="object"){b=c.param(b,c.ajaxSettings.traditional);f="POST"}var j=this;c.ajax({url:a,type:f,dataType:"html",data:b,complete:function(i,o){if(o==="success"||o==="notmodified")j.html(e?c("<div />").append(i.responseText.replace(tb,"")).find(e):i.responseText);d&&j.each(d,[i.responseText,o,i])}});return this},serialize:function(){return c.param(this.serializeArray())},serializeArray:function(){return this.map(function(){return this.elements?c.makeArray(this.elements):this}).filter(function(){return this.name&&!this.disabled&&(this.checked||ub.test(this.nodeName)||vb.test(this.type))}).map(function(a,b){a=c(this).val();return a==null?null:c.isArray(a)?c.map(a,function(d){return{name:b.name,value:d}}):{name:b.name,value:a}}).get()}});c.each("ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "),function(a,b){c.fn[b]=function(d){return this.bind(b,d)}});c.extend({get:function(a,b,d,f){if(c.isFunction(b)){f=f||d;d=b;b=null}return c.ajax({type:"GET",url:a,data:b,success:d,dataType:f})},getScript:function(a,b){return c.get(a,null,b,"script")},getJSON:function(a,b,d){return c.get(a,b,d,"json")},post:function(a,b,d,f){if(c.isFunction(b)){f=f||d;d=b;b={}}return c.ajax({type:"POST",url:a,data:b,success:d,dataType:f})},ajaxSetup:function(a){c.extend(c.ajaxSettings,a)},ajaxSettings:{url:location.href,global:true,type:"GET",contentType:"application/x-www-form-urlencoded",processData:true,async:true,xhr:A.XMLHttpRequest&&(A.location.protocol!=="file:"||!A.ActiveXObject)?function(){return new A.XMLHttpRequest}:function(){try{return new A.ActiveXObject("Microsoft.XMLHTTP")}catch(a){}},accepts:{xml:"application/xml, text/xml",html:"text/html",script:"text/javascript, application/javascript",json:"application/json, text/javascript",text:"text/plain",_default:"*/*"}},lastModified:{},etag:{},ajax:function(a){function b(){e.success&&e.success.call(k,o,i,x);e.global&&f("ajaxSuccess",[x,e])}function d(){e.complete&&e.complete.call(k,x,i);e.global&&f("ajaxComplete",[x,e]);e.global&&!--c.active&&c.event.trigger("ajaxStop")}function f(q,p){(e.context?c(e.context):c.event).trigger(q,p)}var e=c.extend(true,{},c.ajaxSettings,a),j,i,o,k=a&&a.context||e,n=e.type.toUpperCase();if(e.data&&e.processData&&typeof e.data!=="string")e.data=c.param(e.data,e.traditional);if(e.dataType==="jsonp"){if(n==="GET")N.test(e.url)||(e.url+=(ka.test(e.url)?"&":"?")+(e.jsonp||"callback")+"=?");else if(!e.data||!N.test(e.data))e.data=(e.data?e.data+"&":"")+(e.jsonp||"callback")+"=?";e.dataType="json"}if(e.dataType==="json"&&(e.data&&N.test(e.data)||N.test(e.url))){j=e.jsonpCallback||"jsonp"+sb++;if(e.data)e.data=(e.data+"").replace(N,"="+j+"$1");e.url=e.url.replace(N,"="+j+"$1");e.dataType="script";A[j]=A[j]||function(q){o=q;b();d();A[j]=w;try{delete A[j]}catch(p){}z&&z.removeChild(C)}}if(e.dataType==="script"&&e.cache===null)e.cache=false;if(e.cache===false&&n==="GET"){var r=J(),u=e.url.replace(wb,"$1_="+r+"$2");e.url=u+(u===e.url?(ka.test(e.url)?"&":"?")+"_="+r:"")}if(e.data&&n==="GET")e.url+=(ka.test(e.url)?"&":"?")+e.data;e.global&&!c.active++&&c.event.trigger("ajaxStart");r=(r=xb.exec(e.url))&&(r[1]&&r[1]!==location.protocol||r[2]!==location.host);if(e.dataType==="script"&&n==="GET"&&r){var z=s.getElementsByTagName("head")[0]||s.documentElement,C=s.createElement("script");C.src=e.url;if(e.scriptCharset)C.charset=e.scriptCharset;if(!j){var B=false;C.onload=C.onreadystatechange=function(){if(!B&&(!this.readyState||this.readyState==="loaded"||this.readyState==="complete")){B=true;b();d();C.onload=C.onreadystatechange=null;z&&C.parentNode&&z.removeChild(C)}}}z.insertBefore(C,z.firstChild);return w}var E=false,x=e.xhr();if(x){e.username?x.open(n,e.url,e.async,e.username,e.password):x.open(n,e.url,e.async);try{if(e.data||a&&a.contentType)x.setRequestHeader("Content-Type",e.contentType);if(e.ifModified){c.lastModified[e.url]&&x.setRequestHeader("If-Modified-Since",c.lastModified[e.url]);c.etag[e.url]&&x.setRequestHeader("If-None-Match",c.etag[e.url])}r||x.setRequestHeader("X-Requested-With","XMLHttpRequest");x.setRequestHeader("Accept",e.dataType&&e.accepts[e.dataType]?e.accepts[e.dataType]+", */*":e.accepts._default)}catch(ga){}if(e.beforeSend&&e.beforeSend.call(k,x,e)===false){e.global&&!--c.active&&c.event.trigger("ajaxStop");x.abort();return false}e.global&&f("ajaxSend",[x,e]);var g=x.onreadystatechange=function(q){if(!x||x.readyState===0||q==="abort"){E||d();E=true;if(x)x.onreadystatechange=c.noop}else if(!E&&x&&(x.readyState===4||q==="timeout")){E=true;x.onreadystatechange=c.noop;i=q==="timeout"?"timeout":!c.httpSuccess(x)?"error":e.ifModified&&c.httpNotModified(x,e.url)?"notmodified":"success";var p;if(i==="success")try{o=c.httpData(x,e.dataType,e)}catch(v){i="parsererror";p=v}if(i==="success"||i==="notmodified")j||b();else c.handleError(e,x,i,p);d();q==="timeout"&&x.abort();if(e.async)x=null}};try{var h=x.abort;x.abort=function(){x&&h.call(x);g("abort")}}catch(l){}e.async&&e.timeout>0&&setTimeout(function(){x&&!E&&g("timeout")},e.timeout);try{x.send(n==="POST"||n==="PUT"||n==="DELETE"?e.data:null)}catch(m){c.handleError(e,x,null,m);d()}e.async||g();return x}},handleError:function(a,b,d,f){if(a.error)a.error.call(a.context||a,b,d,f);if(a.global)(a.context?c(a.context):c.event).trigger("ajaxError",[b,a,f])},active:0,httpSuccess:function(a){try{return!a.status&&location.protocol==="file:"||a.status>=200&&a.status<300||a.status===304||a.status===1223||a.status===0}catch(b){}return false},httpNotModified:function(a,b){var d=a.getResponseHeader("Last-Modified"),f=a.getResponseHeader("Etag");if(d)c.lastModified[b]=d;if(f)c.etag[b]=f;return a.status===304||a.status===0},httpData:function(a,b,d){var f=a.getResponseHeader("content-type")||"",e=b==="xml"||!b&&f.indexOf("xml")>=0;a=e?a.responseXML:a.responseText;e&&a.documentElement.nodeName==="parsererror"&&c.error("parsererror");if(d&&d.dataFilter)a=d.dataFilter(a,b);if(typeof a==="string")if(b==="json"||!b&&f.indexOf("json")>=0)a=c.parseJSON(a);else if(b==="script"||!b&&f.indexOf("javascript")>=0)c.globalEval(a);return a},param:function(a,b){function d(i,o){if(c.isArray(o))c.each(o,function(k,n){b||/\[\]$/.test(i)?f(i,n):d(i+"["+(typeof n==="object"||c.isArray(n)?k:"")+"]",n)});else!b&&o!=null&&typeof o==="object"?c.each(o,function(k,n){d(i+"["+k+"]",n)}):f(i,o)}function f(i,o){o=c.isFunction(o)?o():o;e[e.length]=encodeURIComponent(i)+"="+encodeURIComponent(o)}var e=[];if(b===w)b=c.ajaxSettings.traditional;if(c.isArray(a)||a.jCSFG)c.each(a,function(){f(this.name,this.value)});else for(var j in a)d(j,a[j]);return e.join("&").replace(yb,"+")}});var la={},Ab=/toggle|show|hide/,Bb=/^([+-]=)?([\d+-.]+)(.*)$/,W,va=[["height","marginTop","marginBottom","paddingTop","paddingBottom"],["width","marginLeft","marginRight","paddingLeft","paddingRight"],["opacity"]];c.fn.extend({show:function(a,b){if(a||a===0)return this.animate(K("show",3),a,b);else{a=0;for(b=this.length;a<b;a++){var d=c.data(this[a],"olddisplay");this[a].style.display=d||"";if(c.css(this[a],"display")==="none"){d=this[a].nodeName;var f;if(la[d])f=la[d];else{var e=c("<"+d+" />").appendTo("body");f=e.css("display");if(f==="none")f="block";e.remove();la[d]=f}c.data(this[a],"olddisplay",f)}}a=0;for(b=this.length;a<b;a++)this[a].style.display=c.data(this[a],"olddisplay")||"";return this}},hide:function(a,b){if(a||a===0)return this.animate(K("hide",3),a,b);else{a=0;for(b=this.length;a<b;a++){var d=c.data(this[a],"olddisplay");!d&&d!=="none"&&c.data(this[a],"olddisplay",c.css(this[a],"display"))}a=0;for(b=this.length;a<b;a++)this[a].style.display="none";return this}},_toggle:c.fn.toggle,toggle:function(a,b){var d=typeof a==="boolean";if(c.isFunction(a)&&c.isFunction(b))this._toggle.apply(this,arguments);else a==null||d?this.each(function(){var f=d?a:c(this).is(":hidden");c(this)[f?"show":"hide"]()}):this.animate(K("toggle",3),a,b);return this},fadeTo:function(a,b,d){return this.filter(":hidden").css("opacity",0).show().end().animate({opacity:b},a,d)},animate:function(a,b,d,f){var e=c.speed(b,d,f);if(c.isEmptyObject(a))return this.each(e.complete);return this[e.queue===false?"each":"queue"](function(){var j=c.extend({},e),i,o=this.nodeType===1&&c(this).is(":hidden"),k=this;for(i in a){var n=i.replace(ia,ja);if(i!==n){a[n]=a[i];delete a[i];i=n}if(a[i]==="hide"&&o||a[i]==="show"&&!o)return j.complete.call(this);if((i==="height"||i==="width")&&this.style){j.display=c.css(this,"display");j.overflow=this.style.overflow}if(c.isArray(a[i])){(j.specialEasing=j.specialEasing||{})[i]=a[i][1];a[i]=a[i][0]}}if(j.overflow!=null)this.style.overflow="hidden";j.curAnim=c.extend({},a);c.each(a,function(r,u){var z=new c.fx(k,j,r);if(Ab.test(u))z[u==="toggle"?o?"show":"hide":u](a);else{var C=Bb.exec(u),B=z.cur(true)||0;if(C){u=parseFloat(C[2]);var E=C[3]||"px";if(E!=="px"){k.style[r]=(u||1)+E;B=(u||1)/z.cur(true)*B;k.style[r]=B+E}if(C[1])u=(C[1]==="-="?-1:1)*u+B;z.custom(B,u,E)}else z.custom(B,u,"")}});return true})},stop:function(a,b){var d=c.timers;a&&this.queue([]);this.each(function(){for(var f=d.length-1;f>=0;f--)if(d[f].elem===this){b&&d[f](true);d.splice(f,1)}});b||this.dequeue();return this}});c.each({slideDown:K("show",1),slideUp:K("hide",1),slideToggle:K("toggle",1),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"}},function(a,b){c.fn[a]=function(d,f){return this.animate(b,d,f)}});c.extend({speed:function(a,b,d){var f=a&&typeof a==="object"?a:{complete:d||!d&&b||c.isFunction(a)&&a,duration:a,easing:d&&b||b&&!c.isFunction(b)&&b};f.duration=c.fx.off?0:typeof f.duration==="number"?f.duration:c.fx.speeds[f.duration]||c.fx.speeds._default;f.old=f.complete;f.complete=function(){f.queue!==false&&c(this).dequeue();c.isFunction(f.old)&&f.old.call(this)};return f},easing:{linear:function(a,b,d,f){return d+f*a},swing:function(a,b,d,f){return(-Math.cos(a*Math.PI)/2+0.5)*f+d}},timers:[],fx:function(a,b,d){this.options=b;this.elem=a;this.prop=d;if(!b.orig)b.orig={}}});c.fx.prototype={update:function(){this.options.step&&this.options.step.call(this.elem,this.now,this);(c.fx.step[this.prop]||c.fx.step._default)(this);if((this.prop==="height"||this.prop==="width")&&this.elem.style)this.elem.style.display="block"},cur:function(a){if(this.elem[this.prop]!=null&&(!this.elem.style||this.elem.style[this.prop]==null))return this.elem[this.prop];return(a=parseFloat(c.css(this.elem,this.prop,a)))&&a>-10000?a:parseFloat(c.curCSS(this.elem,this.prop))||0},custom:function(a,b,d){function f(j){return e.step(j)}this.startTime=J();this.start=a;this.end=b;this.unit=d||this.unit||"px";this.now=this.start;this.pos=this.state=0;var e=this;f.elem=this.elem;if(f()&&c.timers.push(f)&&!W)W=setInterval(c.fx.tick,13)},show:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.show=true;this.custom(this.prop==="width"||this.prop==="height"?1:0,this.cur());c(this.elem).show()},hide:function(){this.options.orig[this.prop]=c.style(this.elem,this.prop);this.options.hide=true;this.custom(this.cur(),0)},step:function(a){var b=J(),d=true;if(a||b>=this.options.duration+this.startTime){this.now=this.end;this.pos=this.state=1;this.update();this.options.curAnim[this.prop]=true;for(var f in this.options.curAnim)if(this.options.curAnim[f]!==true)d=false;if(d){if(this.options.display!=null){this.elem.style.overflow=this.options.overflow;a=c.data(this.elem,"olddisplay");this.elem.style.display=a?a:this.options.display;if(c.css(this.elem,"display")==="none")this.elem.style.display="block"}this.options.hide&&c(this.elem).hide();if(this.options.hide||this.options.show)for(var e in this.options.curAnim)c.style(this.elem,e,this.options.orig[e]);this.options.complete.call(this.elem)}return false}else{e=b-this.startTime;this.state=e/this.options.duration;a=this.options.easing||(c.easing.swing?"swing":"linear");this.pos=c.easing[this.options.specialEasing&&this.options.specialEasing[this.prop]||a](this.state,e,0,1,this.options.duration);this.now=this.start+(this.end-this.start)*this.pos;this.update()}return true}};c.extend(c.fx,{tick:function(){for(var a=c.timers,b=0;b<a.length;b++)a[b]()||a.splice(b--,1);a.length||c.fx.stop()},stop:function(){clearInterval(W);W=null},speeds:{slow:600,fast:200,_default:400},step:{opacity:function(a){c.style(a.elem,"opacity",a.now)},_default:function(a){if(a.elem.style&&a.elem.style[a.prop]!=null)a.elem.style[a.prop]=(a.prop==="width"||a.prop==="height"?Math.max(0,a.now):a.now)+a.unit;else a.elem[a.prop]=a.now}}});if(c.expr&&c.expr.filters)c.expr.filters.animated=function(a){return c.grep(c.timers,function(b){return a===b.elem}).length};c.fn.offset="getBoundingClientRect"in s.documentElement?function(a){var b=this[0];if(a)return this.each(function(e){c.offset.setOffset(this,a,e)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);var d=b.getBoundingClientRect(),f=b.ownerDocument;b=f.body;f=f.documentElement;return{top:d.top+(self.pageYOffset||c.support.boxModel&&f.scrollTop||b.scrollTop)-(f.clientTop||b.clientTop||0),left:d.left+(self.pageXOffset||c.support.boxModel&&f.scrollLeft||b.scrollLeft)-(f.clientLeft||b.clientLeft||0)}}:function(a){var b=this[0];if(a)return this.each(function(r){c.offset.setOffset(this,a,r)});if(!b||!b.ownerDocument)return null;if(b===b.ownerDocument.body)return c.offset.bodyOffset(b);c.offset.initialize();var d=b.offsetParent,f=b,e=b.ownerDocument,j,i=e.documentElement,o=e.body;f=(e=e.defaultView)?e.getComputedStyle(b,null):b.currentStyle;for(var k=b.offsetTop,n=b.offsetLeft;(b=b.parentNode)&&b!==o&&b!==i;){if(c.offset.supportsFixedPosition&&f.position==="fixed")break;j=e?e.getComputedStyle(b,null):b.currentStyle;k-=b.scrollTop;n-=b.scrollLeft;if(b===d){k+=b.offsetTop;n+=b.offsetLeft;if(c.offset.doesNotAddBorder&&!(c.offset.doesAddBorderForTableAndCells&&/^t(able|d|h)$/i.test(b.nodeName))){k+=parseFloat(j.borderTopWidth)||0;n+=parseFloat(j.borderLeftWidth)||0}f=d;d=b.offsetParent}if(c.offset.subtractsBorderForOverflowNotVisible&&j.overflow!=="visible"){k+=parseFloat(j.borderTopWidth)||0;n+=parseFloat(j.borderLeftWidth)||0}f=j}if(f.position==="relative"||f.position==="static"){k+=o.offsetTop;n+=o.offsetLeft}if(c.offset.supportsFixedPosition&&f.position==="fixed"){k+=Math.max(i.scrollTop,o.scrollTop);n+=Math.max(i.scrollLeft,o.scrollLeft)}return{top:k,left:n}};c.offset={initialize:function(){var a=s.body,b=s.createElement("div"),d,f,e,j=parseFloat(c.curCSS(a,"marginTop",true))||0;c.extend(b.style,{position:"absolute",top:0,left:0,margin:0,border:0,width:"1px",height:"1px",visibility:"hidden"});b.innerHTML="<div style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;'><div></div></div><table style='position:absolute;top:0;left:0;margin:0;border:5px solid #000;padding:0;width:1px;height:1px;' cellpadding='0' cellspacing='0'><tr><td></td></tr></table>";a.insertBefore(b,a.firstChild);d=b.firstChild;f=d.firstChild;e=d.nextSibling.firstChild.firstChild;this.doesNotAddBorder=f.offsetTop!==5;this.doesAddBorderForTableAndCells=e.offsetTop===5;f.style.position="fixed";f.style.top="20px";this.supportsFixedPosition=f.offsetTop===20||f.offsetTop===15;f.style.position=f.style.top="";d.style.overflow="hidden";d.style.position="relative";this.subtractsBorderForOverflowNotVisible=f.offsetTop===-5;this.doesNotIncludeMarginInBodyOffset=a.offsetTop!==j;a.removeChild(b);c.offset.initialize=c.noop},bodyOffset:function(a){var b=a.offsetTop,d=a.offsetLeft;c.offset.initialize();if(c.offset.doesNotIncludeMarginInBodyOffset){b+=parseFloat(c.curCSS(a,"marginTop",true))||0;d+=parseFloat(c.curCSS(a,"marginLeft",true))||0}return{top:b,left:d}},setOffset:function(a,b,d){if(/static/.test(c.curCSS(a,"position")))a.style.position="relative";var f=c(a),e=f.offset(),j=parseInt(c.curCSS(a,"top",true),10)||0,i=parseInt(c.curCSS(a,"left",true),10)||0;if(c.isFunction(b))b=b.call(a,d,e);d={top:b.top-e.top+j,left:b.left-e.left+i};"using"in b?b.using.call(a,d):f.css(d)}};c.fn.extend({position:function(){if(!this[0])return null;var a=this[0],b=this.offsetParent(),d=this.offset(),f=/^body|html$/i.test(b[0].nodeName)?{top:0,left:0}:b.offset();d.top-=parseFloat(c.curCSS(a,"marginTop",true))||0;d.left-=parseFloat(c.curCSS(a,"marginLeft",true))||0;f.top+=parseFloat(c.curCSS(b[0],"borderTopWidth",true))||0;f.left+=parseFloat(c.curCSS(b[0],"borderLeftWidth",true))||0;return{top:d.top-f.top,left:d.left-f.left}},offsetParent:function(){return this.map(function(){for(var a=this.offsetParent||s.body;a&&!/^body|html$/i.test(a.nodeName)&&c.css(a,"position")==="static";)a=a.offsetParent;return a})}});c.each(["Left","Top"],function(a,b){var d="scroll"+b;c.fn[d]=function(f){var e=this[0],j;if(!e)return null;if(f!==w)return this.each(function(){if(j=wa(this))j.scrollTo(!a?f:c(j).scrollLeft(),a?f:c(j).scrollTop());else this[d]=f});else return(j=wa(e))?"pageXOffset"in j?j[a?"pageYOffset":"pageXOffset"]:c.support.boxModel&&j.document.documentElement[d]||j.document.body[d]:e[d]}});c.each(["Height","Width"],function(a,b){var d=b.toLowerCase();c.fn["inner"+b]=function(){return this[0]?c.css(this[0],d,false,"padding"):null};c.fn["outer"+b]=function(f){return this[0]?c.css(this[0],d,false,f?"margin":"border"):null};c.fn[d]=function(f){var e=this[0];if(!e)return f==null?null:this;if(c.isFunction(f))return this.each(function(j){var i=c(this);i[d](f.call(this,j,i[d]()))});return"scrollTo"in e&&e.document?e.document.compatMode==="CSS1Compat"&&e.document.documentElement["client"+b]||e.document.body["client"+b]:e.nodeType===9?Math.max(e.documentElement["client"+b],e.body["scroll"+b],e.documentElement["scroll"+b],e.body["offset"+b],e.documentElement["offset"+b]):f===w?c.css(e,d):this.css(d,typeof f==="string"?f:f+"px")}});A.jCSFG=A.$=c})(window);
// jQuery XML to JSON Plugin v1.0
(function($){$.extend({xml2json:function(xml,extended){if(!xml)return{};function parseXML(node,simple){if(!node)return null;var txt='',obj=null,att=null;var nt=node.nodeType,nn=jsVar(node.localName||node.nodeName);var nv=node.text||node.nodeValue||'';if(node.childNodes){if(node.childNodes.length>0){$.each(node.childNodes,function(n,cn){var cnt=cn.nodeType,cnn=jsVar(cn.localName||cn.nodeName);var cnv=cn.text||cn.nodeValue||'';if(cnt==8){return;}else if(cnt==3||cnt==4||!cnn){if(cnv.match(/^\s+$/)){return;};txt+=cnv.replace(/^\s+/,'').replace(/\s+$/,'');}else{obj=obj||{};if(obj[cnn]){if(!obj[cnn].length)obj[cnn]=myArr(obj[cnn]);obj[cnn][obj[cnn].length]=parseXML(cn,true);obj[cnn].length=obj[cnn].length;}else{obj[cnn]=parseXML(cn);};};});};};if(node.attributes){if(node.attributes.length>0){att={};obj=obj||{};$.each(node.attributes,function(a,at){var atn=jsVar(at.name),atv=at.value;att[atn]=atv;if(obj[atn]){if(!obj[atn].length)obj[atn]=myArr(obj[atn]);obj[atn][obj[atn].length]=atv;obj[atn].length=obj[atn].length;}else{obj[atn]=atv;};});};};if(obj){obj=$.extend((txt!=''?new String(txt):{}),obj||{});txt=(obj.text)?(typeof(obj.text)=='object'?obj.text:[obj.text||'']).concat([txt]):txt;if(txt)obj.text=txt;txt='';};var out=obj||txt;if(extended){if(txt)out={};txt=out.text||txt||'';if(txt)out.text=txt;if(!simple)out=myArr(out);};return out;};var jsVar=function(s){return String(s||'').replace(/-/g,"_");};var isNum=function(s){return(typeof s=="number")||String((s&&typeof s=="string")?s:'').test(/^((-)?([0-9]*)((\.{0,1})([0-9]+))?$)/);};var myArr=function(o){if(!o.length)o=[o];o.length=o.length;return o;};if(typeof xml=='string')xml=$.text2xml(xml);if(!xml.nodeType)return;if(xml.nodeType==3||xml.nodeType==4)return xml.nodeValue;var root=(xml.nodeType==9)?xml.documentElement:xml;var out=parseXML(root,true);xml=null;root=null;return out;},text2xml:function(str){var out;try{var xml=($.browser.msie)?new ActiveXObject("Microsoft.XMLDOM"):new DOMParser();xml.async=false;}catch(e){throw new Error("XML Parser could not be instantiated")};try{if($.browser.msie)out=(xml.loadXML(str))?xml:false;else out=xml.parseFromString(str,"text/xml");}catch(e){throw new Error("Error parsing XML string")};return out;}});})(jCSFG);
// jQuery TouchWipe Plugin v1.0
(function($){$.fn.touchwipe=function(settings){if($.browser.msie==true)return;var config={min_move_x:20,wipeLeft:function(){},wipeRight:function(){},preventDefaultEvents:true};if(settings)$.extend(config,settings);this.each(function(){var startX;var isMoving=false;function cancelTouch(){this.removeEventListener('touchmove',onTouchMove);startX=null;isMoving=false;}function onTouchMove(e){if(config.preventDefaultEvents){e.preventDefault();}if(isMoving){var x=e.touches[0].pageX;var dx=startX-x;if(Math.abs(dx)>=config.min_move_x){cancelTouch();if(dx>0){config.wipeLeft();}else{config.wipeRight();}}}}function onTouchStart(e){if(e.touches.length==1){startX=e.touches[0].pageX;isMoving=true;this.addEventListener('touchmove',onTouchMove,false);}}this.addEventListener('touchstart',onTouchStart,false);});return this;};})(jCSFG);
// jQuery CSSRule Plugin (Customized)
(function($){$.cssRule=function(Selector,Property,Value){if(typeof Selector=="object"){$.each(Selector,function(NewSelector,NewProperty){$.cssRule(NewSelector,NewProperty);});return;}if((typeof Selector=="string")&&(Selector.indexOf(":")>-1)&&(Property==undefined)&&(Value==undefined)){Data=Selector.split("{");Data[1]=Data[1].replace(/\}/,"");$.cssRule($.trim(Data[0]),$.trim(Data[1]));return;}if((typeof Selector=="string")&&(Selector.indexOf(",")>-1)){Multi=Selector.split(",");for(x=0;x<Multi.length;x++){Multi[x]=$.trim(Multi[x]);if(Multi[x]!="")$.cssRule(Multi[x],Property,Value);}return;}if(typeof Property=="object"){if(Property.length==undefined){$.each(Property,function(NewProperty,NewValue){$.cssRule(Selector+" "+NewProperty,NewValue);});}else if((Property.length==2)&&(typeof Property[0]=="string")&&(typeof Property[1]=="string")){$.cssRule(Selector,Property[0],Property[1]);}else{for(x1=0;x1<Property.length;x1++){$.cssRule(Selector,Property[x1],Value);}}return;}if((typeof Property=="string")&&(Property.indexOf("{")>-1)&&(Property.indexOf("}")>-1)){Property=Property.replace(/\{/,"").replace(/\}/,"");}if((typeof Property=="string")&&(Property.indexOf(";")>-1)){Multi1=Property.split(";");for(x2=0;x2<Multi1.length;x2++){$.cssRule(Selector,Multi1[x2],undefined);}return;}if((typeof Property=="string")&&(Property.indexOf(":")>-1)){Multi3=Property.split(":");$.cssRule(Selector,Multi3[0],Multi3[1]);return;}if((typeof Property=="string")&&(Property.indexOf(",")>-1)){Multi2=Property.split(",");for(x3=0;x3<Multi2.length;x3++){$.cssRule(Selector,Multi2[x3],Value);}return;}var ssbStyle=undefined;for(var i=0;i<document.styleSheets.length;i++){if(document.styleSheets[i].title=='CustomSimpleFadeStyleSheet'){ssbStyle=document.styleSheets[i];}}if(typeof ssbStyle!='object'){if(typeof document.createElementNS!='undefined'){var ssbStyle=document.createElementNS("http://www.w3.org/1999/xhtml","style");}else{var ssbStyle=document.createElement("style");}ssbStyle.setAttribute("type","text/css");ssbStyle.setAttribute("media","screen");ssbStyle.setAttribute("title","CustomSimpleFadeStyleSheet");$($("head")[0]).append(ssbStyle);for(var i=0;i<document.styleSheets.length;i++){if(document.styleSheets[i].title=='CustomSimpleFadeStyleSheet'){ssbStyle=document.styleSheets[i];}}}if((Property==undefined)||(Value==undefined))return;Selector=$.trim(Selector);Property=$.trim(Property);Value=$.trim(Value);if((Property=="")||(Value==""))return;if($.browser.msie){switch(Property){case"float":Property="style-float";break;}}else{switch(Property){case"float":Property="css-float";break;}}CssProperty=(Property||"").replace(/\-(\w)/g,function(m,c){return(c.toUpperCase());});var Rules=(ssbStyle.cssRules||ssbStyle.rules);LowerSelector=Selector.toLowerCase();for(var i2=0,len=Rules.length-1;i2<len;i2++){if(Rules[i2].selectorText&&(Rules[i2].selectorText.toLowerCase()==LowerSelector)){if(Value!=null){Rules[i2].style[CssProperty]=Value;return;}else{if(ssbStyle.deleteRule){ssbStyle.deleteRule(i2);}else if(ssbStyle.removeRule){ssbStyle.removeRule(i2);}else{Rules[i2].style.cssText="";}}}}if(Property&&Value){if(ssbStyle.insertRule){Rules=(ssbStyle.cssRules||ssbStyle.rules);ssbStyle.insertRule(Selector+"{ "+Property+":"+Value+"; }",Rules.length);}else if(ssbStyle.addRule){ssbStyle.addRule(Selector,Property+":"+Value+";",0);}else{throw new Error("Add/insert not enabled.");}}};$.tocssRule=function(cssText){matchRes=cssText.match(/(.*?)\{(.*?)\}/);while(matchRes){cssText=cssText.replace(/(.*?)\{(.*?)\}/,"");$.cssRule(matchRes[1],matchRes[2]);matchRes=cssText.match(/(.*?)\{(.*?)\}/);}};})(jCSFG);
// jQuery Canvas Plugin (Customized)
(function($){$.fn.canvas=function(where){$(this).each(function(){var $this=$(this);var w=$this.width();var h=$this.height();if(w===0&&$this.css('width')!=='0px'){w=parseInt($this.css('width'));}if(h===0&&$this.css('height')!=='0px'){h=parseInt($this.css('height'));}if(!where)where='under';$this.find('.cnvsWrapper').remove();$this.find('.cnvsCanvas').remove();var $canvas=document.createElement('CANVAS');$canvas.className='cnvsCanvas';$canvas.style.position='absolute';$canvas.style.top='0px';$canvas.style.left='0px';$canvas.setAttribute('width',w);$canvas.setAttribute('height',h);if((where=='under'||where=='over')&&$this.html()!==''){$this.wrapInner('<div class="cnvsWrapper" style="position:absolute;top:0px;left:0px;width:100%;height:100%;border:0px;padding:0px;margin:0px;"></div>');}if(where=='under'||where=='unshift'){$this.prepend($canvas);}if(where=='over'||where=='push'){$this.append($canvas);}if($.browser.msie){var canvas=G_vmlCanvasManager.initElement($($canvas).get(0));$canvas=$(canvas);}this.cnvs=canvasObject($($canvas),w,h);return this;});return this;};$.fn.uncanvas=function(){$(this).each(function(){this.cnvs.getTag().remove();this.cnvs=null;});return this;};$.fn.hidecanvas=function(){$(this).each(function(){this.cnvs.getTag().hide();});return this;};$.fn.showcanvas=function(){$(this).each(function(){this.cnvs.getTag().show();});return this;};$.fn.canvasraw=function(callback){$(this).each(function(){if(callback)eval(callback)(this.cnvs);});};$.fn.canvasinfo=function(info){$(this).each(function(){info[info.length]={};info[info.length-1].width=this.cnvs.w;info[info.length-1].height=this.cnvs.h;info[info.length-1].tag=this.cnvs.$tag;info[info.length-1].context=this.cnvs.c;});};$.fn.style=function(style){$(this).each(function(){this.cnvs.style(style);return this;});return this;};$.fn.beginPath=function(){$(this).each(function(){this.cnvs.beginPath();return this;});return this;};$.fn.closePath=function(){$(this).each(function(){this.cnvs.closePath();return this;});return this;};$.fn.stroke=function(){$(this).each(function(){this.cnvs.stroke();return this;});return this;};$.fn.fill=function(){$(this).each(function(){this.cnvs.fill();return this;});return this;};$.fn.moveTo=function(coord){$(this).each(function(){this.cnvs.moveTo(coord);return this;});return this;};$.fn.arc=function(coord,settings,style){$(this).each(function(){this.cnvs.arc(coord,settings,style);return this;});return this;};$.fn.arcTo=function(coord1,coord2,settings,style){$(this).each(function(){this.cnvs.arcTo(coord1,coord2,settings,style);return this;});return this;};$.fn.bezierCurveTo=function(ref1,ref2,end,style){$(this).each(function(){this.cnvs.bezierCurveTo(ref1,ref2,end,style);return this;});return this;};$.fn.quadraticCurveTo=function(ref1,end,style){$(this).each(function(){this.cnvs.quadraticCurveTo(ref1,end,style);return this;});return this;};$.fn.clearRect=function(coord,settings){$(this).each(function(){this.cnvs.clearRect(coord,settings);return this;});return this;};$.fn.strokeRect=function(coord,settings,style){$(this).each(function(){this.cnvs.strokeRect(coord,settings,style);return this;});return this;};$.fn.fillRect=function(coord,settings,style){$(this).each(function(){this.cnvs.fillRect(coord,settings,style);return this;});return this;};$.fn.rect=function(coord,settings,style){$(this).each(function(){this.cnvs.rect(coord,settings,style);return this;});return this;};$.fn.lineTo=function(end,style){$(this).each(function(){this.cnvs.lineTo(end,style);return this;});return this;};$.fn.fillText=function(txt,x,y){$(this).each(function(){this.cnvs.fillText(txt,x,y);return this;});return this;};$.fn.translate=function(x,y){$(this).each(function(){this.cnvs.translate(x,y);return this;});return this;};$.fn.transform=function(m11,m12,m21,m22,dx,dy){$(this).each(function(){this.cnvs.transform(m11,m12,m21,m22,dx,dy);return this;});return this;};$.fn.rotate=function(r){$(this).each(function(){this.cnvs.rotate(r);return this;});return this;};$.fn.save=function(){$(this).each(function(){this.cnvs.save();return this;});return this;};$.fn.restore=function(){$(this).each(function(){this.cnvs.restore();return this;});return this;};$.fn.polygon=function(start,blocks,settings,style){$(this).each(function(){this.cnvs.atomPolygon(start,blocks,settings,style);});};function canvasObject($canvas,width,height){var cnvs={};cnvs.w=width;cnvs.h=height;cnvs.$tag=$canvas;cnvs.c=$canvas.get(0).getContext('2d');cnvs.laststyle={'fillStyle':'rgba( 0, 0, 0, 0.2)','strokeStyle':'rgba( 0, 0, 0, 0.5)','lineWidth':5};cnvs.getContext=function(){return this.c;};cnvs.getTag=function(){return this.$tag;};cnvs.deg2rad=function(deg){return 2*3.14159265*(deg/360);};cnvs.style=function(style){if(style)this.laststyle=style;for(var name in this.laststyle)this.c[name]=this.laststyle[name];};cnvs.fillText=function(txt,x,y){this.c.fillText(txt,x,y);};cnvs.translate=function(x,y){this.c.translate(x,y);};cnvs.transform=function(m11,m12,m21,m22,dx,dy){this.c.transform(m11,m12,m21,m22,dx,dy);};cnvs.rotate=function(r){this.c.rotate(r);};cnvs.save=function(){this.c.save();};cnvs.restore=function(){this.c.restore();};cnvs.beginPath=function(){this.c.beginPath();};cnvs.closePath=function(){this.c.closePath();};cnvs.stroke=function(){this.c.stroke();};cnvs.fill=function(){this.c.fill();};cnvs.moveTo=function(coord){this.c.moveTo(coord[0],coord[1]);};cnvs.arc=function(coord,settings,style){settings=$.extend({'radius':50,'startAngle':0,'endAngle':360,'clockwise':true},settings);if(style)this.style(style);this.c.arc(coord[0],coord[1],settings.radius,this.deg2rad(settings.startAngle),this.deg2rad(settings.endAngle),settings.clockwise?1:0);};cnvs.arcTo=function(coord1,coord2,settings,style){settings=$.extend({'radius':50},settings);if(style)this.style(style);this.c.arcTo(coord1[0],coord1[1],coord2[0],coord2[1],settings.radius);};cnvs.bezierCurveTo=function(ref1,ref2,end,style){if(style)this.style(style);this.c.bezierCurveTo(ref1[0],ref1[1],ref2[0],ref2[1],end[0],end[1]);};cnvs.quadraticCurveTo=function(ref1,end,style){if(style)this.style(style);this.c.quadraticCurveTo(ref1[0],ref1[1],end[0],end[1]);};cnvs.clearRect=function(coord,settings,style){if(!coord)coord=[0,0];settings=$.extend({'width':this.w,'height':this.h},settings);this.c.clearRect(coord[0],coord[1],settings.width,settings.height);};cnvs.fillRect=function(coord,settings,style){settings=$.extend({'width':100,'height':50},settings);if(style)this.style(style);this.c.fillRect(coord[0],coord[1],settings.width,settings.height);};cnvs.strokeRect=function(coord,settings,style){settings=$.extend({'width':100,'height':50},settings);if(style)this.style(style);this.c.strokeRect(coord[0],coord[1],settings.width,settings.height);};cnvs.rect=function(coord,settings,style){settings=$.extend({'width':100,'height':50},settings);if(style)this.style(style);this.c.rect(coord[0],coord[1],settings.width,settings.height);};cnvs.lineTo=function(end,style){if(style)this.style(style);this.c.lineTo(end[0],end[1]);};cnvs.path=function(blocks){for(var i=0;i<blocks.length;i++){var arg1=null;var arg2=null;var arg3=null;var arg4=null;if(blocks[i].length>=2)arg1=blocks[i][1];if(blocks[i].length>=3)arg2=blocks[i][2];if(blocks[i].length>=4)arg3=blocks[i][3];if(blocks[i].length>=5)arg4=blocks[i][4];if(blocks[i][0]=='moveTo')this.moveTo(arg1);if(blocks[i][0]=='arc')this.arc(arg1,arg2,arg3);if(blocks[i][0]=='arcTo')this.arcTo(arg1,arg2,arg3,arg4);if(blocks[i][0]=='bezierCurveTo')this.bezierCurveTo(arg1,arg2,arg3,arg4);if(blocks[i][0]=='quadraticCurveTo')this.quadraticCurveTo(arg1,arg2,arg3);if(blocks[i][0]=='lineTo')this.lineTo(arg1,arg2);}};cnvs.atomPolygon=function(start,blocks,settings,style){settings=$.extend({'fill':false,'stroke':true,'close':false},settings);this.style(style);if(settings.stroke){this.beginPath();this.moveTo(start);this.path(blocks);if(settings.close){this.moveTo(start);this.closePath();}this.c.fillStyle='rgba( 0, 0, 0, 0)';this.stroke();}this.style(style);if(settings.fill){this.beginPath();this.moveTo(start);this.path(blocks);if(settings.close){this.moveTo(start);this.closePath();}this.c.strokeStyle='rgba( 0, 0, 0, 0)';this.fill();}this.style(style);};return cnvs;}})(jCSFG);
// jQuery exCanvas
if(!document.createElement('canvas').getContext){(function(){var m=Math;var mr=m.round;var ms=m.sin;var mc=m.cos;var abs=m.abs;var sqrt=m.sqrt;var Z=10;var Z2=Z/2;var IE_VERSION=+navigator.userAgent.match(/MSIE ([\d.]+)?/)[1];function getContext(){return this.context_||(this.context_=new CanvasRenderingContext2D_(this));}var slice=Array.prototype.slice;function bind(f,obj,var_args){var a=slice.call(arguments,2);return function(){return f.apply(obj,a.concat(slice.call(arguments)));};}function encodeHtmlAttribute(s){return String(s).replace(/&/g,'&amp;').replace(/"/g,'&quot;');}function addNamespace(doc,prefix,urn){if(!doc.namespaces[prefix]){doc.namespaces.add(prefix,urn,'#default#VML');}}function addNamespacesAndStylesheet(doc){addNamespace(doc,'g_vml_','urn:schemas-microsoft-com:vml');addNamespace(doc,'g_o_','urn:schemas-microsoft-com:office:office');if(!doc.styleSheets['ex_canvas_']){var ss=doc.createStyleSheet();ss.owningElement.id='ex_canvas_';ss.cssText='canvas{display:inline-block;overflow:hidden;'+'text-align:left;width:300px;height:150px}';}}addNamespacesAndStylesheet(document);var G_vmlCanvasManager_={init:function(opt_doc){var doc=opt_doc||document;doc.createElement('canvas');doc.attachEvent('onreadystatechange',bind(this.init_,this,doc));},init_:function(doc){var els=doc.getElementsByTagName('canvas');for(var i=0;i<els.length;i++){this.initElement(els[i]);}},initElement:function(el){if(!el.getContext){el.getContext=getContext;addNamespacesAndStylesheet(el.ownerDocument);el.innerHTML='';el.attachEvent('onpropertychange',onPropertyChange);el.attachEvent('onresize',onResize);var attrs=el.attributes;if(attrs.width&&attrs.width.specified){el.style.width=attrs.width.nodeValue+'px';}else{el.width=el.clientWidth;}if(attrs.height&&attrs.height.specified){el.style.height=attrs.height.nodeValue+'px';}else{el.height=el.clientHeight;}}return el;}};function onPropertyChange(e){var el=e.srcElement;switch(e.propertyName){case'width':el.getContext().clearRect();el.style.width=el.attributes.width.nodeValue+'px';el.firstChild.style.width=el.clientWidth+'px';break;case'height':el.getContext().clearRect();el.style.height=el.attributes.height.nodeValue+'px';el.firstChild.style.height=el.clientHeight+'px';break;}}function onResize(e){var el=e.srcElement;if(el.firstChild){el.firstChild.style.width=el.clientWidth+'px';el.firstChild.style.height=el.clientHeight+'px';}}G_vmlCanvasManager_.init();var decToHex=[];for(var i=0;i<16;i++){for(var j=0;j<16;j++){decToHex[i*16+j]=i.toString(16)+j.toString(16);}}function createMatrixIdentity(){return[[1,0,0],[0,1,0],[0,0,1]];}function matrixMultiply(m1,m2){var result=createMatrixIdentity();for(var x=0;x<3;x++){for(var y=0;y<3;y++){var sum=0;for(var z=0;z<3;z++){sum+=m1[x][z]*m2[z][y];}result[x][y]=sum;}}return result;}function copyState(o1,o2){o2.fillStyle=o1.fillStyle;o2.lineCap=o1.lineCap;o2.lineJoin=o1.lineJoin;o2.lineWidth=o1.lineWidth;o2.miterLimit=o1.miterLimit;o2.shadowBlur=o1.shadowBlur;o2.shadowColor=o1.shadowColor;o2.shadowOffsetX=o1.shadowOffsetX;o2.shadowOffsetY=o1.shadowOffsetY;o2.strokeStyle=o1.strokeStyle;o2.globalAlpha=o1.globalAlpha;o2.font=o1.font;o2.textAlign=o1.textAlign;o2.textBaseline=o1.textBaseline;o2.arcScaleX_=o1.arcScaleX_;o2.arcScaleY_=o1.arcScaleY_;o2.lineScale_=o1.lineScale_;}var colorData={aliceblue:'#F0F8FF',antiquewhite:'#FAEBD7',aquamarine:'#7FFFD4',azure:'#F0FFFF',beige:'#F5F5DC',bisque:'#FFE4C4',black:'#000000',blanchedalmond:'#FFEBCD',blueviolet:'#8A2BE2',brown:'#A52A2A',burlywood:'#DEB887',cadetblue:'#5F9EA0',chartreuse:'#7FFF00',chocolate:'#D2691E',coral:'#FF7F50',cornflowerblue:'#6495ED',cornsilk:'#FFF8DC',crimson:'#DC143C',cyan:'#00FFFF',darkblue:'#00008B',darkcyan:'#008B8B',darkgoldenrod:'#B8860B',darkgray:'#A9A9A9',darkgreen:'#006400',darkgrey:'#A9A9A9',darkkhaki:'#BDB76B',darkmagenta:'#8B008B',darkolivegreen:'#556B2F',darkorange:'#FF8C00',darkorchid:'#9932CC',darkred:'#8B0000',darksalmon:'#E9967A',darkseagreen:'#8FBC8F',darkslateblue:'#483D8B',darkslategray:'#2F4F4F',darkslategrey:'#2F4F4F',darkturquoise:'#00CED1',darkviolet:'#9400D3',deeppink:'#FF1493',deepskyblue:'#00BFFF',dimgray:'#696969',dimgrey:'#696969',dodgerblue:'#1E90FF',firebrick:'#B22222',floralwhite:'#FFFAF0',forestgreen:'#228B22',gainsboro:'#DCDCDC',ghostwhite:'#F8F8FF',gold:'#FFD700',goldenrod:'#DAA520',grey:'#808080',greenyellow:'#ADFF2F',honeydew:'#F0FFF0',hotpink:'#FF69B4',indianred:'#CD5C5C',indigo:'#4B0082',ivory:'#FFFFF0',khaki:'#F0E68C',lavender:'#E6E6FA',lavenderblush:'#FFF0F5',lawngreen:'#7CFC00',lemonchiffon:'#FFFACD',lightblue:'#ADD8E6',lightcoral:'#F08080',lightcyan:'#E0FFFF',lightgoldenrodyellow:'#FAFAD2',lightgreen:'#90EE90',lightgrey:'#D3D3D3',lightpink:'#FFB6C1',lightsalmon:'#FFA07A',lightseagreen:'#20B2AA',lightskyblue:'#87CEFA',lightslategray:'#778899',lightslategrey:'#778899',lightsteelblue:'#B0C4DE',lightyellow:'#FFFFE0',limegreen:'#32CD32',linen:'#FAF0E6',magenta:'#FF00FF',mediumaquamarine:'#66CDAA',mediumblue:'#0000CD',mediumorchid:'#BA55D3',mediumpurple:'#9370DB',mediumseagreen:'#3CB371',mediumslateblue:'#7B68EE',mediumspringgreen:'#00FA9A',mediumturquoise:'#48D1CC',mediumvioletred:'#C71585',midnightblue:'#191970',mintcream:'#F5FFFA',mistyrose:'#FFE4E1',moccasin:'#FFE4B5',navajowhite:'#FFDEAD',oldlace:'#FDF5E6',olivedrab:'#6B8E23',orange:'#FFA500',orangered:'#FF4500',orchid:'#DA70D6',palegoldenrod:'#EEE8AA',palegreen:'#98FB98',paleturquoise:'#AFEEEE',palevioletred:'#DB7093',papayawhip:'#FFEFD5',peachpuff:'#FFDAB9',peru:'#CD853F',pink:'#FFC0CB',plum:'#DDA0DD',powderblue:'#B0E0E6',rosybrown:'#BC8F8F',royalblue:'#4169E1',saddlebrown:'#8B4513',salmon:'#FA8072',sandybrown:'#F4A460',seagreen:'#2E8B57',seashell:'#FFF5EE',sienna:'#A0522D',skyblue:'#87CEEB',slateblue:'#6A5ACD',slategray:'#708090',slategrey:'#708090',snow:'#FFFAFA',springgreen:'#00FF7F',steelblue:'#4682B4',tan:'#D2B48C',thistle:'#D8BFD8',tomato:'#FF6347',turquoise:'#40E0D0',violet:'#EE82EE',wheat:'#F5DEB3',whitesmoke:'#F5F5F5',yellowgreen:'#9ACD32'};function getRgbHslContent(styleString){var start=styleString.indexOf('(',3);var end=styleString.indexOf(')',start+1);var parts=styleString.substring(start+1,end).split(',');if(parts.length!=4||styleString.charAt(3)!='a'){parts[3]=1;}return parts;}function percent(s){return parseFloat(s)/100;}function clamp(v,min,max){return Math.min(max,Math.max(min,v));}function hslToRgb(parts){var r,g,b,h,s,l;h=parseFloat(parts[0])/360%360;if(h<0)h++;s=clamp(percent(parts[1]),0,1);l=clamp(percent(parts[2]),0,1);if(s==0){r=g=b=l;}else{var q=l<0.5?l*(1+s):l+s-l*s;var p=2*l-q;r=hueToRgb(p,q,h+1/3);g=hueToRgb(p,q,h);b=hueToRgb(p,q,h-1/3);}return'#'+decToHex[Math.floor(r*255)]+decToHex[Math.floor(g*255)]+decToHex[Math.floor(b*255)];}function hueToRgb(m1,m2,h){if(h<0)h++;if(h>1)h--;if(6*h<1)return m1+(m2-m1)*6*h;else if(2*h<1)return m2;else if(3*h<2)return m1+(m2-m1)*(2/3-h)*6;else return m1;}var processStyleCache={};function processStyle(styleString){if(styleString in processStyleCache){return processStyleCache[styleString];}var str,alpha=1;styleString=String(styleString);if(styleString.charAt(0)=='#'){str=styleString;}else if(/^rgb/.test(styleString)){var parts=getRgbHslContent(styleString);var str='#',n;for(var i=0;i<3;i++){if(parts[i].indexOf('%')!=-1){n=Math.floor(percent(parts[i])*255);}else{n=+parts[i];}str+=decToHex[clamp(n,0,255)];}alpha=+parts[3];}else if(/^hsl/.test(styleString)){var parts=getRgbHslContent(styleString);str=hslToRgb(parts);alpha=parts[3];}else{str=colorData[styleString]||styleString;}return processStyleCache[styleString]={color:str,alpha:alpha};}var DEFAULT_STYLE={style:'normal',variant:'normal',weight:'normal',size:10,family:'sans-serif'};var fontStyleCache={};function processFontStyle(styleString){if(fontStyleCache[styleString]){return fontStyleCache[styleString];}var el=document.createElement('div');var style=el.style;try{style.font=styleString;}catch(ex){}return fontStyleCache[styleString]={style:style.fontStyle||DEFAULT_STYLE.style,variant:style.fontVariant||DEFAULT_STYLE.variant,weight:style.fontWeight||DEFAULT_STYLE.weight,size:style.fontSize||DEFAULT_STYLE.size,family:style.fontFamily||DEFAULT_STYLE.family};}function getComputedStyle(style,element){var computedStyle={};for(var p in style){computedStyle[p]=style[p];}var canvasFontSize=parseFloat(element.currentStyle.fontSize),fontSize=parseFloat(style.size);if(typeof style.size=='number'){computedStyle.size=style.size;}else if(style.size.indexOf('px')!=-1){computedStyle.size=fontSize;}else if(style.size.indexOf('em')!=-1){computedStyle.size=canvasFontSize*fontSize;}else if(style.size.indexOf('%')!=-1){computedStyle.size=(canvasFontSize/100)*fontSize;}else if(style.size.indexOf('pt')!=-1){computedStyle.size=fontSize/.75;}else{computedStyle.size=canvasFontSize;}computedStyle.size*=0.981;return computedStyle;}function buildStyle(style){return style.style+' '+style.variant+' '+style.weight+' '+style.size+'px '+style.family;}var lineCapMap={'butt':'flat','round':'round'};function processLineCap(lineCap){return lineCapMap[lineCap]||'square';}function CanvasRenderingContext2D_(canvasElement){this.m_=createMatrixIdentity();this.mStack_=[];this.aStack_=[];this.currentPath_=[];this.strokeStyle='#000';this.fillStyle='#000';this.lineWidth=1;this.lineJoin='miter';this.lineCap='butt';this.miterLimit=Z*1;this.globalAlpha=1;this.font='10px sans-serif';this.textAlign='left';this.textBaseline='alphabetic';this.canvas=canvasElement;var cssText='width:'+canvasElement.clientWidth+'px;height:'+canvasElement.clientHeight+'px;overflow:hidden;position:absolute';var el=canvasElement.ownerDocument.createElement('div');el.style.cssText=cssText;canvasElement.appendChild(el);var overlayEl=el.cloneNode(false);overlayEl.style.backgroundColor='red';overlayEl.style.filter='alpha(opacity=0)';canvasElement.appendChild(overlayEl);this.element_=el;this.arcScaleX_=1;this.arcScaleY_=1;this.lineScale_=1;}var contextPrototype=CanvasRenderingContext2D_.prototype;contextPrototype.clearRect=function(){if(this.textMeasureEl_){this.textMeasureEl_.removeNode(true);this.textMeasureEl_=null;}this.element_.innerHTML='';};contextPrototype.beginPath=function(){this.currentPath_=[];};contextPrototype.moveTo=function(aX,aY){var p=getCoords(this,aX,aY);this.currentPath_.push({type:'moveTo',x:p.x,y:p.y});this.currentX_=p.x;this.currentY_=p.y;};contextPrototype.lineTo=function(aX,aY){var p=getCoords(this,aX,aY);this.currentPath_.push({type:'lineTo',x:p.x,y:p.y});this.currentX_=p.x;this.currentY_=p.y;};contextPrototype.bezierCurveTo=function(aCP1x,aCP1y,aCP2x,aCP2y,aX,aY){var p=getCoords(this,aX,aY);var cp1=getCoords(this,aCP1x,aCP1y);var cp2=getCoords(this,aCP2x,aCP2y);bezierCurveTo(this,cp1,cp2,p);};function bezierCurveTo(self,cp1,cp2,p){self.currentPath_.push({type:'bezierCurveTo',cp1x:cp1.x,cp1y:cp1.y,cp2x:cp2.x,cp2y:cp2.y,x:p.x,y:p.y});self.currentX_=p.x;self.currentY_=p.y;}contextPrototype.quadraticCurveTo=function(aCPx,aCPy,aX,aY){var cp=getCoords(this,aCPx,aCPy);var p=getCoords(this,aX,aY);var cp1={x:this.currentX_+2.0/3.0*(cp.x-this.currentX_),y:this.currentY_+2.0/3.0*(cp.y-this.currentY_)};var cp2={x:cp1.x+(p.x-this.currentX_)/3.0,y:cp1.y+(p.y-this.currentY_)/3.0};bezierCurveTo(this,cp1,cp2,p);};contextPrototype.arc=function(aX,aY,aRadius,aStartAngle,aEndAngle,aClockwise){aRadius*=Z;var arcType=aClockwise?'at':'wa';var xStart=aX+mc(aStartAngle)*aRadius-Z2;var yStart=aY+ms(aStartAngle)*aRadius-Z2;var xEnd=aX+mc(aEndAngle)*aRadius-Z2;var yEnd=aY+ms(aEndAngle)*aRadius-Z2;if(xStart==xEnd&&!aClockwise){xStart+=0.125;}var p=getCoords(this,aX,aY);var pStart=getCoords(this,xStart,yStart);var pEnd=getCoords(this,xEnd,yEnd);this.currentPath_.push({type:arcType,x:p.x,y:p.y,radius:aRadius,xStart:pStart.x,yStart:pStart.y,xEnd:pEnd.x,yEnd:pEnd.y});};contextPrototype.rect=function(aX,aY,aWidth,aHeight){this.moveTo(aX,aY);this.lineTo(aX+aWidth,aY);this.lineTo(aX+aWidth,aY+aHeight);this.lineTo(aX,aY+aHeight);this.closePath();};contextPrototype.strokeRect=function(aX,aY,aWidth,aHeight){var oldPath=this.currentPath_;this.beginPath();this.moveTo(aX,aY);this.lineTo(aX+aWidth,aY);this.lineTo(aX+aWidth,aY+aHeight);this.lineTo(aX,aY+aHeight);this.closePath();this.stroke();this.currentPath_=oldPath;};contextPrototype.fillRect=function(aX,aY,aWidth,aHeight){var oldPath=this.currentPath_;this.beginPath();this.moveTo(aX,aY);this.lineTo(aX+aWidth,aY);this.lineTo(aX+aWidth,aY+aHeight);this.lineTo(aX,aY+aHeight);this.closePath();this.fill();this.currentPath_=oldPath;};contextPrototype.createLinearGradient=function(aX0,aY0,aX1,aY1){var gradient=new CanvasGradient_('gradient');gradient.x0_=aX0;gradient.y0_=aY0;gradient.x1_=aX1;gradient.y1_=aY1;return gradient;};contextPrototype.createRadialGradient=function(aX0,aY0,aR0,aX1,aY1,aR1){var gradient=new CanvasGradient_('gradientradial');gradient.x0_=aX0;gradient.y0_=aY0;gradient.r0_=aR0;gradient.x1_=aX1;gradient.y1_=aY1;gradient.r1_=aR1;return gradient;};contextPrototype.drawImage=function(image,var_args){var dx,dy,dw,dh,sx,sy,sw,sh;var oldRuntimeWidth=image.runtimeStyle.width;var oldRuntimeHeight=image.runtimeStyle.height;image.runtimeStyle.width='auto';image.runtimeStyle.height='auto';var w=image.width;var h=image.height;image.runtimeStyle.width=oldRuntimeWidth;image.runtimeStyle.height=oldRuntimeHeight;if(arguments.length==3){dx=arguments[1];dy=arguments[2];sx=sy=0;sw=dw=w;sh=dh=h;}else if(arguments.length==5){dx=arguments[1];dy=arguments[2];dw=arguments[3];dh=arguments[4];sx=sy=0;sw=w;sh=h;}else if(arguments.length==9){sx=arguments[1];sy=arguments[2];sw=arguments[3];sh=arguments[4];dx=arguments[5];dy=arguments[6];dw=arguments[7];dh=arguments[8];}else{throw Error('Invalid number of arguments');}var d=getCoords(this,dx,dy);var w2=sw/2;var h2=sh/2;var vmlStr=[];var W=10;var H=10;vmlStr.push(' <g_vml_:group',' coordsize="',Z*W,',',Z*H,'"',' coordorigin="0,0"',' style="width:',W,'px;height:',H,'px;position:absolute;');if(this.m_[0][0]!=1||this.m_[0][1]||this.m_[1][1]!=1||this.m_[1][0]){var filter=[];filter.push('M11=',this.m_[0][0],',','M12=',this.m_[1][0],',','M21=',this.m_[0][1],',','M22=',this.m_[1][1],',','Dx=',mr(d.x/Z),',','Dy=',mr(d.y/Z),'');var max=d;var c2=getCoords(this,dx+dw,dy);var c3=getCoords(this,dx,dy+dh);var c4=getCoords(this,dx+dw,dy+dh);max.x=m.max(max.x,c2.x,c3.x,c4.x);max.y=m.max(max.y,c2.y,c3.y,c4.y);vmlStr.push('padding:0 ',mr(max.x/Z),'px ',mr(max.y/Z),'px 0;filter:progid:DXImageTransform.Microsoft.Matrix(',filter.join(''),", sizingmethod='clip');");}else{vmlStr.push('top:',mr(d.y/Z),'px;left:',mr(d.x/Z),'px;');}vmlStr.push(' ">','<g_vml_:image src="',image.src,'"',' style="width:',Z*dw,'px;',' height:',Z*dh,'px"',' cropleft="',sx/w,'"',' croptop="',sy/h,'"',' cropright="',(w-sx-sw)/w,'"',' cropbottom="',(h-sy-sh)/h,'"',' />','</g_vml_:group>');this.element_.insertAdjacentHTML('BeforeEnd',vmlStr.join(''));};contextPrototype.stroke=function(aFill){var lineStr=[];var lineOpen=false;var W=10;var H=10;lineStr.push('<g_vml_:shape',' filled="',!!aFill,'"',' style="position:absolute;width:',W,'px;height:',H,'px;"',' coordorigin="0,0"',' coordsize="',Z*W,',',Z*H,'"',' stroked="',!aFill,'"',' path="');var newSeq=false;var min={x:null,y:null};var max={x:null,y:null};for(var i=0;i<this.currentPath_.length;i++){var p=this.currentPath_[i];var c;switch(p.type){case'moveTo':c=p;lineStr.push(' m ',mr(p.x),',',mr(p.y));break;case'lineTo':lineStr.push(' l ',mr(p.x),',',mr(p.y));break;case'close':lineStr.push(' x ');p=null;break;case'bezierCurveTo':lineStr.push(' c ',mr(p.cp1x),',',mr(p.cp1y),',',mr(p.cp2x),',',mr(p.cp2y),',',mr(p.x),',',mr(p.y));break;case'at':case'wa':lineStr.push(' ',p.type,' ',mr(p.x-this.arcScaleX_*p.radius),',',mr(p.y-this.arcScaleY_*p.radius),' ',mr(p.x+this.arcScaleX_*p.radius),',',mr(p.y+this.arcScaleY_*p.radius),' ',mr(p.xStart),',',mr(p.yStart),' ',mr(p.xEnd),',',mr(p.yEnd));break;}if(p){if(min.x==null||p.x<min.x){min.x=p.x;}if(max.x==null||p.x>max.x){max.x=p.x;}if(min.y==null||p.y<min.y){min.y=p.y;}if(max.y==null||p.y>max.y){max.y=p.y;}}}lineStr.push(' ">');if(!aFill){appendStroke(this,lineStr);}else{appendFill(this,lineStr,min,max);}lineStr.push('</g_vml_:shape>');this.element_.insertAdjacentHTML('beforeEnd',lineStr.join(''));};function appendStroke(ctx,lineStr){var a=processStyle(ctx.strokeStyle);var color=a.color;var opacity=a.alpha*ctx.globalAlpha;var lineWidth=ctx.lineScale_*ctx.lineWidth;if(lineWidth<1){opacity*=lineWidth;}lineStr.push('<g_vml_:stroke',' opacity="',opacity,'"',' joinstyle="',ctx.lineJoin,'"',' miterlimit="',ctx.miterLimit,'"',' endcap="',processLineCap(ctx.lineCap),'"',' weight="',lineWidth,'px"',' color="',color,'" />');}function appendFill(ctx,lineStr,min,max){var fillStyle=ctx.fillStyle;var arcScaleX=ctx.arcScaleX_;var arcScaleY=ctx.arcScaleY_;var width=max.x-min.x;var height=max.y-min.y;if(fillStyle instanceof CanvasGradient_){var angle=0;var focus={x:0,y:0};var shift=0;var expansion=1;if(fillStyle.type_=='gradient'){var x0=fillStyle.x0_/arcScaleX;var y0=fillStyle.y0_/arcScaleY;var x1=fillStyle.x1_/arcScaleX;var y1=fillStyle.y1_/arcScaleY;var p0=getCoords(ctx,x0,y0);var p1=getCoords(ctx,x1,y1);var dx=p1.x-p0.x;var dy=p1.y-p0.y;angle=Math.atan2(dx,dy)*180/Math.PI;if(angle<0){angle+=360;}if(angle<1e-6){angle=0;}}else{var p0=getCoords(ctx,fillStyle.x0_,fillStyle.y0_);focus={x:(p0.x-min.x)/width,y:(p0.y-min.y)/height};width/=arcScaleX*Z;height/=arcScaleY*Z;var dimension=m.max(width,height);shift=2*fillStyle.r0_/dimension;expansion=2*fillStyle.r1_/dimension-shift;}var stops=fillStyle.colors_;stops.sort(function(cs1,cs2){return cs1.offset-cs2.offset;});var length=stops.length;var color1=stops[0].color;var color2=stops[length-1].color;var opacity1=stops[0].alpha*ctx.globalAlpha;var opacity2=stops[length-1].alpha*ctx.globalAlpha;var colors=[];for(var i=0;i<length;i++){var stop=stops[i];colors.push(stop.offset*expansion+shift+' '+stop.color);}lineStr.push('<g_vml_:fill type="',fillStyle.type_,'"',' method="none" focus="100%"',' color="',color1,'"',' color2="',color2,'"',' colors="',colors.join(','),'"',' opacity="',opacity2,'"',' g_o_:opacity2="',opacity1,'"',' angle="',angle,'"',' focusposition="',focus.x,',',focus.y,'" />');}else if(fillStyle instanceof CanvasPattern_){if(width&&height){var deltaLeft=-min.x;var deltaTop=-min.y;lineStr.push('<g_vml_:fill',' position="',deltaLeft/width*arcScaleX*arcScaleX,',',deltaTop/height*arcScaleY*arcScaleY,'"',' type="tile"',' src="',fillStyle.src_,'" />');}}else{var a=processStyle(ctx.fillStyle);var color=a.color;var opacity=a.alpha*ctx.globalAlpha;lineStr.push('<g_vml_:fill color="',color,'" opacity="',opacity,'" />');}}contextPrototype.fill=function(){this.stroke(true);};contextPrototype.closePath=function(){this.currentPath_.push({type:'close'});};function getCoords(ctx,aX,aY){var m=ctx.m_;return{x:Z*(aX*m[0][0]+aY*m[1][0]+m[2][0])-Z2,y:Z*(aX*m[0][1]+aY*m[1][1]+m[2][1])-Z2};};contextPrototype.save=function(){var o={};copyState(this,o);this.aStack_.push(o);this.mStack_.push(this.m_);this.m_=matrixMultiply(createMatrixIdentity(),this.m_);};contextPrototype.restore=function(){if(this.aStack_.length){copyState(this.aStack_.pop(),this);this.m_=this.mStack_.pop();}};function matrixIsFinite(m){return isFinite(m[0][0])&&isFinite(m[0][1])&&isFinite(m[1][0])&&isFinite(m[1][1])&&isFinite(m[2][0])&&isFinite(m[2][1]);}function setM(ctx,m,updateLineScale){if(!matrixIsFinite(m)){return;}ctx.m_=m;if(updateLineScale){var det=m[0][0]*m[1][1]-m[0][1]*m[1][0];ctx.lineScale_=sqrt(abs(det));}}contextPrototype.translate=function(aX,aY){var m1=[[1,0,0],[0,1,0],[aX,aY,1]];setM(this,matrixMultiply(m1,this.m_),false);};contextPrototype.rotate=function(aRot){var c=mc(aRot);var s=ms(aRot);var m1=[[c,s,0],[-s,c,0],[0,0,1]];setM(this,matrixMultiply(m1,this.m_),false);};contextPrototype.scale=function(aX,aY){this.arcScaleX_*=aX;this.arcScaleY_*=aY;var m1=[[aX,0,0],[0,aY,0],[0,0,1]];setM(this,matrixMultiply(m1,this.m_),true);};contextPrototype.transform=function(m11,m12,m21,m22,dx,dy){var m1=[[m11,m12,0],[m21,m22,0],[dx,dy,1]];setM(this,matrixMultiply(m1,this.m_),true);};contextPrototype.setTransform=function(m11,m12,m21,m22,dx,dy){var m=[[m11,m12,0],[m21,m22,0],[dx,dy,1]];setM(this,m,true);};contextPrototype.drawText_=function(text,x,y,maxWidth,stroke){var m=this.m_,delta=1000,left=0,right=delta,offset={x:0,y:0},lineStr=[];var fontStyle=getComputedStyle(processFontStyle(this.font),this.element_);var fontStyleString=buildStyle(fontStyle);var elementStyle=this.element_.currentStyle;var textAlign=this.textAlign.toLowerCase();switch(textAlign){case'left':case'center':case'right':break;case'end':textAlign=elementStyle.direction=='ltr'?'right':'left';break;case'start':textAlign=elementStyle.direction=='rtl'?'right':'left';break;default:textAlign='left';}switch(this.textBaseline){case'hanging':case'top':offset.y=fontStyle.size/1.75;break;case'middle':break;default:case null:case'alphabetic':case'ideographic':case'bottom':offset.y=-fontStyle.size/2.25;break;}switch(textAlign){case'right':left=delta;right=0.05;break;case'center':left=right=delta/2;break;}var d=getCoords(this,x+offset.x,y+offset.y);lineStr.push('<g_vml_:line from="',-left,' 0" to="',right,' 0.05" ',' coordsize="100 100" coordorigin="0 0"',' filled="',!stroke,'" stroked="',!!stroke,'" style="position:absolute;width:1px;height:1px;">');if(stroke){appendStroke(this,lineStr);}else{appendFill(this,lineStr,{x:-left,y:0},{x:right,y:fontStyle.size});}var skewM=m[0][0].toFixed(3)+','+m[1][0].toFixed(3)+','+m[0][1].toFixed(3)+','+m[1][1].toFixed(3)+',0,0';var skewOffset=mr(d.x/Z)+','+mr(d.y/Z);lineStr.push('<g_vml_:skew on="t" matrix="',skewM,'" ',' offset="',skewOffset,'" origin="',left,' 0" />','<g_vml_:path textpathok="true" />','<g_vml_:textpath on="true" string="',encodeHtmlAttribute(text),'" style="v-text-align:',textAlign,';font:',encodeHtmlAttribute(fontStyleString),'" /></g_vml_:line>');this.element_.insertAdjacentHTML('beforeEnd',lineStr.join(''));};contextPrototype.fillText=function(text,x,y,maxWidth){this.drawText_(text,x,y,maxWidth,false);};contextPrototype.strokeText=function(text,x,y,maxWidth){this.drawText_(text,x,y,maxWidth,true);};contextPrototype.measureText=function(text){if(!this.textMeasureEl_){var s='<span style="position:absolute;'+'top:-20000px;left:0;padding:0;margin:0;border:none;'+'white-space:pre;"></span>';this.element_.insertAdjacentHTML('beforeEnd',s);this.textMeasureEl_=this.element_.lastChild;}var doc=this.element_.ownerDocument;this.textMeasureEl_.innerHTML='';this.textMeasureEl_.style.font=this.font;this.textMeasureEl_.appendChild(doc.createTextNode(text));return{width:this.textMeasureEl_.offsetWidth};};contextPrototype.clip=function(){};contextPrototype.arcTo=function(){};contextPrototype.createPattern=function(image,repetition){return new CanvasPattern_(image,repetition);};function CanvasGradient_(aType){this.type_=aType;this.x0_=0;this.y0_=0;this.r0_=0;this.x1_=0;this.y1_=0;this.r1_=0;this.colors_=[];}CanvasGradient_.prototype.addColorStop=function(aOffset,aColor){aColor=processStyle(aColor);this.colors_.push({offset:aOffset,color:aColor.color,alpha:aColor.alpha});};function CanvasPattern_(image,repetition){assertImageIsValid(image);switch(repetition){case'repeat':case null:case'':this.repetition_='repeat';break;case'repeat-x':case'repeat-y':case'no-repeat':this.repetition_=repetition;break;default:throwException('SYNTAX_ERR');}this.src_=image.src;this.width_=image.width;this.height_=image.height;}function throwException(s){throw new DOMException_(s);}function assertImageIsValid(img){if(!img||img.nodeType!=1||img.tagName!='IMG'){throwException('TYPE_MISMATCH_ERR');}if(img.readyState!='complete'){throwException('INVALID_STATE_ERR');}}function DOMException_(s){this.code=this[s];this.message=s+': DOM Exception '+this.code;}var p=DOMException_.prototype=new Error;p.INDEX_SIZE_ERR=1;p.DOMSTRING_SIZE_ERR=2;p.HIERARCHY_REQUEST_ERR=3;p.WRONG_DOCUMENT_ERR=4;p.INVALID_CHARACTER_ERR=5;p.NO_DATA_ALLOWED_ERR=6;p.NO_MODIFICATION_ALLOWED_ERR=7;p.NOT_FOUND_ERR=8;p.NOT_SUPPORTED_ERR=9;p.INUSE_ATTRIBUTE_ERR=10;p.INVALID_STATE_ERR=11;p.SYNTAX_ERR=12;p.INVALID_MODIFICATION_ERR=13;p.NAMESPACE_ERR=14;p.INVALID_ACCESS_ERR=15;p.VALIDATION_ERR=16;p.TYPE_MISMATCH_ERR=17;G_vmlCanvasManager=G_vmlCanvasManager_;CanvasRenderingContext2D=CanvasRenderingContext2D_;CanvasGradient=CanvasGradient_;CanvasPattern=CanvasPattern_;DOMException=DOMException_;})();}

// Custom Simple Fade Gallery
(function($){
	$.CustomSimpleFade = {

		/**
		 * Slideshow initialization
		 */
		init: function(configs) {

			this.clearResources();


			//*** IDENTIFIERS ***\\

			// generic canvas identifier
			this.canvasIdentifier = null,

			// preloader identifier
			this.preloaderIdentifier = null,

			// timeout id's
			this.timeoutResources = [],
			this.hideElements = [],
			this.resizeTimeout = null,

			// call stack shows how many times embed canvas was initialized
			this.callStack = 0;

			// instance number shows the number of template class initialization
			this.instanceNO = 0,



			//*** CUSTOMIZATION DEFAULTS ***\\

			// Auto hide controls property
			this.autoHideControls =	false,

			// Auto slideshow property
			this.autoSlideShow = true,

			// The color of the background displayed by the album
			this.backgroundColor = '#000000',

			// The URL or file path and name of an image displayed as the background of the album
			this.backgroundImage = '',

			// Background visible property
			this.backgroundVisible = true,

			// Border color value
			this.borderColor = '#ffffff',

			// Border size value
			this.borderSize = 5,

			// Controls hide speed value
			this.controlsHideSpeed = 2,

			// Show exit button property
			this.exitButton = true,

			// The URL or file path and name of an image displayed as the exit button
			this.exitButtonURL = '',

			// Control bar icons URL
			this.iconsURL = 'icons/',

			// Load original images property
			this.loadOriginalImages = false,

			// Scale background property
			this.scaleBackground = true,

			// Scale mode type
			this.scaleMode = 'scaleCrop',

			// Shadow color value
			this.shadowColor = '#000000',

			// Shadow distance value
			this.shadowDistance = 5,

			// Slideshow speed value
			this.slideShowSpeed = 6,

			// Transition speed value
			this.transitionSpeed = 0.4,

			// Transition type
			this.transitionType = 'fade',



			//*** SETTINGS ***\\

			// canvas width in normal screen mode - defined by setWidth method
			this.defaultCanvasWidth = null,

			// curent canvas width
			this.canvasWidth = null,

			// slideshow display width
			this.displayWidth = null,

			// canvas height in normal screen mode - defined by setHeight method
			this.defaultCanvasHeight = null,

			// curent canvas height
			this.canvasHeight = null,

			// slideshow display height
			this.displayHeight = null,

			// preloader animation speed, lower = faster
			this.preloaderSpeed = 80,

			// images xml path
			this.source = null,

			// xml json object containing images
			this.xml,



			//*** FLAGS ***\\

			// fix css flag
			this.flagFixCss = true,

			// frozen engine
			this.flagFrozen = false,

			// resize handler
			this.flagResizeHandler = false,

			// fullscreen flag
			this.fullScreenMode = false;



			//*** GO ON ***\\

			if (!this.parseConfigs(configs)) {
				return;
			}

			if (!this.generateIdentifier()) {
				return;
			}

			this.fixCSS();

			if (typeof configs.appendToID != 'undefined' && configs.appendToID.length > 0) {
				$('<div />').attr('id', this.canvasIdentifier + '_GP')
					.css({width:this.defaultCanvasWidth+'px',height:this.defaultCanvasHeight+'px'})
					.appendTo('#'+configs.appendToID);

			} else if (typeof configs.insertAfterID != 'undefined' && configs.insertAfterID.length > 0) {
				$('<div />').attr('id', this.canvasIdentifier + '_GP')
					.css({width:this.defaultCanvasWidth+'px',height:this.defaultCanvasHeight+'px'})
					.insertAfter('#'+configs.insertAfterID);
			}

			$('<div />').attr('id',this.canvasIdentifier).appendTo('#'+this.canvasIdentifier+'_GP');

			this.preloaderIdentifier = this.canvasIdentifier + '_preloader';

			eval('$(document).ready(function(){window.'
					+ this.canvasIdentifier + '.loadTemplateXml(' + this.callStack + ')})');
		},

		/**
		 * clear timeout resources
		 */
		clearResources: function(){
			if (typeof this.timeoutResources != 'undefined') {
				while(this.timeoutResources.length>0){
					clearTimeout(this.timeoutResources[0]);
					this.timeoutResources.splice(0, 1);
				}
			}
			if (typeof this.timeoutResources != 'undefined') {
				while(this.hideElements.length>0){
					$('#'+this.hideElements[0]).hide();
					this.hideElements.splice(0, 1);
				}
			}
		},

		/**
		 * Parse user configs
		 */
		parseConfigs: function(configs) {
			if (typeof configs.width != 'number' || configs.width <= 0
				|| typeof configs.height != 'number' || configs.height <= 0
				|| typeof configs.source != 'string' || configs.source.length <= 0
				||
				(
					(typeof configs.appendToID != 'string' || configs.appendToID.length <= 0)
					&&
					(typeof configs.insertAfterID != 'string' || configs.insertAfterID.length <= 0)
				))
			{
				return false;
			}

			// source
			this.source = configs.source;

			// width and height
			this.defaultCanvasWidth = parseInt(configs.width);
			this.defaultCanvasHeight = parseInt(configs.height);

			// fix css
			if (typeof configs.fixCss != 'undefined') {
				if (configs.fixCss.toString().toLowerCase() == 'true') {
					this.flagFixCss = true;
				} else if (configs.fixCss.toString().toLowerCase() == 'false') {
					this.flagFixCss = false;
				}
			}

			// autoHideControls
			if (typeof configs.autoHideControls != 'undefined') {
				if (configs.autoHideControls.toString().toLowerCase() == 'true') {
					this.autoHideControls = true;
				} else if (configs.autoHideControls.toString().toLowerCase() == 'false') {
					this.autoHideControls = false;
				}
			}

			// autoSlideShow
			if (typeof configs.autoSlideShow != 'undefined') {
				if (configs.autoSlideShow.toString().toLowerCase() == 'true') {
					this.autoSlideShow = true;
				} else if (configs.autoSlideShow.toString().toLowerCase() == 'false') {
					this.autoSlideShow = false;
				}
			}

			// backgroundColor
			if (typeof configs.backgroundColor != 'undefined' && configs.backgroundColor.length > 0) {
				this.backgroundColor = configs.backgroundColor;
			}

			// backgroundImage
			if (typeof configs.backgroundImage != 'undefined' && configs.backgroundImage.length > 0) {
				this.backgroundImage = configs.backgroundImage;
			}

			// backgroundVisible
			if (typeof configs.backgroundVisible != 'undefined') {
				if (configs.backgroundVisible.toString().toLowerCase() == 'true') {
					this.backgroundVisible = true;
				} else if (configs.backgroundVisible.toString().toLowerCase() == 'false') {
					this.backgroundVisible = false;
				}
			}

			// borderColor
			if (typeof configs.borderColor != 'undefined' && configs.borderColor.length > 0) {
				this.borderColor = configs.borderColor;
			}

			// borderSize
			if (typeof configs.borderSize != 'undefined' && configs.borderSize >= 0) {
				this.borderSize = parseInt(configs.borderSize);
			}

			// controlsHideSpeed
			if (typeof configs.controlsHideSpeed != 'undefined' && configs.controlsHideSpeed >= 0) {
				this.controlsHideSpeed = parseFloat(configs.controlsHideSpeed) * 1000;
			}

			// exitButton
			if (typeof configs.exitButton != 'undefined') {
				if (configs.exitButton.toString().toLowerCase() == 'true') {
					this.exitButton = true;
				} else if (configs.exitButton.toString().toLowerCase() == 'false') {
					this.exitButton = false;
				}
			}

			// exitButtonURL
			if (typeof configs.exitButtonURL != 'undefined' && configs.exitButtonURL.length > 0) {
				this.exitButtonURL = configs.exitButtonURL;
			}

			// iconsURL
			if (typeof configs.iconsURL != 'undefined' && configs.iconsURL.length > 0) {
				this.iconsURL = configs.iconsURL;
			}

			// loadOriginalImages
			if (typeof configs.loadOriginalImages != 'undefined') {
				if (configs.loadOriginalImages.toString().toLowerCase() == 'true') {
					this.loadOriginalImages = true;
				} else if (configs.loadOriginalImages.toString().toLowerCase() == 'false') {
					this.loadOriginalImages = false;
				}
			}

			// scaleBackground
			if (typeof configs.scaleBackground != 'undefined') {
				if (configs.scaleBackground.toString().toLowerCase() == 'true') {
					this.scaleBackground = true;
				} else if (configs.scaleBackground.toString().toLowerCase() == 'false') {
					this.scaleBackground = false;
				}
			}
			// scaleMode
			if (typeof configs.scaleMode != 'undefined') {
				if (configs.scaleMode.toString().toLowerCase() == 'scale') {
					this.scaleMode = 'scale';
				} else if (configs.scaleMode.toString().toLowerCase() == 'scalecrop') {
					this.scaleMode = 'scalecrop';
				}
			}

			// shadowColor
			if (typeof configs.shadowColor != 'undefined' && configs.shadowColor.length > 0) {
				this.shadowColor = configs.shadowColor;
			}

			// shadowDistance
			if (typeof configs.shadowDistance != 'undefined' && configs.shadowDistance >= 0) {
				this.shadowDistance = parseInt(configs.shadowDistance);
			}

			// slideShowSpeed
			if (typeof configs.slideShowSpeed != 'undefined' && configs.slideShowSpeed >= 0) {
				this.slideShowSpeed = parseFloat(configs.slideShowSpeed) * 1000;
			}

			// transitionSpeed
			if (typeof configs.transitionSpeed != 'undefined' && configs.transitionSpeed >= 0) {
				this.transitionSpeed = parseFloat(configs.transitionSpeed) * 1000;
			}

			// transitionType
			if (typeof configs.transitionType != 'undefined') {
				if (configs.transitionType.toString().toLowerCase() == 'fade') {
					this.transitionType = 'fade';
				} else if (configs.transitionType.toString().toLowerCase() == 'slide') {
					this.transitionType = 'slide';
				}
			}

			return true;
		},

		/**
		 * Globally Unique Identifier Generator for current slideshow
		 */
		generateIdentifier: function() {
			var i = 1;
			while((document.getElementById('CustomSimpleFadeContainer'+i) != null
					|| eval('typeof window.CustomSimpleFadeContainer'+i) != 'undefined')
					&& i < 1000)
			{
				i++;
			}
			this.canvasIdentifier='CustomSimpleFadeContainer'+i;
			this.callStack = i;
			eval('window.'+this.canvasIdentifier+'=this');

			return true;
		},

		/**
		 * Fix CSS
		 */
		fixCSS: function(){
			if (this.flagFixCss == false) {
				return;
			}
			var err;
			try {
				$.tocssRule(
					'#'+this.canvasIdentifier+'_GP, #'+this.canvasIdentifier+'_GP * {'+
						'background:none fixed transparent left top no-repeat;'+
						'border:none;'+
						'bottom:auto;'+
						'clear:none;'+
						'cursor:auto;'+
						'direction:ltr;'+
						'display:block;'+
						'float:none;'+
						'font-family:"Lucida Grande","Lucida Sans Unicode","Lucida Sans",'+
							'Verdana,Arial,Helvetica,sans-serif;'+
						'font-size:10px;'+
						'font-size-adjust:none;'+
						'font-stretch:normal;'+
						'font-style:normal;'+
						'font-variant:normal;'+
						'font-weight:normal;'+
						'height:auto;'+
						'layout-flow:horizontal;'+
						'layout-grid:none;'+
						'left:0px;'+
						'letter-spacing:normal;'+
						'line-break:normal;'+
						'line-height:normal;'+
						'list-style:disc outside none;'+
						'margin:0px 0px 0px 0px;'+
						'max-height:none;'+
						'max-width:none;'+
						'min-height:0px;'+
						'min-width:0px;'+
						'-moz-border-radius:0;'+
						'outline-color:invert;'+
						'outline-style:none;'+
						'outline-width:medium;'+
						'overflow:visible;'+
						'padding:0px 0px 0px 0px;'+
						'position:static;'+
						'right:auto;'+
						'text-align:left;'+
						'text-decoration:none;'+
						'text-indent:0px;'+
						'text-shadow:none;'+
						'text-transform:none;'+
						'top:0px;'+
						'vertical-align:baseline;'+
						'visibility:visible;'+
						'width:auto;'+
						'word-spacing:normal;'+
						'z-index:1;'+
						'zoom:1;'+
					'}'
				);
			} catch(err) {};
		},

		/**
		 * Load Album Template XML, store data in xml var and run canvas setup function
		 */
		loadTemplateXml: function(callStack) {
			if (this.callStack != callStack) {
				return;
			}
			var obj = this;

			$.get(this.source, function(data) {
				obj.xml = $.xml2json(data);
				if (typeof obj.xml.items.item[0] == 'undefined') {
					if (typeof obj.xml.items.item.largeImagePath != 'undefined') {
						obj.xml.items.item = [obj.xml.items.item];
					} else {
						return false;
					}
				}
				obj.canvasSetup(callStack);
			});
		},

		/**
		 * Canvas Master Setup
		 */
		canvasSetup: function(callStack) {
			if (typeof callStack == 'undefined') {
				var callStack = this.callStack;
			} else if (this.callStack != callStack) {
				return;
			}
			var instanceNO = ++this.instanceNO;
			this.setFrozenFlagOn();


			var obj = this;

			if (this.fullScreenMode == true) {
				if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
					$('#'+this.canvasIdentifier).css({
						position:'absolute',
						marginTop:'auto',
						marginLeft:'auto'
					});

					var elemOffset = $('#'+this.canvasIdentifier).offset();

					$('#'+this.canvasIdentifier).css({
						position:'absolute',
						marginTop:(-1*elemOffset.top+$(window).scrollTop())+'px',
						marginLeft:(-1*elemOffset.left+$(window).scrollLeft())+'px',
						width:$(window).width()+'px',
						height:$(window).height()+'px',
						overflow:'hidden',
						backgroundColor:this.backgroundColor
					});

					$(window).scroll(function () {
						if (obj.fullScreenMode == true) {
							$('#'+obj.canvasIdentifier).css({
								marginTop:(-1*elemOffset.top+$(window).scrollTop())+'px',
								marginLeft:(-1*elemOffset.left+$(window).scrollLeft())+'px'
							});
						}
					});
				} else {
					$('#'+this.canvasIdentifier).css({
						position:'fixed',
						top:'0px',
						left:'0px',
						width:$(window).width()+'px',
						height:$(window).height()+'px',
						overflow:'hidden',
						backgroundColor:this.backgroundColor
					});
				}

				if ($.browser.msie && $.browser.version < 7) {
					$(document).keypress(function(event) {
						if (event.keyCode == '27' && obj.fullScreenMode == true && !obj.isFrozen()) {
							obj.showNormalScreen();
							return false;
						}
					});
				} else {
					$(document).keydown(function(event) {
						if (event.keyCode == '27' && obj.fullScreenMode == true && !obj.isFrozen()) {
							obj.showNormalScreen();
							return false;
						}
					});
				}
				this.canvasWidth = $('#'+this.canvasIdentifier).width();
				this.canvasHeight = $('#'+this.canvasIdentifier).height();
			} else {
				$('#'+this.canvasIdentifier).css({
					position:'relative',
					width:this.defaultCanvasWidth+'px',
					height:this.defaultCanvasHeight+'px',
					overflow:'hidden'
				});
				this.canvasWidth = this.defaultCanvasWidth;
				this.canvasHeight = this.defaultCanvasHeight;
			}

			if (this.backgroundVisible) {
				$('#'+this.canvasIdentifier).css({backgroundColor:this.backgroundColor});
			} else {
				$('#'+this.canvasIdentifier).css({backgroundColor:'transparent'});
			}

			this.displayHeight = this.canvasHeight;
			this.displayWidth = this.canvasWidth;

			this.generatePreloader(this.preloaderIdentifier,
				'window.' + this.canvasIdentifier + '.showPreloader(' + callStack + ')');

			if($('#'+this.canvasIdentifier).is(':visible')) {
				this.setBackgroundImage(callStack);
				this.initiateTemplateJS(callStack, instanceNO);
			} else {
				$('#'+this.canvasIdentifier).fadeIn('fast', function(){
					obj.setBackgroundImage(callStack);
					obj.initiateTemplateJS(callStack, instanceNO);
				});
			}
		},

		/**
		 * Check if canvas is in frozen state
		 */
		isFrozen: function(){
			return this.flagFrozen == true;
		},

		/**
		 * Unfroze canvas
		 */
		setFrozenFlagOff: function(){
			this.flagFrozen = false;
		},

		/**
		 * Froze canvas
		 */
		setFrozenFlagOn: function(){
			this.flagFrozen = true;
		},

		/**
		 * Run fullscreen mode
		 */
		showFullScreen: function() {
			if (this.isFrozen()) {
				return;
			}
			this.clearResources();
			this.fullScreenMode = true;
			this.autoSlideShow = undefined;

			var localScope = this;

			if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
				$('#'+this.canvasIdentifier).empty();
				$('embed, object, select').css({ 'visibility' : 'visible' });
				if (!localScope.flagResizeHandler) {
					localScope.flagResizeHandler = true;
					$(window).resize(function() {
						if (localScope.fullScreenMode == true) {
							window.clearTimeout(localScope.resizeTimeout);
							localScope.resizeTimeout =window.setTimeout(
									'window.'+localScope.canvasIdentifier+'.showFullScreen()',100);
						}
					});
				}
				localScope.canvasSetup();
			} else {
				$('#'+this.canvasIdentifier).fadeOut('fast', function(){
					$(this).empty();
					$('embed, object, select').css({ 'visibility' : 'visible' });
					if (!localScope.flagResizeHandler) {
						localScope.flagResizeHandler = true;
						$(window).resize(function() {
							if (localScope.fullScreenMode == true) {
								window.clearTimeout(localScope.resizeTimeout);
								localScope.resizeTimeout =window.setTimeout(
										'window.'+localScope.canvasIdentifier+'.showFullScreen()',100);
							}
						});
					}
					localScope.canvasSetup();
				});
			}
		},

		/**
		 * Run normal screen mode
		 */
		showNormalScreen: function() {
			if (this.isFrozen()) {
				return;
			}
			this.clearResources();
			this.fullScreenMode = false;
			this.autoSlideShow = undefined;

			var localScope = this;

			if (!$.support.boxModel || ($.browser.msie && $.browser.version < 7)) {
				$('#'+this.canvasIdentifier).empty();
				$('embed, object, select').css({ 'visibility' : 'visible' });
				$('#'+localScope.canvasIdentifier).css({marginTop:'auto',marginLeft:'auto'});
				localScope.canvasSetup();
			} else {
				$('#'+this.canvasIdentifier).fadeOut('fast', function(){
					$(this).empty();
					$('embed, object, select').css({ 'visibility' : 'visible' });
					localScope.canvasSetup();
				});
			}
		},

		/**
		 * Convert hex to rgba colors
		 */
		hexToRgb: function (color, alpha) {
			if (typeof color === 'undefined' || (color.length !== 4 && color.length !== 7)) {
				return false;
			}
			if (color.length === 4) {
				color = ('#' + color.substring(1, 2)) + color.substring(1, 2) + color.substring(2, 3) + color.substring(2, 3) + color.substring(3, 4) + color.substring(3, 4);
			}
			var r = parseInt(color.substring(1, 7).substring(0, 2), 16);
			var g = parseInt(color.substring(1, 7).substring(2, 4), 16);
			var b = parseInt(color.substring(1, 7).substring(4, 6), 16);
			return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
		},

		/**
		 * Set Background Image
		 */
		setBackgroundImage: function(callStack) {
			if (this.callStack != callStack) {
				return;
			}
			var localScope = this;
			if (this.backgroundVisible && this.backgroundImage.length > 0)
			{
				var obj = this;
				var bgImg = this.canvasIdentifier+'_backgroundImage';
				$('<img>').load(function(){
					$(this).unbind('load').hide().attr('id',bgImg).appendTo('#'+obj.canvasIdentifier);
					if (localScope.scaleBackground) {
						var cH = $(this).height();
						var cW = $(this).width();
						var canvasProp = obj.displayWidth/obj.displayHeight;
						var imageProp = cW/cH;

						if (cH != obj.displayHeight || cW != obj.displayWidth) {
							if (canvasProp > imageProp) {
								$(this).width(obj.displayWidth)
									.height(Math.ceil(cH * obj.displayWidth / cW))
									// max-width -> fix for chrome and safari
									.css('max-width', obj.displayWidth);
							} else {
								$(this).height(obj.displayHeight)
									.width(Math.ceil(cW * obj.displayHeight / cH))
									// max-width -> fix for chrome and safari
									.css('max-width', Math.ceil(cW * obj.displayHeight / cH));
							}
						}
					}
					$(this).css({position:'absolute', zIndex:0,
							marginTop:(obj.canvasHeight-$(this).height())/2+'px',
							marginLeft:(obj.canvasWidth-$(this).width())/2+'px'})
						.fadeIn('fast');
				}).attr('src', this.backgroundImage);
			}
		},

		/**
		 * Rotate preloader
		 */
		rotatePreloaderTick: function(func, preloader, preloaderSpeed) {
			return function() {
				var o;
				$(preloader).clearRect([-15, -15], {width: 30, height: 30});
				$(preloader).rotate(Math.PI / 6);
				for (var i = 0; i < 12; i++) {
					o = ((i > 10) ? 10 : i) / 10;
					$(preloader).style({
						fillStyle: 'rgba(255, 255, 255, ' + o + ')',
						strokeStyle: 'rgba(0, 0, 0, ' + o + ')',
						lineWidth: .5
					});
					$(preloader).strokeRect([-1.5, 7], {width: 3, height: 7});
					$(preloader).fillRect([-1.5, 7], {width: 3, height: 7});
					$(preloader).rotate(Math.PI / 6);
				}
				setTimeout(func.call(this, func, preloader, preloaderSpeed), preloaderSpeed);
			};
		},

		/**
		 * Generate preloader
		 */
		generatePreloader: function(id, callback) {
			var obj = this;

			var preloader = $('<div/>').attr('id', id).css({
				width: 30, minWidth: 30,
				height: 30, minHeight: 30
			}).appendTo('#' + this.canvasIdentifier).canvas();

			var tick, ticks = [];
			$(preloader).translate(15, 15);
			setTimeout(this.rotatePreloaderTick(this.rotatePreloaderTick, preloader, this.preloaderSpeed), this.preloaderSpeed);

			if (typeof callback === 'string') {
				setTimeout(callback, 0); // eval calls too quickly? - the above css() doesn't seem to get executed fast enough so the width/height is not set
			}
		},

		/**
		 * Show generic preloader
		 */
		showPreloader: function(callStack) {
			if (typeof callStack != 'undefined' && this.callStack != callStack) {
				return;
			}
			$('#' + this.preloaderIdentifier).css({position:'absolute', zIndex:50,
				marginTop:((this.displayHeight-$('#'+this.preloaderIdentifier).height())/2)+'px',
				marginLeft:((this.displayWidth-$('#'+this.preloaderIdentifier).width())/2)+'px'
			}).show();
		},

		/**
		 * Hide generic preloader
		 */
		hidePreloader: function(callback) {
			$('#'+this.preloaderIdentifier).hide();

			if (typeof callback === 'string') {
				eval(callback);
			}
		},

		/**
		 * Slideshow initialization
		 */
		initiateTemplateJS: function(callStack, instanceNO) {
			if (this.callStack != callStack) {
				return;
			}

			if (this.instanceNO <= 1) {
				this.setGlobals();

			} else if (this.instanceNO != instanceNO) {
				return;
			}

			this.setFrozenFlagOff();

			this.infoBarIdentifier = this.canvasIdentifier+'_infoBar';
			this.imageIdentifier = this.canvasIdentifier+'_template_img';
			this.oldImageIdentifier = this.canvasIdentifier+'_template_img_old';
			this.controlBarIdentifier = this.canvasIdentifier+'_controlBar';
			this.shadowBgCanvas = this.canvasIdentifier+'_shadowBgCanvas';
			this.imgContainer = this.canvasIdentifier+'_imgContainer';

			this.inCanvas = false;
			this.controlBarFocused = false;
			this.oldImage = this.currentImage;
			this.firstLoad = true;
			clearTimeout(this.slideTimeout);

			if (this.loadControls(callStack)){
				this.startSlideShow(callStack);
			}
		},

		/**
		 * Control bar visibility controler
		 */
		cbControl: function(){
			if(this.controlBarVisible){
				this.controlBarVisible = false;
				$('#'+this.controlBarIdentifier).stop(true, true);
				$('#'+this.controlBarIdentifier+'_updown_bt').stop(true, true);
				this.rollDownCB();
			}else{
				this.controlBarVisible = true;
				$('#'+this.controlBarIdentifier).stop(true, true);
				$('#'+this.controlBarIdentifier+'_updown_bt').stop(true, true);
				this.rollUpCB();
			}
		},

		/**
		 * Next image
		 */
		nextControl: function() {
			this.nextImage();
		},

		/**
		 * Previous image
		 */
		prevControl: function() {
			this.prevImage();
		},

		/**
		 * Exit button control
		 */
		exitControl: function(){
			window.location=this.exitButtonURL;
		},

		/**
		 * caption button control
		 */
		captionControl: function(){
			this.captionVisible = !this.captionVisible;
			if(this.captionVisible){
				this.showCaption('normal');
			}else{
				this.hideCaption('normal');
			}
		},

		/**
		 * Play/Pause button control
		 */
		ppControl: function(callStack){
			if(this.autoSlideShow){
				this.pauseControl(callStack);
			}else{
				this.playControl(callStack);
			}
			if(this.autoSlideShow){
				var pp_pos = '44px 0px';
			}else{
				var pp_pos = '0px -44px';
			}
			$('#'+this.controlBarIdentifier+'_ctrl4').css({
				backgroundPosition:pp_pos
			});
		},

		/**
		 * Start autoplay
		 */
		playControl: function(callStack) {
			if (this.isFrozen(callStack)) {
				return;
			}
			this.autoSlideShow = true;
			this.slideTimeout = setTimeout('window.'+this.canvasIdentifier+'.nextImage()',
				this.slideShowSpeed);
			this.timeoutResources.push(this.slideTimeout);
		},

		/**
		 * Stop autoplay
		 */
		pauseControl: function(callStack) {
			if (this.isFrozen()) {
				return;
			}
			this.autoSlideShow = false;
			clearTimeout(this.slideTimeout);
		},

		/**
		 * Fullscreen/Normal screen button control
		 */
		screenControl: function(){
			if(this.fullScreenMode){
				this.normalScreenControl();
			}else{
				this.fullScreenControl();
			}
			if(this.fullScreenMode){
				var screen_pos = '21px 0px';
			}else{
				var screen_pos = '0px 0px';
			}
			$('#'+this.controlBarIdentifier+'_ctrl6').css({
				backgroundPosition:screen_pos
			});
		},

		/**
		 * Show in full screen
		 */
		fullScreenControl: function() {
			if (this.isBusy() || this.isFrozen()) {
				return;
			}
			this.setBusyFlagOn();
			clearTimeout(this.slideTimeout);
			this.showFullScreen();
		},

		/**
		 * Show in normal screen
		 */
		normalScreenControl: function() {
			if (this.isBusy() || this.isFrozen()) {
				return;
			}
			this.setBusyFlagOn();
			clearTimeout(this.slideTimeout);
			this.showNormalScreen();
		},

		/**
		 * Check if browser is IE
		 */
		isIE: function() {
			  return '\v' == 'v';
		},

		/**
		 * Draw the shadow around the border
		 */
		drawShadow: function(id){
			if(id==1){
				var sbg = this.sbg1;
			}else{
				var sbg = this.sbg2;
			}
			var ci_w = parseInt($('#'+this.imgContainer+id).css('width'))+2*this.borderSize - 20;
			var ci_h = parseInt($('#'+this.imgContainer+id).css('height'))+2*this.borderSize - 20;
			var g_color = this.shadowColor;
			var g_distance = this.shadowDistance + 12;
			var bg_color = this.backgroundColor;
			var x1 = parseInt($('#'+this.imgContainer+id).css('margin-left')) + 10;
			if(x1>this.displayWidth){
				x1 -= this.displayWidth;
			}
			if(x1<0){
				x1 += this.displayWidth;
			}
			var x2 = x1;
			var x3 = x1-g_distance;
			var x4 = x1 + ci_w;

			var y1 = parseInt($('#'+this.imgContainer+id).css('margin-top')) - g_distance + 10;
			var y2 = y1 + ci_h + g_distance;
			var y3 = y1 + g_distance;
			var y4 = y3;

			var localScope = this;
			$(sbg).clearRect([0,0],{width:localScope.displayWidth,height:localScope.displayHeight});

			$(sbg).canvasraw(function(cnvs){

				var grad1 = cnvs.c.createLinearGradient(x1,y1,x1,y1+g_distance);
				grad1.addColorStop(0,localScope.hexToRgb(g_color,0));
				grad1.addColorStop(1,g_color);

				var grad2 = cnvs.c.createLinearGradient(x2,y2,x2,y2+g_distance);
				grad2.addColorStop(0,g_color);
				grad2.addColorStop(1,localScope.hexToRgb(g_color,0));

				var grad3 = cnvs.c.createLinearGradient(x3,y3,x3+g_distance,y3);
				grad3.addColorStop(0,localScope.hexToRgb(g_color,0));
				grad3.addColorStop(1,g_color);

				var grad4 = cnvs.c.createLinearGradient(x4,y4,x4+g_distance,y4);
				grad4.addColorStop(0,g_color);
				grad4.addColorStop(1,localScope.hexToRgb(g_color,0));

				var grad5 = cnvs.c.createRadialGradient(x1,y1+g_distance,0,x1-4,y1-4+g_distance,g_distance-4);
				grad5.addColorStop(0,g_color);
				grad5.addColorStop(1,localScope.hexToRgb(g_color,0));
				cnvs.c.fillStyle = grad5;
				cnvs.c.fillRect(x1-g_distance,y1,g_distance-4,g_distance-4);

				var grad6 = cnvs.c.createRadialGradient(x2,y2,0,x2-4,y2+4,g_distance-4);
				grad6.addColorStop(0,g_color);
				grad6.addColorStop(1,localScope.hexToRgb(g_color,0));
				cnvs.c.fillStyle = grad6;
				cnvs.c.fillRect(x2-g_distance,y2+4,g_distance-4,g_distance-4);

				var grad7 = cnvs.c.createRadialGradient(x4,y4,0,x4+4,y4-4,g_distance-4);
				grad7.addColorStop(0,g_color);
				grad7.addColorStop(1,localScope.hexToRgb(g_color,0));
				cnvs.c.fillStyle = grad7;
				cnvs.c.fillRect(x4+4,y4-g_distance,g_distance-4,g_distance-4);

				var grad8 = cnvs.c.createRadialGradient(x4,y4+ci_h,0,x4+4,y4+4+ci_h,g_distance-4);
				grad8.addColorStop(0,g_color);
				grad8.addColorStop(1,localScope.hexToRgb(g_color,0));
				cnvs.c.fillStyle = grad8;
				cnvs.c.fillRect(x4+4,y4+4+ci_h,g_distance-4,g_distance-4);

				if(localScope.isIE()){
					cnvs.c.fillStyle = grad1;
					cnvs.c.fillRect(x1-4,y1,ci_w+8,g_distance-4);

					cnvs.c.fillStyle = grad2;
					cnvs.c.fillRect(x2-4,y2+4,ci_w+8,g_distance-4);

					cnvs.c.fillStyle = grad3;
					cnvs.c.fillRect(x3,y3-4,g_distance-4,ci_h+8);

					cnvs.c.fillStyle = grad4;
					cnvs.c.fillRect(x4+4,y4-4,g_distance-4,ci_h+8);
				}else{
					cnvs.c.fillStyle = grad1;
					cnvs.c.fillRect(x1-4,y1,ci_w+8,g_distance-10);

					cnvs.c.fillStyle = grad2;
					cnvs.c.fillRect(x2-4,y2+10,ci_w+8,g_distance-10);

					cnvs.c.fillStyle = grad3;
					cnvs.c.fillRect(x3,y3-4,g_distance-10,ci_h+8);

					cnvs.c.fillStyle = grad4;
					cnvs.c.fillRect(x4+10,y4-4,g_distance-10,ci_h+8);
				}

			});
		},

		/**
		 * Set global vars to default value
		 */
		setGlobals: function() {

			//*** RESOURCES ***\\

			//canvas offset
			this.canvasOffs = null;

			// images array
			this.images = [];

			// current image index
			this.currentImage = 0;

			// old image index
			this.oldImage = 0;

			// slide timeout resource
			this.slideTimeout = null;

			// control bar timer
			this.autohidetimerID = null;

			//img max size for resize
			this.imgMaxWidth = 0;
			this.imgMaxHeight = 0;

			this.cbHeight = 75;
			this.cbWidth = 256;

			//control buttons margin left param
			this.cbML = 0;
			this.cbMT = 0;



			//*** FLAGS ***\\

			// slideshow busy flag
			this.flagBusy = false;

			// mouse-ul este in canvas sau nu
			this.inCanvas = false;

			//control bar status
			this.controlBarVisible = false;

			// if control bar focused - not hide
			this.controlBarFocused = false;

			//description visible
			this.captionVisible = true;
			this.captionCounter = 1;

			//first load
			this.firstLoad = true;

			//next button or not
			this.nextSlide = false;

			//shadow canvas
			this.sbg1 = null;
			this.sbg2 = null;
		},

		calculateImageMaxSize: function(){
			this.imgMaxWidth = Math.floor(this.displayWidth*0.9-2*this.borderSize);
			this.imgMaxHeight = Math.floor((this.displayHeight - this.cbHeight)*0.9-2*this.borderSize);
		},

		/**
		 * loading controls
		 */
		loadControls: function(callStack) {
			if (this.callStack != callStack) {
				return;
			}

			var instanceNO = this.instanceNO;

			this.calculateImageMaxSize();
			this.cbML = Math.floor((this.displayWidth - this.cbWidth)/2);
			this.cbMT = this.displayHeight - this.cbHeight;

			// generate images array
			this.images = [];
			for(var i = 0, j = 0; i < this.xml.items.item.length; i++){
				if (typeof this.xml.items.item[i].largeImagePath != 'undefined'
					&& this.xml.items.item[i].largeImagePath != '' ) {
					this.images[j] = {};
					this.images[j].largeImagePath = this.xml.items.item[i].largeImagePath;
					if (typeof this.xml.items.item[i].fullScreenImagePath != 'undefined' &&
							this.xml.items.item[i].fullScreenImagePath.length > 0)
					{
						this.images[j].fullScreenImagePath = this.xml.items.item[i].fullScreenImagePath;
					} else {
						this.images[j].fullScreenImagePath = this.xml.items.item[i].largeImagePath;
					}
					if (typeof this.xml.items.item[i].description != 'undefined'){
						this.images[j].description = this.xml.items.item[i].description.replace(/\r\n/g,'<br />').replace(/\n/g,'<br />').replace(/\r/g,'<br />');
					} else {
						this.images[j].description = '';
					}
					this.images[j].loaded = 0;
					j++;
				}
			}

			if (this.images.length == 0) {
				return false;
			}

			var localScope = this;

			this.sbg1 = $('<div />').attr('id',this.shadowBgCanvas+'1')
				.css({
					position: 'absolute',
					height: this.displayHeight,
					minHeight: this.displayHeight,
					width: this.displayWidth,
					minWidth: this.displayWidth,
					zIndex:9,
					overflow:'hidden'
				})
				.appendTo('#'+this.canvasIdentifier);
			$(this.sbg1).canvas();
			this.sbg2 = $('<div />').attr('id',this.shadowBgCanvas+'2')
				.css({
					position: 'absolute',
					height: this.displayHeight,
					minHeight: this.displayHeight,
					width: this.displayWidth,
					minWidth: this.displayWidth,
					marginLeft:this.displayWidth,
					zIndex:9,
					overflow:'hidden'
				})
				.appendTo('#'+this.canvasIdentifier);
			$(this.sbg2).canvas();

			$('<div />').attr('id',this.imgContainer+'1')
				.css({
					position: 'absolute',
					marginLeft:this.displayWidth,
					border: this.borderSize+'px solid '+this.borderColor,
					zIndex:9,
					overflow:'hidden'
				})
				.appendTo('#'+this.shadowBgCanvas+'1');

			$('<div />').attr('id',this.imgContainer+'2')
				.css({
					position: 'absolute',
					marginLeft:this.displayWidth,
					border: this.borderSize+'px solid '+this.borderColor,
					zIndex:9,
					overflow:'hidden'
				})
				.appendTo('#'+this.shadowBgCanvas+'2');

			//caption
			$('<div />').attr('id',this.infoBarIdentifier+'1').hide()
				.css({
					zIndex:12,
					position:'absolute'
				})
				.appendTo('#'+this.shadowBgCanvas+'1');
			$('<div />').attr('id',this.infoBarIdentifier+'1_bg')
				.css({
					position:'absolute',
					zIndex:12,
					backgroundColor:'#000000',
					opacity:0.5
				})
				.appendTo('#'+this.infoBarIdentifier+'1');
			$('<div />').attr('id',this.infoBarIdentifier+'1_iDescription')
				.css({
					position:'absolute',
					zIndex:13,
					color:'#ffffff',
					fontSize: '18px',
					fontFamily:'Lucida Sans Unicode',
					marginTop:'0px',
					marginLeft:'5px',
					paddingTop:'3px',
					lineHeight: '27px',
					textAlign:'center',
					overflow:'hidden'
				})
				.appendTo('#'+this.infoBarIdentifier+'1');

			//caption 2
			$('<div />').attr('id',this.infoBarIdentifier+'2').hide()
				.css({
					zIndex:12,
					position:'absolute'
				})
				.appendTo('#'+this.shadowBgCanvas+'2');
			$('<div />').attr('id',this.infoBarIdentifier+'2_bg')
				.css({
					position:'absolute',
					zIndex:12,
					backgroundColor:'#000000',
					opacity:0.5
				})
				.appendTo('#'+this.infoBarIdentifier+'2');
			$('<div />').attr('id',this.infoBarIdentifier+'2_iDescription')
				.css({
					position:'absolute',
					zIndex:13,
					color:'#ffffff',
					fontSize: '18px',
					fontFamily:'Lucida Sans Unicode',
					marginTop:'0px',
					marginLeft:'5px',
					paddingTop:'3px',
					lineHeight: '27px',
					textAlign:'center',
					overflow:'hidden'
				})
				.appendTo('#'+this.infoBarIdentifier+'2');

			// gesture for touchscreen
			$('#'+this.canvasIdentifier).touchwipe({
				wipeLeft: this.nextControl,
				wipeRight: this.prevControl
			});

			//control bar
			$('<div />').attr('id',this.controlBarIdentifier).hide()
				.css({
					position: 'absolute',
					height: this.cbHeight,
					width: this.cbWidth,
					marginTop:this.cbMT,
					marginLeft:this.cbML,
					zIndex:12,
					overflow:'hidden'
				})
				.appendTo('#'+this.canvasIdentifier);

			$('<div />').attr('id',this.controlBarIdentifier+'_bg')
				.css({
					position:'absolute',
					height:this.cbHeight,
					width: this.cbWidth,
					background:'url("' + this.iconsURL + 'cb.png")',
					zIndex:13
				})
				.hover( function(){
								localScope.controlBarFocused = true;
							}, function(){
								localScope.controlBarFocused = false;
							})
				.appendTo('#'+this.controlBarIdentifier);

			//control bar up/down button
			var updownML = this.cbML+Math.floor((this.cbWidth-46)/2);

			if(this.controlBarVisible){
				var updownMT = this.cbMT;
				var bg_position = '46px 0px';
			}else{
				var updownMT = this.displayHeight-12;
				var bg_position = '0px 0px';
			}

			$('<div />').attr('id',this.controlBarIdentifier+'_updown_bt')
				.appendTo('#'+this.canvasIdentifier)
				.css({
					position: 'absolute',
					cursor: 'pointer',
					width:'46px',
					height:'12px',
					marginLeft:updownML,
					marginTop:updownMT,
					background:'url("' + this.iconsURL + 'cb_control.png")',
					backgroundPosition: bg_position,
					zIndex:20
				})
				.bind('click', function(){localScope.cbControl()})
				.hover(function(){
						localScope.controlBarFocused = true;
						$(this).css({
							opacity:0.8
						});
					},function(){
						localScope.controlBarFocused = false;
						$(this).css({
							opacity:1
						});
					});
			if(this.exitButton){
				//exit button
				$('<div />').attr('id',this.controlBarIdentifier+'_ctrl1')
					.css({
						position:'absolute',
						cursor:'pointer',
						marginTop:'15px',
						marginLeft:'30px',
						width:124,
						minWidth:124,
						height:31,
						minHeight:31,
						background:'url("' + this.iconsURL + 'exit.png")',
						backgroundPosition:'0px 0px',
						zIndex:20
					})
					.bind('click', function(){localScope.exitControl()})
					.mouseover(function(){
						$(this).css({
							backgroundPosition:'0px -31px'
						});
						localScope.controlBarFocused = true;
					})
					.mouseout(function(){
						$(this).css({
							backgroundPosition:'0px 0px'
						});
						localScope.controlBarFocused = false;
					})
					.mousedown(function(){
						$(this).css({
							backgroundPosition:'0px -62px'
						});
					})
					.mouseup(function(){
						$(this).css({
							backgroundPosition:'0px -31px'
						});
					})
					.appendTo('#'+this.canvasIdentifier);
			}

			//caption button
			if(this.captionVisible){
				var capt_pos = '0px -44px';
			}else{
				var capt_pos = '0px 0px';
			}
			$('<div />').attr('id',this.controlBarIdentifier+'_ctrl2')
				.css({
					position:'absolute',
					cursor:'pointer',
					marginTop:'32px',
					marginLeft:'16px',
					width:25,
					minWidth:25,
					height:22,
					minHeight:22,
					background:'url("' + this.iconsURL + 'caption.png")',
					backgroundPosition:capt_pos,
					zIndex:15
				})
				.bind('click', function(){
					localScope.captionControl(callStack);
				})
				.mouseover(function(){
					$(this).css({
						backgroundPosition:'0px -22px'
					});
					localScope.controlBarFocused = true;
				})
				.mouseout(function(){
					if(localScope.captionVisible){
						var capt_pos = '0px -44px';
					}else{
						var capt_pos = '0px 0px';
					}
					$(this).css({
						backgroundPosition:capt_pos
					});
					localScope.controlBarFocused = false;
				})
				.appendTo('#'+this.controlBarIdentifier);

			//prev and next button
			$('<div />').attr('id',this.controlBarIdentifier+'_ctrl3')
				.css({
					position:'absolute',
					cursor:'pointer',
					marginTop:'35px',
					marginLeft:'66px',
					width:17,
					minWidth:17,
					height:16,
					minHeight:16,
					background:'url("' + this.iconsURL + 'prev.png")',
					backgroundPosition:'0px 0px',
					zIndex:15
				})
				.bind('click', function(){
					localScope.prevControl(callStack);
				})
				.mouseover(function(){
					$(this).css({
						backgroundPosition:'0px -16px'
					});
					localScope.controlBarFocused = true;
				})
				.mouseout(function(){
					$(this).css({
						backgroundPosition:'0px 0px'
					});
					localScope.controlBarFocused = true;
				})
				.mousedown(function(){
					$(this).css({
						backgroundPosition:'0px -32px'
					});
				})
				.mouseup(function(){
					$(this).css({
						backgroundPosition:'0px -16px'
					});
				})
				.appendTo('#'+this.controlBarIdentifier);
			$('<div />').attr('id',this.controlBarIdentifier+'_ctrl5')
				.css({
					position:'absolute',
					cursor:'pointer',
					marginTop:'35px',
					marginLeft:'173px',
					width:17,
					minWidth:17,
					height:16,
					minHeight:16,
					background:'url("' + this.iconsURL + 'next.png")',
					backgroundPosition:'0px 0px',
					zIndex:15
				})
				.bind('click', function(){
					localScope.nextControl();
				})
				.mouseover(function(){
					$(this).css({
						backgroundPosition:'0px -16px'
					});
					localScope.controlBarFocused = true;
				})
				.mouseout(function(){
					$(this).css({
						backgroundPosition:'0px 0px'
					});
					localScope.controlBarFocused = true;
				})
				.mousedown(function(){
					$(this).css({
						backgroundPosition:'0px -32px'
					});
				})
				.mouseup(function(){
					$(this).css({
						backgroundPosition:'0px -16px'
					});
				})
				.appendTo('#'+this.controlBarIdentifier);

			//play and pause button
			if(this.autoSlideShow){
				var pp_pos = '44px 0px';
			}else{
				var pp_pos = '0px 0px';
			}
			$('<div />').attr('id',this.controlBarIdentifier+'_ctrl4')
				.css({
					position:'absolute',
					cursor:'pointer',
					marginTop:'21px',
					marginLeft:'106px',
					width:44,
					minWidth:44,
					height:44,
					minHeight:44,
					background:'url("' + this.iconsURL + 'pp.png")',
					backgroundPosition:pp_pos,
					zIndex:15
				})
				.bind('click', function(){
					localScope.ppControl(callStack);
				})
				.mouseover(function(){
					if(localScope.autoSlideShow){
						var pp_pos = '44px -44px';
					}else{
						var pp_pos = '0px -44px';
					}
					$(this).css({
						backgroundPosition:pp_pos
					});
					localScope.controlBarFocused = true;
				})
				.mouseout(function(){
					if(localScope.autoSlideShow){
						var pp_pos = '44px 0px';
					}else{
						var pp_pos = '0px 0px';
					}
					$(this).css({
						backgroundPosition:pp_pos
					});
					localScope.controlBarFocused = true;
				})
				.mousedown(function(){
					if(localScope.autoSlideShow){
						var pp_pos = '44px -88px';
					}else{
						var pp_pos = '0px -88px';
					}
					$(this).css({
						backgroundPosition:pp_pos
					});
				})
				.appendTo('#'+this.controlBarIdentifier);

			//full/normal screen
			if(this.fullScreenMode){
				var screen_pos = '21px 0px';
			}else{
				var screen_pos = '0px 0px';
			}
			$('<div />').attr('id',this.controlBarIdentifier+'_ctrl6')
				.css({
					position:'absolute',
					cursor:'pointer',
					marginTop:'33px',
					marginLeft:'218px',
					width:21,
					minWidth:21,
					height:21,
					minHeight:21,
					background:'url("' + this.iconsURL + 'screen.png")',
					backgroundPosition:screen_pos,
					zIndex:15
				})
				.bind('click', function(){
					localScope.screenControl()
				})
				.mouseover(function(){
					if(localScope.fullScreenMode){
						var screen_pos = '21px -21px';
					}else{
						var screen_pos = '0px -21px';
					}
					$(this).css({
						backgroundPosition:screen_pos
					});
					localScope.controlBarFocused = true;
				})
				.mouseout(function(){
					if(localScope.fullScreenMode){
						var screen_pos = '21px 0px';
					}else{
						var screen_pos = '0px 0px';
					}
					$(this).css({
						backgroundPosition:screen_pos
					});
					localScope.controlBarFocused = true;
				})
				.mousedown(function(){
					if(localScope.fullScreenMode){
						var screen_pos = '21px -42px';
					}else{
						var screen_pos = '0px -42px';
					}
					$(this).css({
						backgroundPosition:screen_pos
					});
				})
				.appendTo('#'+this.controlBarIdentifier);

			this.showControlBar(instanceNO, callStack);

			this.canvasOffs = $('#'+this.canvasIdentifier).offset();
			$(document).mousemove(function(e){
				if (localScope.isFrozen() ||
						instanceNO != localScope.instanceNO ||
						callStack != localScope.callStack)
					{
						return;
					}
				if (localScope.autoHideControls){
					if (( e.pageX<localScope.canvasOffs.left ) || ( e.pageY<localScope.canvasOffs.top ) || ( e.pageX > localScope.canvasOffs.left+localScope.canvasWidth ) || ( e.pageY > localScope.canvasOffs.top+localScope.canvasHeight ) ){
						if(localScope.inCanvas){
							localScope.autoHideControlBar();
							localScope.inCanvas = false;
						}
					}else{
						localScope.inCanvas = true;
						clearTimeout(localScope.autohidetimerID);
						if (!localScope.controlBarFocused){
							localScope.autohidetimerID = setTimeout( 'window.'+localScope.canvasIdentifier+'.autoHideControlBar()' , localScope.controlsHideSpeed);
						}
					}
				}
			});
			return true;
		},

		/**
		 * Auto hide control bar
		 */
		autoHideControlBar : function (){
			this.controlBarVisible = false;
			$('#'+this.controlBarIdentifier).stop(true, false);
			$('#'+this.controlBarIdentifier+'_updown_bt').stop(true, false);
			this.rollDownCB();
		},

		/**
		 * Start slideshow command
		 */
		startSlideShow: function(callStack) {
			if (this.callStack != callStack) {
				return;
			}
			if (typeof this.currentImage != 'number') {
				this.currentImage = 0;
			}
			this.setFrozenFlagOff();
			this.setBusyFlagOff();
			this.showCurrentImage(this.instanceNo,callStack);
		},

		/**
		 * Image preloader
		 */
		preLoadImage: function(id, callback, fullscreenmode) {
			if (this.isFrozen()) {
				return;
			}
			if (this.fullScreenMode==true) {
				if(this.images[id].error1 == 1){
					this.images[id].src = this.images[id]['largeImagePath'];
				}else{
					this.images[id].src = this.images[id]['fullScreenImagePath'];
				}
			} else {
				this.images[id].src = this.images[id]['largeImagePath'];
			}
			this.images[id].cacheImage = document.createElement('img');

			var localScope = this;

			$(this.images[id].cacheImage).load(function (){
				$(this).unbind('load');
				localScope.images[this.lang]['loaded'] = 1;
				if (typeof callback != 'undefined' && !localScope.isFrozen()) {
					eval(callback);
				}
			}).error(function (){
				if(localScope.images[id].src!=localScope.images[id].largeImagePath){
					localScope.images[id].error1 = 1;
					localScope.preLoadImage(id, callback, fullscreenmode);
					return;
				}
				$(this).unbind('error');
				localScope.images[this.lang].error = 1;
				if (typeof callback != 'undefined' && !localScope.isFrozen()) {
					eval(callback);
				}
			 });
			this.images[id].cacheImage.lang = id;
			this.images[id].cacheImage.src = this.images[id].src;
		},

		resizeCurrentImage: function(){
			if ( this.loadOriginalImages ){
				return;
			}
			if (this.images[this.currentImage].error == 1) return;

			if(this.isIE()){
				var cH = $(this.images[this.currentImage].cacheImage).height();
				var cW = $(this.images[this.currentImage].cacheImage).width();
			}else{
				var cH = $(this.images[this.currentImage].cacheImage).attr('height');
				var cW = $(this.images[this.currentImage].cacheImage).attr('width');
			}
			if ( cH<=this.imgMaxHeight && cW<=this.imgMaxWidth) return;
			var canvasProp = this.imgMaxWidth/this.imgMaxHeight;
			var imageProp = cW/cH;

			var perc = 0;

			switch(this.scaleMode)
			{
				case 'scale':
					if (canvasProp > imageProp) {
						if (cH < this.imgMaxHeight) {
							ref = cH;
						} else {
							ref = this.imgMaxHeight;
						}
						$(this.images[this.currentImage].cacheImage)
							.height(ref)
							.width(Math.ceil(cW * ref / cH));
					} else {
						if (cW < this.imgMaxWidth) {
							ref = cW;
						} else {
							ref = this.imgMaxWidth;
						}
						$(this.images[this.currentImage].cacheImage)
							.width(ref)
							.height(Math.ceil(cH * ref / cW));
					}
					break;
				case 'scaleCrop':
				default:
					if (canvasProp > imageProp) {
						if (cW < this.imgMaxWidth) {
							ref = cW;
						} else {
							ref = this.imgMaxWidth;
						}
						$(this.images[this.currentImage].cacheImage)
							.width(ref)
							.height(Math.ceil(cH * ref / cW));
					} else {
						if (cH < this.imgMaxHeight) {
							ref = cH;
						} else {
							ref = this.imgMaxHeight;
						}
						$(this.images[this.currentImage].cacheImage)
							.height(ref)
							.width(Math.ceil(cW * ref / cH));
					}
					break;
			}
		},

		/**
		 * show current image
		 */
		showCurrentImage: function(instanceNO, callStack) {
			if (this.isFrozen()) {
				return;
			}
			if (typeof instanceNO == 'undefined') {
				var instanceNO = this.instanceNO;
			} else if (instanceNO != this.instanceNO) {
				return;
			}
			if (typeof callStack == 'undefined') {
				var callStack = this.callStack;
			} else if (callStack != this.callStack) {
				return;
			}

			clearTimeout(this.slideTimeout);

			if (this.images[this.currentImage].loaded != 1 && this.images[this.currentImage].error != 1) {
				this.showPreloader();
				this.preLoadImage(this.currentImage, 'window.'+this.canvasIdentifier+'.showCurrentImage('+instanceNO+', '+callStack+')');
				return;
			}
			this.hidePreloader();
			if(this.oldImage!=this.currentImage){
				if(this.captionCounter==1){
					var prev_caption_nr = 2;
				}else{
					var prev_caption_nr = 1;
				}
			}else{
				var prev_caption_nr = this.captionCounter;
			}

			if(this.oldImage!=this.currentImage){
				$(this.images[this.oldImage].cacheImage).attr('id', this.oldImageIdentifier)
					.appendTo('#'+this.imgContainer+this.captionCounter)
					.css({
						position:'absolute',
						zIndex:10
					});
				var oic_h = $('#'+this.oldImageIdentifier).height();
				/*
				if(oic_h>this.imgMaxHeight){
					oic_h = this.imgMaxHeight;
				}
				*/
				var oic_mt = Math.floor(((this.displayHeight-this.cbHeight) - (oic_h+2*this.borderSize))/2);
				var oic_w = $('#'+this.oldImageIdentifier).width();
				/*
				if(oic_w>this.imgMaxWidth){
					oic_w = this.imgMaxWidth;
				}
				*/
				var oic_ml = Math.floor((this.displayWidth - (oic_w+2*this.borderSize))/2);
				$('#'+this.imgContainer+this.captionCounter)
					.css({
						width:oic_w,
						height:oic_h,
						marginTop:oic_mt,
						marginLeft:oic_ml
					});
				var oi_mt = Math.floor((oic_h - $('#'+this.oldImageIdentifier).height())/2);
				var oi_ml = Math.floor((oic_w - $('#'+this.oldImageIdentifier).width())/2);
				$('#'+this.oldImageIdentifier)
					.css({
						marginTop:oi_mt,
						marginLeft:oi_ml
					});
			}

			$('#'+this.shadowBgCanvas+prev_caption_nr).css({
				marginLeft:0
			});
			var localScope = this;
			$(this.images[this.currentImage].cacheImage).hide()
				.appendTo('#'+this.imgContainer+prev_caption_nr)
				.attr('id', this.imageIdentifier)
				.css({
					position:'absolute',
					cursor:'pointer',
					zIndex:10
				})
				.bind('click', function(){
					localScope.nextControl()
				});

			this.resizeCurrentImage();

			var ic_h = $('#'+this.imageIdentifier).height();
			/*
			if(ic_h>this.imgMaxHeight){
				ic_h = this.imgMaxHeight;
			}
			*/
			var ic_mt = Math.floor(((this.displayHeight-this.cbHeight) - (ic_h+2*this.borderSize))/2);
			var ic_w = $('#'+this.imageIdentifier).width();
			/*
			if(ic_w>this.imgMaxWidth){
				ic_w = this.imgMaxWidth;
			}
			*/
			var ic_ml = Math.floor((this.displayWidth - (ic_w+2*this.borderSize))/2);
			$('#'+this.imgContainer+prev_caption_nr)
				.css({
					width:ic_w,
					height:ic_h,
					marginTop:ic_mt,
					marginLeft:ic_ml
				});

			var i_mt = Math.floor((ic_h - $('#'+this.imageIdentifier).height())/2);
			var i_ml = Math.floor((ic_w - $('#'+this.imageIdentifier).width())/2);
			$('#'+this.imageIdentifier)
				.css({
					marginTop:i_mt+'px',
					marginLeft:i_ml+'px'
				});
			this.imageTransition();
		},

		/**
		 * Hide caption
		 */
		hideCaption : function(){
			//hide caption
			$('#'+this.infoBarIdentifier+this.captionCounter).fadeOut('normal');
		},

		/**
		 * Show caption
		 */
		showCaption : function (t_speed){
			this.actualizeCaption();
			$('#'+this.infoBarIdentifier+this.captionCounter).fadeIn(t_speed);
		},

		/**
		 * Actualize caption
		 */
		actualizeCaption: function(){
			var ciH = parseInt($('#'+this.imgContainer+this.captionCounter).css('height'));
			var ciW = parseInt($('#'+this.imgContainer+this.captionCounter).css('width'));
			var mt = Math.floor(((this.displayHeight - this.cbHeight) - ciH)/2);
			var ml = Math.floor((this.displayWidth - ciW)/2);
			$('#'+this.infoBarIdentifier+this.captionCounter+'_iDescription')
				.css({width:((ciW)-10)})
				.html(this.images[this.currentImage].description);

			$('#'+this.infoBarIdentifier+this.captionCounter).show();
			var descH = $('#'+this.infoBarIdentifier+this.captionCounter+'_iDescription').height();
			$('#'+this.infoBarIdentifier+this.captionCounter).hide();
			if(descH>0){
				descH += 8;
			}

			if (descH>=(this.imgMaxHeight-23))
				return;

			$('#'+this.infoBarIdentifier+this.captionCounter+'_bg')
				.css({
					width: ciW+'px',
					height: descH+'px'
				});

			$('#'+this.infoBarIdentifier+this.captionCounter)
				.css({
					width: ciW+'px',
					height:descH+'px',
					marginTop: (ciH-descH)+mt,
					marginLeft: ml
				});
		},

		/**
		 * Image transition
		 */
		imageTransition: function(){
			var localScope = this;
			if(this.transitionType == 'fade'){
				if(this.firstLoad){
					$('#'+this.imageIdentifier)
						.show();
					this.drawShadow(this.captionCounter);
					this.actualizeCaption();
					if(this.captionVisible){
						$('#'+this.infoBarIdentifier+this.captionCounter).show();
					}
					this.firstLoad = false;
					this.onTransitionComplete();

				}else{
					if (this.oldImage!=this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)){
						$('#'+this.shadowBgCanvas+this.captionCounter).fadeOut(this.transitionSpeed, function(){
							$(this).css({marginLeft:localScope.displayWidth}).show();
							$('#'+localScope.oldImageIdentifier).unbind().hide();
							$('#'+localScope.oldImageIdentifier).remove();
						});
					}
					$('#'+this.imageIdentifier)
						.css({
							opacity:0
						})
						.hide().show();
					this.actualizeCounter();
					this.actualizeCaption();
					if(this.captionVisible){
						this.showCaption(this.transitionSpeed);
					}
					this.drawShadow(this.captionCounter);
					$('#'+this.shadowBgCanvas+this.captionCounter)
						.css({marginLeft:0});

					$('#'+this.imageIdentifier).animate({opacity:1}, this.transitionSpeed, function(){
						localScope.onTransitionComplete();
					});

					$('#'+this.imgContainer+this.captionCounter).css({opacity:0}).animate({opacity:1}, localScope.transitionSpeed);
					$('#'+this.shadowBgCanvas+this.captionCounter+' canvas').css({opacity:0}).animate({opacity:1},this.transitionSpeed);
				}
			}else{
				if(this.transitionType == 'slide'){
					if(this.firstLoad){
						$('#'+this.imageIdentifier)
							.show();
						this.actualizeCaption();
						if(this.captionVisible){
							$('#'+this.infoBarIdentifier+this.captionCounter).show();
						}
						this.drawShadow(this.captionCounter);
						this.firstLoad = false;
						this.onTransitionComplete();

					} else {
						if (this.oldImage!=this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)){
							var sbg_ml = 0;
							if(this.nextSlide){
								sbg_ml -= this.displayWidth;
							}else{
								sbg_ml += this.displayWidth;
							}

							$('#'+this.shadowBgCanvas+this.captionCounter).animate({
								marginLeft:sbg_ml
							}, localScope.transitionSpeed, function(){
								$('#'+localScope.oldImageIdentifier).unbind().hide();
								$('#'+localScope.oldImageIdentifier).remove();
							});
						}

						$('#'+this.imageIdentifier).show();

						this.actualizeCounter();
						this.actualizeCaption();
						if(this.captionVisible){
							$('#'+this.infoBarIdentifier+this.captionCounter).show();
						}

						if(this.nextSlide){
							var sbg_ml = this.displayWidth;
						}else{
							var sbg_ml = -1*this.displayWidth;
						}
						this.drawShadow(this.captionCounter);
						$('#'+this.shadowBgCanvas+this.captionCounter)
							.css({marginLeft:sbg_ml})
							.animate({marginLeft:0}, this.transitionSpeed, function(){
								localScope.onTransitionComplete();
							});
					}
				}
			}
		},

		/**
		 * Transition complete callback
		 */
		onTransitionComplete: function(){
			this.setBusyFlagOff();

			if (this.autoSlideShow == true) {
				this.slideTimeout = setTimeout('window.'+this.canvasIdentifier+'.nextImage()',
												this.slideShowSpeed);
				this.timeoutResources.push(this.slideTimeout);
			}
		},

		/**
		 * Actualize counter
		 */
		actualizeCounter: function(){
			if(this.captionCounter==2){
				this.captionCounter = 1;
			}else{
				this.captionCounter = 2;
			}
		},

		/**
		 * Show control bar
		 */
		showControlBar: function(instanceNO, callStack){
			if (this.isFrozen()) {
				return;
			}
			if (instanceNO != this.instanceNO || callStack != this.callStack) {
				return;
			}

			if (!this.controlBarVisible) {
				$('#'+this.controlBarIdentifier)
					.css({marginTop:this.displayHeight - 12});
				$('#'+this.controlBarIdentifier+'_ctrl1').hide();
			}

			$('#'+this.controlBarIdentifier).show();
		},

		/**
		 * check if busy flag is on
		 */
		isBusy: function(){
			return this.flagBusy == true;
		},

		/**
		 * Set busy flag off
		 */
		setBusyFlagOff: function(){
			this.flagBusy = false;
		},

		/**
		 * Set busy flag on
		 */
		setBusyFlagOn: function(){
			this.flagBusy = true;
		},

		/**
		 * Roll down control bar
		 */
		rollDownCB: function(){
			$('#'+this.controlBarIdentifier)
				.animate({marginTop:this.displayHeight - 12}, 300);
			$('#'+this.controlBarIdentifier+'_updown_bt')
				.css({
					backgroundPosition:'0px 0px'
				})
				.animate({marginTop:this.displayHeight - 12}, 300);
			$('#'+this.controlBarIdentifier+'_ctrl1').fadeOut('300');
		},

		/**
		 * Roll up control bar
		 */
		rollUpCB: function(){
			$('#'+this.controlBarIdentifier)
				.animate({marginTop:this.cbMT}, 300);
			$('#'+this.controlBarIdentifier+'_updown_bt')
				.css({
					backgroundPosition:'46px 0px'
				})
				.animate({marginTop:this.cbMT}, 300);
			$('#'+this.controlBarIdentifier+'_ctrl1').fadeIn('300');
		},

		/**
		 * Show next image
		 */
		nextImage: function(callStack) {
			if (this.isBusy() || this.isFrozen() ) {
				return;
			}
			this.setBusyFlagOn();
			this.oldImage = this.currentImage;
			if (this.currentImage < this.images.length-1) {
				this.currentImage++;
			} else {
				this.currentImage = 0;
			}
			this.nextSlide = true;
			this.showCurrentImage();
		},

		/**
		 * Show previous image
		 */
		prevImage: function() {
			if (this.isBusy() || this.isFrozen()) {
				return;
			}
			this.setBusyFlagOn();
			this.oldImage = this.currentImage;
			if (this.currentImage > 0) {
				this.currentImage--;
			} else {
				this.currentImage = this.images.length-1;
			}
			this.nextSlide = false;
			this.showCurrentImage();
		}
	};

})(jCSFG);