/*******************************************************************************
 * This notice must be untouched at all times.
 * 
 * CSS Sandpaper: smooths out differences between CSS implementations.
 * 
 * This javascript library contains routines to implement the CSS transform,
 * box-shadow and gradient in IE.  It also provides a common syntax for other
 * browsers that support vendor-specific methods.
 * 
 * Written by: Zoltan Hawryluk. Version 1.0 beta 1 completed on March 8, 2010.
 * 
 * Some routines are based on code from CSS Gradients via Canvas v1.2 
 * by Weston Ruter <http://weston.ruter.net/projects/css-gradients-via-canvas/>
 * 
 * Requires sylvester.js by James Coglan http://sylvester.jcoglan.com/  
 *
 * cssSandpaper.js v.1.0 beta 1 available at http://www.useragentman.com/
 * 
 * released under the MIT License: 
 *   http://www.opensource.org/licenses/mit-license.php
 * 
 ******************************************************************************/


if (!document.querySelectorAll) {
    document.querySelectorAll = cssQuery;
}


var cssSandpaper = new function(){
    var me = this;
    
    var styleNodes, styleSheets = new Array();
    
    var ruleSetRe = /[^\{]*{[^\}]*}/g;
    var ruleSplitRe = /[\{\}]/g;
    
    var reGradient = /gradient\([\s\S]*\)/g;
    
    // This regexp from the article 
    http://james.padolsey.com/javascript/javascript-comment-removal-revisted/
 	var reMultiLineComment = /\/\/.+?(?=\n|\r|$)|\/\*[\s\S]+?\*\//g;
	
	var reAtRule = /@[^\{\};]*;|@[^\{\};]*\{[^\}]*\}/g;
    
	var reFunctionSpaces = /\(\s*/g
    
    
    var ruleLists = new Array();
    var styleNode;
    
    var tempObj;
    var body;
    
    me.init = function(){
        if (EventHelpers.hasPageLoadHappened(arguments)) {
            return;
        }
        body = document.body;
        
        tempObj = document.createElement('div');
        
        getStyleSheets();
        
        indexRules();
        
        
        fixTransforms();
        fixBoxShadow();
		 
        fixLinearGradients();
		
        
        //fixBorderRadius();
    
    }
    
    function fixTransforms(){
    
        var transformRules = getRuleList('-sand-transform').values;
        var property = CSS3Helpers.findTransformProperty(document.body);
        
       
        for (var i in transformRules) {
            var rule = transformRules[i];
            var nodes = document.querySelectorAll(rule.selector);
            if (property=="filter") {
            
                var matrix = CSS3Helpers.getTransformationMatrix(rule.value);
               
                for (var j = 0; j < nodes.length; j++) {
					
                    CSS3Helpers.setMatrixFilter(nodes[j], matrix)
					
                }
            } else if (tempObj.style[property] != null) {
                for (var j = 0; j < nodes.length; j++) {
					// Opera doesn't like spaces before numbers in functions ... 
					// removing. 
					//alert(rule.value.replace(reFunctionSpaces, '('))
                    nodes[j].style[property] = rule.value;
                }
            } 
        }
       
    }
    
    function fixBoxShadow(){
    
        var transformRules = getRuleList('-sand-box-shadow').values;
        
        //var matrices = new Array();
        
        
        for (var i in transformRules) {
            var rule = transformRules[i];
            
            var nodes = document.querySelectorAll(rule.selector);
            
            var values = CSS3Helpers.getBoxShadowValues(rule.value)
            
            
            if (document.body.filters) {
            
            
                for (var j = 0; j < nodes.length; j++) {
                
                    CSS3Helpers.addFilter(nodes[j], 
						'DXImageTransform.Microsoft.DropShadow', 
						StringHelpers.sprintf("color=%s,offX=%d,offY=%d", values.color, values.offsetX, values.offsetY));
                    
                    
                }
            } else if (tempObj.style.MozBoxShadow != null) {
                for (var j = 0; j < nodes.length; j++) {
                    nodes[j].style.MozBoxShadow = rule.value;
                }
            } else if (tempObj.style.WebkitTransform != null) {
                for (var j = 0; j < nodes.length; j++) {
                    nodes[j].style.WebkitBoxShadow = rule.value;
                }
            }
        }
        
    }
    
    function fixLinearGradients(){
    
        var backgroundRules = getRuleList('background').values.concat(getRuleList('background-image').values);
        //var matrices = new Array();
        var support = CSS3Helpers.reportGradientSupport();
        for (var i in backgroundRules) {
        
            var rule = backgroundRules[i];
            
            
                var nodes = document.querySelectorAll(rule.selector);
                
                var values = CSS3Helpers.getGradient(rule.value);
                
                if (values != null) {
                
                    for (var j = 0; j < nodes.length; j++) {
                        var node = nodes[j];
                        if (document.body.filters) {
                        	
                            if (values.colorStops.length == 2 &&
                            values.colorStops[0].stop == 0.0 &&
                            values.colorStops[1].stop == 1.0) {
                            
                                CSS3Helpers.addFilter(node, 'DXImageTransform.Microsoft.Gradient', StringHelpers.sprintf("GradientType = %s, StartColorStr = '%s', EndColorStr = '%s'", values.IEdir, values.colorStops[0].color, values.colorStops[1].color));
                                
                            }
                        } else if (support == implementation.MOZILLA) {
                        
                            node.style.backgroundImage = StringHelpers.sprintf('-moz-gradient( %s, %s, from(%s), to(%s))', values.dirBegin, values.dirEnd, values.colorStops[0].color, values.colorStops[1].color);
                        } else if (support == implementation.WEBKIT) {
                        
                            var tmp = StringHelpers.sprintf('-webkit-gradient(%s, %s, %s %s, %s %s)', values.type, values.dirBegin, values.r0 ? values.r0 + ", " : "", values.dirEnd, values.r1 ? values.r1 + ", " : "", listColorStops(values.colorStops));
                            
                            node.style.backgroundImage = tmp;
                        } else if (support == implementation.WORKAROUND) {
                        
                        
                            try {
                                CSS3Helpers.applyCanvasGradient(node, values);
                            } 
                            catch (ex) {
								// do nothing (for now).
                            }
                            
                        }
                    }
                }
            
            
            
        }
    }
    
    function listColorStops(colorStops){
        var sb = new StringBuffer();
        
        for (var i = 0; i < colorStops.length; i++) {
            sb.append(StringHelpers.sprintf("color-stop(%s, %s)", colorStops[i].stop, colorStops[i].color));
            if (i < colorStops.length - 1) {
                sb.append(', ');
            }
        }
        
        return sb.toString();
    }
    
    
    function getStyleSheet(node){
        var sheetCssText;
        switch (node.nodeName.toLowerCase()) {
            case 'style':
                sheetCssText = StringHelpers.uncommentHTML(node.innerHTML); //does not work with inline styles because IE doesn't allow you to get the text content of a STYLE element
                
                break;
            case 'link':
                var xhr = XMLHelpers.getXMLHttpRequest(node.href, null, "GET", null, false);
                sheetCssText = xhr.responseText;
                
                break;
        }
        
        sheetCssText = sheetCssText.replace(reMultiLineComment, '').replace(reAtRule, '');
        
        return sheetCssText;
    }
    
    function getStyleSheets(){
		 
        styleNodes = document.querySelectorAll('style, link');
        
        for (var i = 0; i < styleNodes.length; i++) {
            styleSheets.push(getStyleSheet(styleNodes[i]))
        }
    }
    
    function indexRules(){
    
        for (var i = 0; i < styleSheets.length; i++) {
            var sheet = styleSheets[i];
            
            rules = sheet.match(ruleSetRe);
            
            for (var j = 0; j < rules.length; j++) {
                var parsedRule = rules[j].split(ruleSplitRe);
                var selector = parsedRule[0].trim();
                var propertiesStr = parsedRule[1];
                var properties = propertiesStr.split(';');
                for (var k = 0; k < properties.length; k++) {
                    if (properties[k].trim() != '') {
                        var splitProperty = properties[k].split(':')
                        var name = splitProperty[0].trim().toLowerCase();
                        var value = splitProperty[1];
                        if (!ruleLists[name]) {
                            ruleLists[name] = new RuleList(name);
                        }
                        
                        if (value) {
                            ruleLists[name].add(selector, value.trim());
                        }
                    }
                }
            }
        }
		
    }
    
    function getRuleList(name){
        var list = ruleLists[name];
        if (!list) {
            list = new RuleList(name);
        }
        return list;
    }
    
    
}

function RuleList(propertyName){
    var me = this;
    me.values = new Array();
    me.propertyName = propertyName;
    me.add = function(selector, value){
        me.values.push(new CSSRule(selector, me.propertyName, value));
    }
}

function CSSRule(selector, name, value){
    var me = this;
    me.selector = selector;
    me.name = name;
    me.value = value;
    
    me.toString = function(){
        return StringHelpers.sprintf("%s { %s: %s}", me.selector, me.name, me.value);
    }
}

var MatrixGenerator = new function(){
    var me = this;
    var reUnit = /[a-z]+$/;
    me.identity = $M([[1, 0], [0, 1]]);
    
    
    function degreesToRadians(degrees){
        return (degrees - 360) * Math.PI / 180;
    }
    
    function getRadianScalar(angleStr){
        var num = parseFloat(angleStr);
        var unit = angleStr.match(reUnit);
        
        if (unit.length != 1 || num == 0) {
            return 0;
        }
		
        
        unit = unit[0];
        
        
        var rad;
        switch (unit) {
            case "deg":
                rad = degreesToRadians(num);
                break;
            case "rad":
                rad = num;
                break;
            default:
                return me.identity;
        }
        return rad;
    }
    
    me.rotate = function(angleStr){
        var num = getRadianScalar(angleStr);
        return Matrix.Rotation(num);
    }
    
    me.scale = function(sx, sy){
        sx = parseFloat(sx)
        
        if (!sy) {
            sy = sx;
        } else {
            sy = parseFloat(sy)
        }
        
        
        return $M([[sx, 0], [0, sy]]);
    }
    
    me.scaleX = function(sx){
        return me.scale(sx, 1);
    }
    
    me.scaleY = function(sy){
        return me.scale(1, sy);
    }
    
    me.skew = function(ax, ay){
        var xRad = getRadianScalar(ax);
        var yRad;
        
        if (ay != null) {
            yRad = getRadianScalar(ay)
        } else {
			
            yRad = xRad
        }
        return $M([[1, Math.tan(xRad)], [Math.tan(yRad), 1]]);
    }
    
    me.skewX = function(ax){
        return me.skew(ax, 0);
    }
    
    me.skewY = function(ay){
        return me.skew(0, ay);
    }
    
    
    
    me.matrix = function(a, b, c, d, e, f){
    
        // for now, e and f are ignored
        return $M([[a, c], [b, d]])
    }
}

CSS3Helpers = new function(){
    var me = this;
    
    
    var reTransformListSplitter = /[a-z]+\([^\)]*\)\s*/g;
    
    var reLeftBracket = /\(/g;
    var reRightBracket = /\)/g;
    var reComma = /,/g;
    
    var reSpaces = /\s+/g
    
    var reFilterNameSplitter = /progid:([^\(]*)/g;
    
    var reLinearGradient
    
    var canvas;
    
    me.getCanvas = function(){
    
        if (canvas) {
            return canvas;
        } else {
            canvas = document.createElement('canvas');
            return canvas;
        }
    }
    
    me.getTransformationMatrix = function(CSS3TransformProperty){
		
        var transforms = CSS3TransformProperty.match(reTransformListSplitter);
        var resultantMatrix = MatrixGenerator.identity;
        
        for (var j = 0; j < transforms.length; j++) {
        
            var transform = transforms[j];
            transform = transform.replace(reLeftBracket, '("').replace(reComma, '", "').replace(reRightBracket, '")');
            
            
            try {
                var matrix = eval('MatrixGenerator.' + transform);
                resultantMatrix = resultantMatrix.x(matrix);
            } 
            catch (ex) {
                // do nothing;
            }
        }
		
        return resultantMatrix;
        
    }
    
    me.getBoxShadowValues = function(propertyValue){
        var r = new Object();
        
        var values = propertyValue.split(reSpaces);
        
        if (values[0] == 'inset') {
            r.inset = true;
            values = values.reverse().pop().reverse();
        } else {
            r.inset = false;
        }
        
        r.offsetX = parseInt(values[0]);
        r.offsetY = parseInt(values[1]);
        
        if (values.length > 3) {
            r.blurRadius = values[2];
            
            if (values.length > 4) {
                r.spreadRadius = values[3]
            }
        }
        
        r.color = values[values.length - 1];
        
        return r;
    }
    
    me.getGradient = function(propertyValue){
        var r = new Object();
        r.colorStops = new Array();
        
        
        var substring = me.getBracketedSubstring(propertyValue, '-sand-gradient');
        if (substring == undefined) {
            return null;
        }
        var parameters = substring.match(/[^\(,]+(\([^\)]*\))?[^,]*/g); //substring.split(reComma);
        r.type = parameters[0].trim();
        
        if (r.type == 'linear') {
            r.dirBegin = parameters[1].trim();
            r.dirEnd = parameters[2].trim();
            var beginCoord = r.dirBegin.split(reSpaces);
            var endCoord = r.dirEnd.split(reSpaces);
            
            for (var i = 3; i < parameters.length; i++) {
                r.colorStops.push(parseColorStop(parameters[i].trim(), i - 3));
            }
            
            
            
            
            /* The following logic only applies to IE */
            if (document.body.filters) {
                if (r.x0 == r.x1) {
                    /* IE only supports "center top", "center bottom", "top left" and "top right" */
                    
                    switch (beginCoord[1]) {
                        case 'top':
                            r.IEdir = 0;
                            break;
                        case 'bottom':
                            swapIndices(r.colorStops, 0, 1);
                            r.IEdir = 0;
                            /* r.from = parameters[4].trim();
                         r.to = parameters[3].trim(); */
                            break;
                    }
                }
                
                if (r.y0 == r.y1) {
                    switch (beginCoord[0]) {
                        case 'left':
                            r.IEdir = 1;
                            break;
                        case 'right':
                            r.IEdir = 1;
                            swapIndices(r.colorStops, 0, 1);
                            
                            break;
                    }
                }
            }
        } else {
        
            // don't even bother with IE
            if (document.body.filters) {
                return null;
            }
            
            
            r.dirBegin = parameters[1].trim();
            r.r0 = parameters[2].trim();
            
            r.dirEnd = parameters[3].trim();
            r.r1 = parameters[4].trim();
            
            var beginCoord = r.dirBegin.split(reSpaces);
            var endCoord = r.dirEnd.split(reSpaces);
            
            for (var i = 5; i < parameters.length; i++) {
                r.colorStops.push(parseColorStop(parameters[i].trim(), i - 5));
            }
            
        }
        
        
        r.x0 = beginCoord[0];
        r.y0 = beginCoord[1];
        
        r.x1 = endCoord[0];
        r.y1 = endCoord[1];
        
        return r;
    }
    
    function swapIndices(array, index1, index2){
        var tmp = array[index1];
        array[index1] = array[index2];
        array[index2] = tmp;
    }
    
    function parseColorStop(colorStop, index){
        var r = new Object();
        var substring = me.getBracketedSubstring(colorStop, 'color-stop');
        var from = me.getBracketedSubstring(colorStop, 'from');
        var to = me.getBracketedSubstring(colorStop, 'to');
        
        
        if (substring) {
            //color-stop
            var parameters = substring.split(',')
            r.stop = normalizePercentage(parameters[0].trim());
            r.color = parameters[1].trim();
        } else if (from) {
            r.stop = 0.0;
            r.color = from.trim();
        } else if (to) {
            r.stop = 1.0;
            r.color = to.trim();
        } else {
            if (index <= 1) {
                r.color = colorStop;
                if (index == 0) {
                    r.stop = 0.0;
                } else {
                    r.stop = 1.0;
                }
            } else {
                throw (StringHelpers.sprintf('invalid argument "%s"', colorStop));
            }
        }
        return r;
    }
    
    function normalizePercentage(s){
        if (s.substring(s.length - 1, s.length) == '%') {
            return parseFloat(s) / 100 + "";
        } else {
            return s;
        }
        
    }
    
    me.reportGradientSupport = function(){
        var div = document.createElement('div');
        div.style.cssText = "background-image:-webkit-gradient(linear, 0% 0%, 0% 100%, from(red), to(blue));";
        
        if (div.style.backgroundImage) {
            return implementation.WEBKIT;
        }
        
        div.style.cssText = "background-image:-moz-linear-gradient(top left, bottom right, from(red), to(blue));";
        
        if (div.style.backgroundImage) {
            return implementation.MOZILLA;
        }
        
        var canvas = CSS3Helpers.getCanvas();
        if (canvas.getContext && canvas.toDataURL) {
            return implementation.WORKAROUND;
        }
        
        return implementation.NONE;
        
    }
    
    me.getBracketedSubstring = function(s, header){
        var gradientIndex = s.indexOf(header + '(')
        
        if (gradientIndex != -1) {
            var substring = s.substring(gradientIndex);
            
            var openBrackets = 1;
            for (var i = header.length + 1; i < 100 || i < substring.length; i++) {
                var c = substring.substring(i, i + 1);
                switch (c) {
                    case "(":
                        openBrackets++;
                        break;
                    case ")":
                        openBrackets--;
                        break;
                }
                
                if (openBrackets == 0) {
                    break;
                }
                
            }
            
            return substring.substring(gradientIndex + header.length + 1, i);
        }
        
        
    }
    
    
    me.setMatrixFilter = function(obj, matrix){
    
    
        if (!hasIETransformWorkaround(obj)) {
            addIETransformWorkaround(obj)
        }
        
        var container = obj.parentNode;
        //container.xTransform = degrees;
        
        
        filter = obj.filters.item('DXImageTransform.Microsoft.Matrix');
        
        filter.M11 = matrix.e(1, 1);
        filter.M12 = matrix.e(1, 2);
        filter.M21 = matrix.e(2, 1);
        filter.M22 = matrix.e(2, 2);
        
        // Now, adjust the margins of the parent object
        var originalWidth = parseFloat(container.xOriginalWidth);
        var originalHeight = parseFloat(container.xOriginalHeight);
        
        var offset;
        if (obj.currentStyle.display == 'inline') {
            offset = 0;
        } else {
            offset = 13;  // This works ... don't know why.
        }
        
        container.style.marginLeft = (((originalWidth - obj.offsetWidth) / 2) - offset) + 'px'
        container.style.marginTop = (((originalHeight - obj.offsetHeight) / 2) - offset) + 'px'
        
    }
    
    function hasIETransformWorkaround(obj){
    
        return CSSHelpers.isMemberOfClass(obj.parentNode, 'IETransformContainer');
    }
    
    function addIETransformWorkaround(obj){
        if (!hasIETransformWorkaround(obj)) {
            var parentNode = obj.parentNode;
            var filter;
            
            // This is the container to offset the strange rotation behavior
            var container = document.createElement('div');
            CSSHelpers.addClass(container, 'IETransformContainer');
            
            
            container.style.width = obj.offsetWidth + 'px';
            container.style.height = obj.offsetHeight + 'px';
            container.xOriginalWidth = obj.offsetWidth;
            container.xOriginalHeight = obj.offsetHeight;
            container.style.position = 'absolute'
            container.style.zIndex = obj.currentStyle.zIndex;
		
            
            var horizPaddingFactor = 0; //parseInt(obj.currentStyle.paddingLeft); 
            var vertPaddingFactor = 0; //parseInt(obj.currentStyle.paddingTop);
            if (obj.currentStyle.display == 'block') {
                container.style.left = obj.offsetLeft + 13 - horizPaddingFactor + "px";
                container.style.top = obj.offsetTop + 13 + -vertPaddingFactor + 'px';
            } else {
                container.style.left = obj.offsetLeft + "px";
                container.style.top = obj.offsetTop + 'px';
                
            }
            //container.style.float = obj.currentStyle.float;
            
            
            obj.style.top = "auto";
            obj.style.left = "auto"
            obj.style.bottom = "auto";
            obj.style.right = "auto";
            // This is what we need in order to insert to keep the document
            // flow ok
            var replacement = obj.cloneNode(true);
            replacement.style.visibility = 'hidden';
            
            obj.replaceNode(replacement);
            
            // now, wrap container around the original node ... 
            
            obj.style.position = 'absolute';
            container.appendChild(obj);
            parentNode.insertBefore(container, replacement);
            container.style.backgroundColor = 'transparent';
            
            container.style.padding = '0';
            
            filter = me.addFilter(obj, 'DXImageTransform.Microsoft.Matrix', "sizingMethod='auto expand', M11=1, M12=0, M21=0, M22=1")
            
        }
        
    }
    
    me.addFilter = function(obj, filterName, filterValue){
        // now ... insert the filter so we can exploit its wonders
        
        var filter;
        try {
            filter = obj.filters.item(filterName);
        } 
        catch (ex) {
            // dang! We have to go through all of them and make sure filter
            // is set right before we add the new one.
            
            
            var filterList = new MSFilterList(obj)
            
            filterList.fixFilterStyle();
           
            var comma = ", ";
            
            if (obj.filters.length == 0) {
                comma = "";
            }
            
            obj.style.filter += StringHelpers.sprintf("%sprogid:%s(%s)", comma, filterName, filterValue);
            
            filter = obj.filters.item(filterName);
            
        }
        
        return filter;
    }
    
    
    function degreesToRadians(degrees){
        return (degrees - 360) * Math.PI / 180;
    }
    
    me.findTransformProperty = function (obj){
        var style = obj.style;
		var r = null;
		
        var properties = ['transform', 'MozTransform', 'WebkitTransform', 'OTransform', 'filter'];
        for (var i = 0; i < properties.length; i++) {
            if (style[properties[i]] != null) {
                r = properties[i];
				break;
            }
        }
		
		if (r == 'filter' && document.body.filters == undefined) {
			r = null;
		}
		
        return r;
    }
    
    /*
     * "A point is a pair of space-separated values. The syntax supports numbers,
     *  percentages or the keywords top, bottom, left and right for point values."
     *  This keywords and percentages into pixel equivalents
     */
    me.parseCoordinate = function(value, max){
        //Convert keywords
        switch (value) {
            case 'top':
            case 'left':
                return 0;
            case 'bottom':
            case 'right':
                return max;
            case 'center':
                return max / 2;
        }
        
        //Convert percentage
        if (value.indexOf('%') != -1) 
            value = parseFloat(value.substr(0, value.length - 1)) / 100 * max;
        //Convert bare number (a pixel value)
        else 
            value = parseFloat(value);
        if (isNaN(value)) 
            throw Error("Unable to parse coordinate: " + value);
        return value;
    }
    
    me.applyCanvasGradient = function(el, gradient){
    
        var canvas = me.getCanvas();
        var computedStyle = document.defaultView.getComputedStyle(el, null);
        
        canvas.width = parseInt(computedStyle.width) + parseInt(computedStyle.paddingLeft) + parseInt(computedStyle.paddingRight) + 1; // inserted by Zoltan
        canvas.height = parseInt(computedStyle.height) + parseInt(computedStyle.paddingTop) + parseInt(computedStyle.paddingBottom) + 2; // 1 inserted by Zoltan
        var ctx = canvas.getContext('2d');
        
        //Iterate over the gradients and build them up
        
        var canvasGradient;
        // Linear gradient
        if (gradient.type == 'linear') {
        
        
            canvasGradient = ctx.createLinearGradient(me.parseCoordinate(gradient.x0, canvas.width), me.parseCoordinate(gradient.y0, canvas.height), me.parseCoordinate(gradient.x1, canvas.width), me.parseCoordinate(gradient.y1, canvas.height));
        } // Radial gradient
 else /*if(gradient.type == 'radial')*/ {
            canvasGradient = ctx.createRadialGradient(me.parseCoordinate(gradient.x0, canvas.width), me.parseCoordinate(gradient.y0, canvas.height), gradient.r0, me.parseCoordinate(gradient.x1, canvas.width), me.parseCoordinate(gradient.y1, canvas.height), gradient.r1);
        }
        
        //Add each of the color stops to the gradient
        for (var i = 0; i < gradient.colorStops.length; i++) {
            var cs = gradient.colorStops[i];
            
            canvasGradient.addColorStop(cs.stop, cs.color);
        };
        
        //Paint the gradient
        ctx.fillStyle = canvasGradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        
        //Apply the gradient to the selectedElement
        el.style.backgroundImage = "url('" + canvas.toDataURL() + "')";
        
    }
    
}

function MSFilterList(node){
    var me = this;
    
    me.list = new Array();
    me.node = node;
    
    var reFilterListSplitter = /[\s\S]*\([\s\S]*\)/g;
    
    var styleAttr = node.style;
    
    function init(){
    
        var filterCalls = styleAttr.filter.match(reFilterListSplitter);
        
        if (filterCalls != null) {
        
            for (var i = 0; i < filterCalls.length; i++) {
                var call = filterCalls[i];
                
                me.list.push(new MSFilter(node, call));
                
            }
        }
        
        
    }
    
    me.toString = function(){
        var sb = new StringBuffer();
        
        for (var i = 0; i < me.list.length; i++) {
        
            sb.append(me.list[i].toString());
            if (i < me.list.length - 1) {
                sb.append(',')
            }
        }
        return sb.toString();
    }
    
    
    me.fixFilterStyle = function(){
    
        try {
            me.node.style.filter = me.toString();
        } 
        catch (ex) {
            // do nothing.
        }
        
    }
    
    init();
}

function MSFilter(node, filterCall){
    var me = this;
    
    me.node = node;
    me.filterCall = filterCall;
    
    var reFilterNameSplitter = /progid:([^\(]*)/g;
    var reParameterName = /([a-zA-Z0-9]+)=/g;
    
    
    function init(){
        me.name = me.filterCall.match(reFilterNameSplitter)[0].replace('progid:', '');
        
        //This may not be the best way to do this.
        var parameterString = filterCall.split('(')[1].replace(')', '');
        me.parameters = parameterString.match(reParameterName);
        for (var i = 0; i < me.parameters.length; i++) {
            me.parameters[i] = me.parameters[i].replace('=', '');
        }
        
    }
    
    me.toString = function(){
    
        var sb = new StringBuffer();
        
        sb.append(StringHelpers.sprintf('progid:%s(', me.name));
        
        for (var i = 0; i < me.parameters.length; i++) {
            var param = me.parameters[i];
            var filterObj = me.node.filters.item(me.name);
            var paramValue = filterObj[param];
            if (typeof(paramValue) == 'string') {
                sb.append(StringHelpers.sprintf('%s="%s"', param, filterObj[param]));
            } else {
                sb.append(StringHelpers.sprintf('%s=%s', param, filterObj[param]));
            }
            
            if (i != me.parameters.length - 1) {
                sb.append(', ')
            }
        }
        sb.append(')');
        
        return sb.toString();
    }
    
    
    
    init();
}

var implementation = new function(){
    this.NONE = 0;
    this.MOZILLA = 1;
    this.WEBKIT = 2;
    this.IE = 3;
    this.OPERA = 4;
    this.WORKAROUND = 5;
}

/*
 * Extra helper routines
 */


var StringHelpers = new function () {
	var me = this;
	
	// used by the String.prototype.trim()			
	me.initWhitespaceRe = /^\s\s*/;
	me.endWhitespaceRe = /\s\s*$/;
	me.whitespaceRe = /\s/;
	
	/*******************************************************************************
	 * Function sprintf(format_string,arguments...) Javascript emulation of the C
	 * printf function (modifiers and argument types "p" and "n" are not supported
	 * due to language restrictions)
	 * 
	 * Copyright 2003 K&L Productions. All rights reserved
	 * http://www.klproductions.com
	 * 
	 * Terms of use: This function can be used free of charge IF this header is not
	 * modified and remains with the function code.
	 * 
	 * Legal: Use this code at your own risk. K&L Productions assumes NO
	 * resposibility for anything.
	 ******************************************************************************/
	me.sprintf = function (fstring)
	  { var pad = function(str,ch,len)
	      { var ps='';
	        for(var i=0; i<Math.abs(len); i++) ps+=ch;
	        return len>0?str+ps:ps+str;
	      }
	    var processFlags = function(flags,width,rs,arg)
	      { var pn = function(flags,arg,rs)
	          { if(arg>=0)
	              { if(flags.indexOf(' ')>=0) rs = ' ' + rs;
	                else if(flags.indexOf('+')>=0) rs = '+' + rs;
	              }
	            else
	                rs = '-' + rs;
	            return rs;
	          }
	        var iWidth = parseInt(width,10);
	        if(width.charAt(0) == '0')
	          { var ec=0;
	            if(flags.indexOf(' ')>=0 || flags.indexOf('+')>=0) ec++;
	            if(rs.length<(iWidth-ec)) rs = pad(rs,'0',rs.length-(iWidth-ec));
	            return pn(flags,arg,rs);
	          }
	        rs = pn(flags,arg,rs);
	        if(rs.length<iWidth)
	          { if(flags.indexOf('-')<0) rs = pad(rs,' ',rs.length-iWidth);
	            else rs = pad(rs,' ',iWidth - rs.length);
	          }    
	        return rs;
	      }
	    var converters = new Array();
	    converters['c'] = function(flags,width,precision,arg)
	      { if(typeof(arg) == 'number') return String.fromCharCode(arg);
	        if(typeof(arg) == 'string') return arg.charAt(0);
	        return '';
	      }
	    converters['d'] = function(flags,width,precision,arg)
	      { return converters['i'](flags,width,precision,arg); 
	      }
	    converters['u'] = function(flags,width,precision,arg)
	      { return converters['i'](flags,width,precision,Math.abs(arg)); 
	      }
	    converters['i'] =  function(flags,width,precision,arg)
	      { var iPrecision=parseInt(precision);
	        var rs = ((Math.abs(arg)).toString().split('.'))[0];
	        if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
	        return processFlags(flags,width,rs,arg); 
	      }
	    converters['E'] = function(flags,width,precision,arg) 
	      { return (converters['e'](flags,width,precision,arg)).toUpperCase();
	      }
	    converters['e'] =  function(flags,width,precision,arg)
	      { iPrecision = parseInt(precision);
	        if(isNaN(iPrecision)) iPrecision = 6;
	        rs = (Math.abs(arg)).toExponential(iPrecision);
	        if(rs.indexOf('.')<0 && flags.indexOf('#')>=0) rs = rs.replace(/^(.*)(e.*)$/,'$1.$2');
	        return processFlags(flags,width,rs,arg);        
	      }
	    converters['f'] = function(flags,width,precision,arg)
	      { iPrecision = parseInt(precision);
	        if(isNaN(iPrecision)) iPrecision = 6;
	        rs = (Math.abs(arg)).toFixed(iPrecision);
	        if(rs.indexOf('.')<0 && flags.indexOf('#')>=0) rs = rs + '.';
	        return processFlags(flags,width,rs,arg);
	      }
	    converters['G'] = function(flags,width,precision,arg)
	      { return (converters['g'](flags,width,precision,arg)).toUpperCase();
	      }
	    converters['g'] = function(flags,width,precision,arg)
	      { iPrecision = parseInt(precision);
	        absArg = Math.abs(arg);
	        rse = absArg.toExponential();
	        rsf = absArg.toFixed(6);
	        if(!isNaN(iPrecision))
	          { rsep = absArg.toExponential(iPrecision);
	            rse = rsep.length < rse.length ? rsep : rse;
	            rsfp = absArg.toFixed(iPrecision);
	            rsf = rsfp.length < rsf.length ? rsfp : rsf;
	          }
	        if(rse.indexOf('.')<0 && flags.indexOf('#')>=0) rse = rse.replace(/^(.*)(e.*)$/,'$1.$2');
	        if(rsf.indexOf('.')<0 && flags.indexOf('#')>=0) rsf = rsf + '.';
	        rs = rse.length<rsf.length ? rse : rsf;
	        return processFlags(flags,width,rs,arg);        
	      }  
	    converters['o'] = function(flags,width,precision,arg)
	      { var iPrecision=parseInt(precision);
	        var rs = Math.round(Math.abs(arg)).toString(8);
	        if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
	        if(flags.indexOf('#')>=0) rs='0'+rs;
	        return processFlags(flags,width,rs,arg); 
	      }
	    converters['X'] = function(flags,width,precision,arg)
	      { return (converters['x'](flags,width,precision,arg)).toUpperCase();
	      }
	    converters['x'] = function(flags,width,precision,arg)
	      { var iPrecision=parseInt(precision);
	        arg = Math.abs(arg);
	        var rs = Math.round(arg).toString(16);
	        if(rs.length<iPrecision) rs=pad(rs,' ',iPrecision - rs.length);
	        if(flags.indexOf('#')>=0) rs='0x'+rs;
	        return processFlags(flags,width,rs,arg); 
	      }
	    converters['s'] = function(flags,width,precision,arg)
	      { var iPrecision=parseInt(precision);
	        var rs = arg;
	        if(rs.length > iPrecision) rs = rs.substring(0,iPrecision);
	        return processFlags(flags,width,rs,0);
	      }
	    farr = fstring.split('%');
	    retstr = farr[0];
	    fpRE = /^([-+ #]*)(\d*)\.?(\d*)([cdieEfFgGosuxX])(.*)$/;
	    for(var i=1; i<farr.length; i++)
	      { fps=fpRE.exec(farr[i]);
	        if(!fps) continue;
	        if(arguments[i]!=null) retstr+=converters[fps[4]](fps[1],fps[2],fps[3],arguments[i]);
	        retstr += fps[5];
	      }
	    return retstr;
	}
	
	/**
	 * Take out the first comment inside a block of HTML
	 * 
	 * @param {String} s - an HTML block
	 * @return {String} s - the HTML block uncommented.
	 */
	me.uncommentHTML = function(s) {
		if (s.indexOf('-->')!= -1 && s.indexOf('<!--') != -1) {
			return s.replace("<!--", "").replace("-->", "");
		} else {
			return s;
		}
	}
}

var XMLHelpers = new function() {
	
	var me = this;
	
	/**
	 * Wrapper for XMLHttpRequest Object.  Grabbing data (XML and/or text) from a URL.
	 * Grabbing data from a URL. Input is one parameter, url. It returns a request
	 * object. Based on code from
	 * http://www.xml.com/pub/a/2005/02/09/xml-http-request.html.  IE caching problem
	 * fix from Wikipedia article http://en.wikipedia.org/wiki/XMLHttpRequest
	 * 
	 * @param {String} url - the URL to retrieve
	 * @param {Function} processReqChange - the function/method to call at key events of the URL retrieval.
	 * @param {String} method - (optional) "GET" or "POST" (default "GET")
	 * @param {String} data - (optional) the CGI data to pass.  Default null.
	 * @param {boolean} isAsync - (optional) is this call asyncronous.  Default true.
	 * 
	 * @return {Object} a XML request object.
	 */
	me.getXMLHttpRequest = function (url, processReqChange) //, method, data, isAsync)
	{
		var argv = me.getXMLHttpRequest.arguments;
		var argc = me.getXMLHttpRequest.arguments.length;
		var httpMethod = (argc > 2) ? argv[2] : 'GET';
		var data = (argc > 3) ? argv[3] : "";
		var isAsync = (argc > 4) ? argv[4] : true;
		
		var req;
		// branch for native XMLHttpRequest object
		if (window.XMLHttpRequest) {
			req = new XMLHttpRequest();	
		// branch for IE/Windows ActiveX version
		} else if (window.ActiveXObject) {
			try {
				req = new ActiveXObject('Msxml2.XMLHTTP');
			} catch (ex) {
				req = new ActiveXObject("Microsoft.XMLHTTP");
			} 
			// the browser doesn't support XML HttpRequest. Return null;
		} else {
			return null;
		}
		
		if (isAsync) {
			req.onreadystatechange = processReqChange;
		}
		
		if (httpMethod == "GET" && data != "") {
			url += "?" + data;
		}
		
		req.open(httpMethod, url, isAsync);
		
		//Fixes IE Caching problem
		req.setRequestHeader( "If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT" );
		req.send(data);
		
		return req;
	}
}

var CSSHelpers = new function () {
	var me = this;
	
	var blankRe = new RegExp('\\s');
	
	/**
	 * Determines if an HTML object is a member of a specific class.
	 * @param {Object} obj - an HTML object.
	 * @param {Object} className - the CSS class name.
	 */
	me.isMemberOfClass = function (obj, className) {
		
		if (blankRe.test(className))
			return false;
		
		var re = new RegExp(getClassReString(className) , "g");
	
		return (re.test(obj.className));
	
	
	}
	
	/**
	 * Make an HTML object be a member of a certain class.
	 * 
	 * @param {Object} obj - an HTML object
	 * @param {String} className - a CSS class name.
	 */
	me.addClass = function (obj, className) {
		if (blankRe.test(className)) {
			return;
		}
		
		// only add class if the object is not a member of it yet.
		if (!me.isMemberOfClass(obj, className)) {
			obj.className += " " + className;
		}
	}
	
	/**
	 * Make an HTML object *not* be a member of a certain class.
	 * 
	 * @param {Object} obj - an HTML object
	 * @param {Object} className - a CSS class name.
	 */
	me.removeClass = function (obj, className) {
	
		if (blankRe.test(className)) {
			return; 
		}
		
		
		var re = new RegExp(getClassReString(className) , "g");
		
		var oldClassName = obj.className;
	
	
		if (obj.className) {
			obj.className = oldClassName.replace(re, '');
		}
	
	
	}
	
	/**
	 * Generates a regular expression string that can be used to detect a class name
	 * in a tag's class attribute.  It is used by a few methods, so I 
	 * centralized it.
	 * 
	 * @param {String} className - a name of a CSS class.
	 */
	
	function getClassReString(className) {
		return '\\s'+className+'\\s|^' + className + '\\s|\\s' + className + '$|' + '^' + className +'$';
	}
	
	
}

/* 
 * Adding trim method to String Object.  Ideas from 
 * http://www.faqts.com/knowledge_base/view.phtml/aid/1678/fid/1 and
 * http://blog.stevenlevithan.com/archives/faster-trim-javascript
 */
String.prototype.trim = function() { 
	var str = this;
	
	// The first method is faster on long strings than the second and 
	// vice-versa.
	if (this.length > 6000) {
		str = this.replace(StringHelpers.initWhitespaceRe, '');
		var i = str.length;
		while (StringHelpers.whitespaceRe.test(str.charAt(--i)));
		return str.slice(0, i + 1);
	} else {
		return this.replace(StringHelpers.initWhitespaceRe, '')
			.replace(StringHelpers.endWhitespaceRe, '');
	}  
	
	
};

/*
*  stringBuffer.js - ideas from 
*  http://www.multitask.com.au/people/dion/archives/000354.html
*/

function StringBuffer() {
	var me = this;

	var buffer = []; 
	

	me.append = function(string)
	{
		buffer.push(string);
		return me;
	}
	
	me.appendBuffer = function(bufferToAppend) {
		buffer = buffer.concat(bufferToAppend);
	}
	
	me.toString = function()
	{
		return buffer.join("");
	}
	
	me.getLength = function() 
	{
		return buffer.length;
	}
	
	me.flush = function () 
	{
		buffer.length=0;
	}

}





EventHelpers.addPageLoadEvent('cssSandpaper.init')
