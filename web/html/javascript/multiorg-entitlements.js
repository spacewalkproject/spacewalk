var rowHash = new Array();
var browserType;
var columnsPerRow;
 
// tip of the Red Hat to Mar Orlygsson for this little IE detection script
var is_ie/*@cc_on = {
 quirksmode : (document.compatMode=="BackCompat"),
 version : parseFloat(navigator.appVersion.match(/MSIE (.+?);/)[1])
}@*/;
browserType = is_ie;

function onLoadStuff(columns) {
 var channelTable = document.getElementById('multiorg-entitlement-listview');
 createParentRows(channelTable, rowHash);
 reuniteChildrenWithParents(channelTable, rowHash);
 hideAllRows();
}

function createParentRows(channelTable, rowHash) {
 for (var i = 0; i < channelTable.rows.length; i++) {
  tableRowNode = channelTable.rows[i];

  var rowParentDiv = getRowParentDiv(tableRowNode);
  if (rowParentDiv) {
    tableRowNode = rowParentDiv;
    if (!tableRowNode.id) { continue; }
    id = tableRowNode.id;
    var toolTip = findRowToolTip(id);
    if (!toolTip) { continue; }
    rowHash[id] = new Row(rowParentDiv, toolTip);
  }
 }
 return;
}

function Row(parentDiv, toolTip) {
 this.parentDiv = parentDiv;
 this.children = parentDiv.children;
 this.toolTip = toolTip;
 this.isHidden = 1; // 1 = hidden; 0 = visible. all rows are hidden by default
 
 // Row object methods below!
 this.toggleVisibility = function() {
  hideAllRows();
  this.show();
  return;
 }
 
 this.hide = function hide() {
  this.toolTip.style.visibility = 'hidden';
  this.isHidden = 1;
  return;
 }

 this.show = function show() {
  this.toolTip.style.visibility = 'visible';
  this.isHidden = 0;
  return;
 }
}

/* return 0 if not a parent, if a parent of a parent, return the node for the parent div */
function getRowParentDiv(node) {
 /* make sure it's a tr */
 var trNodeInLowercase = getNodeTagName(node);
 var tdNode = null;
 var divNode = null;

 if (trNodeInLowercase != 'tr') { return 0; }

 /* now, iterate through the tds */
 for (var j = 0; j < node.childNodes.length; j++) {
  tdNode = node.childNodes[j];
  if (getNodeTagName(tdNode) != 'td') { continue; }
  if (tdNode.childNodes.length >= 3) {
   for (var k = 0; tdNode.childNodes[k]; k++) {
    divNode = tdNode.childNodes[k];
    if (getNodeTagName(divNode) != 'div') { continue; }
     if (divNode.id.indexOf('id')) { return 0; }
      return divNode;
   }
  }
 }
}

function findRowToolTip(id) {
 var toolTipId = id + '-tooltip';
 return document.getElementById(toolTipId);
}

function hideAllRows() {
 var row;
 for (var i in rowHash) {
  row = rowHash[i];
  if (!row) { continue; }
  if (!rowHash[i].toolTip) { continue; }
  row.hide();
 }
 return;
}

function showAllRows() {
 var row;
 for (var i in rowHash) {
  row = rowHash[i];
  if (!row) { continue; }
  if (!rowHash[i].toolTip) { continue; }
  row.show();
 }
 return;
}




// called from clicking the show/hide button on individual rows in the page
function toggleRowVisibility(id) {
 if (!rowHash[id]) { return; }
 if (!rowHash[id].hasChildren) { return; }
 rowHash[id].toggleVisibility();
 return;
}

function reuniteChildrenWithParents(channelTable, rowHash) {
 var parentNode;
 var childId;
 var tableChildRowNode;
 for (var i = 0; i < channelTable.rows.length; i++) {
  tableChildRowNode = channelTable.rows[i];
  // when we find a parent, set it as parent for the children after it
  if (getRowParentDiv(tableChildRowNode) && tableChildRowNode.id) {
   parentNode = tableChildRowNode;
   continue;
  }
  if (!parentNode) { continue; }

  // it its not a child node we bail here
  if (!isChildRowNode(tableChildRowNode)) { continue; }
  // FIXME: chceck child id against parent id
  if (!rowHash[parentNode.id]) { continue; }
  for (var j = 0; j < tableChildRowNode.cells.length; j++) {
   rowHash[parentNode.id].cells.push(tableChildRowNode.cells[j]);
   rowHash[parentNode.id].hasChildren = 1;
  }
 }
 return;
}

function getNodeTagName(node) {
 var tagName;
 var nodeId;
 tagName = new String(node.tagName);
 return tagName.toLowerCase();
}

function isChildRowNode(node) {
 var nodeInLowercase = getNodeTagName(node);
 var nodeId;
 if (nodeInLowercase != 'tr') { return 0; }
 nodeId = node.id;
 if (nodeId.indexOf('child')) { return 0; }
 return 1;
}
