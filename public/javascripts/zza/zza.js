
///*
//  * toJsonString
//  *
//  * produces a JSON string representation of a javascript object
//  * usage: var jsonstring = someobject.toJSONString();
//  *
//  * Tino Zijdel - crisp@xs4all.nl, 01/10/2006
//  */
//(
//	function()
//	{
//		var re = /[\x00-\x1f\\"]/;
//		function toJSONString(obj)
//		{
//			switch (typeof obj)
//			{
//				case 'string':
//					return '"' + (re.test(obj) ? encodeString(obj) : obj) + '"';
//				case 'number':
//				case 'boolean':
//					return String(obj);
//				case 'object':
//					if (obj)
//					{
//						switch (obj.constructor)
//						{
//							case Array:
//								var a = [];
//								for (var i = 0, l = obj.length; i < l; i++)
//									a[a.length] = toJSONString(obj[i]);
//								return '[' + a.join(',') + ']';
//							case Object:
//								var a = [];
//								for (var i in obj)
//									if (obj.hasOwnProperty(i))
//										a[a.length] = '"' + (re.test(i) ? encodeString(i) : i) + '":' + toJSONString(obj[i]);
//								return '{' + a.join(',') + '}';
//							case String:
//								return '"' + (re.test(obj) ? encodeString(obj) : obj) + '"';
//							case Number:
//							case Boolean:
//								return String(obj);
//							case Function:
//							case Date:
//							case RegExp:
//								return 'undefined';
//						}
//					}
//					return 'null';
//				case 'function':
//				case 'undefined':
//				case 'unknown':
//					return 'undefined';
//				default:
//					return 'null';
//			}
//		}
//		var stringescape = {
//			'\b': '\\b',
//			'\t': '\\t',
//			'\n': '\\n',
//			'\f': '\\f',
//			'\r': '\\r',
//			'"' : '\\"',
//			'\\': '\\\\'
//		};
//		function encodeString(string)
//		{
//			return string.replace(
//				/[\x00-\x1f\\"]/g,
//				function(a)
//				{
//					var b = stringescape[a];
//					if (b)
//						return b;
//					b = a.charCodeAt();
//					return '\\u00' + Math.floor(b / 16).toString(16) + (b % 16).toString(16);
//				}
//			);
//		}
//		if (!Object.prototype.toJSONString)
//			Object.prototype.toJSONString = function() { return toJSONString(this); }
//		if (!Object.prototype.hasOwnProperty)
//			Object.prototype.hasOwnProperty = function(p) { var undefined; return this.constructor.prototype[p] === undefined; }
//	}
//)();

function ZZA()
{
	this.evts = new Array();
	this.last = null;
	this.maxevts = 15;
	this.maxtime = 5000;
	this.zzaurl = 'http://zza.zangzing.com'			// for test mode: 'http://localhost:8000'
	this.req = null;
	this.pushed = 0;

	this.init = function(id)
	{
		this.id = id;

		var _this = this;
		window.setTimeout(function() { _this.timer(); }, 5000);
	}

	this.track_user = function(evt, user, xdata)
	{
		this.track(evt, user, 1, xdata);
	}

	this.track_visitor = function(evt, visitor, xdata)
	{
		this.track(evt, visitor, 2, xdata);
	}

	this.track = function(evt, user, usertype, xdata)
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

	this.timer = function()
	{
		this.flush(false);

		var _this = this;
		window.setTimeout(function() { _this.timer(); }, 5000);
	}

	this.flush = function(all)
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
			this.push();

			this.evts = new Array();
			this.last = null;
		}
	}

	this.close = function()
	{
		// close (flush all)

		this.flush(true)
	}

	this.push = function()
	{
		// push to server

		if (this.evts.length == 0)
			return;

		if (this.req == null) {
			if (window.XMLHttpRequest)
				this.req = new XMLHttpRequest();
			else
				this.req = new ActiveXObject("Microsoft.XMLHTTP");
		}

		this.pushed += this.evts.length;
		var d = {id: this.id, evts: this.evts};
		var body = $.toJSON(d);

		this.req.open("POST", this.zzaurl, true);
		this.req.send(body);
	}

	this.count = function()
	{
		return this.evts.length;
	}

	this.pushed_count = function()
	{
		return this.pushed;
	}
}

