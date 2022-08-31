# qt5-qml-sortlistmodel
Implements SortListModel QML component.

It extends the ListModel QML component with the public properties and methods:

 - property int sortOrder     // Qt.AscendingOrder (default) or Qt.DescendingOrder.
 - property var sortRole      // Can be a string or array representation of what to be sorted
 - property var sortCompare   // An Array-like sort comparator function. Not needed if using sortRole.
 - property int sortCount     // number of records that have been sorted.
 - property bool sorted       // indicates whether sorting has finished.
 - property bool sorting      // indicates whether sorting is still ongoing.

it also has the following private methods:

 - method resort() // forces incremental sort to start over.
 - method sortStep() // binary insertion incremental sort loop with pauses every 50ms threshold
 - method defaultSortCompare() // provided sort comparator
 - method findInsertIndex(item, head, tail, compareFunc) // use binary search to find where to move an unsorted item to
 - method sortItem(index) // moves an unsorted record to it's sorted spot

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

To sort both `city` and `pop` roles with `city` having priority set
`sortRole` to a string array.

```qml
SortListModel {
    id: items
    sortRole: [ "city", "pop" ]
    sortOrder: Qt.AscendingOrder
}
```        

To sort `city` and `pop` with differing sortOrders applied set
`sortROle` to an object array.

```qml
SortListModel {
    id: items
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
will sort as many items it can within 50ms before scheduling the next
iteration of `sortStep`.

This improves the user experience with the UI thread always free to
react to user events such as scrolling a ListView whilst a sort is
occuring. It also allows the user to change the sort properties without
needing to wait for an existing sort to complete.

To use SortListModel QML component in your project consider cloning this
repo directly in your project:

    git clone https://github.com/stephenquan/qt5-qml-sortlistmodel.git
    
or adding it as a submodule:

    git submodule add https://github.com/stephenquan/qt5-qml-sortlistmodel.git qt5-qml-sortlistmodel
    git submodule update
