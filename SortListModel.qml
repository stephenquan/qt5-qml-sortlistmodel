import QtQuick 2.13

ListModel {
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

    function incrementalSort(compareFunc) {
        sortItems(count - 1, count, compareFunc);
    }

    function sort(compareFunc) {
        sortItems(0, count, compareFunc);
    }
}
