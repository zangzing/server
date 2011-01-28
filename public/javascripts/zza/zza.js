
function ZZA(id, useridentifier, usemixpanel)
{
	this.id = id;
	this.zzv_id = null;
	
	this.useridentifier = useridentifier;
	if (this.useridentifier)
		this.usertype = 1;
	else
		this.usertype = 2;
	
	if (usemixpanel == undefined)
		usemixpanel = false;
	this.usemixpanel = usemixpanel;
	
	this.evts = new Array();
	this.last = null;
	this.maxevts = 10;
	this.maxtime = 2500;
	this.maxpushbytes = 2000;
	this.zzaurl = 'http://localhost:8080'			// for test mode: 'http://localhost:8080'   http://zza.zangzing.com
	this.pushed = 0;
	this.pindex = 0;
	
	this.re = /[\x00-\x1f\\"]/;
	this.stringescape = {
		'\b': '\\b',
		'\t': '\\t',
		'\n': '\\n',
		'\f': '\\f',
		'\r': '\\r',
		'"' : '\\"',
		'\\': '\\\\'
	};	
	
	// public api
	this.init = function()
	{
		this.zzv_id = this._readCookie('_zzv_id');
		if (this.zzv_id == null) {
			
			var zdomain = 'zangzing.com';
			var domain = null;
			var l = location.host.lastIndexOf(zdomain);
			if ((l != -1) && (l + zdomain.length == location.host.length))
				domain = zdomain;		// share across all zangzing.com domains
			
			this.zzv_id = this.createUUID();
			this._createCookie('_zzv_id', this.zzv_id, domain, 10950);
		}
		
		var _this = this;
		window.setTimeout(function() { _this._timer(); }, 5000);
	}
	
	this.track_event = function(evt, xdata)
	{
		var userid;
		if (this.usertype == 1)
			userid = this.useridentifier;
		else if (this.usertype == 2)
			userid = this.zzv_id;
			
		this._track(evt, userid, this.usertype, xdata)
	}
	
	this.track_event_from_user = function(evt, user, xdata)
	{
		this._track(evt, user, 1, xdata);
	}
	
	this.track_event_from_visitor = function(evt, visitor, xdata)
	{
		this._track(evt, visitor, 2, xdata);
	}
	
	this.close = function()
	{
		// close (flush all)
		
		this._flush(true)
	}
	
	this.count = function()
	{
		return this.evts.length;
	}
	
	this.pushed_count = function()
	{
		return this.pushed;
	}
	
	
	// internal
	this._track = function(evt, user, usertype, xdata)
	{
		if (xdata == undefined)
			xdata = {};
		
		var e = {};
		e.e = evt;
		e.t = new Date().getTime();
		e.u = user;
		e.v = usertype;
		e.x = xdata;
		e.r = document.referrer;
		
		this.evts.push(e);
		this.last = new Date().getTime();			
	}
	
	this._timer = function()
	{
		this._flush(false);
					
		var _this = this;
		window.setTimeout(function() { _this._timer(); }, 2000);
	}
	
	this._flush = function(all)
	{
		// flush events to server
		
		var f = false;
		if (all)
			f = true;
		else {
			if (this.evts.length > this.maxevts)
				f = true;
			else {
				if (this.last != null) {
					var n = new Date().getTime() - this.last;
					if (n > this.maxtime)
						f = true;
				}
			}
		}
		
		if (f) {
			this._push();
			
			this.evts = new Array();
			this.last = null;
		}
	}
	
	this._getrandom = function(n)
	{
		return Math.floor(Math.random()*(n+1)) + 1;
	}
	
	this._getevts = function()
	{
		// from pindex, get n events 
		
		if (this.pindex > this.evts.length - 1)
			return null;
		
		var pmax = this.maxpushbytes;
		var pevts = new Array();
			
		while(this.pindex < this.evts.length) {
			var evt = this.evts[this.pindex];
			var evtlen = this.toJSONString(evt).length;
			if (evtlen > pmax)
				break;
			
			if (this.usemixpanel && typeof(mpmetrics) != 'undefined') {
				p = {};
				if (this.usertype == 1)
					p.Zuser = evt.u;
				else
					p.Zvisitor = evt.u;
				for(var x in evt.x)
					p[x] = evt.x[x];
			
				//console.log('mp: ' + evt.e + "; prop: " + this.toJSONString(p))
				mpmetrics.track(evt.e, p);
			}
				
			pevts.push(evt);
			pmax -= evtlen;
			this.pindex += 1;
		}
		
		//console.log('pushing evts: ' + pevts.length);
		
		this.pushed += pevts.length;
		var d = {id: this.id, evts: pevts}
		return this.toJSONString(d);
	}
	
	this._push = function()
	{
		// push to server
		
		if (this.evts.length == 0)
			return;
		
		this.pindex = 0;
		
		while(this.pindex < this.evts.length) {
			//console.log('getevts');
			
			var data = this._getevts();
			//console.log('pushing bytes: ' + data.length);
			
			var r = this._getrandom(10000000);
			var img = new Image();
			img.src = this.zzaurl + '/_z.gif?r=' + r + '&e=' + encodeURI(data);
		}
	}
	
	// toJSONString util functions, adapted from Tino Zijdel - crisp@xs4all.nl, 01/10/2006
	this.encodeString = function(string)
	{
		return string.replace(
			/[\x00-\x1f\\"]/g,
			function(a)
			{
				var b = this.stringescape[a];
				if (b)
					return b;
				b = a.charCodeAt();
				return '\\u00' + Math.floor(b / 16).toString(16) + (b % 16).toString(16);
			}
		);
	}
	
	this.toJSONString = function(obj)
	{
		switch (typeof obj)
		{
			case 'string':
				return '"' + (this.re.test(obj) ? this.encodeString(obj) : obj) + '"';
			case 'number':
			case 'boolean':
				return String(obj);
			case 'object':
				if (obj)
				{
					switch (obj.constructor)
					{
						case Array:
							var a = [];
							for (var i = 0, l = obj.length; i < l; i++)
								a[a.length] = this.toJSONString(obj[i]);
							return '[' + a.join(',') + ']';
						case Object:
							var a = [];
							for (var i in obj)
								if (obj.hasOwnProperty(i))
									a[a.length] = '"' + (this.re.test(i) ? this.encodeString(i) : i) + '":' + this.toJSONString(obj[i]);
							return '{' + a.join(',') + '}';
						case String:
							return '"' + (this.re.test(obj) ? this.encodeString(obj) : obj) + '"';
						case Number:
						case Boolean:
							return String(obj);
						case Function:
						case Date:
						case RegExp:
							return 'undefined';
					}
				}
				return 'null';
			case 'function':
			case 'undefined':
			case 'unknown':
				return 'undefined';
			default:
				return 'null';
		}
	}
	
	this.createUUID = function() {
	    // http://www.ietf.org/rfc/rfc4122.txt
	    var s = [];
	    var hexDigits = "0123456789ABCDEF";
	    for (var i = 0; i < 32; i++) {
	        s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1);
	    }
	    s[12] = "4";  // bits 12-15 of the time_hi_and_version field to 0010
	    s[16] = hexDigits.substr((s[16] & 0x3) | 0x8, 1);  // bits 6-7 of the clock_seq_hi_and_reserved to 01

	    var uuid = s.join("");
	    return uuid;
	}
	
	this._createCookie = function(name,value,domain,days) 
	{
		if (days) {
			var date = new Date();
			date.setTime(date.getTime()+(days*24*60*60*1000));
			var expires = "; expires="+date.toGMTString();
		}
		else var expires = "";
		var c = name+"="+value+expires+"; path=/";
		if (domain != null)
			c += '; domain=' + domain;
		document.cookie = c;
	}

	this._readCookie = function(name)
	{
		var nameEQ = name + "=";
		var ca = document.cookie.split(';');
		for(var i=0;i < ca.length;i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1,c.length);
			if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
		}
		return null;
	}

	this._eraseCookie = function(name)
	{
		createCookie(name,"",-1);
	}
}
