

function get_row(element) {
	if (element.parentNode && element.parentNode.parentNode) {
	    return element.parentNode.parentNode;
	}
	else if (element.parentElement && element.parentElement.parentElement) {
	    return element.parentElement.parentElement;
	}
}


function find_in_row(row, name_start) {

	var par = null;
	var elem = null;

	for(var i = 0; i < row.childNodes.length; i++) {

		par = row.childNodes.item(i);

		for (var j = 0; j < par.childNodes.length; j++) {

			elem = par.childNodes.item(j);
			//alert("elem.name:  " + elem.name);
			if (elem.name != null && elem.name.indexOf(name_start) == 0) {
				return elem;
			}
		}
	}

	return null;
}

function toggle_row(element, toggle_class_root, selected) {

	var row = get_row(element);
	//var selected = null;
	var odd_selected = toggle_class_root + "-odd-selected";
	var even_selected = toggle_class_root + "-even-selected";
	

	if (toggle_class_root == null) {
		toggle_class_root = "list-row";
	}

	//selected = ((row.className == 'list-row-odd') || (row.className == 'list-row-even'));
	//selected = selected || element.checked;

	if (selected) {
		select_row(row, toggle_class_root);
	}
	else {
		unselect_row(row, toggle_class_root);
	}
}

function select_row(row, class_root) {

    var odd_index = row.className.indexOf("odd");
    var even_index = row.className.indexOf("even");

    if (odd_index > 0) {
	row.className = class_root + "-odd-selected";
    }
    else if (even_index > 0) {
	row.className = class_root + "-even-selected";
    }
}

function unselect_row(row) {
    var odd_index = row.className.indexOf("odd");
    var even_index = row.className.indexOf("even");

    if (odd_index > 0) {
	row.className = "list-row-odd";
    }
    else if (even_index > 0) {
	row.className = "list-row-even";
    }
}