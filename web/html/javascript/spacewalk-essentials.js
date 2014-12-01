$(document).on("ready", function(){

  /* Menu in the left column - actions to hide submenu and create animation when a 
  menu only has submenues and doesnt have a URL */
  $("#sidenav ul>ul").hide();

  $("#sidenav li.active").each(function() {
    $(this).next("ul").show();
  });

  /* Systems Selected Toolbar - actions to hide the toolbar when th Clear button is pressed or when 
  no system is selected */

  $("#clear-btn").click(hidesystemtool);

  function hidesystemtool(){
    $(".spacewalk-bar").animate({
      "right": "-=50px",
      "opacity": "0"},
      300, function() {
      /* after animation is complete we hide the element */
      $(this).hide();
    });
  }
  // See if there is a system already selected as soon as the page loads
  updateSsmToolbarOpacity();

  // This is a function from spacewalk-checkall.js
  create_checkall_checkbox();

  // Adding div wrapping the tables in a div which will make them responsive    
  $(".table").wrap("<div class='table-responsive'>");

});

/* Getting the screen size to create a fixed padding-bottom in the Section tag to make both columns the same size */
// On window load
$(window).load(function () {
  columnHeight();
});

// On window resize
$(window).resize( function () {
  $(".spacewalk-main-column-layout aside").css("padding-bottom", "");
  columnHeight();
});

// Make columns 100% in height
function columnHeight() {
  //Only if the screen size is higher than the max-width set up in the Variables.less under the definition @screen-md: 
  //PLEASE: update this if you change the content of @screen-md
    var asideHeight = $(".spacewalk-main-column-layout aside").height();
    var heightDoc = $(document).height();
    // Column heights should equal the document height minus the header height and footer height
    // header + footer height = 196px; extra 10px to have scrollbar always visible
    var newHeight = heightDoc - asideHeight - 186 + "px";
    $(".spacewalk-main-column-layout aside").css("padding-bottom", newHeight);
};

// returns an object that can be passed to DWR renderer as a callback
// puts rendered HTML in #divId, opens an alert with the same text if
// debug is true
function makeRendererHandler(divId, debug) {
  return makeAjaxHandler(function(text) {
    if (debug) {
      alert(text);
    }
    $('#' + divId).html(text);
    $('#' + divId).fadeIn();
    columnHeight();
  });
}

// returns an object that can be passed to DWR as a callback
// callbackFunction: function to call when AJAX requests succeeds
// errorHandlerFunction: function to call when AJAX requests fail
// (can be omitted for showFatalError)
// works around a DWR bug calling errorHandler when navigating away
// from a page during an AJAX request
function makeAjaxHandler(callbackFunction, errorHandlerFunction) {
    errorHandlerFunction = typeof errorHandlerFunction !== "undefined" ?
      errorHandlerFunction : showFatalError;

    // workaround to a DWR bug that calls errorHandler when user
    // navigates away from page during an AJAX call
    // first, we detect page unloading
    $(window).on("beforeunload", function() {
      $.unloading = true;
    });
    return {
      callback: callbackFunction,
      errorHandler: function(message, exception) {
        // second, if we get an error during unloading we ignore it
        if ($.unloading == true) {
          console.log("Ignoring exception " + exception + " with message " + message + " because it is a DWR error during unload");
        }
        else {
          errorHandlerFunction(message, exception);
        }
      }
    }
}

// shows a fatal DWR/AJAX error
function showFatalError(message, exception) {
  console.log("DWR AJAX call failed with message: " + message);
  console.log(exception);
  alert("Unexpected error, please reload the page and check server logs.");
}


// Extension to Twitter Bootstrap.
// Gives you a col-XX-auto class like Bootstrap
// That dynamically adjust the grid for the columns to take
// as much space as possible while still being responsive
// So three col-md-auto would get col-md-4 each.
// Five col-md-auto would get two with col-md-3 and three with col-md-2
$(document).on("ready", function() {
  $.each(['xs', 'sm', 'md', 'lg'], function(idx, gridSize) {
    //for each div with class row
    $('.col-' + gridSize + '-auto:first').parent().each(function() {
      //we count the number of childrens with class col-md-6
      var numberOfCols = $(this).children('.col-'  + gridSize + '-auto').length;
      if (numberOfCols > 0 && numberOfCols < 13) {
        minSpan = Math.floor(12 / numberOfCols);
        remainder = (12 % numberOfCols);
        $(this).children('.col-' + gridSize + '-auto').each(function(idx, col) {
          var width = minSpan;
          if (remainder > 0) {
            width += 1;
            remainder--;
          }
          $(this).addClass('col-' + gridSize + '-' + width);
        });
      }
    });
  });
});

// Put the focus on a given form element
function formFocus(form, name) {
  var focusControl = document.forms[form].elements[name];
  if (focusControl.type != "hidden" && !focusControl.disabled) {
     focusControl.focus();
  }
}

// Humanizes all the time elements with the human class
function humanizeDates() {
  $("time.human-from, time.human-calendar").each(function (index) {
    var datetime = $(this).attr('datetime');
    if (datetime == undefined) {
      // if the attribute is not set, the content
      // should be a valid date
      datetime = $(this).html();
    }
    var parsed = moment(datetime);
    if (parsed.isValid()) {
      var originalContent = $(this).html();
      if ($(this).hasClass("human-from")) {
        var ref = $(this).attr("data-reference-date");
        if (ref) {
          var refParsed = moment(ref);
          if (refParsed.isValid()) {
            $(this).html(parsed.from(refParsed));
          }
        }
        else {
          $(this).html(parsed.fromNow());
        }
      }
      if ($(this).hasClass("human-calendar")) {
        $(this).html(parsed.calendar());
      }
      // if the original did not had a datetime attribute, add it
      var datetimeAttr = $(this).attr('datetime');
      if (datetimeAttr == undefined) {
        $(this).attr('datetime', datetime);
      }
      // add a tooltip
      $(this).wrap('<a href="#" data-toggle="tooltip" title="' + originalContent + '"></a>');
    }
  });
}

$(document).on("ready", function() {
  humanizeDates();
});

/**
 * Setups ACE editor in a textarea element
 * textarea is a jQuery object
 * mode is the language mode, if emmpty
 * shows a select box to choose it.
 */
function setupTextareaEditor(textarea, mode) {
  var editDiv = $('<div>', {
      position: 'absolute',
      width: textarea.width(),
      height: textarea.height(),
      'class': textarea.attr('class')
  }).insertBefore(textarea);

  var toolBar = $('<div></div>').insertBefore(editDiv[0]);
  textarea.hide();

  var editor = ace.edit(editDiv[0]);
  editor.getSession().setValue(textarea.val());

  editor.setTheme("ace/theme/xcode");
  editor.getSession().setMode("ace/mode/sh");

  // before submitting the code, the textarea
  // should be updated with the editor value
  textarea.closest('form').submit(function () {
      textarea.val(editor.getSession().getValue());
  })

  toolBar.addClass('ace_editor');
  toolBar.css('width', editDiv.css('width'));
  var modeSel = $('<select> \
    <option selected value="sh">Shell</option> \
    <option value="xml">XML</option> \
    <option value="ruby">Ruby</option> \
    <option value="python">Python</option> \
    <option value="perl">perl</option> \
    </select>');
  modeSel.find('option').each(function() {
  if ($(this).text() == mode)
    $(this).attr('selected', 'selected');
  });

  toolBar.append(modeSel);
  if (mode != "") {
    editor.getSession().setMode("ace/mode/" + mode);
    toolBar.hide();
  }

  modeSel.change(function () {
    editor.getSession().setMode("ace/mode/" + $(this).val());
  });

  // Set editor to read only according to data attribute
  editor.setReadOnly(textarea.data('readonly'));
}

/**
 * setups every textarea with data-editor attribute
 * set to some language with an ACE editor
 */
$(function () {
  $('textarea[data-editor]').each(function () {
    var textarea = $(this);
    var mode = textarea.data('editor');
    setupTextareaEditor(textarea, mode);
  });
});

// Disables the enter key from submitting the form
function disableEnterKey() {
  $(window).keydown(function(event){
    if(event.keyCode == 13) {
      event.preventDefault();
      return false;
    }
  });
}
