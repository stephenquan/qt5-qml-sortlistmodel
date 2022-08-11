# qt5-qml-sortlistmodel
Implements SortListModel QML component.

It extends the ListModel QML component with the following methods:

 - findInsertIndex(item, head, tail, compareFunc)
 - sortItems(head, tail, compareFunc)
 - incrementalSort(compareFunc)
 - sort(compareFunc)

These methods help us implement an in-place sort.

It requires the record to already be in the ListModel, typically at the
end with `append` and moved to the correct place with `incrementalSort`.

For example:

```qml
SortListModel {
    id: cities
    property var orderByCity: (a, b) => a.city.localeCompare(b.city)
    property var compare: orderByCity
}

Button {
    text: qsTr("Add Melbourne")
    onClicked: {
        cities.append( { "city": "Melbourne" } );
        cities.incrementalSort( cities.compare );
    }
}
```

When used with `Qt.callLater`, we can get interesting UI friendly resorting
of large lists. We can keep track of where the list was sorted, and use
`sortItems` to continue sorting records from that point onwards.

```qml
SortListModel {
    id: cities
    property var orderByCity: (a, b) => a.city.localeCompare(b.city)
    property var orderByCityDescending: (a, b) => -a.city.localeCompare(b.city)
    property var compare: orderByCity
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

Button {
    text: qsTr("Sort by City")
    onClicked: {
        cities.compare = cities.orderByCity;
        cities.sortAll();
     }
}

Button {
    text: qsTr("Sort by City Descending")
    onClicked: {
        cities.compare = cities.orderByCityDescending;
        cities.sortAll();
    }
}
```

For completeness a `sort` method is provide which performs a full sort,
but, for very large list this could have unintended consequences of
blocking the UI.

To use SortListModel QML component in your project consider cloning this
repo directly in your project:

    git clone https://github.com/stephenquan/qt5-qml-sortlistmodel.git
    
or adding it as a submodule:

    git submodule add https://github.com/stephenquan/qt5-qml-sortlistmodel.git qt5-qml-sortmodel
    git submodule update
