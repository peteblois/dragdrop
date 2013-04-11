part of drag_drop;

/**
 * Drag source for text data.
 *
 * This will allow data to be passed between this browser window
 * and other applications using the text data type.
 */
class TextDragSource extends DragSource {
  // The text to be dragged.
  String text;
  // Default dragging to allow both copy and move.
  String allowedEffects = 'copyMove';
  final StreamController _moved = new StreamController();
  static const TEXT_MIME_TYPE = 'text/plain';

  TextDragSource(Element target, [String text]):
      super(target),
      this.text = text {
  }

  void processDragStart(MouseEvent e) {
    var data = text;
    if (data != null) {
      e.dataTransfer.setData(TEXT_MIME_TYPE, text);
      e.dataTransfer.effectAllowed = allowedEffects;
    }
  }

  void moveData(DataTransfer data) {
    _moved.add(data);
  }

  /**
   * Notification that this drag source has been dropped
   * resulting in a request to move the data.
   */
  Stream<DataTransfer> get moved => _moved.stream;
}

/**
 * Drop target for text data.
 *
 * This is used to accept drop operations of text. It can interop with other
 * browser windows and in some cases other applications on the local machine.
 *
 * This class can also be used in conjunction with [TextDragSource]
 */
class TextDropTarget extends DropTarget {
  final StreamController<String> _controller =
      new StreamController<String>();

  TextDropTarget(Element target): super(target) {
  }

  Stream<String> get drops => _controller.stream;

  bool canCopy(DataTransfer data) {
    return data.types != null && data.types.contains(TextDragSource.TEXT_MIME_TYPE);
  }
  bool copyData(DataTransfer data) {
    _controller.add(data.getData(TextDragSource.TEXT_MIME_TYPE));
    return true;
  }

  bool canMove(DataTransfer data) {
    return data.types != null && data.types.contains(TextDragSource.TEXT_MIME_TYPE);
  }
  bool moveData(DataTransfer data) {
    _controller.add(data.getData(TextDragSource.TEXT_MIME_TYPE));
    return true;
  }
}
