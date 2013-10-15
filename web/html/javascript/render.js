function makeAjaxCallback(divId, debug) {
   cb = function(text) {
      if (debug) {
         alert(text);
      }
      $('#' + divId).html(text);
      $('#' + divId).fadeIn();
      columnHeight();
   };
   return cb;
}
