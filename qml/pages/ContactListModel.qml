import QtQuick.XmlListModel 2.0

XmlListModel {
    query: "/methodResponse/params/param/value/array/data/value/struct"

    XmlRole { name: "contactId"; query: "member[name='contactid']/value/string/string()"; isKey:true }
    XmlRole { name: "contactType"; query: "member[name='type']/value/int/number()" }
    XmlRole { name: "contactEmail"; query: "member[name='email']/value/string/string()" }
    XmlRole { name: "contactFirstName"; query: "member[name='firstname']/value/string/string()" }
    XmlRole { name: "contactLastName"; query: "member[name='lastname']/value/string/string()" }
}
