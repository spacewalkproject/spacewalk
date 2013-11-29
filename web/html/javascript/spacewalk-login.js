$(document).on("ready", function() {
  $("aside").remove();
  var me = $("section");
  var newMe = $("<div class='login-page'>");
  newMe.html(me.html());
  me.replaceWith(newMe);
  formFocus('loginForm', 'username');
});

