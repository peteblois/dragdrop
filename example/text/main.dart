import 'dart:html';
import 'dart:async';

import 'package:drag_drop/drag_drop.dart';

void main() {
  createDropTarget(['A', 'B', 'C']);
  createDropTarget(['1', '2', '3']);
}

// Creates an Element which acts as a drop target for a list of items.
void createDropTarget(List<String> defaultItems) {
  var list = new OListElement();
  list.classes.add('dropTarget');
  query('.text').append(list);

  // Create the drop target.
  new TextDropTarget(list).drops.listen((text) {
    // Add a new item for the dropped text.
    createDragSource(text, list);
  });

  // Populate the lists with some default items.
  for (var value in defaultItems) {
    createDragSource(value, list);
  }
}

void createDragSource(String text, Element parent) {
  var item = new LIElement();
  item.classes.add('dragItem');
  item.text = text;
  parent.append(item);

  // Create the drag source to make the item draggable, and specify
  // the text which should be dragged.
  new TextDragSource(item, text).moved.listen((_) {
    // Remove the text if it's moved, since we're adding it
    // on the other side.
    item.remove();
  });

  // Grey the item out when it is being dragged.
  item.onDragStart.listen((_) {
    item.classes.add('dragging');
  });

  item.onDragEnd.listen((_) {
    item.classes.remove('dragging');
  });
}
