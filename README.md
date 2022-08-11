# qt5-qml-sortlistmodel
Implements SortListModel QML component.

It is based on the ListModel QML component but with methods for incremental sort and full sort.
It is an in-place sort, in which the ListModel has records added to it, usually with append and incrementalSort method is used to move that record to the correct place.
The algorithm for the incremental sort is based on a combination of binary search and merge sort.

```qml
SortListModel {
    id: cities
}

Button {
    text: qsTr("Add Melbourne")
    onClicked: {
        cities.append( { "city": "Melbourne" } );
        cities.incrementalSort( (a,b) => a.city.localeCompare(b.city) );
    }
}
```

When used with Qt.callLater, we can get interesting UI friendly sorting of large lists.
We can keep track of where the list was sorted, and apply sort from that point onwards.
This is useful for resetting the sort such as changing the compare function for different sort orders.

```qml
SortListModel {
    id: cities
    property var compare: (a, b) => a.city.localeCompare(b.city)
    property int sorted: 0
    function sortOne() {
        if (sorted >= count) return;
        sortItems(sorted, sorted+1, compare);
        sorted++;
        Qt.callLater(sortOne);
    }
    function sortAll() {
        sorted = 0;
        Qt.callLater(sortOne);
    }
}
```

To use SortListModel QML component in your project consider cloning this repo directly in your project:

    git clone https://github.com/stephenquan/qt5-qml-sortlistmodel.git
    
or adding it as a submodule:

    git submodule add https://github.com/stephenquan/qt5-qml-sortlistmodel.git qt5-qml-sortmodel
    git submodule update
