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

// Custom Simple Fade Gallery
(function($) {
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
                    this.autoHideControls = false,

                // Auto slideshow property
                    this.autoSlideShow = true,

                // The text of the exit button
                    this.backButtonLabel = 'Back to album';

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

                //control bar opened or closed
                    this.controlBarState = 'opened';

            // Controls hide speed value
            this.controlsHideSpeed = 2,

                // Show exit button property
                    this.backButton = true,

                // The URL or file path and name of an image displayed as the exit button
                    this.backButtonURL = '',

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

                //source type json or xml
                    this.sourceType = 'json';

            // images xml path
            this.source = null,

                // xml json object containing images
                    this.xml,

                // preload After or Before
                    this.preload = 'after';

            //*** FLAGS ***\\

            // fix css flag
            this.flagFixCss = true,

                // frozen engine
                    this.flagFrozen = false,

                // resize handler
                    this.flagResizeHandler = false,

                // fullscreen flag
                    this.fullScreenMode = true;

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
                        .css({width:this.defaultCanvasWidth + 'px',height:this.defaultCanvasHeight + 'px'})
                        .appendTo('#' + configs.appendToID);

            } else if (typeof configs.insertAfterID != 'undefined' && configs.insertAfterID.length > 0) {
                $('<div />').attr('id', this.canvasIdentifier + '_GP')
                        .css({width:this.defaultCanvasWidth + 'px',height:this.defaultCanvasHeight + 'px'})
                        .insertAfter('#' + configs.insertAfterID);
            }

            $('<div />').attr('id', this.canvasIdentifier).appendTo('#' + this.canvasIdentifier + '_GP');

            this.preloaderIdentifier = this.canvasIdentifier + '_preloader';

            eval('$(document).ready(function(){window.'
                    + this.canvasIdentifier + '.loadTemplateXml(' + this.callStack + ')})');
        },

        /**
         * clear timeout resources
         */
        clearResources: function() {
            if (typeof this.timeoutResources != 'undefined') {
                while (this.timeoutResources.length > 0) {
                    clearTimeout(this.timeoutResources[0]);
                    this.timeoutResources.splice(0, 1);
                }
            }
            if (typeof this.timeoutResources != 'undefined') {
                while (this.hideElements.length > 0) {
                    $('#' + this.hideElements[0]).hide();
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
                            )) {
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
            // backButtonLabel
            if (typeof configs.backButtonLabel != 'undefined' && configs.backButtonLabel.length > 0) {
                this.backButtonLabel = configs.backButtonLabel;
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

            // control bar state
            if (typeof configs.controlBarState != 'undefined') {
                if (configs.controlBarState.toString().toLowerCase() == 'opened') {
                    this.controlBarState = 'opened';
                } else if (configs.controlBarState.toString().toLowerCase() == 'closed') {
                    this.controlBarState = 'closed';
                }
            }

            // controlsHideSpeed
            if (typeof configs.controlsHideSpeed != 'undefined' && configs.controlsHideSpeed >= 0) {
                this.controlsHideSpeed = parseFloat(configs.controlsHideSpeed) * 1000;
            }

            // backButton
            if (typeof configs.backButton != 'undefined') {
                if (configs.backButton.toString().toLowerCase() == 'true') {
                    this.backButton = true;
                } else if (configs.backButton.toString().toLowerCase() == 'false') {
                    this.backButton = false;
                }
            }

            // backButtonURL
            if (typeof configs.backButtonURL != 'undefined' && configs.backButtonURL.length > 0) {
                this.backButtonURL = configs.backButtonURL;
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

            // chaching parameters
            if (typeof configs.preloadAfter != 'undefined' && configs.preloadAfter >= 0) {
                this.preloadAfter = parseInt(configs.preloadAfter);
            }
            if (typeof configs.preloadBefore != 'undefined' && configs.preloadBefore >= 0) {
                this.preloadBefore = parseInt(configs.preloadBefore);
            }

            //sourceType json or xml
            if (typeof configs.sourceType != 'undefined') {
                if (configs.sourceType.toString().toLowerCase() == 'xml') {
                    this.sourceType = 'xml';
                } else if (configs.sourceType.toString().toLowerCase() == 'json') {
                    this.sourceType = 'json';
                }
            }
            return true;
        },

        /**
         * Globally Unique Identifier Generator for current slideshow
         */
        generateIdentifier: function() {
            var i = 1;
            while ((document.getElementById('CustomSimpleFadeContainer' + i) != null
                    || eval('typeof window.CustomSimpleFadeContainer' + i) != 'undefined')
                    && i < 1000) {
                i++;
            }
            this.canvasIdentifier = 'CustomSimpleFadeContainer' + i;
            this.callStack = i;
            eval('window.' + this.canvasIdentifier + '=this');

            return true;
        },

        /**
         * Fix CSS
         */
        fixCSS: function() {
            if (this.flagFixCss == false) {
                return;
            }
            var err;
            try {
                $.tocssRule(
                        '#' + this.canvasIdentifier + '_GP, #' + this.canvasIdentifier + '_GP * {' +
                                'background:none fixed transparent left top no-repeat;' +
                                'border:none;' +
                                'bottom:auto;' +
                                'clear:none;' +
                                'cursor:auto;' +
                                'direction:ltr;' +
                                'display:block;' +
                                'float:none;' +
                                'font-family:"Lucida Grande","Lucida Sans Unicode","Lucida Sans",' +
                                'Verdana,Arial,Helvetica,sans-serif;' +
                                'font-size:10px;' +
                                'font-size-adjust:none;' +
                                'font-stretch:normal;' +
                                'font-style:normal;' +
                                'font-variant:normal;' +
                                'font-weight:normal;' +
                                'height:auto;' +
                                'layout-flow:horizontal;' +
                                'layout-grid:none;' +
                                'left:0px;' +
                                'letter-spacing:normal;' +
                                'line-break:normal;' +
                                'line-height:normal;' +
                                'list-style:disc outside none;' +
                                'margin:0px 0px 0px 0px;' +
                                'max-height:none;' +
                                'max-width:none;' +
                                'min-height:0px;' +
                                'min-width:0px;' +
                                '-moz-border-radius:0;' +
                                'outline-color:invert;' +
                                'outline-style:none;' +
                                'outline-width:medium;' +
                                'overflow:visible;' +
                                'padding:0px 0px 0px 0px;' +
                                'position:static;' +
                                'right:auto;' +
                                'text-align:left;' +
                                'text-decoration:none;' +
                                'text-indent:0px;' +
                                'text-shadow:none;' +
                                'text-transform:none;' +
                                'top:0px;' +
                                'vertical-align:baseline;' +
                                'visibility:visible;' +
                                'width:auto;' +
                                'word-spacing:normal;' +
                                'z-index:1;' +
                                'zoom:1;' +
                                '}'
                        );
            } catch(err) {
            }
            ;
        },

        /**
         * Load Album Template XML, store data in xml var and run canvas setup function
         */
        loadTemplateXml: function(callStack) {
            if (this.callStack != callStack) {
                return;
            }
            var obj = this;
            if (this.sourceType == 'xml') {
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
            }
            if (this.sourceType == 'json') {
                $.getJSON(this.source, function(data) {
                    obj.xml = {items:{item:[]}};
                    var element;
                    if (data.length == 0) {
                        return false;
                    }
                    for (i = 0; i < data.length; i++) {
                        element = {fullScreenImagePath:data[i].full_screen_url, largeImagePath:data[i].screen_url, description:data[i].caption};
                        obj.xml.items.item.push(element);
                    }
                    obj.canvasSetup(callStack);
                });
            }
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
                    $('#' + this.canvasIdentifier).css({
                        position:'absolute',
                        marginTop:'auto',
                        marginLeft:'auto'
                    });

                    var elemOffset = $('#' + this.canvasIdentifier).offset();

                    $('#' + this.canvasIdentifier).css({
                        position:'absolute',
                        marginTop:(-1 * elemOffset.top + $(window).scrollTop()) + 'px',
                        marginLeft:(-1 * elemOffset.left + $(window).scrollLeft()) + 'px',
                        width:$(window).width() + 'px',
                        height:$(window).height() + 'px',
                        overflow:'hidden',
                        backgroundColor:this.backgroundColor
                    });

                    $(window).scroll(function () {
                        if (obj.fullScreenMode == true) {
                            $('#' + obj.canvasIdentifier).css({
                                marginTop:(-1 * elemOffset.top + $(window).scrollTop()) + 'px',
                                marginLeft:(-1 * elemOffset.left + $(window).scrollLeft()) + 'px'
                            });
                        }
                    });
                } else {
                    $('#' + this.canvasIdentifier).css({
                        position:'fixed',
                        top:'0px',
                        left:'0px',
                        width:$(window).width() + 'px',
                        height:$(window).height() + 'px',
                        overflow:'hidden',
                        backgroundColor:this.backgroundColor
                    });
                }

                /* in the js version there is only fullscreen mode
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
                 */

                this.canvasWidth = $('#' + this.canvasIdentifier).width();
                this.canvasHeight = $('#' + this.canvasIdentifier).height();
            } else {
                $('#' + this.canvasIdentifier).css({
                    position:'relative',
                    width:this.defaultCanvasWidth + 'px',
                    height:this.defaultCanvasHeight + 'px',
                    overflow:'hidden'
                });
                this.canvasWidth = this.defaultCanvasWidth;
                this.canvasHeight = this.defaultCanvasHeight;
            }

            if (this.backgroundVisible) {
                $('#' + this.canvasIdentifier).css({backgroundColor:this.backgroundColor});
            } else {
                $('#' + this.canvasIdentifier).css({backgroundColor:'transparent'});
            }

            this.displayHeight = this.canvasHeight;
            this.displayWidth = this.canvasWidth;

            this.generatePreloader(this.preloaderIdentifier,
                    'window.' + this.canvasIdentifier + '.showPreloader(' + callStack + ')');

            if ($('#' + this.canvasIdentifier).is(':visible')) {
                this.setBackgroundImage(callStack);
                this.initiateTemplateJS(callStack, instanceNO);
            } else {
                $('#' + this.canvasIdentifier).fadeIn('fast', function() {
                    obj.setBackgroundImage(callStack);
                    obj.initiateTemplateJS(callStack, instanceNO);
                });
            }
        },

        /**
         * Check if canvas is in frozen state
         */
        isFrozen: function() {
            return this.flagFrozen == true;
        },

        /**
         * Unfroze canvas
         */
        setFrozenFlagOff: function() {
            this.flagFrozen = false;
        },

        /**
         * Froze canvas
         */
        setFrozenFlagOn: function() {
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
                $('#' + this.canvasIdentifier).empty();
                $('embed, object, select').css({ 'visibility' : 'visible' });
                if (!localScope.flagResizeHandler) {
                    localScope.flagResizeHandler = true;
                    $(window).resize(function() {
                        if (localScope.fullScreenMode == true) {
                            window.clearTimeout(localScope.resizeTimeout);
                            localScope.resizeTimeout = window.setTimeout(
                                    'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
                        }
                    });
                }
                localScope.canvasSetup();
            } else {
                $('#' + this.canvasIdentifier).fadeOut('fast', function() {
                    $(this).empty();
                    $('embed, object, select').css({ 'visibility' : 'visible' });
                    if (!localScope.flagResizeHandler) {
                        localScope.flagResizeHandler = true;
                        $(window).resize(function() {
                            if (localScope.fullScreenMode == true) {
                                window.clearTimeout(localScope.resizeTimeout);
                                localScope.resizeTimeout = window.setTimeout(
                                        'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
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
                $('#' + this.canvasIdentifier).empty();
                $('embed, object, select').css({ 'visibility' : 'visible' });
                $('#' + localScope.canvasIdentifier).css({marginTop:'auto',marginLeft:'auto'});
                localScope.canvasSetup();
            } else {
                $('#' + this.canvasIdentifier).fadeOut('fast', function() {
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
            if (this.backgroundVisible && this.backgroundImage.length > 0) {
                var obj = this;
                var bgImg = this.canvasIdentifier + '_backgroundImage';
                $('<img>').load(
                        function() {
                            $(this).unbind('load').hide().attr('id', bgImg).appendTo('#' + obj.canvasIdentifier);
                            if (localScope.scaleBackground) {
                                var cH = $(this).height();
                                var cW = $(this).width();
                                var canvasProp = obj.displayWidth / obj.displayHeight;
                                var imageProp = cW / cH;

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
                                marginTop:(obj.canvasHeight - $(this).height()) / 2 + 'px',
                                marginLeft:(obj.canvasWidth - $(this).width()) / 2 + 'px'})
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
                marginTop:((this.displayHeight - $('#' + this.preloaderIdentifier).height()) / 2) + 'px',
                marginLeft:((this.displayWidth - $('#' + this.preloaderIdentifier).width()) / 2) + 'px'
            }).show();
        },

        /**
         * Hide generic preloader
         */
        hidePreloader: function(callback) {
            $('#' + this.preloaderIdentifier).hide();

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

            this.infoBarIdentifier = this.canvasIdentifier + '_infoBar';
            this.imageIdentifier = this.canvasIdentifier + '_template_img';
            this.oldImageIdentifier = this.canvasIdentifier + '_template_img_old';
            this.controlBarIdentifier = this.canvasIdentifier + '_controlBar';
            this.shadowBgCanvas = this.canvasIdentifier + '_shadowBgCanvas';
            this.imgContainer = this.canvasIdentifier + '_imgContainer';

            this.inCanvas = false;
            this.controlBarFocused = false;
            this.oldImage = this.currentImage;
            this.firstLoad = true;
            clearTimeout(this.slideTimeout);

            if (this.loadControls(callStack)) {
                this.startSlideShow(callStack);
            }
        },

        /**
         * Control bar visibility controler
         */
        cbControl: function() {
            if (this.controlBarVisible) {
                this.controlBarVisible = false;
                $('#' + this.controlBarIdentifier).stop(true, true);
                $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, true);
                this.rollDownCB();
            } else {
                this.controlBarVisible = true;
                $('#' + this.controlBarIdentifier).stop(true, true);
                $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, true);
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
        exitControl: function() {
            window.location = this.backButtonURL;
        },

        /**
         * caption button control
         */
        captionControl: function() {
            this.captionVisible = !this.captionVisible;
            if (this.captionVisible) {
                this.showCaption('normal');
            } else {
                this.hideCaption('normal');
            }
        },

        /**
         * Play/Pause button control
         */
        ppControl: function(callStack) {
            if (this.autoSlideShow) {
                this.pauseControl(callStack);
            } else {
                this.playControl(callStack);
            }
            if (this.autoSlideShow) {
                var pp_pos = '44px 0px';
            } else {
                var pp_pos = '0px 0px';
            }
            $('#' + this.controlBarIdentifier + '_ctrl4').css({
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
            this.slideTimeout = setTimeout('window.' + this.canvasIdentifier + '.nextImage()',
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
        screenControl: function() {
            if (this.fullScreenMode) {
                this.normalScreenControl();
            } else {
                this.fullScreenControl();
            }
            if (this.fullScreenMode) {
                var screen_pos = '21px 0px';
            } else {
                var screen_pos = '0px 0px';
            }
            $('#' + this.controlBarIdentifier + '_ctrl6').css({
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

        calculateImageMaxSize: function() {
            this.imgMaxWidth = Math.floor(this.displayWidth * 0.9 - 2 * this.borderSize);
            this.imgMaxHeight = Math.floor((this.displayHeight - (this.cbHeight + 46)) * 0.9 - 2 * this.borderSize);
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
            this.cbML = Math.floor((this.displayWidth - this.cbWidth) / 2);
            this.cbMT = this.displayHeight - this.cbHeight;

            // generate images array
            this.images = [];
            for (var i = 0, j = 0; i < this.xml.items.item.length; i++) {
                if (typeof this.xml.items.item[i].largeImagePath != 'undefined'
                        && this.xml.items.item[i].largeImagePath != '') {
                    this.images[j] = {};
                    this.images[j].largeImagePath = this.xml.items.item[i].largeImagePath;
                    if (typeof this.xml.items.item[i].fullScreenImagePath != 'undefined' &&
                            this.xml.items.item[i].fullScreenImagePath.length > 0) {
                        this.images[j].fullScreenImagePath = this.xml.items.item[i].fullScreenImagePath;
                    } else {
                        this.images[j].fullScreenImagePath = this.xml.items.item[i].largeImagePath;
                    }
                    if (typeof this.xml.items.item[i].description != 'undefined') {
                        this.images[j].description = this.xml.items.item[i].description.replace(/\r\n/g, '<br />').replace(/\n/g, '<br />').replace(/\r/g, '<br />');
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

            this.sbg1 = $('<div />').attr('id', this.shadowBgCanvas + '1')
                    .css({
                             position: 'absolute',
                             height: this.displayHeight,
                             minHeight: this.displayHeight,
                             width: this.displayWidth,
                             minWidth: this.displayWidth,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.canvasIdentifier);
            this.sbg2 = $('<div />').attr('id', this.shadowBgCanvas + '2')
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
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.imgContainer + '1')
                    .css({
                             position: 'absolute',
                             marginLeft:this.displayWidth,
                             border: this.borderSize + 'px solid ' + this.borderColor,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '1');

            $('<div />').attr('id', this.imgContainer + '2')
                    .css({
                             position: 'absolute',
                             marginLeft:this.displayWidth,
                             border: this.borderSize + 'px solid ' + this.borderColor,
                             zIndex:9,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '2');

            if (localScope.shadowDistance != 0) {
                $('<div />').attr('id', this.imgContainer + '1')
                        .css({
                                 '-moz-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 '-webkit-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 'box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)'
                             });
                $('<div />').attr('id', this.imgContainer + '2')
                        .css({
                                 '-moz-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 '-webkit-box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)',
                                 'box-shadow': '0 0 ' + localScope.shadowDistance + 'px rgba(256,256,256,1)'
                             });
            }

            //caption
            $('<div />').attr('id', this.infoBarIdentifier + '1').hide()
                    .css({
                             zIndex:12,
                             position:'absolute'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '1');
            $('<div />').attr('id', this.infoBarIdentifier + '1_bg')
                    .css({
                             position:'absolute',
                             zIndex:12,
                             backgroundColor:'#000000',
                             opacity:0.5
                         })
                    .appendTo('#' + this.infoBarIdentifier + '1');
            $('<div />').attr('id', this.infoBarIdentifier + '1_iDescription')
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
                    .appendTo('#' + this.infoBarIdentifier + '1');

            //caption 2
            $('<div />').attr('id', this.infoBarIdentifier + '2').hide()
                    .css({
                             zIndex:12,
                             position:'absolute'
                         })
                    .appendTo('#' + this.shadowBgCanvas + '2');
            $('<div />').attr('id', this.infoBarIdentifier + '2_bg')
                    .css({
                             position:'absolute',
                             zIndex:12,
                             backgroundColor:'#000000',
                             opacity:0.5
                         })
                    .appendTo('#' + this.infoBarIdentifier + '2');
            $('<div />').attr('id', this.infoBarIdentifier + '2_iDescription')
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
                    .appendTo('#' + this.infoBarIdentifier + '2');

            // gesture for touchscreen
            $('#' + localScope.canvasIdentifier).touchwipe({
                wipeLeft: function() {
                    localScope.nextControl();
                },
                wipeRight: function() {
                    localScope.prevControl();
                }
            });

            //control bar
            $('<div />').attr('id', this.controlBarIdentifier).hide()
                    .css({
                             position: 'absolute',
                             height: this.cbHeight,
                             width: this.cbWidth,
                             marginTop:this.cbMT,
                             marginLeft:this.cbML,
                             zIndex:12,
                             overflow:'hidden'
                         })
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.controlBarIdentifier + '_bg')
                    .css({
                             position:'absolute',
                             height:this.cbHeight,
                             width: this.cbWidth,
                             background:'url("' + this.iconsURL + 'cb.png")',
                             zIndex:13
                         })
                    .hover(function() {
                localScope.controlBarFocused = true;
            }, function() {
                localScope.controlBarFocused = false;
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //control bar up/down button
            var updownML = this.cbML + Math.floor((this.cbWidth - 46) / 2);

            if (this.controlBarState == 'opened') {
                this.controlBarVisible = true;
            } else if (this.controlBarState == 'closed') {
                this.controlBarVisible = false;
            }

            if (this.controlBarVisible) {
                var updownMT = this.cbMT;
                var bg_position = '46px 0px';
            } else {
                var updownMT = this.displayHeight - 12;
                var bg_position = '0px 0px';
            }

            $('<div />').attr('id', this.controlBarIdentifier + '_updown_bt')
                    .appendTo('#' + this.canvasIdentifier)
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
                    .bind('click', function() {
                localScope.cbControl()
            })
                    .hover(function() {
                localScope.controlBarFocused = true;
                $(this).css({
                    opacity:0.8
                });
            }, function() {
                localScope.controlBarFocused = false;
                $(this).css({
                    opacity:1
                });
            });

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'15px',
                             marginLeft:'15px',
                             height:31,
                             minHeight:31,
                             zIndex:20
                         })
                    .bind('click', function() {
                localScope.exitControl()
            })
                    .mouseover(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -31px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px 0px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px 0px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = false;
            })
                    .mousedown(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -62px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -62px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -62px'
                });
            })
                    .mouseup(function() {
                $('#' + localScope.controlBarIdentifier + '_ctrl1_left').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_text').css({
                    backgroundPosition:'0px -31px'
                });
                $('#' + localScope.controlBarIdentifier + '_ctrl1_right').css({
                    backgroundPosition:'0px -31px'
                });
            })
                    .appendTo('#' + this.canvasIdentifier);

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1_left')
                    .css({
                             position:'absolute',
                             height:'31px',
                             width:'15px',
                             cursor:'pointer',
                             background:'url("' + this.iconsURL + 'exit_left.png")',
                             backgroundPosition:'0px 0px',
                             zIndex: 21
                         })
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            $('<span />').attr('id', this.controlBarIdentifier + '_ctrl1_text')
                    .css({
                             position:'absolute',
                             height:'24px',
                             paddingTop: '7px',
                             paddingRight:'1px',
                             marginLeft:'14px',
                             cursor:'pointer',
                             fontSize:14,
                             fontFamily:'Arial',
                             //lineHeight:'29px',
                             fontWeight:'bold',
                             color:'#333333',
                             background:'url("' + this.iconsURL + 'exit_mid.png")',
                             backgroundPosition:'0px 0px',
                             whiteSpace:'nowrap',
                             zIndex: 21
                         })
                    .html(localScope.backButtonLabel)
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl1_right')
                    .css({
                             position:'absolute',
                             height:'31px',
                             width:'8px',
                             cursor:'pointer',
                             background:'url("' + this.iconsURL + 'exit_right.png")',
                             backgroundPosition:'0px 0px',
                             zIndex: 21
                         })
                    .bind('click', function() {
                localScope.exitControl();
            })
                    .appendTo('#' + this.controlBarIdentifier + '_ctrl1');

            //left + mid + right .... mid+right = 23
            var exit_width = parseInt($('#' + localScope.controlBarIdentifier + '_ctrl1_text')[0].offsetWidth) + 23;

            $('#' + this.controlBarIdentifier + '_ctrl1').css({
                width: exit_width,
                minWidth: exit_width
            });
            $('#' + this.controlBarIdentifier + '_ctrl1_right').css({
                marginLeft:exit_width - 10
            });

            //caption button
            if (this.captionVisible) {
                var capt_pos = '0px -44px';
            } else {
                var capt_pos = '0px 0px';
            }

            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl2')
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
                    .bind('click', function() {
                localScope.captionControl(callStack);
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -22px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                if (localScope.captionVisible) {
                    var capt_pos = '0px -44px';
                } else {
                    var capt_pos = '0px 0px';
                }
                $(this).css({
                    backgroundPosition:capt_pos
                });
                localScope.controlBarFocused = false;
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //prev and next button
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl3')
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
                    .bind('click', function() {
                localScope.prevControl(callStack);
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -32px'
                });
            })
                    .mouseup(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl5')
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
                    .bind('click', function() {
                localScope.nextControl();
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -32px'
                });
            })
                    .mouseup(function() {
                $(this).css({
                    backgroundPosition:'0px -16px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //play and pause button
            if (this.autoSlideShow) {
                var pp_pos = '44px 0px';
            } else {
                var pp_pos = '0px 0px';
            }
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl4')
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
                    .bind('click', function() {
                localScope.ppControl(callStack);
            })
                    .mouseover(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px -44px';
                } else {
                    var pp_pos = '0px -44px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px 0px';
                } else {
                    var pp_pos = '0px 0px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                if (localScope.autoSlideShow) {
                    var pp_pos = '44px -88px';
                } else {
                    var pp_pos = '0px -88px';
                }
                $(this).css({
                    backgroundPosition:pp_pos
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            //full/normal screen
            $('<div />').attr('id', this.controlBarIdentifier + '_ctrl6')
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             marginTop:'33px',
                             marginLeft:'218px',
                             width:20,
                             minWidth:20,
                             height:20,
                             minHeight:20,
                             background:'url("' + this.iconsURL + 'close.png")',
                             backgroundPosition:'0px 0px',
                             zIndex:15
                         })
                    .bind('click', function() {
                localScope.exitControl()
            })
                    .mouseover(function() {
                $(this).css({
                    backgroundPosition:'0px -20px'
                });
                localScope.controlBarFocused = true;
            })
                    .mouseout(function() {
                $(this).css({
                    backgroundPosition:'0px 0px'
                });
                localScope.controlBarFocused = true;
            })
                    .mousedown(function() {
                $(this).css({
                    backgroundPosition:'0px -40px'
                });
            })
                    .appendTo('#' + this.controlBarIdentifier);

            this.showControlBar(instanceNO, callStack);

            this.canvasOffs = $('#' + this.canvasIdentifier).offset();

            $(document).keydown(function(e) {
                if (localScope.isFrozen() ||
                        instanceNO != localScope.instanceNO ||
                        callStack != localScope.callStack) {
                    return;
                }
                var KeyID = (window.event) ? event.keyCode : e.keyCode;
                switch (KeyID) {
                    case 32:
                        localScope.ppControl(callStack);
                        break;
                    case 37:
                        localScope.prevControl();
                        break;
                    case 39:
                        localScope.nextControl();
                        break;
                }
            });

            $(document).mousemove(function(e) {
                if (localScope.isFrozen() ||
                        instanceNO != localScope.instanceNO ||
                        callStack != localScope.callStack) {
                    return;
                }
                if (localScope.autoHideControls) {
                    if (( e.pageX < localScope.canvasOffs.left ) || ( e.pageY < localScope.canvasOffs.top ) || ( e.pageX > localScope.canvasOffs.left + localScope.canvasWidth ) || ( e.pageY > localScope.canvasOffs.top + localScope.canvasHeight )) {
                        if (localScope.inCanvas) {
                            localScope.autoHideControlBar();
                            localScope.inCanvas = false;
                        }
                    } else {
                        localScope.inCanvas = true;
                        clearTimeout(localScope.autohidetimerID);
                        if (!localScope.controlBarFocused) {
                            localScope.autohidetimerID = setTimeout('window.' + localScope.canvasIdentifier + '.autoHideControlBar()', localScope.controlsHideSpeed);
                        }
                    }
                }
            });

            $(window).resize(function() {
                if (localScope.fullScreenMode == true) {
                    window.clearTimeout(localScope.resizeTimeout);
                    localScope.resizeTimeout = window.setTimeout(
                            'window.' + localScope.canvasIdentifier + '.showFullScreen()', 100);
                }
            });
            return true;
        },

        /**
         * Auto hide control bar
         */
        autoHideControlBar : function () {
            this.controlBarVisible = false;
            $('#' + this.controlBarIdentifier).stop(true, false);
            $('#' + this.controlBarIdentifier + '_updown_bt').stop(true, false);
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
            this.showCurrentImage(this.instanceNo, callStack);
        },

        /**
         * Image preloader
         */
        preLoadImage: function(id, callback, fullscreenmode) {
            if (this.isFrozen()) {
                return;
            }
            if (this.fullScreenMode == true) {
                if (this.images[id].error1 == 1) {
                    this.images[id].src = this.images[id]['largeImagePath'];
                } else {
                    this.images[id].src = this.images[id]['fullScreenImagePath'];
                }
            } else {
                this.images[id].src = this.images[id]['largeImagePath'];
            }
            this.images[id].cacheImage = document.createElement('img');

            var localScope = this;

            $(this.images[id].cacheImage).load(
                    function () {
                        $(this).unbind('load');
                        localScope.images[this.lang]['loaded'] = 1;
                        if (typeof callback != 'undefined' && !localScope.isFrozen()) {
                            eval(callback);
                        }
                    }).error(function () {
                if (localScope.images[id].src != localScope.images[id].largeImagePath) {
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

        resizeCurrentImage: function() {
            if (this.loadOriginalImages) {
                return;
            }
            if (this.images[this.currentImage].error == 1) return;

            if (this.isIE()) {
                var cH = $(this.images[this.currentImage].cacheImage).height();
                var cW = $(this.images[this.currentImage].cacheImage).width();
            } else {
                var cH = $(this.images[this.currentImage].cacheImage).attr('height');
                var cW = $(this.images[this.currentImage].cacheImage).attr('width');
            }
            if (cH <= this.imgMaxHeight && cW <= this.imgMaxWidth) return;
            var canvasProp = this.imgMaxWidth / this.imgMaxHeight;
            var imageProp = cW / cH;

            var perc = 0;

            switch (this.scaleMode) {
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
                this.preLoadImage(this.currentImage, 'window.' + this.canvasIdentifier + '.showCurrentImage(' + instanceNO + ', ' + callStack + ')');
                return;
            }
            this.hidePreloader();
            if (this.firstLoad) {
                this.preloadA();
                this.preloadB();
            } else {
                if (this.preload == 'after') {
                    this.preloadA();
                }
                if (this.preload == 'before') {
                    this.preloadB();
                }
            }

            if (this.oldImage != this.currentImage) {
                if (this.captionCounter == 1) {
                    var prev_caption_nr = 2;
                } else {
                    var prev_caption_nr = 1;
                }
            } else {
                var prev_caption_nr = this.captionCounter;
            }

            if (this.oldImage != this.currentImage) {
                $(this.images[this.oldImage].cacheImage).attr('id', this.oldImageIdentifier)
                        .appendTo('#' + this.imgContainer + this.captionCounter)
                        .css({
                                 position:'absolute',
                                 zIndex:10
                             });
                var oic_h = $('#' + this.oldImageIdentifier).height();
                var oic_mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - (oic_h + 2 * this.borderSize)) / 2) + 46;
                var oic_w = $('#' + this.oldImageIdentifier).width();
                var oic_ml = Math.floor((this.displayWidth - (oic_w + 2 * this.borderSize)) / 2);
                $('#' + this.imgContainer + this.captionCounter)
                        .css({
                                 width:oic_w,
                                 height:oic_h,
                                 marginTop:oic_mt,
                                 marginLeft:oic_ml
                             });
                var oi_mt = Math.floor((oic_h - $('#' + this.oldImageIdentifier).height()) / 2);
                var oi_ml = Math.floor((oic_w - $('#' + this.oldImageIdentifier).width()) / 2);
                $('#' + this.oldImageIdentifier)
                        .css({
                                 marginTop:oi_mt,
                                 marginLeft:oi_ml
                             });
            }

            $('#' + this.shadowBgCanvas + prev_caption_nr).css({
                marginLeft:0
            });
            var localScope = this;
            $(this.images[this.currentImage].cacheImage).hide()
                    .appendTo('#' + this.imgContainer + prev_caption_nr)
                    .attr('id', this.imageIdentifier)
                    .css({
                             position:'absolute',
                             cursor:'pointer',
                             zIndex:10
                         })
                    .bind('click', function() {
                localScope.nextControl()
            });

            this.resizeCurrentImage();

            var ic_h = $('#' + this.imageIdentifier).height();
            var ic_mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - (ic_h + 2 * this.borderSize)) / 2) + 46;
            var ic_w = $('#' + this.imageIdentifier).width();
            var ic_ml = Math.floor((this.displayWidth - (ic_w + 2 * this.borderSize)) / 2);
            $('#' + this.imgContainer + prev_caption_nr)
                    .css({
                             width:ic_w,
                             height:ic_h,
                             marginTop:ic_mt,
                             marginLeft:ic_ml
                         });

            var i_mt = Math.floor((ic_h - $('#' + this.imageIdentifier).height()) / 2);
            var i_ml = Math.floor((ic_w - $('#' + this.imageIdentifier).width()) / 2);
            $('#' + this.imageIdentifier)
                    .css({
                             marginTop:i_mt + 'px',
                             marginLeft:i_ml + 'px'
                         });
            this.imageTransition();
        },

        /**
         * Hide caption
         */
        hideCaption : function() {
            //hide caption
            $('#' + this.infoBarIdentifier + this.captionCounter).fadeOut('normal');
        },

        /**
         * Show caption
         */
        showCaption : function (t_speed) {
            this.actualizeCaption();
            $('#' + this.infoBarIdentifier + this.captionCounter).fadeIn(t_speed);
        },

        /**
         * Actualize caption
         */
        actualizeCaption: function() {
            var ciH = parseInt($('#' + this.imgContainer + this.captionCounter).css('height'));
            var ciW = parseInt($('#' + this.imgContainer + this.captionCounter).css('width'));
            var mt = Math.floor(((this.displayHeight - (this.cbHeight + 46)) - ciH) / 2) + 46;
            var ml = Math.floor((this.displayWidth - ciW) / 2);
            $('#' + this.infoBarIdentifier + this.captionCounter + '_iDescription')
                    .css({width:((ciW) - 10)})
                    .html(this.images[this.currentImage].description);

            $('#' + this.infoBarIdentifier + this.captionCounter).show();
            var descH = $('#' + this.infoBarIdentifier + this.captionCounter + '_iDescription').height();
            $('#' + this.infoBarIdentifier + this.captionCounter).hide();
            if (descH > 0) {
                descH += 8;
            }

            if (descH >= (this.imgMaxHeight - 23))
                return;

            $('#' + this.infoBarIdentifier + this.captionCounter + '_bg')
                    .css({
                             width: ciW + 'px',
                             height: descH + 'px'
                         });

            $('#' + this.infoBarIdentifier + this.captionCounter)
                    .css({
                             width: ciW + 'px',
                             height:descH + 'px',
                             marginTop: (ciH - descH) + mt,
                             marginLeft: ml
                         });
        },

        /**
         * Image transition
         */
        imageTransition: function() {
            var localScope = this;
            if (this.transitionType == 'fade') {
                if (this.firstLoad) {
                    $('#' + this.imageIdentifier)
                            .show();
                    this.actualizeCaption();
                    if (this.captionVisible) {
                        $('#' + this.infoBarIdentifier + this.captionCounter).show();
                    }
                    this.firstLoad = false;
                    this.onTransitionComplete();
                } else {
                    if (this.oldImage != this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)) {
                        $('#' + this.shadowBgCanvas + this.captionCounter).fadeOut(this.transitionSpeed, function() {
                            $(this).css({marginLeft:localScope.displayWidth}).show();
                            $('#' + localScope.oldImageIdentifier).unbind().hide();
                            $('#' + localScope.oldImageIdentifier).remove();
                        });
                    }
                    $('#' + this.imageIdentifier)
                            .css({
                                     opacity:1
                                 })
                            .hide().show();
                    this.actualizeCounter();
                    this.actualizeCaption();
                    if (this.captionVisible) {
                        this.showCaption(this.transitionSpeed);
                    }
                    $('#' + this.shadowBgCanvas + this.captionCounter)
                            .css({marginLeft:0});

                    $('#' + this.imgContainer + this.captionCounter).css({opacity:0}).animate({opacity:1}, localScope.transitionSpeed, function() {
                        localScope.onTransitionComplete();
                    });
                    $('#' + this.shadowBgCanvas + this.captionCounter + ' canvas').css({opacity:0}).animate({opacity:1}, this.transitionSpeed);
                }
            } else {
                if (this.transitionType == 'slide') {
                    if (this.firstLoad) {
                        $('#' + this.imageIdentifier)
                                .show();
                        this.actualizeCaption();
                        if (this.captionVisible) {
                            $('#' + this.infoBarIdentifier + this.captionCounter).show();
                        }
                        this.firstLoad = false;
                        this.onTransitionComplete();

                    } else {
                        if (this.oldImage != this.currentImage && (this.images[this.oldImage].loaded == 1 || this.images[this.oldImage].error == 1)) {
                            var sbg_ml = 0;
                            if (this.nextSlide) {
                                sbg_ml -= this.displayWidth;
                            } else {
                                sbg_ml += this.displayWidth;
                            }

                            $('#' + this.shadowBgCanvas + this.captionCounter).animate({
                                marginLeft:sbg_ml
                            }, localScope.transitionSpeed, function() {
                                $('#' + localScope.oldImageIdentifier).unbind().hide();
                                $('#' + localScope.oldImageIdentifier).remove();
                            });
                        }

                        $('#' + this.imageIdentifier).show();

                        this.actualizeCounter();
                        this.actualizeCaption();
                        if (this.captionVisible) {
                            $('#' + this.infoBarIdentifier + this.captionCounter).show();
                        }

                        if (this.nextSlide) {
                            var sbg_ml = this.displayWidth;
                        } else {
                            var sbg_ml = -1 * this.displayWidth;
                        }
                        $('#' + this.shadowBgCanvas + this.captionCounter)
                                .css({marginLeft:sbg_ml})
                                .animate({marginLeft:0}, this.transitionSpeed, function() {
                            localScope.onTransitionComplete();
                        });
                    }
                }
            }
        },

        /**
         * Transition complete callback
         */
        onTransitionComplete: function() {
            this.setBusyFlagOff();

            if (this.autoSlideShow == true) {
                this.slideTimeout = setTimeout('window.' + this.canvasIdentifier + '.nextImage()',
                        this.slideShowSpeed);
                this.timeoutResources.push(this.slideTimeout);
            }
        },

        /**
         * Actualize counter
         */
        actualizeCounter: function() {
            if (this.captionCounter == 2) {
                this.captionCounter = 1;
            } else {
                this.captionCounter = 2;
            }
        },

        /**
         * Show control bar
         */
        showControlBar: function(instanceNO, callStack) {
            if (this.isFrozen()) {
                return;
            }
            if (instanceNO != this.instanceNO || callStack != this.callStack) {
                return;
            }

            if (!this.controlBarVisible) {
                $('#' + this.controlBarIdentifier)
                        .css({marginTop:this.displayHeight - 12});
                $('#' + this.controlBarIdentifier + '_ctrl1').hide();
            }

            $('#' + this.controlBarIdentifier).show();
        },

        /**
         * check if busy flag is on
         */
        isBusy: function() {
            return this.flagBusy == true;
        },

        /**
         * Set busy flag off
         */
        setBusyFlagOff: function() {
            this.flagBusy = false;
        },

        /**
         * Set busy flag on
         */
        setBusyFlagOn: function() {
            this.flagBusy = true;
        },

        /**
         * Roll down control bar
         */
        rollDownCB: function() {
            $('#' + this.controlBarIdentifier)
                    .animate({marginTop:this.displayHeight - 12}, 300);
            $('#' + this.controlBarIdentifier + '_updown_bt')
                    .css({
                             backgroundPosition:'0px 0px'
                         })
                    .animate({marginTop:this.displayHeight - 12}, 300);
            $('#' + this.controlBarIdentifier + '_ctrl1').fadeOut('300');
        },

        /**
         * Roll up control bar
         */
        rollUpCB: function() {
            $('#' + this.controlBarIdentifier)
                    .animate({marginTop:this.cbMT}, 300);
            $('#' + this.controlBarIdentifier + '_updown_bt')
                    .css({
                             backgroundPosition:'46px 0px'
                         })
                    .animate({marginTop:this.cbMT}, 300);
            $('#' + this.controlBarIdentifier + '_ctrl1').fadeIn('300');
        },

        preloadA: function() {
            for (var i = 1; i <= this.preloadAfter; i++) {
                if (this.currentImage + i <= this.images.length - 1) {
                    var c_id = this.currentImage + i;
                } else {
                    var c_id = (this.currentImage + i) - this.images.length;
                }
                if (this.images[c_id].loaded != 1 && this.images[c_id].error != 1) {
                    this.preLoadImage(c_id);
                }
            }
        },

        preloadB: function() {
            for (var i = 1; i <= this.preloadBefore; i++) {
                if (this.currentImage - i >= 0) {
                    var c_id = this.currentImage - i;
                } else {
                    var c_id = this.images.length + (this.currentImage - i)
                }
                if (this.images[c_id].loaded != 1 && this.images[c_id].error != 1) {
                    this.preLoadImage(c_id);
                }
            }
        },

        /**
         * Show next image
         */
        nextImage: function() {
            if (this.isBusy() || this.isFrozen()) {
                return;
            }
            this.setBusyFlagOn();
            this.oldImage = this.currentImage;
            if (this.currentImage < this.images.length - 1) {
                this.currentImage++;
            } else {
                this.currentImage = 0;
            }
            this.nextSlide = true;
            this.preload = 'after';
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
                this.currentImage = this.images.length - 1;
            }
            this.nextSlide = false;
            this.preload = 'before';
            this.showCurrentImage();
        }
    };

})(jQuery);
