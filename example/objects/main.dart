import 'dart:html';
import 'dart:async';
import 'dart:json' as json;

import 'package:drag_drop/drag_drop.dart';

void main() {
  createDropTarget([{'C': 1}, {'B': 2}, {'C': 3}]);
  createDropTarget([{'1': 'C'}, {'2': 'B'}, {'3': 'C'}]);
}

// A unique mime type for the data. Every data type should use a unique mime
// type.
var mimeType = 'application/dart-map-data';

void createDropTarget(List<Map> defaultItems) {
  var list = new OListElement();
  list.classes.add('dropTarget');
  query('.text').append(list);

  // Add some highlights for drag enter/leave.
  list.onDragEnter.listen((_) {
    list.classes.add('dragOver');
  });
  list.onDragLeave.listen((_) {
    list.classes.remove('dragOver');
  });
  list.onDragEnd.listen((_) {
    list.classes.remove('dragOver');
  });

  // Create the drop target.
  new ObjectDropTarget<Map>(list, mimeType).moves.listen((object) {
    // Add a new item for the dropped text.
    createDragSource(object, list);
  });

  // Populate the lists with some default items.
  for (var value in defaultItems) {
    createDragSource(value, list);
  }
}

void createDragSource(Map object, Element parent) {
  var item = new LIElement();
  item.classes.add('dragItem');
  item.text = json.stringify(object);
  parent.append(item);

  // Create the drag source to make the item draggable,
  // specify the unique mimeType so we identify drop data types and
  // speciify the data which should be dragged.
  new ObjectDragSource(item, mimeType, object).moved.listen((_) {
      // Remove the object if it's moved, since we're adding it
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
