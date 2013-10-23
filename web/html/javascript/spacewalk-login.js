$(document).on("ready", function() {
  $("aside").remove();
  var me = $("section");
  var newMe = $("<div class='login-page'>");
  newMe.html(me.html());
  me.replaceWith(newMe);
  formFocus('loginForm', 'username');
});

// Put focus on a form element
function formFocus(form, name) {
  var focusControl = document.forms[form].elements[name];
  if (focusControl.type != "hidden" && !focusControl.disabled) {
     focusControl.focus();
  }
}

