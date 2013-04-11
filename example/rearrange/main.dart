import 'dart:html';
import 'dart:async';
import 'dart:json' as json;
import 'package:drag_drop/drag_drop.dart';

/**
 * This uses the browser's drag/drop system to implement a rearranging list.
 *
 * Basically for each item in the list we make a container which looks like:
 *     <div class='dragItem'>
 *       <div class='dropBeforeTarget'></div>
 *       <div> item content </div>
 *       <div class='dropAfterTarget'></div>
 *     </div>
 *
 * (The CSS class names are purely for styling and not functional otherwise.)
 *
 * Each item which can be dragged has an associated ObjectDragSource, then we
 * create invisible drop targets before and after the element to process drop
 * events.
 */

void main() {
  createListItems(["One", "Two", "Three", "Four", "Five"]);
}

// A unique mime type for the data. Every data type should use a unique mime
// type.
var mimeType = 'application/dart-map-data';

void createListItems(List items) {
  var list = query('.rearrangeList');

  // Map of element to data item so we can move elements when the data is moved.
  var elementMap = {};

  // Called when data has to be moved to a new location.
  void moveToBefore(data, reference) {
    var idx = items.indexOf(data);
    items.removeAt(idx);

    var refIdx = items.indexOf(reference);
    var dstIdx = (refIdx - 1).clamp(0, items.length);
    items.insert(dstIdx, data);

    list.insertBefore(elementMap[data], elementMap[reference]);
  }

  // Called when data has to be moved to a new location.
  void moveToAfter(data, reference) {
    var idx = items.indexOf(data);
    items.removeAt(idx);

    var refIdx = items.indexOf(reference);
    var dstIdx = (refIdx + 1).clamp(0, items.length);
    items.insert(dstIdx, data);

    list.insertBefore(elementMap[data], elementMap[reference].nextNode);
  }

  // Create the list items for all of our data items.
  for (var item in items) {
    var element = createListItem(item, list, moveToBefore, moveToAfter);
    elementMap[item] = element;
  }
}

/**
 * Creates the element tree for each item in the list.
 *
 * This tree includes drop targets for insertion points.
 */
Element createListItem(data, list, moveToBefore, moveToAfter) {
  var itemContainer = new DivElement();
  itemContainer.classes.add('dragItem');
  list.append(itemContainer);

  createDropTarget('Before', itemContainer).moves.listen((dropData) {
    // Handle move events to do the actual processing.
    moveToBefore(dropData, data);
  });
  createDropTarget('After', itemContainer).moves.listen((dropData) {
    moveToAfter(dropData, data);
  });

  // This is the actual element representing the item data.
  var item = new LIElement();
  item.text = data.toString();
  itemContainer.append(item);

  // The entire container can be dragged.
  new ObjectDragSource(itemContainer, mimeType, data);

  // Grey the item out when it is being dragged.
  itemContainer.onDragStart.listen((_) {
    item.classes.add('dragging');
  });

  itemContainer.onDragEnd.listen((_) {
    item.classes.remove('dragging');
  });

  return itemContainer;
}

/**
 * Helper to create before or after drop targets.
 * Name should be either 'Before' or 'After'.
 */
ObjectDropTarget createDropTarget(String name, Element container) {
  var target = new DivElement();
  target.classes.addAll(['dropTarget', 'drop${name}Target']);
  container.append(target);

  // Add classes when dragging over so the items sort of push out of the way.
  target.onDragEnter.listen((_) {
    container.classes.add('drop${name}Hover');
  });
  target.onDragLeave.listen((_) {
    container.classes.remove('drop${name}Hover');
  });
  target.onDrop.listen((_) {
    container.classes.remove('drop${name}Hover');
  });

  // Only allow dropping on before & after targets.
  return new ObjectDropTarget(target, mimeType);
}
