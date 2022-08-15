# qt5-qml-sortlistmodel
Implements SortListModel QML component.

It extends the ListModel QML component with the public properties and methods:

 - property int sortOrder
 - property var sortRole
 - property var sortCompare
 - method resort()

it also has the following private methods:

 - method sortMore()
 - method defaultCompare()
 - method findInsertIndex(item, head, tail, compareFunc)
 - method sortItems(head, tail, compareFunc)

These methods help us implement an in-place sort.

It requires the record to already be in the ListModel, typically at the
end with `append` and moved to the correct place with `incrementalSort`.

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
    
    footer: RowLayout {
        Button {
            text: qsTr("Random City")
            onClicked: {
                const list = [ "Melbourne", "Paris", "New York" ];
                const city = list[Math.floor(Math.random() * list.length)];
                cities.append( { city  } );
            }
        }
    }

    SortListModel {
        id: cities
        sortRole: "city"
        sortOrder: Qt.AscendingOrder
    }
}
```

The `sortRole` can be a string, string array or an object array.
This is to support sorting based on 1 or many columns and in different
direction.

To sort ArcGIS Online items in alphabetical order, but, with similar
named items we can used the modified to rank further.

```qml
SortListModel {
    id: items
    sortRole: [ "title", "modified" ]
    sortOrder: Qt.AscendingOrder
}
```        

If you want the ArcGIS Online items sorted in alphabetical order
but with the modified date in reverse order.

```qml
SortListModel {
    id: items
    sortRole: { [ { "sortRole": "title",
                    "sortOrder": Qt.AscendingOrder },
                  { "sortRole": "modified",
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

    git submodule add https://github.com/stephenquan/qt5-qml-sortlistmodel.git qt5-qml-sortmodel
    git submodule update
