
part of drag_drop;

/**
 * Base class which handles initiating drag operations as part of
 * the drag/drop for elements.
 *
 * This makes the element draggable and sets up the event handlers to
 * initiate and process drag/drop operations.
 *
 * A drag source can also be a drop target if an object can both be dragged
 * and dropped onto.
 *
 */
abstract class DragSource {
  final Element _target;
  StreamSubscription _dragEndSubscription;

  DragSource(this._target) {
    _target.draggable = true;
    _target.onDragStart.listen(_handleDragStart);
  }

  void _handleDragStart(MouseEvent e) {
    if (_dragEndSubscription != null) {
      _dragEndSubscription.cancel();
      _dragEndSubscription = null;
    }
    processDragStart(e);

    _dragEndSubscription = _target.onDragEnd.listen(_handleDragEnd);
  }

  /**
   * Called when a drag/drop operation has started on the element.
   */
  void processDragStart(MouseEvent e);

  /**
   * Called when a drop operation has ended as a 'move' effect.
   *
   * Normally the processing of this is done from the drop target but it can
   * be useful to do cleanup here.
   */
  void moveData(DataTransfer e) {}

  /**
   * Called when a drop operation has ended as a 'copy' effect.
   *
   * Normally the processing of this is done from the drop target but it can
   * be useful to do cleanup here.
   */
  void copyData(DataTransfer e) {}

  /**
   * Called when a drop operation has ended as a 'link' effect.
   *
   * Normally the processing of this is done from the drop target but it can
   * be useful to do cleanup here.
   */
  void linkData(DataTransfer e) {}

  void _handleDragEnd(MouseEvent e) {
    if (e.dataTransfer.dropEffect == 'move') {
      moveData(e.dataTransfer);
    }
    if (e.dataTransfer.dropEffect == 'copy') {
      copyData(e.dataTransfer);
    }
    if (e.dataTransfer.dropEffect == 'link') {
      linkData(e.dataTransfer);
    }
    _dragEndSubscription.cancel();
    _dragEndSubscription = null;
  }
}


/**
 * Base class which handles drop operations as part of the drag/drop flow for
 * elements.
 */
abstract class DropTarget {
  final Element target;

  DropTarget(this.target) {
    target.onDragOver.listen(_handleDragOver);
    target.onDrop.listen(_handleDrop);
  }

  /**
   * Default processing when a drag over event occurs on the element.
   *
   * This will be called every time the mouse moves while dragging over
   * the element this is using.
   *
   * This will detect what drop operations are supported for the drag
   * data and specify them on the drag event.
   */
  void processDragOver(MouseEvent e) {
    var effect = determineDropEffect(e);
    var supported = false;
    switch(effect) {
      case 'copy':
        supported = canCopy(e.dataTransfer);
        break;
      case 'move':
        supported = canMove(e.dataTransfer);
        break;
      case 'link':
        supported = canLink(e.dataTransfer);
        break;
    }
    if (supported) {
      e.dataTransfer.dropEffect = effect;
      e.preventDefault();
    } else {
      e.dataTransfer.dropEffect = 'none';
      if (e.dataTransfer.types != null) {
        print('drag over of unsupported: ${e.dataTransfer.types.join(",")}');
      } else {
        // Can happen when dragging non-standard data formats
        // from another app.
        print('drag over of empty type');
      }
    }
  }

  /**
   * Determines what the drop operation should be for the given event.
   *
   * By default this will invoke 'move' operations unless the control key is
   * down when this will invoke a 'copy' operation.
   */
  String determineDropEffect(MouseEvent e) {
    var allowed = e.dataTransfer.effectAllowed.toLowerCase();
    if (e.ctrlKey && allowed.contains('copy') || allowed.contains('all')) {
      return 'copy';
    } else if (allowed.contains('move') || allowed.contains('all')) {
      return 'move';
    } else if (allowed.contains('copy') || allowed.contains('all')) {
      return 'copy';
    }
    return 'none';
  }

  /**
   * Checks if the data can be copied.
   */
  bool canCopy(DataTransfer data) {
    return false;
  }

  /**
   * Checks if the data can be moved.
   */
  bool canMove(DataTransfer data) {
    return false;
  }

  /**
   * Checks if the data can be linked.
   */
  bool canLink(DataTransfer data) {
    return false;
  }

  /**
   * Default processing for drop events which have fired on this element.
   */
  void processDrop(MouseEvent e) {
    var processed = false;
    var dropEffect = _getDropEffect(e);
    switch(dropEffect) {
      case 'copy':
        processed = copyData(e.dataTransfer);
        break;
      case 'move':
        processed = moveData(e.dataTransfer);
        break;
      case 'link':
        processed = linkData(e.dataTransfer);
        break;
    }
    if (processed) {
      e.preventDefault();
    }
  }

  bool copyData(DataTransfer data) {
    return false;
  }

  bool moveData(DataTransfer data) {
    return false;
  }

  bool linkData(DataTransfer data) {
    return false;
  }

  String _getDropEffect(MouseEvent e) {
    // Chrome bug 39399- dropEffect is not always set from onDrop.
    if (e.dataTransfer.dropEffect == 'none') {
      return determineDropEffect(e);
    }
    return e.dataTransfer.dropEffect;
  }

  void _handleDragOver(MouseEvent e) {
    processDragOver(e);
  }

  void _handleDrop(MouseEvent e) {
    processDrop(e);
  }
}
