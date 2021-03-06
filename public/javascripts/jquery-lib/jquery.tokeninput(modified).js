/**
 * @preserve
 * ----------
 *
 * jQuery Plugin: Tokenizing Autocomplete Text Entry
 * Version 1.1.7 by rozwell (21-12-2010 01:35)
 *
 * Copyright (c) 2009 James Smith (http://loopj.com)
 * Licensed jointly under the GPL and MIT licenses,
 * choose which one suits your project best!
 *
 */

(function($){

   $.fn.tokenInput = function(url, options){
      var settings = $.extend({
         url: url,
         hintText: "Type in a search term",
         noResultsText: "No results",
         searchingText: "Searching...",
         searchingErrorText: "Error!",
         searchDelay: 300,
         allowNewValues: false,
         displayOnly: false,
         minChars: 1,
         tokenLimit: null,
         tokenLimitText: "Values limit reached!",
         tokenLimitDisplayTime: 1500,
         jsonContainer: null,
         method: "get",
         dataType: "json",
         queryParam: "q",
         onResult: null,
         hideEntered: true,
         validate: null
      }, options);

      settings.prePopulate = $.extend({
         data: [],
         forceDataFill: false,
         url: settings.url,
         errorText: settings.searchingErrorText,
         method: settings.method,
         dataType: settings.dataType,
         queryParam: "ids",
         onResult: null
      }, options.prePopulate);

      settings.classes = $.extend({
         tokenList: "token-input-list",
         token: "token-input-token",
         tokenDelete: "token-input-delete-token",
         selectedToken: "token-input-selected-token",
         highlightedToken: "token-input-highlighted-token",
         dropdown: "token-input-dropdown",
         dropdownItem: "token-input-dropdown-item",
         dropdownItem2: "token-input-dropdown-item2",
         selectedDropdownItem: "token-input-selected-dropdown-item",
         inputToken: "token-input-input-token"
      }, options.classes);

 
      return this.each(function(){
         var list = new $.TokenList(this, settings);
         $.data(this, 'tokeninput', { list: list } );
      });
   };

   $.TokenList = function(input, settings){
      //
      // Variables
      //

      // Input box position "enum"
      var POSITION = {
         BEFORE: 0,
         AFTER: 1,
         END: 2
      };

      // Keys "enum"
      var KEY = {
         BACKSPACE: 8,
         TAB: 9,
         RETURN: 13,
         ESC: 27,
         LEFT: 37,
         UP: 38,
         RIGHT: 39,
         DOWN: 40,
         COMMA: 188,
         SEMICOLON: 186,
         SEMICOLON_FIREFOX: 59 //firefox has different code
      };

      // Save the tokens
      var saved_tokens = [];

      // Keep track of the number of tokens in the list
      var token_count = 0;

      // Basic cache to save on db hits
//      var cache = new $.TokenList.Cache();

      // Keep track of the timeout
      var timeout;

      // Create a new text input an attach keyup events
      var input_box = $("<input type=\"text\">")
         .attr('placeholder', settings.hintText) //can't use the placeholder plugin because it will pick up the value
         .placeholder()
         .css({
            outline: "none",
            width: "100%"
         })
         .focus(function(){

            //scroll to bottom of list.
            $(token_list).scrollTop(1000);

            if(settings.tokenLimit == null || settings.tokenLimit != token_count){
               show_dropdown_hint();
            } else {
               show_dropdown_token_limit_warning();
            }
         })
         .blur(function(){
            if(settings.allowNewValues) create_new_token();
            hide_dropdown();
         })
         .keydown(function(event){
            var previous_token;
            var next_token;



            switch(event.keyCode){
               case KEY.LEFT:
               case KEY.RIGHT:
               case KEY.UP:
               case KEY.DOWN:
                  if(!$(this).val()){
                     previous_token = input_token.prev();
                     next_token = input_token.next();

                     if((previous_token.length && previous_token.get(0) === selected_token) || (next_token.length && next_token.get(0) === selected_token)){
                        // Check if there is a previous/next token and it is selected
                        if(event.keyCode == KEY.LEFT || event.keyCode == KEY.UP){
                           deselect_token($(selected_token), POSITION.BEFORE);
                        } else {
                           deselect_token($(selected_token), POSITION.AFTER);
                        }
                     } else if((event.keyCode == KEY.LEFT || event.keyCode == KEY.UP) && previous_token.length){
                        // We are moving left, select the previous token if it exists
                        select_token($(previous_token.get(0)));
                     } else if((event.keyCode == KEY.RIGHT || event.keyCode == KEY.DOWN) && next_token.length){
                        // We are moving right, select the next token if it exists
                        select_token($(next_token.get(0)));
                     }
                  } else {
                     var dropdown_item = null;

                     if(event.keyCode == KEY.DOWN || event.keyCode == KEY.RIGHT){
                        dropdown_item = $(selected_dropdown_item).next();
                     } else {
                        dropdown_item = $(selected_dropdown_item).prev();
                     }

                     if(dropdown_item.length){
                        select_dropdown_item(dropdown_item);
                     }
                     return false;
                  }
                  break;

               case KEY.BACKSPACE:
                  previous_token = input_token.prev();

                  if(!$(this).val().length){
                     if(selected_token){
                        delete_token($(selected_token));
                     } else if(previous_token.length){
                        select_token($(previous_token.get(0)));
                     }

                     return false;
                  } else if($(this).val().length == 1){
                     hide_dropdown();
                  } else {
                     // set a timeout just long enough to let this function finish.
                     setTimeout(function(){
                        do_search(false);
                     }, 5);
                  }
                  break;

               case KEY.TAB:
                   if(selected_dropdown_item){
                      add_token($(selected_dropdown_item));
                      return true;
                   }else if(settings.allowNewValues) {
                      create_new_token();
                      return true;
                   }
               case KEY.RETURN:
               case KEY.COMMA:
                  if(selected_dropdown_item){
                     add_token($(selected_dropdown_item));
                     return false;
                  }else if(settings.allowNewValues) {
                    create_new_token();
                    return false;
                  }
                  break;
                case KEY.SEMICOLON:
                   if(selected_dropdown_item){
                      add_token($(selected_dropdown_item));
                      return false;
                   }else if(settings.allowNewValues) {
                     create_new_token();
                     return false;
                   }
                   break;
                case KEY.SEMICOLON_FIREFOX:
                   if(selected_dropdown_item){
                      add_token($(selected_dropdown_item));
                      return false;
                   }else if(settings.allowNewValues) {
                     create_new_token();
                     return false;
                   }
                   break;
               case KEY.ESC:
                  hide_dropdown();
                  return true;

               default:
                  if(is_printable_character(event.keyCode)){
                     // set a timeout just long enough to let this function finish.
                     setTimeout(function(){
                        do_search(false);
                     }, 5);
                  }
                  break;
            }
         });

       //Hide the input box if the list is for displayOnly
       if( settings.displayOnly ) input_box.hide();

      // Keep a reference to the original input box
      var hidden_input = $(input)
         .hide()
         .focus(function(){
            input_box.focus();
         })
         .blur(function(){
            input_box.blur();
         });

      // Keep a reference to the selected token and dropdown item
      var selected_token = null;
      var selected_dropdown_item = null;

      // The list to store the token items in
      var token_list = $("<ul>")
         .addClass(settings.classes.tokenList)
         .insertAfter(hidden_input)
         .click(function(event){
            var li = get_element_from_event(event, "li");
            if(li && li.get(0) != input_token.get(0)){
               toggle_select_token(li);
               return false;
            } else {
               input_box.focus();

               if(selected_token){
                  deselect_token($(selected_token), POSITION.END);
               }
            }
         })
         .mouseover(function(event){
            var li = get_element_from_event(event, "li");
            if(li && selected_token !== this){
               li.addClass(settings.classes.highlightedToken);
            }
         })
         .mouseout(function(event){
            var li = get_element_from_event(event, "li");
            if(li && selected_token !== this){
               li.removeClass(settings.classes.highlightedToken);
            }
         })
         .mousedown(function(event){
            // Stop user selecting text on tokens
            var li = get_element_from_event(event, "li");
            if(li){
               return false;
            }
         });


      // The list to store the dropdown items in
      var dropdown = $("<div>")
         .addClass(settings.classes.dropdown)
         .insertAfter(token_list)
         .hide();

      // The token holding the input box


      var input_token = $("<li></li>")
              .addClass(settings.classes.inputToken)
              .appendTo(token_list)
              .append(input_box);



      init_list();

      //
      // Functions
      //

      // List populate function
      function populate_list(data){
         if(data && data.length){
            for(var i in data){
               var this_token = $("<li><p>"+data[i].name+"</p></li>")
                  .addClass(settings.classes.token)
                  .insertBefore(input_token);

               $("<span>x</span>")
                  .addClass(settings.classes.tokenDelete)
                  .appendTo(this_token)
                  .click(function(){
                     delete_token($(this).parent());
                     return false;
                  });

               var token_text =  ( data[i].token_text ?data[i].token_text :data[i].name );
               $.data(this_token.get(0), "tokeninput", {
                  "id": data[i].id,
                  "name": token_text
               });

               // Clear input box and make sure it keeps focus
               input_box
                  .val("")
                  .focus();

               // Don't show the help dropdown, they've got the idea
               hide_dropdown();

               // Save this token id
               var id_string = data[i].id;
               if(hidden_input.val()){
                  id_string = "," + id_string;
               }
               hidden_input.val(hidden_input.val() + id_string);

               token_count++;

               if(settings.tokenLimit != null && settings.tokenLimit <= token_count){
                  input_box.hide();
                  hide_dropdown();
                  break;
               }
            }
         }
      }

      // Pre-populate list if items exist
      function init_list(){
         if(hidden_input.val().length && !settings.prePopulate.forceDataFill){
            var callbackSuccess = function(results){
               if($.isFunction(settings.prePopulate.onResult)){
                  results = settings.onResult.call(this, results);
               }
               hidden_input.val('');
               populate_list(results);
            }
            var callbackError = function(){
               show_dropdown_pre_populate_error();
            }

            $.ajax({
               url: settings.prePopulate.url,
               dataType: settings.prePopulate.dataType,
               type: settings.prePopulate.method,
               data: settings.prePopulate.queryParam + "=" + hidden_input.val(),
               success: callbackSuccess,
               error: callbackError
            });
         } else {
            hidden_input.val('');
            populate_list(settings.prePopulate.data);
         }
      }

      function is_printable_character(keycode){
         if((keycode >= 48 && keycode <= 90) ||      // 0-1a-z
            (keycode >= 96 && keycode <= 111) ||     // numpad 0-9 + - / * .
            (keycode >= 186 && keycode <= 192) ||    // ; = , - . / ^
            (keycode >= 219 && keycode <= 222)       // ( \ ) '
            ){
            return true;
         } else {
            return false;
         }
      }

      // Get an element of a particular type from an event (click/mouseover etc)
      function get_element_from_event (event, element_type){
         var target = $(event.target);
         var element = null;

         if(target.is(element_type)){
            element = target;
         } else if(target.parent(element_type).length){
            element = target.parent(element_type+":first");
         }

         return element;
      }

      // Inner function to a token to the list
      function insert_token(id, value){
         var this_token = $("<li><p>"+ value +"</p></li>")
            .addClass(settings.classes.token)
            .insertBefore(input_token);

         // The 'delete token' button
         $("<span>x</span>")
            .addClass(settings.classes.tokenDelete)
            .appendTo(this_token)
            .click(function(){
               delete_token($(this).parent());
               return false;
            });
         
         $.data(this_token.get(0), "tokeninput", {
            "id": id,
            "name": value
         });



         // make sure value is valid
         if(settings.validate){
             if(!settings.validate(id)){
                this_token.addClass('error');
             }
         }


         return this_token;
      }

      // Add a token to the token list based on user input
      function add_token (item){
         var li_data = $.data(item.get(0), "tokeninput");
          add_token_from_strings(li_data.id, li_data.name)
      }

      this.add_token = function( id, name ){
        add_token_from_strings(id,name);
      };

       this.empty = function(){
         token_list.find('li').each( function(index,element){
             hidden_input.val('');
             token_count = 0;
             if( $(element).find('input').length <=0 ){
                $(element).remove();
             }
         });
       };

      function add_token_from_strings( id, name ){
         var this_token = insert_token(id, name);

         // Clear input box and make sure it keeps focus
         input_box
            .val("")
            .focus();

         // Don't show the help dropdown, they've got the idea
         hide_dropdown();

         // Save this token id
         var id_string = id;
         if(hidden_input.val()){
            id_string = "," + id_string;
         }
//         id_string = id_string + ",";
         hidden_input.val(hidden_input.val() + id_string);

         token_count++;

         if(settings.tokenLimit != null && settings.tokenLimit <= token_count){
            input_box.hide();
            hide_dropdown();
         }
      }

       function create_new_token () {
            var string = input_box.val(); //.toLowerCase();
            if(string.length > 0 && string != settings.hintText){
                // split the string by tabs,commas,returns or spaces and
                // make each part a token.
                var string_parts =  string.split(/\s*,\s*|\s*\t\s*/);
                for( var i in string_parts){
                    var str = string_parts[i]; //$('<div/>').text(string_parts[i]).html();
                    add_token_from_strings( str, str);
                }
            }
       }


      // Select a token in the token list
      function select_token (token){
         token.addClass(settings.classes.selectedToken);
         selected_token = token.get(0);

         // Hide input box
         input_box.val("");

         // Hide dropdown if it is visible (eg if we clicked to select token)
         hide_dropdown();
      }

      // Deselect a token in the token list
      function deselect_token (token, position){
         token.removeClass(settings.classes.selectedToken);
         selected_token = null;

         if(position == POSITION.BEFORE){
            input_token.insertBefore(token);
         } else if(position == POSITION.AFTER){
            input_token.insertAfter(token);
         } else {
            input_token.appendTo(token_list);
         }

         // Show the input box and give it focus again
         input_box.focus();
      }

      // Toggle selection of a token in the token list
      function toggle_select_token (token){
         if(selected_token == token.get(0)){
            deselect_token(token, POSITION.END);
         } else {
            if(selected_token){
               deselect_token($(selected_token), POSITION.END);
            }
            select_token(token);
         }
      }

      // Delete a token from the token list
      function delete_token (token){
         // Remove the id from the saved list
         var token_data = $.data(token.get(0), "tokeninput");

         // Delete the token
         token.remove();
         selected_token = null;

         // Show the input box and give it focus again
         if( !settings.displayOnly )  input_box.focus();

         // Delete this token's id from hidden input
         var id_array = hidden_input.val().split(",");
         id_array.splice( $.inArray( token_data.id.toString(), id_array ), 1);
         hidden_input.val(id_array.join(","));

         token_count--;

         if( settings.tokenLimit != null && !settings.displayOnly ){
            input_box
               .show()
               .val("")
               .focus();
         }
         hidden_input.trigger('tokenDeleted',[token_data.id, token_data.name, token_count]);
      }

      // Hide and clear the results dropdown
      function hide_dropdown(){
         dropdown.hide().empty();
         selected_dropdown_item = null;
      }

      function show_dropdown_searching(){
         selected_dropdown_item = null;
         dropdown
            .html("<p>"+settings.searchingText+"</p>")
            .show();
      }

      function show_dropdown_error(){
         dropdown
            .html("<p>"+settings.searchingErrorText+"</p>")
            .show();
      }

      function show_dropdown_pre_populate_error(){
         dropdown
            .html("<p>"+settings.prePopulate.errorText+"</p>")
            .show();
      }

      function show_dropdown_hint(){
         if( ! settings.displayOnly ){
         dropdown
            .html("<p>"+settings.hintText+"</p>")
            .show();
         }
      }

      function show_dropdown_token_limit_warning(){
         dropdown
            .html("<p>"+settings.tokenLimitText+"</p>")
            .show(0)
            .delay(settings.tokenLimitDisplayTime)
            .hide(0);
      }

      // Highlight the query part of the search term
      function highlight_term(value, term){
         return value.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(" + term + ")(?![^<>]*>)(?![^&;]+;)", "gi"), "<b>$1</b>");
      }

      // Populate the results dropdown with some results
      function populate_dropdown (query, results){
         // Remove already displayed objects from results
         if(settings.hideEntered && results.length && $(hidden_input).val()){
            // Make array of entered ids
            var entered = $(hidden_input).val().split(',');
            // Filter results
            results = $.grep(results, function(element){
               return !($.inArray(element.id.toString(), entered) != -1);
            });
         }

         if(results.length){
            dropdown.empty();
            var dropdown_ul = $("<ul>")
               .appendTo(dropdown)
               .mouseover(function(event){
                  select_dropdown_item(get_element_from_event(event, "li"));
               })
               .click(function(event){
                  add_token(get_element_from_event(event, "li"));
               })
               .mousedown(function(event){
                  // Stop user selecting text on tokens
                  return false;
               })
               .hide();

            for(var i in results){
               if(results.hasOwnProperty(i)){
                  var this_li = $("<li>"+highlight_term(results[i].name, query)+"</li>")
                     .appendTo(dropdown_ul);

                  if(i%2){
                     this_li.addClass(settings.classes.dropdownItem);
                  } else {
                     this_li.addClass(settings.classes.dropdownItem2);
                  }

                  if(i == 0){
                     select_dropdown_item(this_li);
                  }

                  var token_text =  ( results[i].token_text ? results[i].token_text : results[i].name );
                  $.data(this_li.get(0), "tokeninput", {
                     "id": results[i].id,
                     "name": token_text
                  });
               }
            }

            dropdown.show();
            dropdown_ul.slideDown("fast");

         } else {
            selected_dropdown_item = null;
            dropdown
               .html("<p>"+settings.noResultsText+"</p>")
               .show();
         }
      }

      // Highlight an item in the results dropdown
      function select_dropdown_item(item){
         if(item){
            if(selected_dropdown_item){
               deselect_dropdown_item($(selected_dropdown_item));
            }

            item.addClass(settings.classes.selectedDropdownItem);
            selected_dropdown_item = item.get(0);
         }
      }

      // Remove highlighting from an item in the results dropdown
      function deselect_dropdown_item(item){
         item.removeClass(settings.classes.selectedDropdownItem);
         selected_dropdown_item = null;
      }

      // Do a search and show the "searching" dropdown if the input is longer
      // than settings.minChars
      function do_search(immediate){
         var query = input_box.val().toLowerCase();

         if(query && query.length){
            if(selected_token){
               deselect_token($(selected_token), POSITION.AFTER);
            }
            if(query.length >= settings.minChars){
               show_dropdown_searching();
               if(immediate){
                  run_search(query);
               } else {
                  clearTimeout(timeout);
                  timeout = setTimeout(function(){
                     run_search(query);
                  }, settings.searchDelay);
               }
            } else {
               hide_dropdown();
            }
         }
      }

       // Do the actual search
       function run_search(query){
//           var cached_results = cache.get(query);
//           if(cached_results){
//               populate_dropdown(query, cached_results);
//           } else {
               var callback = function(results){
                   if($.isFunction(settings.onResult)){
                       results = settings.onResult.call(this, results);
                   }
//                   cache.add(query, settings.jsonContainer ? results[settings.jsonContainer] : results);
                   populate_dropdown(query, settings.jsonContainer ? results[settings.jsonContainer] : results);
               };
               var callbackError = function(){
                   show_dropdown_error();
               };
               if( $.isFunction(settings.url) ){
                    var query_results = settings.url(query);
                    if( query_results != null ){
                        callback( query_results );
                    }else{
                        callbackError();
                    }
               }else{
                   $.ajax({
                       url: settings.url,
                       dataType: settings.dataType,
                       type: settings.method,
                       data: settings.queryParam + "=" + query,
                       success: callback,
                       error: callbackError
                   });
               }
//           }
       }

   };

//   // Basic cache for the results
//   $.TokenList.Cache = function(options){
//      var settings = $.extend({
//         max_size: 50
//      }, options);
//
//      var data = {};
//      var size = 0;
//
//      // Creating our own shift function because associative keys in js sucks
//      var shift = function(obj){
//         for(i in obj){
//            value = data[i];
//            delete data[i];
//            return value;
//         }
//      }
//
//      this.add = function(query, results){
//         // If cache is full, remove first value
//         if(size >= settings.max_size){
//            shift(data);
//         } else if(!data[query]){
//            size++;
//         }
//         // Add the value at the end of array
//         data[query] = results;
//      };
//
//      this.get = function(query){
//         return data[query];
//      };
//   };

})(jQuery);
