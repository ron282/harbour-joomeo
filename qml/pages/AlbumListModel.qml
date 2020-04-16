import QtQuick.XmlListModel 2.0

XmlListModel {
    id: xmlFilesModel

    query: "/methodResponse/params/param/value/array/data/value/struct"

    XmlRole { name: "fileId"; query: "member[name='fileid']/value/string/string()"; isKey: true }
    XmlRole { name: "fileName"; query: "member[name='filename']/value/string/string()" }
    XmlRole { name: "fileRotation"; query: "member[name='rotation']/value/int/number()" }
    XmlRole { name: "rating"; query: "member[name='rating']/value/int/number()" }
    XmlRole { name: "joomeo_type"; query: "member[name='joomeo_type']/value/string/string()" }
    XmlRole { name: "size"; query: "member[name='size']/value/int/number()" }
    XmlRole { name: "width"; query: "member[name='width']/value/int/number()" }
    XmlRole { name: "height"; query: "member[name='height']/value/int/number()" }
    XmlRole { name: "mimeType"; query: "member[name='type_mime']/value/string/string()" }
    XmlRole { name: "dateShooting"; query: "member[name='date_shooting']/value/double/string()" }
    XmlRole { name: "dateCreation"; query: "member[name='date_creation']/value/double/string()" }
    XmlRole { name: "allowDownload"; query: "member[name='allowdownload']/value/int/number()" }
    XmlRole { name: "allowsEndComments"; query: "member[name='allowsendcomments']/value/int/number()" }
    XmlRole { name: "legend"; query: "member[name='legend']/value/string/string()" }
    XmlRole { name: "nbComments"; query: "member[name='nbComments']/value/int/number()" }
    XmlRole { name: "albumId"; query: "member[name='albumid']/value/string/string()" }

}
