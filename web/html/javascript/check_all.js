create_checkall_checkbox();

function blockEnter(evt) {
    evt = (evt) ? evt : event;
    var charCode = (evt.charCode) ? evt.charCode :((evt.which) ? evt.which : evt.keyCode);
    if (charCode == 13) {
        return false;
    } else {
        return true;
    }
}

function create_checkall_checkbox() {
  var checkall = document.getElementById("rhn_javascriptenabled_checkall_checkbox");

  if (checkall) {
    checkall.style.display = "inline";
  }

  var update_list_key = document.getElementById("update_list_key_id");
  if (update_list_key) {
    update_list_key.style.display = "none";
  }
}

function check_all_on_page(form, set_label) {
  var form_name = form.name;
  if (form_name == "") {
    form_name = form.id;
  }
  var flag = eval("document.forms['" + form_name + "'].checkall.checked");
  var cboxes = eval("document.forms['" + form_name + "'].items_selected");
  process_check_all(set_label, cboxes, flag, []);
}

function process_check_all(set_label, cbox_items, flag, ignorables_ids) {
    var ignorables = ids_to_elements(ignorables_ids);
    var cboxes = new Array();
    cboxes = cboxes.concat(ignorables); 
    if (cbox_items.length) {
        for (var i = 0 ; i < cbox_items.length; i++) {
            cboxes.push(cbox_items[i]);
        }
    }
    else {
        //for a single element check box
        //push the form element
        cboxes.push(cbox_items);
    }

    var boxes = process_group(set_label, cboxes, flag);
    var includes = new Array();
    for (var i = 0; i < boxes.length; i++) {
        var include = true;
        for (var j = 0; j < ignorables.length; j++) {
            if (ignorables[j].value == boxes[i]) {
                include = false;
                break;
            }
        }
        if (include) {
            includes.push(boxes[i]);
        }
    }
    update_server_set("ids", set_label, flag, includes); 
}

function ids_to_elements(elem_ids) {
    var elements = new Array();
    for (var i = 0; i < elem_ids.length; i++) {
        elements.push(document.getElementById(elem_ids[i]));
    }
    return elements;
}


function process_group(set_label, cboxes, flag) {
  var i;
  var changed = new Array();

  if (cboxes.length) {
    for (i = 0; i < cboxes.length; i++) {
      //check the box only if it is enabled
      if (!cboxes[i].disabled) {
        if (cboxes[i].checked != flag) {
          changed.push(cboxes[i].value);
        } //if
        cboxes[i].checked = flag;
      } //if
    } //for
  } //if
  else {
    if (cboxes.checked != flag) {
      changed.push(cboxes.value)
    }
    cboxes.checked = flag;
  }
  return changed;
}

function checkbox_clicked(thebox, set_label) {
  var form_name = thebox.form.name;
  if (form_name == "") {
    form_name = thebox.form.id;
  }
  var  checkall = eval("document.forms['" + form_name + "'].checkall");
  process_checkbox_clicked(thebox, set_label, checkall, [], [],"", true);
}


/**
 * This method is called when a single checkbox is clicked
 * thebox - The check box that was clicked
 * set_label  - The rhnSet label of the checkbox that was clicked
 * checkall - The link to the select all box
 * 
 * If this list tag is using some sort of tree/grouping structure
 * 
 * children - if this is a parent node then list the children or [] otherwise
 * members - if this is a child node then list the siblings and include the child or [] otherwise
 * parent_id - if this is a child node then list the parent_id or [] otherwise
 **/

function process_checkbox_clicked(thebox, set_label, checkall, children, members, parent_id, parentIsElement) {
    var a =  process_checkbox_clicked_client_side(thebox, set_label, checkall, children, members, parent_id, parentIsElement);
    update_server_set("ids", set_label, thebox.checked, a);
}

function process_checkbox_clicked_client_side(thebox, set_label, checkall, children, members, parent_id, parentIsElement) {
    var a = new Array();
    if (parent_id == '') {
        if(parentIsElement) {
            a.push(thebox.value);
        }
    }
    else {
        a.push(thebox.value);
    }
    
    var checkboxes = new Array();    
    for (var i = 0; i < children.length; i++) {
        var checkbox = document.getElementById(children[i]);
        checkboxes.push(checkbox);
        a.push(checkbox.value);
    }
    if (checkboxes.length > 0) {
        process_group(set_label, checkboxes, thebox.checked);
    }

    if (parent_id) {
        var parentBox = document.getElementById(parent_id);
        var boxes = ids_to_elements(members) ;
        process_single_checkbox(boxes, parentBox);
    }
    var form_name = thebox.form.name;
    if (form_name == "") {
        form_name = thebox.form.id;
    }
    var cboxes = eval("document.forms['" + form_name + "']." + thebox.name);
    process_single_checkbox(cboxes, checkall);
    return a;
}



function process_single_checkbox(cboxes, checkall) {
  var i;
  var count_checked_or_disabled = 0;
  var all_checked = false;
  if (cboxes.length) {
    for (i = 0; i < cboxes.length; i++) {
      if (cboxes[i].checked || cboxes[i].disabled) {
        count_checked_or_disabled++;
      }
    }

    if (count_checked_or_disabled == cboxes.length) {
      all_checked = true;
    }
  }
  else {
    if (cboxes.checked) {
      all_checked = true;
    }
  }
  if (checkall) {
	checkall.checked = all_checked;
  }
}

function update_server_set(variable, set_label, checked, values) {
    DWRItemSelector.select(set_label, values, checked,pageResponse);
}

function pageResponse(data) {
    var resp = eval(data);
    if (typeof(resp['header']) != 'undefined') {
            dwr.util.setValue("header_selcount", resp.header, {escapeHtml: false});
    }
    dwr.util.setValue("pagination_selcount_top", resp.pagination);
    dwr.util.setValue("pagination_selcount_bottom", resp.pagination);
}

function sortColumn(sortByWidget, sortByValue, sortDirWidget, sortDirValue) {
     var sortBy = document.getElementById(sortByWidget); 
     sortBy.value = sortByValue;
     var sortDir = document.getElementById(sortDirWidget);
     sortDir.value = sortDirValue;
     sortBy.form.submit();
}
