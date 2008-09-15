EXPANDER_CLOSED = '/img/list-expand.gif';
EXPANDER_OPEN = '/img/list-collapse.gif'; 

function toggleExpander(secretId, imageId) {
  if (isVisible(imageId)) {
    hide(secretId, imageId);
  }
  else if (!isVisible(imageId)) {
    show(secretId, imageId);
  }
  return; 
}

function getImage(imageId) {
  return document.getElementById(imageId);
}

function getSecret(secretId) {
  return document.getElementById(secretId);
}

function show(secretId, imageId) {
  getImage(imageId).src = EXPANDER_OPEN;
  getSecret(secretId).style.display = 'block';
}

function hide(secretId, imageId) {
  getImage(imageId).src = EXPANDER_CLOSED;
  getSecret(secretId).style.display = 'none';
}

function isVisible(imageId) {
  if (getImage(imageId).src.indexOf(EXPANDER_CLOSED) >= 0) {
    return 0;
  }
    return 1;
}
