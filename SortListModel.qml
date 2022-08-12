import QtQuick 2.13

ListModel {
    property int sortOrder: Qt.AscendingOrder
    property var sortRole: ""
    property var sortCompare: null
    readonly property int sortCount: internal.sortCount
    readonly property bool sorted: internal.sortCount >= count
    readonly property bool sorting: !sorted

    property QtObject internal: QtObject {
        property int sortCount: 0
        property var sortOps: [ ]
    }

    onCountChanged: {
        if (count < internal.sortCount) {
            internal.sortCount = count;
            return;
        }

        if (internal.sortCount < count) {
            Qt.callLater(sortMore);
        }
    }

    onSortOrderChanged: Qt.callLater(resort)
    onSortRoleChanged: Qt.callLater(resort)

    function resort() {
        internal.sortCount = 0;
        compileSortRole();
        Qt.callLater(sortMore);
    }

    function compileSortRole() {
        internal.sortOps = [ ];
        if (typeof(sortRole) === 'string') {
            if (sortRole) {
                internal.sortOps.push( {
                        sortRole: sortRole,
                        sortOrder: sortOrder
                     } );

                return;
            }
        }

        if (!sortRole.length) {
            console.warn("sortRole needs to be a string or an array");
            return;
        }

        for (let op of sortRole ) {
            let _sortRole = op.sortRole;
            if (!_sortRole) {
                continue;
            }

            let _op = {
                sortRole: _sortRole
            };
            if ("sortOrder" in op) {
                _op.sortOrder = op.sortOrder;
            }
            internal.sortOps.push( _op );
        }
    }

    function sortMore() {
        if (internal.sortCount >= count)  return;

        for (let ts = Date.now(); Date.now() < ts + 50; ) {
            sortItems(internal.sortCount, internal.sortCount + 1, sortCompare || defaultCompare);
            internal.sortCount++;
            if (internal.sortCount >= count) return;
        }

        if (internal.sortCount < count) {
            Qt.callLater(sortMore);
        }
    }

    function defaultCompare(a, b) {
        let cmp = 0;
        for (let sortOp of internal.sortOps) {
            let sortRole = sortOp.sortRole;
            let aval = a[sortRole];
            let bval = b[sortRole];
            if (typeof(aval) === 'string' && typeof(bval) === 'string') {
                cmp = aval.localeCompare(bval);
            } else {
                cmp = aval - bval;
            }
            if (cmp) {
                let sign = sortOp.sortOrder === Qt.DescendingOrder ? -1 : 1;
                return sign * cmp;
            }
        }
        return 0;
    }

    function findInsertIndex(item, head, tail, compareFunc) {
        if (head >= count) {
            return head;
        }

        let cmp = compareFunc(item, get(head));
        if (cmp <= 0) {
            return head;
        }

        cmp = compareFunc(item, get(tail));
        if (cmp === 0) {
            return tail;
        }
        if (cmp > 0) {
            return tail + 1;
        }

        while (head + 1 < tail) {
            let mid = (head + tail) >> 1;
            cmp = compareFunc(item, get(mid));
            if (cmp === 0) {
                return mid;
            }

            if (cmp > 0) {
                head = mid;
            } else {
                tail = mid;
            }
        }

        return tail;
    }

    function sortItems(head, tail, compareFunc) {
       while (head < tail) {
           if (head === 0) {
               head++;
               continue;
           }

           let index = findInsertIndex(get(head), 0, head - 1, compareFunc);
           if (head === index) {
               head++;
               continue;
           }

           move(head, index, 1);
           head++;
       }
    }
}
