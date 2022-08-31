# qt5-qml-sortlistmodel
Implements SortListModel QML component.

It extends the ListModel QML component with the public properties and methods:

 - property int sortOrder     // Qt.AscendingOrder (default) or Qt.DescendingOrder.
 - property var sortRole      // Can be a string or array representation of what to be sorted
 - property var sortCompare   // An Array-like sort comparator function. Not needed if using sortRole.
 - property int sortCount     // number of records that have been sorted.
 - property bool sorted       // indicates whether sorting has finished.
 - property bool sorting      // indicates whether sorting is still ongoing.
 - method resort() // forces incremental sort to start over.

it also has the following private methods:

 - method naturalExpand(str) // pads all numbers in the string to 8 digits
 - method naturalCompare(a, b) // compares two strings with the numbers normalized with naturalExpand
 - method sortStep() // binary insertion incremental sort loop with pauses every 50ms threshold
 - method defaultSortCompare() // provided sort comparator
 - method findInsertIndex(item, head, tail, compareFunc) // use binary search to find where to move an unsorted item to
 - method sortItem(index) // moves an unsorted record to its sorted spot

These methods help us implement an in-place sort.

It requires the record to already be in the ListModel, typically placed at the end with `append`.
1 or more `append` will trigger `onCountChanged` and, in turn, trigger calls to `sortStep`.

For example:

```qml
import "qt5-qml-sortlistmodel"

Page {
    ListView {
        anchors.fill: parent
        model: cities
        clip: true
        delegate: Text {
            width: ListView.view.width
            text: city
        }
    }

    SortListModel {
        id: cities
        sortRole: "city"
        sortOrder: Qt.AscendingOrder
        Component.onCompleted: {
            append( { city: "Melbourne", pop: 5078000 } );
            append( { city: "Paris", pop: 2161000 } );
            append( { city: "New York", pop: 8380000 } );
        }
    }
}
```

The `sortRole` can be a string, string array or an object array.
This is to support sorting based on 1 or many columns and in different
direction.

To sort just the `city` we only need to set `sortRole` to a string.

```qml
SortListModel {
    id: cities
    sortRole: "city"
    sortOrder: Qt.AscendingOrder
}
```
    
To sort both `city` and `pop` roles with `city` having priority set
`sortRole` to a string array.

```qml
SortListModel {
    id: cities
    sortRole: [ "city", "pop" ]
    sortOrder: Qt.AscendingOrder
}
```        

To sort `city` and `pop` with differing sortOrders applied set
`sortRole` to an object array.

```qml
SortListModel {
    id: cities
    sortRole: { [ { "sortRole": "city",
                    "sortOrder": Qt.AscendingOrder },
                  { "sortRole": "pop",
                    "sortOrder": Qt.DescendingOrder } ] )
}
```        

The algorithm implements an incremental merge sort so unsorted items get
scheduled to be sorted.

The private method `sortStep` is invoked repeatedly with `Qt.callLater`
to incrementally merge sort the entire list. Each iteration of `sortStep`
will sort as many items it can within a 50ms threshold before scheduling
the next invocation of `sortStep`.

This improves the user UI/UX experience. The application can:
 - react to user events such as scrolling the ListView
 - append more records to the ListModel whilst a sort is in progress
 - change sortRole to reset the incremental sort without waiting

If the list is mostly sorted, the incremental sort will quickly locate the
unsorted items and sort them in less time that it takes to do a full sort.

To use SortListModel QML component in your project consider cloning this
repo directly in your project:

    git clone https://github.com/stephenquan/qt5-qml-sortlistmodel.git
    
or adding it as a submodule:

    git submodule add https://github.com/stephenquan/qt5-qml-sortlistmodel.git qt5-qml-sortlistmodel
    git submodule update
