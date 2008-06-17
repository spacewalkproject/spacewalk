/**
 * Puts focus on an element in a form.
 */
function formFocus(form, name) {
  var focusControl = document.forms[form].elements[name];

  if (focusControl.type != "hidden" && !focusControl.disabled) {
     focusControl.focus();
  }
}
