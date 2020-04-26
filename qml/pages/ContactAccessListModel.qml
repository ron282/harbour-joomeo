import QtQuick.XmlListModel 2.0

XmlListModel {
    id: xmlAllowedContactsListModel

    query: "/methodResponse/params/param/value/array/data/value/struct"

    XmlRole { name: "contactId"; query: "member[name='contactid']/value/string/string()"; isKey: true }
    XmlRole { name: "allowUpload"; query: "member[name='allowupload']/value/int/number()";  }
}
