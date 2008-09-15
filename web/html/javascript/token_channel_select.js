function base_channel_selected() {

  var i;
  var channels = document.edit_token.token_channels;
  for (i = 0; i < channels.options.length; i++) {
    channels.options[i].selected = false;
  }

//  var elems = document.edit_token.elements;
/*  var msg;

  for (i = 0; i < elems.length; i++) {
    msg += elems[i].name + "\n";
  }

  alert(msg);
*/
//  document.all.header.disabled = true;

//  document.edit_token.token_channels.options.length = 0;
//  document.edit_token.token_channels.optgroups.length = 0;
//  alert("PING!");

}