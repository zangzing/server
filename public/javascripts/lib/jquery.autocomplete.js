jQuery.autocomplete = function(input, options) {
    // Create a link to self
    var me = this;

    // Create jQuery object for input element
    var $input = $(input).attr("autocomplete", "off");

    // Apply inputClass if necessary
    if (options.inputClass) $input.addClass(options.inputClass);
    var pos = findPos(input);

    //add a hook for position element
    var listTop = $(options.position_element).position().top + $(options.position_element).outerHeight() + "px";
    var listLeft = $(options.position_element).position().left + "px";
    // Create results

    logger.debug('creating results div');
    var results = document.createElement("div");
    // Create jQuery object for results
    var $results = $(results);
    $results.hide().addClass(options.resultsClass).css("position", "absolute");
    if( options.width > 0 ) $results.css("width", options.width);

    // Add to body element
    $(options.append).append(results);

    input.autocompleter = me;

    var timeout = null;
    var prev = "";
    var active = -1;
    var cache = {};
    var keyb = false;
    var hasFocus = false;
    var lastKeyPressCode = null;
    var zz_delete_btn = 1;

	// flush cache
	function flushCache(){
		cache = {};
		cache.data = {};
		cache.length = 0;
	};


    if( options.data != null ){
            setData( options.data );
    }
      
	$input.keydown(function(e) {
		// track last key pressed
		lastKeyPressCode = e.keyCode;
		switch(e.keyCode) {
			case 188: // comma
			    zz_add_recipient(1);
                e.preventDefault();
				break;
			case 38: // up
				e.preventDefault();
				moveSelect(-1);
				break;
			case 40: // down
				e.preventDefault();
				moveSelect(1);
				break;
			case 9:  // tab
                zz_add_recipient(1);
                break;
			case 13: // return
				if( selectCurrent() ){
					// make sure to blur off the current field
					//$input.get(0).blur();
					e.preventDefault();
				} else {
				  zz_add_recipient(0);
				  e.preventDefault();
				}
				break;
            case 8: // delete (same as default, but no delay
                active = -1;
                if (timeout) clearTimeout(timeout);
                onChange();
                break;

			default:
				active = -1;
				if (timeout) clearTimeout(timeout);
				timeout = setTimeout(function(){onChange();}, options.delay);
				break;
		}
	})
	.focus(function(){
		// track whether the field has focus, we shouldn't process any results if the field no longer has focus
		hasFocus = true;
	})
	.blur(function() {
		// track whether the field has focus
		hasFocus = false;
		hideResults();
	});

	hideResultsNow();

	function onChange() {
        // ignore if the following keys are pressed: [del] [shift] [capslock]
        if(lastKeyPressCode == 8) {
            //alert('DELETE KEY');
            if ($('#you-complete-me').val().length == 0 && this.zz_delete_btn == 2) {
                //console.log('Delete the last item!');
                $('#the-recipients li.rounded:last').fadeOut('fast', function(){
                    $('#the-recipients li.rounded:last').remove();
                });
                this.zz_delete_btn = 1;
            } else if ($('#you-complete-me').val().length == 0 && this.zz_delete_btn == 1) {
                //console.log('Select the last item!');
                $('#the-recipients li.rounded:last').addClass('del');
                this.zz_delete_btn = 2;
            } else if ($('#you-complete-me').val().length == 0 && this.zz_delete_btn == 0){
                this.zz_delete_btn = 1;
            }
        } else if (lastKeyPressCode == 46 || lastKeyPressCode > 8 && lastKeyPressCode < 32) {
            this.zz_delete_btn = 1;
            $('#the-recipients li.rounded:last').removeClass('del');
            return $results.hide();
        } else {
            this.zz_delete_btn = 1;
            $('#the-recipients li.rounded:last').removeClass('del');
        }
        var v = $input.val();
        if (v == prev) return;
        prev = v;
        if (v.length >= options.minChars) {
            $input.addClass(options.loadingClass);
            requestData(v);
        } else {
            $input.removeClass(options.loadingClass);
            $results.hide();
        }
	};

 	function moveSelect(step) {

		var lis = $("li", results);
		if (!lis) return;

		active += step;

		if (active < 0) {
			active = 0;
		} else if (active >= lis.size()) {
			active = lis.size() - 1;
		}

		lis.removeClass("ac_over");

		$(lis[active]).addClass("ac_over");

		// Weird behaviour in IE
		// if (lis[active] && lis[active].scrollIntoView) {
		// 	lis[active].scrollIntoView(false);
		// }

	};

	function selectCurrent() {
		var li = $("li.ac_over", results)[0];
		if (!li) {
			var $li = $("li", results);
			if (options.selectOnly) {
				if ($li.length == 1) li = $li[0];
			} else if (options.selectFirst) {
				li = $li[0];
			}
		}
		if (li) {
			selectItem(li);
			return true;
		} else {
			return false;
		}
	};

	function selectItem(li) {
		if (!li) {
			li = document.createElement("li");
			li.extra = [];
			li.selectValue = "";
		}
		var v = $.trim(li.selectValue ? li.selectValue : li.innerHTML);
		input.lastSelected = v;
		prev = v;
		$results.html("");
		$input.val(v);
		hideResultsNow();
		if (options.onItemSelect) setTimeout(function() { options.onItemSelect(li) }, 1);

        setTimeout(function(){
            zz_clone_recipient(li);
        },1);

	};

	// selects a portion of the input string
	function createSelection(start, end){
		// get a reference to the input element
		var field = $input.get(0);
		if( field.createTextRange ){
			var selRange = field.createTextRange();
			selRange.collapse(true);
			selRange.moveStart("character", start);
			selRange.moveEnd("character", end);
			selRange.select();
		} else if( field.setSelectionRange ){
			field.setSelectionRange(start, end);
		} else {
			if( field.selectionStart ){
				field.selectionStart = start;
				field.selectionEnd = end;
			}
		}
		field.focus();
	};

	// fills in the input box w/the first match (assumed to be the best match)
	function autoFill(sValue){
		// if the last user key pressed was backspace, don't autofill
		if( lastKeyPressCode != 8 ){
			// fill in the value (keep the case the user has typed)
			$input.val($input.val() + sValue.substring(prev.length));
			// select the portion of the value not typed by the user (so the next character will erase)
			createSelection(prev.length, sValue.length);
		}
	};

	function showResults() {
		// get the position of the input field right now (in case the DOM is shifted)
		// either use the specified width, or autocalculate based on form element
		var iWidth = (options.width > 0) ? options.width : $input.width();
		// reposition
		$results.css({
			width: parseInt(iWidth) + "px",
			top: $(options.position_element).position().top + $(options.position_element).outerHeight() + "px",
			left: $(options.position_element).position().left + "px"
		}).show();

        logger.debug('done showResults');
	};

	function hideResults() {
		if (timeout) clearTimeout(timeout);
		timeout = setTimeout(hideResultsNow, 200);
	};

	function hideResultsNow() {
		if (timeout) clearTimeout(timeout);
		$input.removeClass(options.loadingClass);
		if ($results.is(":visible")) {
			$results.hide();
		}
		if (options.mustMatch) {
			var v = $input.val();
			if (v != input.lastSelected) {
				selectItem(null);
			}
		}
	};

	function receiveData(q, data) {
		if (data) {
			$input.removeClass(options.loadingClass);
			results.innerHTML = "";

			// if the field no longer has focus or if there are no matches, do not display the drop down
			if( !hasFocus || data.length == 0 ) return hideResultsNow();

			if ($.browser.msie) {
				// we put a styled iframe behind the calendar so HTML SELECT elements don't show through
				$results.append(document.createElement('iframe'));
			}
			results.appendChild(dataToDom(data));
			// autofill in the complete box w/the first match as long as the user hasn't entered in more data
			if( options.autoFill && ($input.val().toLowerCase() == q.toLowerCase()) ) autoFill(data[0][0]);
			showResults();
		} else {
			hideResultsNow();
		}
	};

	function parseData(data) {
		if (!data) return null;
		var parsed = [];
		var rows = data.split(options.lineSeparator);
		for (var i=0; i < rows.length; i++) {
			var row = $.trim(rows[i]);
			if (row) {
				parsed[parsed.length] = row.split(options.cellSeparator);
			}
		}
		return parsed;
	};

	function dataToDom(data) {
		var ul = document.createElement("ul");
		var num = data.length;

		// limited results to a max number
		if( (options.maxItemsToShow > 0) && (options.maxItemsToShow < num) ) num = options.maxItemsToShow;

		for (var i=0; i < num; i++) {
			var row = data[i];
			if (!row) continue;
			var li = document.createElement("li");



            //hardcode the zz formatter
            li.innerHTML = zz_format_autocomplete_row(row, i, num);
            li.selectValue = row[0];

//			if (options.formatItem) {
//				li.innerHTML = options.formatItem(row, i, num);
//				li.selectValue = row[0];
//			} else {
//				li.innerHTML = row[0];
//				li.selectValue = row[0];
//			}
			var extra = null;
			if (row.length > 1) {
				extra = [];
				for (var j=1; j < row.length; j++) {
					extra[extra.length] = row[j];
				}
			}
			li.extra = extra;
			ul.appendChild(li);
			$(li).hover(
				function() { $("li", ul).removeClass("ac_over"); $(this).addClass("ac_over"); active = $("li", ul).indexOf($(this).get(0)); },
				function() { $(this).removeClass("ac_over"); }
			).click(function(e) { e.preventDefault(); e.stopPropagation(); selectItem(this) });
		}
		return ul;
	};

	function requestData(q) {
    	if (!options.matchCase) q = q.toLowerCase();
		var data = options.cacheLength ? loadFromCache(q) : null;
		// recieve the cached data
		if (data) {
            var pure_data = deDupeResultData(q,  data )
			receiveData(q, pure_data);
		// if an AJAX url has been supplied, try loading the data now
		} else if( (typeof options.url == "string") && (options.url.length > 0) ){
			$.get(makeUrl(q), function(data) {
				data = parseData(data);
				addToCache(q, data);
				receiveData(q, data);
			});
		// if there's been no data found, remove the loading class
		} else {
			$input.removeClass(options.loadingClass);
		}
	};

	function makeUrl(q) {
		var url = options.url + "?q=" + encodeURI(q);
		for (var i in options.extraParams) {
			url += "&" + i + "=" + encodeURI(options.extraParams[i]);
		}
		return url;
	};

	function loadFromCache(q) {
		if (!q) return null;
		if (cache.data[q]) return cache.data[q];
		if (options.matchSubset) {
			for (var i = q.length - 1; i >= options.minChars; i--) {
				var qs = q.substr(0, i);
				var c = cache.data[qs];
				if (c) {
					var csub = [];
					for (var j = 0; j < c.length; j++) {
						var x = c[j];
						var x0 = x[0];
						if (matchSubset(x0, q)) {
							csub[csub.length] = x;
						}
					}
					return csub;
				}
			}
		}
		return null;
	};

	function matchSubset(s, sub) {
		if (!options.matchCase) s = s.toLowerCase();
		var i = s.indexOf(sub);
		if (i == -1) return false;
		return i == 0 || options.matchContains;
	};

    function cleanData( data ){
        //it removes duplicate email addresses assumes that each entry in data is [name,email]
        var r = new Array();
        o:for(var i = 0, n = data.length; i < n; i++){
            for(var x = 0, y = r.length; x < y; x++){
                if(r[x][1]==data[i][1]) continue o;
            }
            r[r.length] = data[i];
        }
        return r;
    };


    function setData( dirtyData ){
        //remove duplicates and clean data
        var data = cleanData( dirtyData );
        options.data = ((typeof data == "object") && (data.constructor == Array)) ? data : null;
        flushCache();
        // if there is a data array supplied
        if( options.data != null ){
            var sFirstChar = "", stMatchSets = {}, row = [];

            // no url was specified, we need to adjust the cache length to make sure it fits the local data store
            if( typeof options.url != "string" ) options.cacheLength = 1;

            // loop through the array and create a lookup structure
            for( var i=0; i < options.data.length; i++ ){
                // if row is a string, make an array otherwise just reference the array
                row = ((typeof options.data[i] == "string") ? [options.data[i]] : options.data[i]);

                // Each data row is [name,email]
                // two rows go in the matchSet one for name and one for email
                // matchSet rows are [ matchableString , name, email, index, oneifName, oneifEmail ]

                // if the length is zero, don't add to list
                if( row[0].length > 0 ){
                    var namerow = [row[0], row[0],row[1], i,  1,0 ];
                    // get the first character
                    sFirstChar = row[0].substring(0, 1).toLowerCase();
                    // if no lookup array for this character exists, look it up now
                    if( !stMatchSets[sFirstChar] ) stMatchSets[sFirstChar] = [];
                    // if the match is a string
                    stMatchSets[sFirstChar].push(namerow);
                }
                // if the length is zero, don't add to list
                if( row[1].length > 0 ){
                    var addressrow = [row[1], row[0],row[1], i,  0,1 ];
                    // get the first character
                    sFirstChar = addressrow[0].substring(0, 1).toLowerCase();
                    // if no lookup array for this character exists, look it up now
                    if( !stMatchSets[sFirstChar] ) stMatchSets[sFirstChar] = [];
                    // if the match is a string
                    stMatchSets[sFirstChar].push(addressrow);
                }
            }

            // add the data items to the cache
            for( var k in stMatchSets ){
                // increase the cache size
                options.cacheLength++;
                // add to the cache
                addToCache(k, stMatchSets[k]);
            }
        }
    };
    
	this.flushCache = function() {
		flushCache();
	};

	this.setExtraParams = function(p) {
		options.extraParams = p;
	};

    this.setData = function( data ){
        setData( data );
    };
  

    function deDupeResultData( q, data ){
          if(data != null){
              sparseData = {};
              for( var i=0; i < data.length; i++ ){
                    var index = data[i][3];
                    if( sparseData[ index ] == null){
                          //                      [name,email,match-length,isNameMatch,isEmailMatch] 
                          sparseData[ index ] = [data[i][1], data[i][2], q.length, data[i][4], data[i][5]];
                    } else {
                          if( data[i][4] ==1  ) { sparseData[ index ][3] = 1; }
                          if( data[i][5] ==1  ) { sparseData[ index ][4] = 1; }
                    }

                }
              pure_data = [];
              for(var j in sparseData ){
                  pure_data.push(sparseData[j]);
              }
           return pure_data;
          }
          return[];
     };

	this.findValue = function() {
        var q = $input.val();

        if (!options.matchCase) q = q.toLowerCase();
        var data = options.cacheLength ? loadFromCache(q) : null;
        if (data) {
            var pure_data = deDupeResultData(q,  data );
            findValueCallback(q, pure_data);
        } else if ((typeof options.url == "string") && (options.url.length > 0)) {
            $.get(makeUrl(q), function(data) {
                data = parseData(data)
                addToCache(q, data);
                findValueCallback(q, data);
            });
        } else {
            // no matches
            findValueCallback(q, null);
        }
    };

	function findValueCallback(q, data){
		if (data) $input.removeClass(options.loadingClass);

		var num = (data) ? data.length : 0;
		var li = null;

		for (var i=0; i < num; i++) {
			var row = data[i];

			if( row[0].toLowerCase() == q.toLowerCase() ){
				li = document.createElement("li");
				if (options.formatItem) {
					li.innerHTML = options.formatItem(row, i, num);
					li.selectValue = row[0];
				} else {
					li.innerHTML = row[0];
					li.selectValue = row[0];
				}
				var extra = null;
				if( row.length > 1 ){
					extra = [];
					for (var j=1; j < row.length; j++) {
						extra[extra.length] = row[j];
					}
				}
				li.extra = extra;
			}
		}

		if( options.onFindValue ) setTimeout(function() { options.onFindValue(li) }, 1);
	}

	function addToCache(q, data) {
		if (!data || !q || !options.cacheLength) return;
		if (!cache.length || cache.length > options.cacheLength) {
			flushCache();
			cache.length++;
		} else if (!cache[q]) {
			cache.length++;
		}
		cache.data[q] = data;
	};

	function findPos(obj) {
		var curleft = obj.offsetLeft || 0;
		var curtop = obj.offsetTop || 0;
		while (obj = obj.offsetParent) {
			curleft += obj.offsetLeft
			curtop += obj.offsetTop
		}
		return {x:curleft,y:curtop};
	};


        // adds a recipient to the autocomplete area on keypress
    function zz_add_recipient(comma){
        if (comma == 1) {
            value = $('#you-complete-me').val();
            value = value.split(',')[0];
            $('#you-complete-me').val('');
        } else {
            value = $('#you-complete-me').val();
            $('#you-complete-me').val('');

        }

        if (value.length < 6) {

        } else {


            zz.wizard.email_id++;
            //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
            $('#m-clone-added').clone()
                    .attr({id: 'm-'+zz.wizard.email_id})
                    .insertAfter('#the-recipients li.rounded:last');

            $('#m-'+zz.wizard.email_id+' span').empty().html(value);
            //$('#m-'+zz.wizard.email_id+' input').attr({name: 'i-' + zz.wizard.email_id, checked: 'checked'}).val(value);
            $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);
            $('#m-'+zz.wizard.email_id).fadeIn('fast');
            $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
            $('li.rounded img').click(function(){
                $(this).parent('li').fadeOut('fast', function(){
                    $(this).parent('li').remove();
                });
            });
            //console.log(value);
        }
    };

    function zz_clone_recipient(data){
        // data.selectValue is name|email
        var value = '\"'+data.selectValue+'\" \<'+data.extra[0]+'\>';
        var display_value = ( data.selectValue.length >0 ? data.selectValue : data.extra[0] );

        zz.wizard.email_id++;
        //console.log('ID: '+ zz.wizard.email_id +'-- Add '+ temp +' to the view and a ' + $(data).html() + ' checkbox to the form.');
        $('#you-complete-me').val('');
        $('#m-clone-added').clone()
                .attr({id: 'm-'+zz.wizard.email_id})
                .insertAfter('#the-recipients li.rounded:last');

        $('#m-'+zz.wizard.email_id+' span').empty().html(display_value);
        $('#m-'+zz.wizard.email_id+' input').attr({name: 'email_share[to][]', checked: 'checked'}).val(value);
         $('#m-'+zz.wizard.email_id).fadeIn('fast');
        $('#m-'+zz.wizard.email_id+' img').attr('id', 'img-'+zz.wizard.email_id);
        $('#img-'+zz.wizard.email_id).click(function(){
             $(this).parent('li').fadeOut('fast', function(){
                $(this).remove();
            });
        });
    };


    function zz_format_autocomplete_row(row) {
        var formattedRow ='';
        var name         = row[0];
        var add          = row[1];
        var match_len    = row[2];
        if( row[3] == 1  ){
            //name match
            formattedRow+= '<span class="autocomplete-match">';
            formattedRow+= name.substr(0,match_len);
            formattedRow+= "</span>";
            formattedRow+= name.substr(match_len)+' ';
        } else {
          formattedRow+= ' '+name+' '; //push name
        }

        if( row[4] == 1){
            //address match
            formattedRow += '<<span class="autocomplete-match">';
            formattedRow+= add.substr(0,match_len);
            formattedRow+= "</span>";
            formattedRow+= add.substr(match_len)+'>';
        } else {
         formattedRow+= ' <'+add+'> '; //push add
        }
        return formattedRow;
    };


}

jQuery.fn.autocomplete = function(url, options, data) {


	// Make sure options exists
	options = options || {};
	// Set url as option
	options.url = url;
	// set some bulk local data
	options.data = ((typeof data == "object") && (data.constructor == Array)) ? data : null;

	// Set default values for required options
	options.inputClass = options.inputClass || "ac_input";
	options.resultsClass = options.resultsClass || "ac_results";
	options.lineSeparator = options.lineSeparator || "\n";
	options.cellSeparator = options.cellSeparator || "|";
	options.minChars = options.minChars || 1;
	options.delay = options.delay || 400;
	options.matchCase = options.matchCase || 0;
	options.matchSubset = options.matchSubset || 1;
	options.matchContains = options.matchContains || 0;
	options.cacheLength = options.cacheLength || 1;
	options.mustMatch = options.mustMatch || 0;
	options.extraParams = options.extraParams || {};
	options.loadingClass = options.loadingClass || "ac_loading";
	options.selectFirst = options.selectFirst || false;
	options.selectOnly = options.selectOnly || false;
	options.maxItemsToShow = options.maxItemsToShow || -1;
	options.autoFill = options.autoFill || false;
	options.width = parseInt(options.width, 10) || 0;

	this.each(function() {
		var input = this;
		new jQuery.autocomplete(input, options);
	});

	// Don't break the chain
	return this;
}

jQuery.fn.autocompleteArray = function(data, options) {
    return this.autocomplete(null, options, data);
}

jQuery.fn.indexOf = function(e){
	for( var i=0; i<this.length; i++ ){
		if( this[i] == e ) return i;
	}
	return -1;
};
