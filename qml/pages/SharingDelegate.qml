import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQml.Models 2.2
import QtQuick.XmlListModel 2.0

import "HttpRequests.js" as HttpRequests



DelegateModel {

    id: visualModel
    property var accessList
    property string sessionId
    property string albumId
    property bool allowUpload : false
    property int it : 0



    function setUpload(u)
    {
       allowUpload = u
       it = 0
       changeSelectedAccessRights(allowUpload)
    }

    function hasAccess(contactid)
    {
        for(var i=0; i<accessList.count; i++) {
            var item = accessList.get(i)
           if(contactid === item.contactId) {
               allowUpload |= item.allowUpload
               return true
           }
        }
        return false
    }

    function unselectAll () {
        if( selectedItems.count > 0) {
            var item = selectedItems.get(0)

            HttpRequests.joomeoRemoveContactAccess(sessionId, albumId, item.model.contactId,
                 function () {
                     var item = selectedItems.get(0)
                     item.inSelected = false
                     unselectAll()
                 },
                 function () {
                     console.log("error joomeoRemoveContactAccess")
                     visualModel.sort()
                 })
        } else
        {
            visualModel.sort()
        }
    }

    function changeSelectedAccessRights (u) {
        if( it <selectedItems.count ) {
            allowUpload = u
            HttpRequests.joomeoAllowContactAccess(sessionId, albumId, selectedItems.get(it).model.contactId, u ? 1 : 0,
                 function (req) {
                    it++
                    changeSelectedAccessRights(allowUpload)
                 },
                 function () {
                     console.log("error joomeoAllowContactAccess")
                     it++
                     changeSelectedAccessRights(allowUpload)
                 })
        }
   }

    function lessThan(left, right) {
        if(left.inSelected !== right.inSelected)
            return left.inSelected;
        else if (left.model.contactFirstName !== right.model.contactFirstName)
            return left.model.contactFirstName < right.model.contactFirstName;
        else
            return left.model.contactLastName < right.model.contactLastName;
    }

    function insertPosition(lessThan, item) {
        var lower = 0
        var upper = items.count
        while (lower < upper) {
            var middle = Math.floor(lower + (upper - lower) / 2)
            var result = lessThan(item, items.get(middle));
            if (result) {
                upper = middle
            } else {
                lower = middle + 1
            }
        }
        return lower
    }

    function sort() {
        if(items.count > 0)
            items.remove(0, items.count)

        for (var i=0; i<unsortedItems.count; i++) {
            var item = unsortedItems.get(i)
            var index = insertPosition(lessThan, item)

            if(item.inSelected)
               item.groups = ["unsorted", "selected", "items"]
            else
               item.groups = ["unsorted", "items"]

            if(item.itemsIndex !== index)
                items.move(item.itemsIndex, index)
        }
    }

    items.includeByDefault: false

    groups: [ DelegateModelGroup {
            id: unsortedItems
            name: "unsorted"
            includeByDefault: true
        },
        DelegateModelGroup {
            id: selectedItems
            name: "selected"
            includeByDefault: false
        }
    ]

    model: ContactListModel {
        id: contactList

        onStatusChanged: if(status == XmlListModel.Ready) {
                             if(selectedItems.count > 0)
                                 selectedItems.remove(0, selectedItems.count)

                             allowUpload = false

                             for(var i=0; i<unsortedItems.count; i++) {
                                 var item = unsortedItems.get(i)

                                 if(hasAccess(item.model.contactId))
                                     item.groups = ["unsorted", "selected"]
                             }

                             visualModel.sort()
                         }
    }

    delegate: ListItem {
        id: contactDelegate
        contentHeight: Theme.itemSizeMedium
        anchors { left: parent.left; right: parent.right; rightMargin: Theme.horizontalPageMargin }

        TextSwitch {
            id: textSwitch
            text: contactFirstName + " " + contactLastName
            checked: contactDelegate.DelegateModel.inSelected
            description: contactEmail
            automaticCheck: false
            onClicked: {
                if( ! checked ) {
                    HttpRequests.joomeoAllowContactAccess(sessionId, albumId, contactId,
                                                          allowUpload ? 1 : 0,
                         function () {
                            contactDelegate.DelegateModel.inSelected = true
                            visualModel.sort()
                         },
                         function () {
                             console.log("error")
                         })


                } else
                {
                    HttpRequests.joomeoRemoveContactAccess(sessionId, albumId, contactId,
                         function () {
                             contactDelegate.DelegateModel.inSelected = false
                             visualModel.sort()
                         },
                         function () {
                             console.log("error")
                         })
                }
            }
        }
    }

    Component.onCompleted: {
        HttpRequests.joomeoGetContactList(sessionId,
                                          function (req){
                                              contactList.xml = req.responseText
                                          },
                                          function () {
                                              // error
                                          })
    }
}

