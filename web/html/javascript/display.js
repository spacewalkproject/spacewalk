/**
 * Toggles display attribute between '' and 'none' for all
 * elements on a page matching the name passed in.
 */
function toggleVisibilityByName(name) {
    var items = document.getElementsByName(name);
    for (var i = 0; i < items.length; i++) {
        items[i].style.display = items[i].style.display? "":"none";
    }
}
