/**
 * Sets a refresh form hidden value and submits the form. Interpreting action
 * can then use this value to recognize that the form data needs to be 
 * refreshed.
 */
$(function() {
  $(".refreshes-form").change(function(){
    var refreshFormHidden = $("#refreshForm");
    refreshFormHidden.val(true);
    refreshFormHidden.closest("form").submit();
  });
});
