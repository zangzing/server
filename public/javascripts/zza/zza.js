



function ZZA(id, useridentifier, isuser, usemixpanel)
{
	this.id = id;
	this.useridentifier = useridentifier;
	if (isuser)
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
	this.zzaurl = 'http://localhost:8000'			// for test mode: 'http://localhost:8000'   http://zza.zangzing.com
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
		var _this = this;
		window.setTimeout(function() { _this._timer(); }, 5000);
	}
	
	this.track_event = function(evt, xdata)
	{
		this._track(evt, this.useridentifier, this.usertype, xdata)
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
}
