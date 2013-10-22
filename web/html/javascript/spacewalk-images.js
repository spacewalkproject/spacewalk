// Show form and hide the images table
function showForm(id, name, version, arch, type, editUrl) {
  // Setup link for editing image
  $('#edit-link').text(name);
  $('#edit-link').prop('href', editUrl);
  // Create string representation
  var imgString = "\"" + name + "\", Version " + version + " (" + arch + ", " + type + ")";
  $('#image-string').text(imgString);
  $('#image-id').val(id);
  // Show form fields and hide table
  $('#deployment-form').show();
  $('#images-table').hide();
}
// Show table and hide form fields
function showImages() {
  $('#images-table').show();
  $('#deployment-form').hide();
  // Reset elements
  $('#image-id').val('');
  $('#image-string').empty();
  $('#edit-link').prop('href', '');
  $('#edit-link').empty();
}

