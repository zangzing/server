/*

 ----------
 jQuery JSONP Core Plugin 2.1.4 (2010-11-17)

 http://code.google.com/p/jquery-jsonp/

 Copyright (c) 2010 Julian Aubourg

 This document is licensed as free software under the terms of the
 MIT License: http://www.opensource.org/licenses/mit-license.php
*/
var zz=zz||{};
(function(){function e(){jQuery.validator.methods.regex||jQuery.validator.addMethod("regex",function(c,f,g){g=RegExp(g);return this.optional(f)||g.test(c)},"Please check your input.")}zz.joinform=zz.joinform||{};zz.joinform.add_validation=function(c){e();return c.validate({rules:{"user[email]":{required:true,email:true,remote:"/service/users/validate_email"},"user[password]":{required:true,minlength:6}},messages:{"user[email]":{required:"Please enter your email.",email:"Please type a valid email.",remote:"This email already has an account."},
"user[password]":"Password must be at least 6 characters."}})};zz.joinform.submit_form=function(c,f,g){f=0;f=(c.find("#user_email").val().length!=0)+(c.find("#user_password").val().length!=0);if(c.valid()){f="https://"+document.location.host+"/service/users";if(c.find("#follow_user_id").val())f+="?follow_user_id="+c.find("#follow_user_id").val();$(c).attr("action",f);$(c).attr("method","POST");$(c).submit();ZZAt.track(g+".click");ZZAt.track(g+".click.valid")}else{var h=0,k=0;k=16*c.find("#user_email").valid()+
32*(c.find("#user_email").val().length!=0)+64*c.find("#user_password").valid()+128*(c.find("#user_password").val().length!=0);h=c.find("#user_email").valid()+c.find("#user_password").valid();ZZAt.track(g+".click");ZZAt.track(g+".invalid",{Zjoin_num_fields_nonempty:f,Zjoin_num_fields_valid:h,Zjoin_bit_fields:k})}};zz.joinform.add_regex_validator=e})();
(function(e,c){function f(){}function g(a){s=[a]}function h(a,l,m){return a&&a.apply(l.context||l,m)}function k(a){function l(b){!n++&&c(function(){p();q&&(t[d]={s:[b]});z&&(b=z.apply(a,[b]));h(a.success,a,[b,A]);h(B,a,[a,A])},0)}function m(b){!n++&&c(function(){p();q&&b!=C&&(t[d]=b);h(a.error,a,[a,b]);h(B,a,[a,b])},0)}a=e.extend({},D,a);var B=a.complete,z=a.dataFilter,E=a.callbackParameter,F=a.callback,R=a.cache,q=a.pageCache,G=a.charset,d=a.url,i=a.data,H=a.timeout,r,n=0,p=f;a.abort=function(){!n++&&
p()};if(h(a.beforeSend,a,[a])===false||n)return a;d=d||u;i=i?typeof i=="string"?i:e.param(i,a.traditional):u;d+=i?(/\?/.test(d)?"&":"?")+i:u;E&&(d+=(/\?/.test(d)?"&":"?")+encodeURIComponent(E)+"=?");!R&&!q&&(d+=(/\?/.test(d)?"&":"?")+"_"+(new Date).getTime()+"=");d=d.replace(/=\?(&|$)/,"="+F+"$1");q&&(r=t[d])?r.s?l(r.s[0]):m(r):c(function(b,o,v){if(!n){v=H>0&&c(function(){m(C)},H);p=function(){v&&clearTimeout(v);b[I]=b[w]=b[J]=b[x]=null;j[K](b);o&&j[K](o)};window[F]=g;b=e(L)[0];b.id=M+S++;if(G)b[T]=
G;var O=function(y){(b[w]||f)();y=s;s=undefined;y?l(y[0]):m(N)};if(P.msie){b.event=w;b.htmlFor=b.id;b[I]=function(){/loaded|complete/.test(b.readyState)&&O()}}else{b[x]=b[J]=O;P.opera?(o=e(L)[0]).text="jQuery('#"+b.id+"')[0]."+x+"()":b[Q]=Q}b.src=d;j.insertBefore(b,j.firstChild);o&&j.insertBefore(o,j.firstChild)}},0);return a}var Q="async",T="charset",u="",N="error",M="_jqjsp",w="onclick",x="on"+N,J="onload",I="onreadystatechange",K="removeChild",L="<script/>",A="success",C="timeout",P=e.browser,
j=e("head")[0]||document.documentElement,t={},S=0,s,D={callback:M,url:location.href};k.setup=function(a){e.extend(D,a)};e.jsonp=k})(jQuery,setTimeout);
