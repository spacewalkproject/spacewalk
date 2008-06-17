function makeAjaxCallback(divId, debug) {
   cb = function(text) {
      div = document.getElementById(divId);
      if (debug) {
         alert(text);
      }
      div.innerHTML = text;
      new Effect.Appear(divId);
   };
   return cb;
}
