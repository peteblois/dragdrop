part of drag_drop;

/**
 * Drag source for drag/dropping in-memory Dart objects.
 *
 * The objects are kept in memory and never serialized to the clipboard so
 * this is more appropriate for complex data structures.
 *
 * This is intended to be used in conjunction with [ObjectDropTarget].
 */
class ObjectDragSource<T> extends DragSource {
  static var _currentDragData;

  final StreamController _moved = new StreamController();
  final StreamController _copied = new StreamController();
  final String mimeType;
  // Disable copy by default.
  String allowedEffects = 'move';
  T object;

  /**
   * The mime type should be shared between all drag/drop sources and targets
   * which allow dragging of the same data type.
   *
   * Use unique mime types to differentiate items which cannot be dropped in
   * certain locations.
   */
  ObjectDragSource(Element target, String mimeType, [T object]):
      super(target),
      this.object = object,
      this.mimeType = mimeType {
  }

  void processDragStart(MouseEvent e) {
    var data = object;
    // Cache it statically since we're keeping it in-memory.
    _currentDragData = object;
    if (data != null) {

      // We just set some dummy data as the data
      // will remain in-memory.
      !e.dataTransfer.setData(mimeType, 'placeholder');
      e.dataTransfer.effectAllowed = allowedEffects;
    }
  }

  void moveData(DataTransfer data) {
    _moved.add(data);
  }
  Stream<DataTransfer> get moved => _moved.stream;

  void copyData(DataTransfer data) {
    _copied.add(data);
  }
  Stream<DataTransfer> get copied => _copied.stream;
}


/**
 * Drop target for drag/dropping in-memory Dart objects.
 *
 * The objects are kept in memory and never serialized to the clipboard so
 * this is more appropriate for complex data structures.
 *
 * This is intended to be used in conjunction with [ObjectDragSource].
 */
class ObjectDropTarget<T> extends DropTarget {
  final String mimeType;
  final StreamController<T> _moves = new StreamController<T>();
  final StreamController<T> _copies = new StreamController<T>();

  /**
   * The [mimeType] may need to be a standard MIME type (such as
   * `application/my-data`).
   */
  ObjectDropTarget(Element target, String mimeType):
      super(target),
      this.mimeType = mimeType {
  }

  bool canCopy(DataTransfer data) {
    return data.types != null &&
        data.types.contains(this.mimeType) &&
        ObjectDragSource._currentDragData != null;
  }

  bool copyData(DataTransfer data) {
    var object = ObjectDragSource._currentDragData;
    if (object != null) {
      return copyObject(object);
    }
    return false;
  }

  bool copyObject(T object) {
    _copies.add(object);
    return true;
  }

  bool canMove(DataTransfer data) {
    return data.types != null &&
        data.types.contains(this.mimeType) &&
        ObjectDragSource._currentDragData != null;
  }
  bool moveData(DataTransfer data) {
    var object = ObjectDragSource._currentDragData;
    if (object != null) {
      return moveObject(object);
    }
    return false;
  }

  bool moveObject(T object) {
    _moves.add(object);
    return true;
  }

  Stream<T> get moves => _moves.stream;
  Stream<T> get copies => _copies.stream;
}
