// http://www.html5rocks.com/de/tutorials/dnd/basics/
function handleDragStart(e) {
  this.style.opacity = '0.4';  // this / e.target is the source node.
  dragSrcEl = this;
  e.dataTransfer.effectAllowed = 'move';
  e.dataTransfer.setData('text', this.getAttribute("data-value", 0));
}

function handleDragOver(e) {
  if (e.preventDefault) {
    e.preventDefault(); // Necessary. Allows us to drop.
  }
  e.dataTransfer.dropEffect = 'move';  // See the section on the DataTransfer object.
  return false;
}

function handleDragEnd(e) {
  // this/e.target is the source node.
  this.style.opacity = '1';
}

function registerDragAndDrop(selector) {
  var cols = document.querySelectorAll(selector);
  [].forEach.call(cols, function(col) {
    col.addEventListener('dragstart', handleDragStart, false);
    col.addEventListener('dragover', handleDragOver, false);
    col.addEventListener('dragend', handleDragEnd, false);
  });
}


$(document).ready(function() {
  registerDragAndDrop('.tplitem');
});
