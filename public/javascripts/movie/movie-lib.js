// jQuery XML to JSON Plugin v1.0
//(function($) {
//    $.extend({xml2json:function(xml, extended) {
//        if (!xml)return{};
//        function parseXML(node, simple) {
//            if (!node)return null;
//            var txt = '',obj = null,att = null;
//            var nt = node.nodeType,nn = jsVar(node.localName || node.nodeName);
//            var nv = node.text || node.nodeValue || '';
//            if (node.childNodes) {
//                if (node.childNodes.length > 0) {
//                    $.each(node.childNodes, function(n, cn) {
//                        var cnt = cn.nodeType,cnn = jsVar(cn.localName || cn.nodeName);
//                        var cnv = cn.text || cn.nodeValue || '';
//                        if (cnt == 8) {
//                            return;
//                        } else if (cnt == 3 || cnt == 4 || !cnn) {
//                            if (cnv.match(/^\s+$/)) {
//                                return;
//                            }
//                            ;
//                            txt += cnv.replace(/^\s+/, '').replace(/\s+$/, '');
//                        } else {
//                            obj = obj || {};
//                            if (obj[cnn]) {
//                                if (!obj[cnn].length)obj[cnn] = myArr(obj[cnn]);
//                                obj[cnn][obj[cnn].length] = parseXML(cn, true);
//                                obj[cnn].length = obj[cnn].length;
//                            } else {
//                                obj[cnn] = parseXML(cn);
//                            }
//                            ;
//                        }
//                        ;
//                    });
//                }
//                ;
//            }
//            ;
//            if (node.attributes) {
//                if (node.attributes.length > 0) {
//                    att = {};
//                    obj = obj || {};
//                    $.each(node.attributes, function(a, at) {
//                        var atn = jsVar(at.name),atv = at.value;
//                        att[atn] = atv;
//                        if (obj[atn]) {
//                            if (!obj[atn].length)obj[atn] = myArr(obj[atn]);
//                            obj[atn][obj[atn].length] = atv;
//                            obj[atn].length = obj[atn].length;
//                        } else {
//                            obj[atn] = atv;
//                        }
//                        ;
//                    });
//                }
//                ;
//            }
//            ;
//            if (obj) {
//                obj = $.extend((txt != '' ? new String(txt) : {}), obj || {});
//                txt = (obj.text) ? (typeof(obj.text) == 'object' ? obj.text : [obj.text || '']).concat([txt]) : txt;
//                if (txt)obj.text = txt;
//                txt = '';
//            }
//            ;
//            var out = obj || txt;
//            if (extended) {
//                if (txt)out = {};
//                txt = out.text || txt || '';
//                if (txt)out.text = txt;
//                if (!simple)out = myArr(out);
//            }
//            ;
//            return out;
//        }
//
//        ;
//        var jsVar = function(s) {
//            return String(s || '').replace(/-/g, "_");
//        };
//        var isNum = function(s) {
//            return(typeof s == "number") || String((s && typeof s == "string") ? s : '').test(/^((-)?([0-9]*)((\.{0,1})([0-9]+))?$)/);
//        };
//        var myArr = function(o) {
//            if (!o.length)o = [o];
//            o.length = o.length;
//            return o;
//        };
//        if (typeof xml == 'string')xml = $.text2xml(xml);
//        if (!xml.nodeType)return;
//        if (xml.nodeType == 3 || xml.nodeType == 4)return xml.nodeValue;
//        var root = (xml.nodeType == 9) ? xml.documentElement : xml;
//        var out = parseXML(root, true);
//        xml = null;
//        root = null;
//        return out;
//    },text2xml:function(str) {
//        var out;
//        try {
//            var xml = ($.browser.msie) ? new ActiveXObject("Microsoft.XMLDOM") : new DOMParser();
//            xml.async = false;
//        } catch(e) {
//            throw new Error("XML Parser could not be instantiated")
//        }
//        ;
//        try {
//            if ($.browser.msie)out = (xml.loadXML(str)) ? xml : false; else out = xml.parseFromString(str, "text/xml");
//        } catch(e) {
//            throw new Error("Error parsing XML string")
//        }
//        ;
//        return out;
//    }});
//})(jCSFG);

// jQuery TouchWipe Plugin v1.0
(function($) {
    $.fn.touchwipe = function(settings) {
        if ($.browser.msie == true)return;
        var config = {min_move_x:20,wipeLeft:function() {
        },wipeRight:function() {
        },preventDefaultEvents:false};
        if (settings)$.extend(config, settings);
        this.each(function() {
            var startX;
            var isMoving = false;

            function cancelTouch() {
                this.removeEventListener('touchmove', onTouchMove);
                startX = null;
                isMoving = false;
            }

            function onTouchMove(e) {
                if (config.preventDefaultEvents) {
                    e.preventDefault();
                }
                if (isMoving) {
                    var x = e.touches[0].pageX;
                    var dx = startX - x;
                    if (Math.abs(dx) >= config.min_move_x) {
                        cancelTouch();
                        if (dx > 0) {
                            config.wipeLeft();
                        } else {
                            config.wipeRight();
                        }
                    }
                }
            }

            function onTouchStart(e) {
                if (e.touches.length == 1) {
                    startX = e.touches[0].pageX;
                    isMoving = true;
                    this.addEventListener('touchmove', onTouchMove, false);
                }
            }

            this.addEventListener('touchstart', onTouchStart, false);
        });
        return this;
    };
})(jQuery);
// jQuery CSSRule Plugin (Customized)
(function($) {
    $.cssRule = function(Selector, Property, Value) {
        if (typeof Selector == "object") {
            $.each(Selector, function(NewSelector, NewProperty) {
                $.cssRule(NewSelector, NewProperty);
            });
            return;
        }
        if ((typeof Selector == "string") && (Selector.indexOf(":") > -1) && (Property == undefined) && (Value == undefined)) {
            Data = Selector.split("{");
            Data[1] = Data[1].replace(/\}/, "");
            $.cssRule($.trim(Data[0]), $.trim(Data[1]));
            return;
        }
        if ((typeof Selector == "string") && (Selector.indexOf(",") > -1)) {
            Multi = Selector.split(",");
            for (x = 0; x < Multi.length; x++) {
                Multi[x] = $.trim(Multi[x]);
                if (Multi[x] != "")$.cssRule(Multi[x], Property, Value);
            }
            return;
        }
        if (typeof Property == "object") {
            if (Property.length == undefined) {
                $.each(Property, function(NewProperty, NewValue) {
                    $.cssRule(Selector + " " + NewProperty, NewValue);
                });
            } else if ((Property.length == 2) && (typeof Property[0] == "string") && (typeof Property[1] == "string")) {
                $.cssRule(Selector, Property[0], Property[1]);
            } else {
                for (x1 = 0; x1 < Property.length; x1++) {
                    $.cssRule(Selector, Property[x1], Value);
                }
            }
            return;
        }
        if ((typeof Property == "string") && (Property.indexOf("{") > -1) && (Property.indexOf("}") > -1)) {
            Property = Property.replace(/\{/, "").replace(/\}/, "");
        }
        if ((typeof Property == "string") && (Property.indexOf(";") > -1)) {
            Multi1 = Property.split(";");
            for (x2 = 0; x2 < Multi1.length; x2++) {
                $.cssRule(Selector, Multi1[x2], undefined);
            }
            return;
        }
        if ((typeof Property == "string") && (Property.indexOf(":") > -1)) {
            Multi3 = Property.split(":");
            $.cssRule(Selector, Multi3[0], Multi3[1]);
            return;
        }
        if ((typeof Property == "string") && (Property.indexOf(",") > -1)) {
            Multi2 = Property.split(",");
            for (x3 = 0; x3 < Multi2.length; x3++) {
                $.cssRule(Selector, Multi2[x3], Value);
            }
            return;
        }
        var ssbStyle = undefined;
        for (var i = 0; i < document.styleSheets.length; i++) {
            if (document.styleSheets[i].title == 'CustomSimpleFadeStyleSheet') {
                ssbStyle = document.styleSheets[i];
            }
        }
        if (typeof ssbStyle != 'object') {
            if (typeof document.createElementNS != 'undefined') {
                var ssbStyle = document.createElementNS("http://www.w3.org/1999/xhtml", "style");
            } else {
                var ssbStyle = document.createElement("style");
            }
            ssbStyle.setAttribute("type", "text/css");
            ssbStyle.setAttribute("media", "screen");
            ssbStyle.setAttribute("title", "CustomSimpleFadeStyleSheet");
            $($("head")[0]).append(ssbStyle);
            for (var i = 0; i < document.styleSheets.length; i++) {
                if (document.styleSheets[i].title == 'CustomSimpleFadeStyleSheet') {
                    ssbStyle = document.styleSheets[i];
                }
            }
        }
        if ((Property == undefined) || (Value == undefined))return;
        Selector = $.trim(Selector);
        Property = $.trim(Property);
        Value = $.trim(Value);
        if ((Property == "") || (Value == ""))return;
        if ($.browser.msie) {
            switch (Property) {case"float":Property = "style-float";break;
            }
        } else {
            switch (Property) {case"float":Property = "css-float";break;
            }
        }
        CssProperty = (Property || "").replace(/\-(\w)/g, function(m, c) {
            return(c.toUpperCase());
        });
        var Rules = (ssbStyle.cssRules || ssbStyle.rules);
        LowerSelector = Selector.toLowerCase();
        for (var i2 = 0,len = Rules.length - 1; i2 < len; i2++) {
            if (Rules[i2].selectorText && (Rules[i2].selectorText.toLowerCase() == LowerSelector)) {
                if (Value != null) {
                    Rules[i2].style[CssProperty] = Value;
                    return;
                } else {
                    if (ssbStyle.deleteRule) {
                        ssbStyle.deleteRule(i2);
                    } else if (ssbStyle.removeRule) {
                        ssbStyle.removeRule(i2);
                    } else {
                        Rules[i2].style.cssText = "";
                    }
                }
            }
        }
        if (Property && Value) {
            if (ssbStyle.insertRule) {
                Rules = (ssbStyle.cssRules || ssbStyle.rules);
                ssbStyle.insertRule(Selector + "{ " + Property + ":" + Value + "; }", Rules.length);
            } else if (ssbStyle.addRule) {
                ssbStyle.addRule(Selector, Property + ":" + Value + ";", 0);
            } else {
                throw new Error("Add/insert not enabled.");
            }
        }
    };
    $.tocssRule = function(cssText) {
        matchRes = cssText.match(/(.*?)\{(.*?)\}/);
        while (matchRes) {
            cssText = cssText.replace(/(.*?)\{(.*?)\}/, "");
            $.cssRule(matchRes[1], matchRes[2]);
            matchRes = cssText.match(/(.*?)\{(.*?)\}/);
        }
    };
})(jQuery);
// jQuery Canvas Plugin (Customized)
(function($) {
    $.fn.canvas = function(where) {
        $(this).each(function() {
            var $this = $(this);
            var w = $this.width();
            var h = $this.height();
            if (w === 0 && $this.css('width') !== '0px') {
                w = parseInt($this.css('width'));
            }
            if (h === 0 && $this.css('height') !== '0px') {
                h = parseInt($this.css('height'));
            }
            if (!where)where = 'under';
            $this.find('.cnvsWrapper').remove();
            $this.find('.cnvsCanvas').remove();
            var $canvas = document.createElement('CANVAS');
            $canvas.className = 'cnvsCanvas';
            $canvas.style.position = 'absolute';
            $canvas.style.top = '0px';
            $canvas.style.left = '0px';
            $canvas.setAttribute('width', w);
            $canvas.setAttribute('height', h);
            if ((where == 'under' || where == 'over') && $this.html() !== '') {
                $this.wrapInner('<div class="cnvsWrapper" style="position:absolute;top:0px;left:0px;width:100%;height:100%;border:0px;padding:0px;margin:0px;"></div>');
            }
            if (where == 'under' || where == 'unshift') {
                $this.prepend($canvas);
            }
            if (where == 'over' || where == 'push') {
                $this.append($canvas);
            }
            if ($.browser.msie) {
                var canvas = G_vmlCanvasManager.initElement($($canvas).get(0));
                $canvas = $(canvas);
            }
            this.cnvs = canvasObject($($canvas), w, h);
            return this;
        });
        return this;
    };
    $.fn.uncanvas = function() {
        $(this).each(function() {
            this.cnvs.getTag().remove();
            this.cnvs = null;
        });
        return this;
    };
    $.fn.hidecanvas = function() {
        $(this).each(function() {
            this.cnvs.getTag().hide();
        });
        return this;
    };
    $.fn.showcanvas = function() {
        $(this).each(function() {
            this.cnvs.getTag().show();
        });
        return this;
    };
    $.fn.canvasraw = function(callback) {
        $(this).each(function() {
            if (callback)eval(callback)(this.cnvs);
        });
    };
    $.fn.canvasinfo = function(info) {
        $(this).each(function() {
            info[info.length] = {};
            info[info.length - 1].width = this.cnvs.w;
            info[info.length - 1].height = this.cnvs.h;
            info[info.length - 1].tag = this.cnvs.$tag;
            info[info.length - 1].context = this.cnvs.c;
        });
    };
    $.fn.style = function(style) {
        $(this).each(function() {
            this.cnvs.style(style);
            return this;
        });
        return this;
    };
    $.fn.beginPath = function() {
        $(this).each(function() {
            this.cnvs.beginPath();
            return this;
        });
        return this;
    };
    $.fn.closePath = function() {
        $(this).each(function() {
            this.cnvs.closePath();
            return this;
        });
        return this;
    };
    $.fn.stroke = function() {
        $(this).each(function() {
            this.cnvs.stroke();
            return this;
        });
        return this;
    };
    $.fn.fill = function() {
        $(this).each(function() {
            this.cnvs.fill();
            return this;
        });
        return this;
    };
    $.fn.moveTo = function(coord) {
        $(this).each(function() {
            this.cnvs.moveTo(coord);
            return this;
        });
        return this;
    };
    $.fn.arc = function(coord, settings, style) {
        $(this).each(function() {
            this.cnvs.arc(coord, settings, style);
            return this;
        });
        return this;
    };
    $.fn.arcTo = function(coord1, coord2, settings, style) {
        $(this).each(function() {
            this.cnvs.arcTo(coord1, coord2, settings, style);
            return this;
        });
        return this;
    };
    $.fn.bezierCurveTo = function(ref1, ref2, end, style) {
        $(this).each(function() {
            this.cnvs.bezierCurveTo(ref1, ref2, end, style);
            return this;
        });
        return this;
    };
    $.fn.quadraticCurveTo = function(ref1, end, style) {
        $(this).each(function() {
            this.cnvs.quadraticCurveTo(ref1, end, style);
            return this;
        });
        return this;
    };
    $.fn.clearRect = function(coord, settings) {
        $(this).each(function() {
            this.cnvs.clearRect(coord, settings);
            return this;
        });
        return this;
    };
    $.fn.strokeRect = function(coord, settings, style) {
        $(this).each(function() {
            this.cnvs.strokeRect(coord, settings, style);
            return this;
        });
        return this;
    };
    $.fn.fillRect = function(coord, settings, style) {
        $(this).each(function() {
            this.cnvs.fillRect(coord, settings, style);
            return this;
        });
        return this;
    };
    $.fn.rect = function(coord, settings, style) {
        $(this).each(function() {
            this.cnvs.rect(coord, settings, style);
            return this;
        });
        return this;
    };
    $.fn.lineTo = function(end, style) {
        $(this).each(function() {
            this.cnvs.lineTo(end, style);
            return this;
        });
        return this;
    };
    $.fn.fillText = function(txt, x, y) {
        $(this).each(function() {
            this.cnvs.fillText(txt, x, y);
            return this;
        });
        return this;
    };
    $.fn.translate = function(x, y) {
        $(this).each(function() {
            this.cnvs.translate(x, y);
            return this;
        });
        return this;
    };
    $.fn.transform = function(m11, m12, m21, m22, dx, dy) {
        $(this).each(function() {
            this.cnvs.transform(m11, m12, m21, m22, dx, dy);
            return this;
        });
        return this;
    };
    $.fn.rotate = function(r) {
        $(this).each(function() {
            this.cnvs.rotate(r);
            return this;
        });
        return this;
    };
    $.fn.save = function() {
        $(this).each(function() {
            this.cnvs.save();
            return this;
        });
        return this;
    };
    $.fn.restore = function() {
        $(this).each(function() {
            this.cnvs.restore();
            return this;
        });
        return this;
    };
    $.fn.polygon = function(start, blocks, settings, style) {
        $(this).each(function() {
            this.cnvs.atomPolygon(start, blocks, settings, style);
        });
    };
    function canvasObject($canvas, width, height) {
        var cnvs = {};
        cnvs.w = width;
        cnvs.h = height;
        cnvs.$tag = $canvas;
        cnvs.c = $canvas.get(0).getContext('2d');
        cnvs.laststyle = {'fillStyle':'rgba( 0, 0, 0, 0.2)','strokeStyle':'rgba( 0, 0, 0, 0.5)','lineWidth':5};
        cnvs.getContext = function() {
            return this.c;
        };
        cnvs.getTag = function() {
            return this.$tag;
        };
        cnvs.deg2rad = function(deg) {
            return 2 * 3.14159265 * (deg / 360);
        };
        cnvs.style = function(style) {
            if (style)this.laststyle = style;
            for (var name in this.laststyle)this.c[name] = this.laststyle[name];
        };
        cnvs.fillText = function(txt, x, y) {
            this.c.fillText(txt, x, y);
        };
        cnvs.translate = function(x, y) {
            this.c.translate(x, y);
        };
        cnvs.transform = function(m11, m12, m21, m22, dx, dy) {
            this.c.transform(m11, m12, m21, m22, dx, dy);
        };
        cnvs.rotate = function(r) {
            this.c.rotate(r);
        };
        cnvs.save = function() {
            this.c.save();
        };
        cnvs.restore = function() {
            this.c.restore();
        };
        cnvs.beginPath = function() {
            this.c.beginPath();
        };
        cnvs.closePath = function() {
            this.c.closePath();
        };
        cnvs.stroke = function() {
            this.c.stroke();
        };
        cnvs.fill = function() {
            this.c.fill();
        };
        cnvs.moveTo = function(coord) {
            this.c.moveTo(coord[0], coord[1]);
        };
        cnvs.arc = function(coord, settings, style) {
            settings = $.extend({'radius':50,'startAngle':0,'endAngle':360,'clockwise':true}, settings);
            if (style)this.style(style);
            this.c.arc(coord[0], coord[1], settings.radius, this.deg2rad(settings.startAngle), this.deg2rad(settings.endAngle), settings.clockwise ? 1 : 0);
        };
        cnvs.arcTo = function(coord1, coord2, settings, style) {
            settings = $.extend({'radius':50}, settings);
            if (style)this.style(style);
            this.c.arcTo(coord1[0], coord1[1], coord2[0], coord2[1], settings.radius);
        };
        cnvs.bezierCurveTo = function(ref1, ref2, end, style) {
            if (style)this.style(style);
            this.c.bezierCurveTo(ref1[0], ref1[1], ref2[0], ref2[1], end[0], end[1]);
        };
        cnvs.quadraticCurveTo = function(ref1, end, style) {
            if (style)this.style(style);
            this.c.quadraticCurveTo(ref1[0], ref1[1], end[0], end[1]);
        };
        cnvs.clearRect = function(coord, settings, style) {
            if (!coord)coord = [0,0];
            settings = $.extend({'width':this.w,'height':this.h}, settings);
            this.c.clearRect(coord[0], coord[1], settings.width, settings.height);
        };
        cnvs.fillRect = function(coord, settings, style) {
            settings = $.extend({'width':100,'height':50}, settings);
            if (style)this.style(style);
            this.c.fillRect(coord[0], coord[1], settings.width, settings.height);
        };
        cnvs.strokeRect = function(coord, settings, style) {
            settings = $.extend({'width':100,'height':50}, settings);
            if (style)this.style(style);
            this.c.strokeRect(coord[0], coord[1], settings.width, settings.height);
        };
        cnvs.rect = function(coord, settings, style) {
            settings = $.extend({'width':100,'height':50}, settings);
            if (style)this.style(style);
            this.c.rect(coord[0], coord[1], settings.width, settings.height);
        };
        cnvs.lineTo = function(end, style) {
            if (style)this.style(style);
            this.c.lineTo(end[0], end[1]);
        };
        cnvs.path = function(blocks) {
            for (var i = 0; i < blocks.length; i++) {
                var arg1 = null;
                var arg2 = null;
                var arg3 = null;
                var arg4 = null;
                if (blocks[i].length >= 2)arg1 = blocks[i][1];
                if (blocks[i].length >= 3)arg2 = blocks[i][2];
                if (blocks[i].length >= 4)arg3 = blocks[i][3];
                if (blocks[i].length >= 5)arg4 = blocks[i][4];
                if (blocks[i][0] == 'moveTo')this.moveTo(arg1);
                if (blocks[i][0] == 'arc')this.arc(arg1, arg2, arg3);
                if (blocks[i][0] == 'arcTo')this.arcTo(arg1, arg2, arg3, arg4);
                if (blocks[i][0] == 'bezierCurveTo')this.bezierCurveTo(arg1, arg2, arg3, arg4);
                if (blocks[i][0] == 'quadraticCurveTo')this.quadraticCurveTo(arg1, arg2, arg3);
                if (blocks[i][0] == 'lineTo')this.lineTo(arg1, arg2);
            }
        };
        cnvs.atomPolygon = function(start, blocks, settings, style) {
            settings = $.extend({'fill':false,'stroke':true,'close':false}, settings);
            this.style(style);
            if (settings.stroke) {
                this.beginPath();
                this.moveTo(start);
                this.path(blocks);
                if (settings.close) {
                    this.moveTo(start);
                    this.closePath();
                }
                this.c.fillStyle = 'rgba( 0, 0, 0, 0)';
                this.stroke();
            }
            this.style(style);
            if (settings.fill) {
                this.beginPath();
                this.moveTo(start);
                this.path(blocks);
                if (settings.close) {
                    this.moveTo(start);
                    this.closePath();
                }
                this.c.strokeStyle = 'rgba( 0, 0, 0, 0)';
                this.fill();
            }
            this.style(style);
        };
        return cnvs;
    }
})(jQuery);
// jQuery exCanvas
if (!document.createElement('canvas').getContext) {
    (function() {
        var m = Math;
        var mr = m.round;
        var ms = m.sin;
        var mc = m.cos;
        var abs = m.abs;
        var sqrt = m.sqrt;
        var Z = 10;
        var Z2 = Z / 2;
        var IE_VERSION = +navigator.userAgent.match(/MSIE ([\d.]+)?/)[1];

        function getContext() {
            return this.context_ || (this.context_ = new CanvasRenderingContext2D_(this));
        }

        var slice = Array.prototype.slice;

        function bind(f, obj, var_args) {
            var a = slice.call(arguments, 2);
            return function() {
                return f.apply(obj, a.concat(slice.call(arguments)));
            };
        }

        function encodeHtmlAttribute(s) {
            return String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;');
        }

        function addNamespace(doc, prefix, urn) {
            if (!doc.namespaces[prefix]) {
                doc.namespaces.add(prefix, urn, '#default#VML');
            }
        }

        function addNamespacesAndStylesheet(doc) {
            addNamespace(doc, 'g_vml_', 'urn:schemas-microsoft-com:vml');
            addNamespace(doc, 'g_o_', 'urn:schemas-microsoft-com:office:office');
            if (!doc.styleSheets['ex_canvas_']) {
                var ss = doc.createStyleSheet();
                ss.owningElement.id = 'ex_canvas_';
                ss.cssText = 'canvas{display:inline-block;overflow:hidden;' + 'text-align:left;width:300px;height:150px}';
            }
        }

        addNamespacesAndStylesheet(document);
        var G_vmlCanvasManager_ = {init:function(opt_doc) {
            var doc = opt_doc || document;
            doc.createElement('canvas');
            doc.attachEvent('onreadystatechange', bind(this.init_, this, doc));
        },init_:function(doc) {
            var els = doc.getElementsByTagName('canvas');
            for (var i = 0; i < els.length; i++) {
                this.initElement(els[i]);
            }
        },initElement:function(el) {
            if (!el.getContext) {
                el.getContext = getContext;
                addNamespacesAndStylesheet(el.ownerDocument);
                el.innerHTML = '';
                el.attachEvent('onpropertychange', onPropertyChange);
                el.attachEvent('onresize', onResize);
                var attrs = el.attributes;
                if (attrs.width && attrs.width.specified) {
                    el.style.width = attrs.width.nodeValue + 'px';
                } else {
                    el.width = el.clientWidth;
                }
                if (attrs.height && attrs.height.specified) {
                    el.style.height = attrs.height.nodeValue + 'px';
                } else {
                    el.height = el.clientHeight;
                }
            }
            return el;
        }};

        function onPropertyChange(e) {
            var el = e.srcElement;
            switch (e.propertyName) {case'width':el.getContext().clearRect();el.style.width = el.attributes.width.nodeValue + 'px';el.firstChild.style.width = el.clientWidth + 'px';break;case'height':el.getContext().clearRect();el.style.height = el.attributes.height.nodeValue + 'px';el.firstChild.style.height = el.clientHeight + 'px';break;
            }
        }

        function onResize(e) {
            var el = e.srcElement;
            if (el.firstChild) {
                el.firstChild.style.width = el.clientWidth + 'px';
                el.firstChild.style.height = el.clientHeight + 'px';
            }
        }

        G_vmlCanvasManager_.init();
        var decToHex = [];
        for (var i = 0; i < 16; i++) {
            for (var j = 0; j < 16; j++) {
                decToHex[i * 16 + j] = i.toString(16) + j.toString(16);
            }
        }
        function createMatrixIdentity() {
            return[
                [1,0,0],
                [0,1,0],
                [0,0,1]
            ];
        }

        function matrixMultiply(m1, m2) {
            var result = createMatrixIdentity();
            for (var x = 0; x < 3; x++) {
                for (var y = 0; y < 3; y++) {
                    var sum = 0;
                    for (var z = 0; z < 3; z++) {
                        sum += m1[x][z] * m2[z][y];
                    }
                    result[x][y] = sum;
                }
            }
            return result;
        }

        function copyState(o1, o2) {
            o2.fillStyle = o1.fillStyle;
            o2.lineCap = o1.lineCap;
            o2.lineJoin = o1.lineJoin;
            o2.lineWidth = o1.lineWidth;
            o2.miterLimit = o1.miterLimit;
            o2.shadowBlur = o1.shadowBlur;
            o2.shadowColor = o1.shadowColor;
            o2.shadowOffsetX = o1.shadowOffsetX;
            o2.shadowOffsetY = o1.shadowOffsetY;
            o2.strokeStyle = o1.strokeStyle;
            o2.globalAlpha = o1.globalAlpha;
            o2.font = o1.font;
            o2.textAlign = o1.textAlign;
            o2.textBaseline = o1.textBaseline;
            o2.arcScaleX_ = o1.arcScaleX_;
            o2.arcScaleY_ = o1.arcScaleY_;
            o2.lineScale_ = o1.lineScale_;
        }

        var colorData = {aliceblue:'#F0F8FF',antiquewhite:'#FAEBD7',aquamarine:'#7FFFD4',azure:'#F0FFFF',beige:'#F5F5DC',bisque:'#FFE4C4',black:'#000000',blanchedalmond:'#FFEBCD',blueviolet:'#8A2BE2',brown:'#A52A2A',burlywood:'#DEB887',cadetblue:'#5F9EA0',chartreuse:'#7FFF00',chocolate:'#D2691E',coral:'#FF7F50',cornflowerblue:'#6495ED',cornsilk:'#FFF8DC',crimson:'#DC143C',cyan:'#00FFFF',darkblue:'#00008B',darkcyan:'#008B8B',darkgoldenrod:'#B8860B',darkgray:'#A9A9A9',darkgreen:'#006400',darkgrey:'#A9A9A9',darkkhaki:'#BDB76B',darkmagenta:'#8B008B',darkolivegreen:'#556B2F',darkorange:'#FF8C00',darkorchid:'#9932CC',darkred:'#8B0000',darksalmon:'#E9967A',darkseagreen:'#8FBC8F',darkslateblue:'#483D8B',darkslategray:'#2F4F4F',darkslategrey:'#2F4F4F',darkturquoise:'#00CED1',darkviolet:'#9400D3',deeppink:'#FF1493',deepskyblue:'#00BFFF',dimgray:'#696969',dimgrey:'#696969',dodgerblue:'#1E90FF',firebrick:'#B22222',floralwhite:'#FFFAF0',forestgreen:'#228B22',gainsboro:'#DCDCDC',ghostwhite:'#F8F8FF',gold:'#FFD700',goldenrod:'#DAA520',grey:'#808080',greenyellow:'#ADFF2F',honeydew:'#F0FFF0',hotpink:'#FF69B4',indianred:'#CD5C5C',indigo:'#4B0082',ivory:'#FFFFF0',khaki:'#F0E68C',lavender:'#E6E6FA',lavenderblush:'#FFF0F5',lawngreen:'#7CFC00',lemonchiffon:'#FFFACD',lightblue:'#ADD8E6',lightcoral:'#F08080',lightcyan:'#E0FFFF',lightgoldenrodyellow:'#FAFAD2',lightgreen:'#90EE90',lightgrey:'#D3D3D3',lightpink:'#FFB6C1',lightsalmon:'#FFA07A',lightseagreen:'#20B2AA',lightskyblue:'#87CEFA',lightslategray:'#778899',lightslategrey:'#778899',lightsteelblue:'#B0C4DE',lightyellow:'#FFFFE0',limegreen:'#32CD32',linen:'#FAF0E6',magenta:'#FF00FF',mediumaquamarine:'#66CDAA',mediumblue:'#0000CD',mediumorchid:'#BA55D3',mediumpurple:'#9370DB',mediumseagreen:'#3CB371',mediumslateblue:'#7B68EE',mediumspringgreen:'#00FA9A',mediumturquoise:'#48D1CC',mediumvioletred:'#C71585',midnightblue:'#191970',mintcream:'#F5FFFA',mistyrose:'#FFE4E1',moccasin:'#FFE4B5',navajowhite:'#FFDEAD',oldlace:'#FDF5E6',olivedrab:'#6B8E23',orange:'#FFA500',orangered:'#FF4500',orchid:'#DA70D6',palegoldenrod:'#EEE8AA',palegreen:'#98FB98',paleturquoise:'#AFEEEE',palevioletred:'#DB7093',papayawhip:'#FFEFD5',peachpuff:'#FFDAB9',peru:'#CD853F',pink:'#FFC0CB',plum:'#DDA0DD',powderblue:'#B0E0E6',rosybrown:'#BC8F8F',royalblue:'#4169E1',saddlebrown:'#8B4513',salmon:'#FA8072',sandybrown:'#F4A460',seagreen:'#2E8B57',seashell:'#FFF5EE',sienna:'#A0522D',skyblue:'#87CEEB',slateblue:'#6A5ACD',slategray:'#708090',slategrey:'#708090',snow:'#FFFAFA',springgreen:'#00FF7F',steelblue:'#4682B4',tan:'#D2B48C',thistle:'#D8BFD8',tomato:'#FF6347',turquoise:'#40E0D0',violet:'#EE82EE',wheat:'#F5DEB3',whitesmoke:'#F5F5F5',yellowgreen:'#9ACD32'};

        function getRgbHslContent(styleString) {
            var start = styleString.indexOf('(', 3);
            var end = styleString.indexOf(')', start + 1);
            var parts = styleString.substring(start + 1, end).split(',');
            if (parts.length != 4 || styleString.charAt(3) != 'a') {
                parts[3] = 1;
            }
            return parts;
        }

        function percent(s) {
            return parseFloat(s) / 100;
        }

        function clamp(v, min, max) {
            return Math.min(max, Math.max(min, v));
        }

        function hslToRgb(parts) {
            var r,g,b,h,s,l;
            h = parseFloat(parts[0]) / 360 % 360;
            if (h < 0)h++;
            s = clamp(percent(parts[1]), 0, 1);
            l = clamp(percent(parts[2]), 0, 1);
            if (s == 0) {
                r = g = b = l;
            } else {
                var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
                var p = 2 * l - q;
                r = hueToRgb(p, q, h + 1 / 3);
                g = hueToRgb(p, q, h);
                b = hueToRgb(p, q, h - 1 / 3);
            }
            return'#' + decToHex[Math.floor(r * 255)] + decToHex[Math.floor(g * 255)] + decToHex[Math.floor(b * 255)];
        }

        function hueToRgb(m1, m2, h) {
            if (h < 0)h++;
            if (h > 1)h--;
            if (6 * h < 1)return m1 + (m2 - m1) * 6 * h; else if (2 * h < 1)return m2; else if (3 * h < 2)return m1 + (m2 - m1) * (2 / 3 - h) * 6; else return m1;
        }

        var processStyleCache = {};

        function processStyle(styleString) {
            if (styleString in processStyleCache) {
                return processStyleCache[styleString];
            }
            var str,alpha = 1;
            styleString = String(styleString);
            if (styleString.charAt(0) == '#') {
                str = styleString;
            } else if (/^rgb/.test(styleString)) {
                var parts = getRgbHslContent(styleString);
                var str = '#',n;
                for (var i = 0; i < 3; i++) {
                    if (parts[i].indexOf('%') != -1) {
                        n = Math.floor(percent(parts[i]) * 255);
                    } else {
                        n = +parts[i];
                    }
                    str += decToHex[clamp(n, 0, 255)];
                }
                alpha = +parts[3];
            } else if (/^hsl/.test(styleString)) {
                var parts = getRgbHslContent(styleString);
                str = hslToRgb(parts);
                alpha = parts[3];
            } else {
                str = colorData[styleString] || styleString;
            }
            return processStyleCache[styleString] = {color:str,alpha:alpha};
        }

        var DEFAULT_STYLE = {style:'normal',variant:'normal',weight:'normal',size:10,family:'sans-serif'};
        var fontStyleCache = {};

        function processFontStyle(styleString) {
            if (fontStyleCache[styleString]) {
                return fontStyleCache[styleString];
            }
            var el = document.createElement('div');
            var style = el.style;
            try {
                style.font = styleString;
            } catch(ex) {
            }
            return fontStyleCache[styleString] = {style:style.fontStyle || DEFAULT_STYLE.style,variant:style.fontVariant || DEFAULT_STYLE.variant,weight:style.fontWeight || DEFAULT_STYLE.weight,size:style.fontSize || DEFAULT_STYLE.size,family:style.fontFamily || DEFAULT_STYLE.family};
        }

        function getComputedStyle(style, element) {
            var computedStyle = {};
            for (var p in style) {
                computedStyle[p] = style[p];
            }
            var canvasFontSize = parseFloat(element.currentStyle.fontSize),fontSize = parseFloat(style.size);
            if (typeof style.size == 'number') {
                computedStyle.size = style.size;
            } else if (style.size.indexOf('px') != -1) {
                computedStyle.size = fontSize;
            } else if (style.size.indexOf('em') != -1) {
                computedStyle.size = canvasFontSize * fontSize;
            } else if (style.size.indexOf('%') != -1) {
                computedStyle.size = (canvasFontSize / 100) * fontSize;
            } else if (style.size.indexOf('pt') != -1) {
                computedStyle.size = fontSize / .75;
            } else {
                computedStyle.size = canvasFontSize;
            }
            computedStyle.size *= 0.981;
            return computedStyle;
        }

        function buildStyle(style) {
            return style.style + ' ' + style.variant + ' ' + style.weight + ' ' + style.size + 'px ' + style.family;
        }

        var lineCapMap = {'butt':'flat','round':'round'};

        function processLineCap(lineCap) {
            return lineCapMap[lineCap] || 'square';
        }

        function CanvasRenderingContext2D_(canvasElement) {
            this.m_ = createMatrixIdentity();
            this.mStack_ = [];
            this.aStack_ = [];
            this.currentPath_ = [];
            this.strokeStyle = '#000';
            this.fillStyle = '#000';
            this.lineWidth = 1;
            this.lineJoin = 'miter';
            this.lineCap = 'butt';
            this.miterLimit = Z * 1;
            this.globalAlpha = 1;
            this.font = '10px sans-serif';
            this.textAlign = 'left';
            this.textBaseline = 'alphabetic';
            this.canvas = canvasElement;
            var cssText = 'width:' + canvasElement.clientWidth + 'px;height:' + canvasElement.clientHeight + 'px;overflow:hidden;position:absolute';
            var el = canvasElement.ownerDocument.createElement('div');
            el.style.cssText = cssText;
            canvasElement.appendChild(el);
            var overlayEl = el.cloneNode(false);
            overlayEl.style.backgroundColor = 'red';
            overlayEl.style.filter = 'alpha(opacity=0)';
            canvasElement.appendChild(overlayEl);
            this.element_ = el;
            this.arcScaleX_ = 1;
            this.arcScaleY_ = 1;
            this.lineScale_ = 1;
        }

        var contextPrototype = CanvasRenderingContext2D_.prototype;
        contextPrototype.clearRect = function() {
            if (this.textMeasureEl_) {
                this.textMeasureEl_.removeNode(true);
                this.textMeasureEl_ = null;
            }
            this.element_.innerHTML = '';
        };
        contextPrototype.beginPath = function() {
            this.currentPath_ = [];
        };
        contextPrototype.moveTo = function(aX, aY) {
            var p = getCoords(this, aX, aY);
            this.currentPath_.push({type:'moveTo',x:p.x,y:p.y});
            this.currentX_ = p.x;
            this.currentY_ = p.y;
        };
        contextPrototype.lineTo = function(aX, aY) {
            var p = getCoords(this, aX, aY);
            this.currentPath_.push({type:'lineTo',x:p.x,y:p.y});
            this.currentX_ = p.x;
            this.currentY_ = p.y;
        };
        contextPrototype.bezierCurveTo = function(aCP1x, aCP1y, aCP2x, aCP2y, aX, aY) {
            var p = getCoords(this, aX, aY);
            var cp1 = getCoords(this, aCP1x, aCP1y);
            var cp2 = getCoords(this, aCP2x, aCP2y);
            bezierCurveTo(this, cp1, cp2, p);
        };
        function bezierCurveTo(self, cp1, cp2, p) {
            self.currentPath_.push({type:'bezierCurveTo',cp1x:cp1.x,cp1y:cp1.y,cp2x:cp2.x,cp2y:cp2.y,x:p.x,y:p.y});
            self.currentX_ = p.x;
            self.currentY_ = p.y;
        }

        contextPrototype.quadraticCurveTo = function(aCPx, aCPy, aX, aY) {
            var cp = getCoords(this, aCPx, aCPy);
            var p = getCoords(this, aX, aY);
            var cp1 = {x:this.currentX_ + 2.0 / 3.0 * (cp.x - this.currentX_),y:this.currentY_ + 2.0 / 3.0 * (cp.y - this.currentY_)};
            var cp2 = {x:cp1.x + (p.x - this.currentX_) / 3.0,y:cp1.y + (p.y - this.currentY_) / 3.0};
            bezierCurveTo(this, cp1, cp2, p);
        };
        contextPrototype.arc = function(aX, aY, aRadius, aStartAngle, aEndAngle, aClockwise) {
            aRadius *= Z;
            var arcType = aClockwise ? 'at' : 'wa';
            var xStart = aX + mc(aStartAngle) * aRadius - Z2;
            var yStart = aY + ms(aStartAngle) * aRadius - Z2;
            var xEnd = aX + mc(aEndAngle) * aRadius - Z2;
            var yEnd = aY + ms(aEndAngle) * aRadius - Z2;
            if (xStart == xEnd && !aClockwise) {
                xStart += 0.125;
            }
            var p = getCoords(this, aX, aY);
            var pStart = getCoords(this, xStart, yStart);
            var pEnd = getCoords(this, xEnd, yEnd);
            this.currentPath_.push({type:arcType,x:p.x,y:p.y,radius:aRadius,xStart:pStart.x,yStart:pStart.y,xEnd:pEnd.x,yEnd:pEnd.y});
        };
        contextPrototype.rect = function(aX, aY, aWidth, aHeight) {
            this.moveTo(aX, aY);
            this.lineTo(aX + aWidth, aY);
            this.lineTo(aX + aWidth, aY + aHeight);
            this.lineTo(aX, aY + aHeight);
            this.closePath();
        };
        contextPrototype.strokeRect = function(aX, aY, aWidth, aHeight) {
            var oldPath = this.currentPath_;
            this.beginPath();
            this.moveTo(aX, aY);
            this.lineTo(aX + aWidth, aY);
            this.lineTo(aX + aWidth, aY + aHeight);
            this.lineTo(aX, aY + aHeight);
            this.closePath();
            this.stroke();
            this.currentPath_ = oldPath;
        };
        contextPrototype.fillRect = function(aX, aY, aWidth, aHeight) {
            var oldPath = this.currentPath_;
            this.beginPath();
            this.moveTo(aX, aY);
            this.lineTo(aX + aWidth, aY);
            this.lineTo(aX + aWidth, aY + aHeight);
            this.lineTo(aX, aY + aHeight);
            this.closePath();
            this.fill();
            this.currentPath_ = oldPath;
        };
        contextPrototype.createLinearGradient = function(aX0, aY0, aX1, aY1) {
            var gradient = new CanvasGradient_('gradient');
            gradient.x0_ = aX0;
            gradient.y0_ = aY0;
            gradient.x1_ = aX1;
            gradient.y1_ = aY1;
            return gradient;
        };
        contextPrototype.createRadialGradient = function(aX0, aY0, aR0, aX1, aY1, aR1) {
            var gradient = new CanvasGradient_('gradientradial');
            gradient.x0_ = aX0;
            gradient.y0_ = aY0;
            gradient.r0_ = aR0;
            gradient.x1_ = aX1;
            gradient.y1_ = aY1;
            gradient.r1_ = aR1;
            return gradient;
        };
        contextPrototype.drawImage = function(image, var_args) {
            var dx,dy,dw,dh,sx,sy,sw,sh;
            var oldRuntimeWidth = image.runtimeStyle.width;
            var oldRuntimeHeight = image.runtimeStyle.height;
            image.runtimeStyle.width = 'auto';
            image.runtimeStyle.height = 'auto';
            var w = image.width;
            var h = image.height;
            image.runtimeStyle.width = oldRuntimeWidth;
            image.runtimeStyle.height = oldRuntimeHeight;
            if (arguments.length == 3) {
                dx = arguments[1];
                dy = arguments[2];
                sx = sy = 0;
                sw = dw = w;
                sh = dh = h;
            } else if (arguments.length == 5) {
                dx = arguments[1];
                dy = arguments[2];
                dw = arguments[3];
                dh = arguments[4];
                sx = sy = 0;
                sw = w;
                sh = h;
            } else if (arguments.length == 9) {
                sx = arguments[1];
                sy = arguments[2];
                sw = arguments[3];
                sh = arguments[4];
                dx = arguments[5];
                dy = arguments[6];
                dw = arguments[7];
                dh = arguments[8];
            } else {
                throw Error('Invalid number of arguments');
            }
            var d = getCoords(this, dx, dy);
            var w2 = sw / 2;
            var h2 = sh / 2;
            var vmlStr = [];
            var W = 10;
            var H = 10;
            vmlStr.push(' <g_vml_:group', ' coordsize="', Z * W, ',', Z * H, '"', ' coordorigin="0,0"', ' style="width:', W, 'px;height:', H, 'px;position:absolute;');
            if (this.m_[0][0] != 1 || this.m_[0][1] || this.m_[1][1] != 1 || this.m_[1][0]) {
                var filter = [];
                filter.push('M11=', this.m_[0][0], ',', 'M12=', this.m_[1][0], ',', 'M21=', this.m_[0][1], ',', 'M22=', this.m_[1][1], ',', 'Dx=', mr(d.x / Z), ',', 'Dy=', mr(d.y / Z), '');
                var max = d;
                var c2 = getCoords(this, dx + dw, dy);
                var c3 = getCoords(this, dx, dy + dh);
                var c4 = getCoords(this, dx + dw, dy + dh);
                max.x = m.max(max.x, c2.x, c3.x, c4.x);
                max.y = m.max(max.y, c2.y, c3.y, c4.y);
                vmlStr.push('padding:0 ', mr(max.x / Z), 'px ', mr(max.y / Z), 'px 0;filter:progid:DXImageTransform.Microsoft.Matrix(', filter.join(''), ", sizingmethod='clip');");
            } else {
                vmlStr.push('top:', mr(d.y / Z), 'px;left:', mr(d.x / Z), 'px;');
            }
            vmlStr.push(' ">', '<g_vml_:image src="', image.src, '"', ' style="width:', Z * dw, 'px;', ' height:', Z * dh, 'px"', ' cropleft="', sx / w, '"', ' croptop="', sy / h, '"', ' cropright="', (w - sx - sw) / w, '"', ' cropbottom="', (h - sy - sh) / h, '"', ' />', '</g_vml_:group>');
            this.element_.insertAdjacentHTML('BeforeEnd', vmlStr.join(''));
        };
        contextPrototype.stroke = function(aFill) {
            var lineStr = [];
            var lineOpen = false;
            var W = 10;
            var H = 10;
            lineStr.push('<g_vml_:shape', ' filled="', !!aFill, '"', ' style="position:absolute;width:', W, 'px;height:', H, 'px;"', ' coordorigin="0,0"', ' coordsize="', Z * W, ',', Z * H, '"', ' stroked="', !aFill, '"', ' path="');
            var newSeq = false;
            var min = {x:null,y:null};
            var max = {x:null,y:null};
            for (var i = 0; i < this.currentPath_.length; i++) {
                var p = this.currentPath_[i];
                var c;
                switch (p.type) {case'moveTo':c = p;lineStr.push(' m ', mr(p.x), ',', mr(p.y));break;case'lineTo':lineStr.push(' l ', mr(p.x), ',', mr(p.y));break;case'close':lineStr.push(' x ');p = null;break;case'bezierCurveTo':lineStr.push(' c ', mr(p.cp1x), ',', mr(p.cp1y), ',', mr(p.cp2x), ',', mr(p.cp2y), ',', mr(p.x), ',', mr(p.y));break;case'at':case'wa':lineStr.push(' ', p.type, ' ', mr(p.x - this.arcScaleX_ * p.radius), ',', mr(p.y - this.arcScaleY_ * p.radius), ' ', mr(p.x + this.arcScaleX_ * p.radius), ',', mr(p.y + this.arcScaleY_ * p.radius), ' ', mr(p.xStart), ',', mr(p.yStart), ' ', mr(p.xEnd), ',', mr(p.yEnd));break;
                }
                if (p) {
                    if (min.x == null || p.x < min.x) {
                        min.x = p.x;
                    }
                    if (max.x == null || p.x > max.x) {
                        max.x = p.x;
                    }
                    if (min.y == null || p.y < min.y) {
                        min.y = p.y;
                    }
                    if (max.y == null || p.y > max.y) {
                        max.y = p.y;
                    }
                }
            }
            lineStr.push(' ">');
            if (!aFill) {
                appendStroke(this, lineStr);
            } else {
                appendFill(this, lineStr, min, max);
            }
            lineStr.push('</g_vml_:shape>');
            this.element_.insertAdjacentHTML('beforeEnd', lineStr.join(''));
        };
        function appendStroke(ctx, lineStr) {
            var a = processStyle(ctx.strokeStyle);
            var color = a.color;
            var opacity = a.alpha * ctx.globalAlpha;
            var lineWidth = ctx.lineScale_ * ctx.lineWidth;
            if (lineWidth < 1) {
                opacity *= lineWidth;
            }
            lineStr.push('<g_vml_:stroke', ' opacity="', opacity, '"', ' joinstyle="', ctx.lineJoin, '"', ' miterlimit="', ctx.miterLimit, '"', ' endcap="', processLineCap(ctx.lineCap), '"', ' weight="', lineWidth, 'px"', ' color="', color, '" />');
        }

        function appendFill(ctx, lineStr, min, max) {
            var fillStyle = ctx.fillStyle;
            var arcScaleX = ctx.arcScaleX_;
            var arcScaleY = ctx.arcScaleY_;
            var width = max.x - min.x;
            var height = max.y - min.y;
            if (fillStyle instanceof CanvasGradient_) {
                var angle = 0;
                var focus = {x:0,y:0};
                var shift = 0;
                var expansion = 1;
                if (fillStyle.type_ == 'gradient') {
                    var x0 = fillStyle.x0_ / arcScaleX;
                    var y0 = fillStyle.y0_ / arcScaleY;
                    var x1 = fillStyle.x1_ / arcScaleX;
                    var y1 = fillStyle.y1_ / arcScaleY;
                    var p0 = getCoords(ctx, x0, y0);
                    var p1 = getCoords(ctx, x1, y1);
                    var dx = p1.x - p0.x;
                    var dy = p1.y - p0.y;
                    angle = Math.atan2(dx, dy) * 180 / Math.PI;
                    if (angle < 0) {
                        angle += 360;
                    }
                    if (angle < 1e-6) {
                        angle = 0;
                    }
                } else {
                    var p0 = getCoords(ctx, fillStyle.x0_, fillStyle.y0_);
                    focus = {x:(p0.x - min.x) / width,y:(p0.y - min.y) / height};
                    width /= arcScaleX * Z;
                    height /= arcScaleY * Z;
                    var dimension = m.max(width, height);
                    shift = 2 * fillStyle.r0_ / dimension;
                    expansion = 2 * fillStyle.r1_ / dimension - shift;
                }
                var stops = fillStyle.colors_;
                stops.sort(function(cs1, cs2) {
                    return cs1.offset - cs2.offset;
                });
                var length = stops.length;
                var color1 = stops[0].color;
                var color2 = stops[length - 1].color;
                var opacity1 = stops[0].alpha * ctx.globalAlpha;
                var opacity2 = stops[length - 1].alpha * ctx.globalAlpha;
                var colors = [];
                for (var i = 0; i < length; i++) {
                    var stop = stops[i];
                    colors.push(stop.offset * expansion + shift + ' ' + stop.color);
                }
                lineStr.push('<g_vml_:fill type="', fillStyle.type_, '"', ' method="none" focus="100%"', ' color="', color1, '"', ' color2="', color2, '"', ' colors="', colors.join(','), '"', ' opacity="', opacity2, '"', ' g_o_:opacity2="', opacity1, '"', ' angle="', angle, '"', ' focusposition="', focus.x, ',', focus.y, '" />');
            } else if (fillStyle instanceof CanvasPattern_) {
                if (width && height) {
                    var deltaLeft = -min.x;
                    var deltaTop = -min.y;
                    lineStr.push('<g_vml_:fill', ' position="', deltaLeft / width * arcScaleX * arcScaleX, ',', deltaTop / height * arcScaleY * arcScaleY, '"', ' type="tile"', ' src="', fillStyle.src_, '" />');
                }
            } else {
                var a = processStyle(ctx.fillStyle);
                var color = a.color;
                var opacity = a.alpha * ctx.globalAlpha;
                lineStr.push('<g_vml_:fill color="', color, '" opacity="', opacity, '" />');
            }
        }

        contextPrototype.fill = function() {
            this.stroke(true);
        };
        contextPrototype.closePath = function() {
            this.currentPath_.push({type:'close'});
        };
        function getCoords(ctx, aX, aY) {
            var m = ctx.m_;
            return{x:Z * (aX * m[0][0] + aY * m[1][0] + m[2][0]) - Z2,y:Z * (aX * m[0][1] + aY * m[1][1] + m[2][1]) - Z2};
        }

        ;
        contextPrototype.save = function() {
            var o = {};
            copyState(this, o);
            this.aStack_.push(o);
            this.mStack_.push(this.m_);
            this.m_ = matrixMultiply(createMatrixIdentity(), this.m_);
        };
        contextPrototype.restore = function() {
            if (this.aStack_.length) {
                copyState(this.aStack_.pop(), this);
                this.m_ = this.mStack_.pop();
            }
        };
        function matrixIsFinite(m) {
            return isFinite(m[0][0]) && isFinite(m[0][1]) && isFinite(m[1][0]) && isFinite(m[1][1]) && isFinite(m[2][0]) && isFinite(m[2][1]);
        }

        function setM(ctx, m, updateLineScale) {
            if (!matrixIsFinite(m)) {
                return;
            }
            ctx.m_ = m;
            if (updateLineScale) {
                var det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
                ctx.lineScale_ = sqrt(abs(det));
            }
        }

        contextPrototype.translate = function(aX, aY) {
            var m1 = [
                [1,0,0],
                [0,1,0],
                [aX,aY,1]
            ];
            setM(this, matrixMultiply(m1, this.m_), false);
        };
        contextPrototype.rotate = function(aRot) {
            var c = mc(aRot);
            var s = ms(aRot);
            var m1 = [
                [c,s,0],
                [-s,c,0],
                [0,0,1]
            ];
            setM(this, matrixMultiply(m1, this.m_), false);
        };
        contextPrototype.scale = function(aX, aY) {
            this.arcScaleX_ *= aX;
            this.arcScaleY_ *= aY;
            var m1 = [
                [aX,0,0],
                [0,aY,0],
                [0,0,1]
            ];
            setM(this, matrixMultiply(m1, this.m_), true);
        };
        contextPrototype.transform = function(m11, m12, m21, m22, dx, dy) {
            var m1 = [
                [m11,m12,0],
                [m21,m22,0],
                [dx,dy,1]
            ];
            setM(this, matrixMultiply(m1, this.m_), true);
        };
        contextPrototype.setTransform = function(m11, m12, m21, m22, dx, dy) {
            var m = [
                [m11,m12,0],
                [m21,m22,0],
                [dx,dy,1]
            ];
            setM(this, m, true);
        };
        contextPrototype.drawText_ = function(text, x, y, maxWidth, stroke) {
            var m = this.m_,delta = 1000,left = 0,right = delta,offset = {x:0,y:0},lineStr = [];
            var fontStyle = getComputedStyle(processFontStyle(this.font), this.element_);
            var fontStyleString = buildStyle(fontStyle);
            var elementStyle = this.element_.currentStyle;
            var textAlign = this.textAlign.toLowerCase();
            switch (textAlign) {case'left':case'center':case'right':break;case'end':textAlign = elementStyle.direction == 'ltr' ? 'right' : 'left';break;case'start':textAlign = elementStyle.direction == 'rtl' ? 'right' : 'left';break;default:textAlign = 'left';
            }
            switch (this.textBaseline) {case'hanging':case'top':offset.y = fontStyle.size / 1.75;break;case'middle':break;default:case null:case'alphabetic':case'ideographic':case'bottom':offset.y = -fontStyle.size / 2.25;break;
            }
            switch (textAlign) {case'right':left = delta;right = 0.05;break;case'center':left = right = delta / 2;break;
            }
            var d = getCoords(this, x + offset.x, y + offset.y);
            lineStr.push('<g_vml_:line from="', -left, ' 0" to="', right, ' 0.05" ', ' coordsize="100 100" coordorigin="0 0"', ' filled="', !stroke, '" stroked="', !!stroke, '" style="position:absolute;width:1px;height:1px;">');
            if (stroke) {
                appendStroke(this, lineStr);
            } else {
                appendFill(this, lineStr, {x:-left,y:0}, {x:right,y:fontStyle.size});
            }
            var skewM = m[0][0].toFixed(3) + ',' + m[1][0].toFixed(3) + ',' + m[0][1].toFixed(3) + ',' + m[1][1].toFixed(3) + ',0,0';
            var skewOffset = mr(d.x / Z) + ',' + mr(d.y / Z);
            lineStr.push('<g_vml_:skew on="t" matrix="', skewM, '" ', ' offset="', skewOffset, '" origin="', left, ' 0" />', '<g_vml_:path textpathok="true" />', '<g_vml_:textpath on="true" string="', encodeHtmlAttribute(text), '" style="v-text-align:', textAlign, ';font:', encodeHtmlAttribute(fontStyleString), '" /></g_vml_:line>');
            this.element_.insertAdjacentHTML('beforeEnd', lineStr.join(''));
        };
        contextPrototype.fillText = function(text, x, y, maxWidth) {
            this.drawText_(text, x, y, maxWidth, false);
        };
        contextPrototype.strokeText = function(text, x, y, maxWidth) {
            this.drawText_(text, x, y, maxWidth, true);
        };
        contextPrototype.measureText = function(text) {
            if (!this.textMeasureEl_) {
                var s = '<span style="position:absolute;' + 'top:-20000px;left:0;padding:0;margin:0;border:none;' + 'white-space:pre;"></span>';
                this.element_.insertAdjacentHTML('beforeEnd', s);
                this.textMeasureEl_ = this.element_.lastChild;
            }
            var doc = this.element_.ownerDocument;
            this.textMeasureEl_.innerHTML = '';
            this.textMeasureEl_.style.font = this.font;
            this.textMeasureEl_.appendChild(doc.createTextNode(text));
            return{width:this.textMeasureEl_.offsetWidth};
        };
        contextPrototype.clip = function() {
        };
        contextPrototype.arcTo = function() {
        };
        contextPrototype.createPattern = function(image, repetition) {
            return new CanvasPattern_(image, repetition);
        };
        function CanvasGradient_(aType) {
            this.type_ = aType;
            this.x0_ = 0;
            this.y0_ = 0;
            this.r0_ = 0;
            this.x1_ = 0;
            this.y1_ = 0;
            this.r1_ = 0;
            this.colors_ = [];
        }

        CanvasGradient_.prototype.addColorStop = function(aOffset, aColor) {
            aColor = processStyle(aColor);
            this.colors_.push({offset:aOffset,color:aColor.color,alpha:aColor.alpha});
        };
        function CanvasPattern_(image, repetition) {
            assertImageIsValid(image);
            switch (repetition) {case'repeat':case null:case'':this.repetition_ = 'repeat';break;case'repeat-x':case'repeat-y':case'no-repeat':this.repetition_ = repetition;break;default:throwException('SYNTAX_ERR');
            }
            this.src_ = image.src;
            this.width_ = image.width;
            this.height_ = image.height;
        }

        function throwException(s) {
            throw new DOMException_(s);
        }

        function assertImageIsValid(img) {
            if (!img || img.nodeType != 1 || img.tagName != 'IMG') {
                throwException('TYPE_MISMATCH_ERR');
            }
            if (img.readyState != 'complete') {
                throwException('INVALID_STATE_ERR');
            }
        }

        function DOMException_(s) {
            this.code = this[s];
            this.message = s + ': DOM Exception ' + this.code;
        }

        var p = DOMException_.prototype = new Error;
        p.INDEX_SIZE_ERR = 1;
        p.DOMSTRING_SIZE_ERR = 2;
        p.HIERARCHY_REQUEST_ERR = 3;
        p.WRONG_DOCUMENT_ERR = 4;
        p.INVALID_CHARACTER_ERR = 5;
        p.NO_DATA_ALLOWED_ERR = 6;
        p.NO_MODIFICATION_ALLOWED_ERR = 7;
        p.NOT_FOUND_ERR = 8;
        p.NOT_SUPPORTED_ERR = 9;
        p.INUSE_ATTRIBUTE_ERR = 10;
        p.INVALID_STATE_ERR = 11;
        p.SYNTAX_ERR = 12;
        p.INVALID_MODIFICATION_ERR = 13;
        p.NAMESPACE_ERR = 14;
        p.INVALID_ACCESS_ERR = 15;
        p.VALIDATION_ERR = 16;
        p.TYPE_MISMATCH_ERR = 17;
        G_vmlCanvasManager = G_vmlCanvasManager_;
        CanvasRenderingContext2D = CanvasRenderingContext2D_;
        CanvasGradient = CanvasGradient_;
        CanvasPattern = CanvasPattern_;
        DOMException = DOMException_;
    })();
}

