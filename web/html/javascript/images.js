// These functions make use of prototype.js:
function showForm(id, name, version, arch, type, editUrl) {
    // Setup link for editing image
    var nameEsc = name.escapeHTML();
    $('edit-link').update(nameEsc);
    $('edit-link').setAttribute('href', editUrl);
    // Create string representation
    var imgString = "\"" + nameEsc + "\", Version " + version + " (" + arch + ", " + type + ")";
    $('image-string').update(imgString);
    $('image-id').setValue(id);
    // Show form fields and hide table
    $('deployment-form').show();
    $('images-table').hide();
}
// Show table and hide form fields
function showImages() {
    $('images-table').show();
    $('deployment-form').hide();
    // Reset elements
    $('image-id').setValue('');
    $('image-string').update();
    $('edit-link').setAttribute('href', '');
    $('edit-link').update();
}
