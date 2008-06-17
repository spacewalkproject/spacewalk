/**
 * Sets a refresh form hidden value and submits the form. Interpreting action
 * can then use this value to recognize that the form data needs to be 
 * refreshed.
 */
function refresh(formName) {
   var form = document.getElementById(formName);
   var refreshForm = document.getElementById("refreshForm");
   refreshForm.value = "true";
   form.submit();
}

