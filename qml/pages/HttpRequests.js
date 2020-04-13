/*
 * The javascript part of the program
 * This file contains functions to get data from Joomeo Internet site,
 * parse a XML string containing XML-RPC response.
 * Depending on the message, the parsing is performed here or in QML code
 *
 * to improve:
 * - management of errors
 */

var apiKey = settings.value("apiKey", "2e2b309171e176f53d696a94794e7ea7");

// Url of joomeo access point for XML interface
var apiPoint = "https://api.joomeo.com/xmlrpc.php"
var phpPoint = "https://api.joomeo.com/file.php";
var uploadPoint = "https://api.joomeo.com/upload.php"

var NETWORK_TIMEOUT = 10000;  // milliseconds

var req;

/*var spacename = "";
var username = "";
var password = "";
*/

function getFileUrl(sessionId, albumId, fileId, fileType) {
    return phpPoint+"?apikey="+apiKey+"&sessionid="+sessionId+"&albumid="+albumId+"&fileid="+fileId+"&type="+fileType+"&rotation=0"
}

function getUploadUrl(sessionId) {
    return uploadPoint+"?apikey="+apiKey+"&sessionid="+sessionId;
}

function ajax (data, resolve, reject) {

    req = new XMLHttpRequest()
    req.open('POST', apiPoint, true)
    req.onreadystatechange = function (aEvt) {
        if (req.readyState === XMLHttpRequest.DONE) {
            if(req.status === 200) {
                if(req.responseText.indexOf("<methodResponse>")>0)
                {
                    resolve(req)
                }
                else if(node.nodeName === "fault")
                {
                    var node;
                    var res = []
                    node = getFirstChildNode(req.responseXML.documentElement)
                    node = getChildNode(node, "value")
                    res = parseValue(node)
                    reject(res['faultString'])
                }
                else {
                    reject('unknown syntax')
                }
            }
            else {
                reject(req.status)
            }
        }
    };
    req.send(data)
};

// Parse the <struct> section in XmlRpc

function parseStruct(node) {
    var res={};

    // Return a sub node from its name in Xml

    for(var j=0; j<node.childNodes.length; j++) {
        if(node.childNodes[j].nodeName === "member") {
            var i=0;

            var subnode = node.childNodes[j].childNodes;

            while(i < subnode.length) {
                if(subnode[i].nodeName === "name") {
                    var name = subnode[i].childNodes[0].data;
                    i++;

                    while(i < subnode.length) {
                        if(subnode[i].nodeName === "value") {
                            res[name]=parseValue(subnode[i]);
                        }
                        i++;
                    }
                }
                i++;
            }
        }
    }

    return res;
}


function parseMember(node) {
    var i=0;

    node = node.childNodes;

    while(i < node.length) {
        if(node[i].nodeName === "name") {
            var name = node[i].childNodes[0].data;
            i++;

            while(i < node.length) {
                if(node[i].nodeName === "value") {
                    var res={};
                    res[name]=parseValue(node[i]);
                    return res;
                }
                i++;
            }
        }
        i++;
    }
    throw "Parse Error";
}


// Return a sub node from its name in Xml
function getChildNode(node, nodeName) {

    for(var i=0; i<node.childNodes.length; i++)
        if(node.childNodes[i].nodeName === nodeName)
            return node.childNodes[i];

    throw "Node <"+nodeName+"> not found";
}

// Return a sub node from its name in Xml
function getFirstChildNode(node) {
    for(var i=0; i<node.childNodes.length; i++)
        if(node.childNodes[i].nodeName !== "#text")
            return node.childNodes[i];

    return null;
}

// Parse a <value> node
function parseValue(value) {

    var type = getFirstChildNode(value);

    if (type == null)
        return "";

    switch (type.nodeName) {
    case "boolean":
        return type.childNodes[0].data === "1" ? true : false;
    case "i4":
    case "int":
        return parseInt(type.childNodes[0].data);
    case "double":
        return parseFloat(type.childNodes[0].data);
    case "#text":
        return type.data;
    case "string":
        return type.childNodes[0].data;
    case "array":
        var data = type.childNodes[0];
        var res = new Array(data.childNodes.length);;
        for (var i=0; i < data.childNodes.length; i++)
            res[i] = parseValue(data.childNodes[i]);
        return res;
    case "struct":
        return parseStruct (type);
    case "dateTime.iso8601":
        var s = type.childNodes[0].data;
        var d = new Date();
        d.setUTCFullYear(s.substr(0, 4));
        d.setUTCMonth(parseInt(s.substr(4, 2)) - 1);
        d.setUTCDate(s.substr(6, 2));
        d.setUTCHours(s.substr(9, 2));
        d.setUTCMinutes(s.substr(12, 2));
        d.setUTCSeconds(s.substr(15, 2));
        return d;
    case "base64":
        alert("base64 not supported");
    default:
        throw "parser: expected type, got <"+type.nodeName+">";
    }
}

// Parse an XmlRpc response
function parseResponse(dom) {
    var node;

    node = getChildNode(dom, "params");
    node = getChildNode(node, "param");
    node = getChildNode(node, "value");

    return parseValue(node);
}

function joomeoSessionInit(spacename, username, password, resolve, reject)
{
    ajax("<?xml version=\"1.0\"?>\n"+
         "<methodCall><methodName>joomeo.session.init</methodName>"+
         "<params><param><value><struct><member><name>apikey</name><value><string>"+apiKey+"</string></value></member>"+
         "<member><name>spacename</name><value><string>"+spacename+"</string></value></member>"+
         "<member><name>login</name><value><string>"+username+"</string></value></member>"+
         "<member><name>password</name><value><string>"+password+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject)
}

function joomeoInitContact(sessionid, contactid, resolve, reject)
{
    ajax("<?xml version=\"1.0\"?>\n"+
         "<methodCall><methodName>joomeo.session.initContact</methodName>"+
         "<params><param><value><struct><member><name>apikey</name><value><string>"+apiKey+"</string></value></member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>contactid</name><value><string>"+contactid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve, reject
         )
}

function joomeoSessionKill(sessionid, resolve, reject)
{
    ajax("<?xml version=\"1.0\"?>\n"+
         "<methodCall><methodName>joomeo.session.kill</methodName>"+
         "<params><param><value><struct><member><name>apikey</name><value><string>"+apiKey+"</string></value></member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         );
}


function joomeoGetFolderChildren(sessionid, folderid, resolve, reject)
{
    ajax("<?xml version=\"1.0\"?>\n"+
         "<methodCall><methodName>joomeo.user.getFolderChildren</methodName>"+
         "￼<params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value></member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>folderid</name><value><string>"+folderid+"</string></value></member>"+
         "<member><name>orderby</name><value><string>name</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject);
}

function joomeoGetFilesList(sessionid, albumid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.getFilesList</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>orderby</name><value><string>date</string></value></member>"+
         "<member><name>random</name><value><int>0</int></value> </member>"+
         "<member><name>maxresult</name><value><int>0</int></value></member></struct></value></param></params></methodCall>",
         resolve,
         reject
         );
}


function joomeoGetNetwork(sessionid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.getNetwork</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}


function joomeoGetFirstFileUrl(sessionid, albumid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.getFilesList</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>orderby</name><value><string>date</string></value></member>"+
         "<member><name>random</name><value><int>0</int></value> </member>"+
         "<member><name>startresult</name><value><int>0</int></value></member>"+
         "<member><name>maxresult</name><value><int>1</int></value></member></struct></value></param></params></methodCall>",
         function (req) {
             var ret;
             var node;

             try {
                 node = getChildNode(req.responseXML.documentElement, "params");
                 node = getChildNode(node, "param");
                 node = getChildNode(node, "value");
                 node = getChildNode(node, "array");
                 node = getChildNode(node, "data");
                 node = getChildNode(node, "value");

                 ret = parseValue(node);

                 // Fill source property of the image with address of image to download
                 resolve (getFileUrl(sessionId, elementAlbumId, ret['fileid'], "medium"));
             }
             catch (e) {
                 reject()
             }
         },
         reject)
}


function joomeoGetNumberOfFiles(sessionid, albumid, result, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.getNumberOfFiles</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         function resolve() {
             var ret;
             var node;

             try {



                 node = getChildNode(req.responseXML.documentElement, "params");
                 node = getChildNode(node, "param");
                 node = getChildNode(node, "value");

                 ret = parseValue(node);
                 result(ret['nbfiles']);
             }
             catch (e) {
                 result(0)
             }
         },
         reject
         )
}

function joomeoGetCommentList(sessionid, albumid, fileid)
{
    ajax( "<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.file.getCommentList</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "￼<member><name>fileid</name> <value><string>"+fileid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         function resolve () {
             xmlCommentData = req.responseText
         },
         function reject () {
             NetworkErrorDialog.open()
         }
         )
}

function joomeoAddComment(sessionid, albumid, fileid, comment, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.file.addComment</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "<member><name>fileid</name><value><string>"+fileid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>comment</name><value><string>"+comment+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoDeleteComment(sessionid, commentid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.comment.delete</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name> <value><string>"+sessionid+"</string></value></member>"+
         "<member><name>commentid</name><value><string>"+commentid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}


function joomeoAddFolder(sessionid, label, parentfolderid, resolve, reject)
{    
    if(parentfolderid.length > 0)
        ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
             "<methodName>joomeo.user.addFolder</methodName><params><param><value><struct>"+
             "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
             "￼<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
             "<member><name>label</name><value><string>"+label+"</string></value></member>"+
             "<member><name>parentfolderid</name><value><string>"+parentfolderid+"</string></value></member>"+
             "</struct></value></param></params></methodCall>",
             resolve,
             reject
             )
    else
        ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
             "<methodName>joomeo.user.addFolder</methodName><params><param><value><struct>"+
             "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
             "￼<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
             "<member><name>label</name><value><string>"+label+"</string></value></member>"+
             "</struct></value></param></params></methodCall>",
             resolve,
             reject
             )
}

function joomeoUpdateFolder(sessionid, folderid, label, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.folder.update</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>folderid</name><value><string>"+folderid+"</string></value></member>"+
         "<member><name>label</name><value><string>"+label+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoDeleteFolder(sessionid, folderid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.folder.delete</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>folderid</name><value><string>"+folderid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoAddContact(sessionid, type, email, phoneNumber, firstname, lastname, login, password, usePreferences, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.addContact</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "￼<member><name>type</name> <value><int>"+type+"</int></value></member>"+
         "<member><name>email</name><value><string>"+email+"</string></value></member>"+
         "<member><name>phoneNumber</name><value><string>"+phoneNumber+"</string></value></member>"+
         "<member><name>firstname</name><value><string>"+firstname+"</string></value></member>"+
         "<member><name>lastname</name><value><string>"+lastname+"</string></value></member>"+
         "<member><name>login</name><value><string>"+login+"</string></value></member>"+
         "<member><name>password</name><value><string>"+password+"</string></value></member>"+
         "<member><name>usePreferences</name><value><int>"+usePreferences+"</int></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoAddAlbum(sessionid, label, folderid, resolve, reject)
{
    if(folderid.length > 0)
        ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
             "<methodName>joomeo.user.addAlbum</methodName><params><param><value><struct>"+
             "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
             "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
             "<member><name>label</name><value><string>"+label+"</string></value></member>"+
             "<member><name>folderid</name><value><string>"+folderid+"</string></value></member>"+
             "</struct></value></param></params></methodCall>",
             resolve,
             reject
             )
    else
        ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
             "<methodName>joomeo.user.addAlbum</methodName><params><param><value><struct>"+
             "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
             "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
             "<member><name>label</name><value><string>"+label+"</string></value></member>"+
             "</struct></value></param></params></methodCall>",
             resolve,
             reject
             )
}

function joomeoSaveUploadedFile(sessionid, albumid, uploadid, filename, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.saveUploadedFile</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>uploadid</name><value><string>"+uploadid+"</string></value></member>"+
         "<member><name>filename</name><value><string>"+filename+"</string></value></member>"+
         "<member><name>legend</name><value><string>"+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoDeleteFile(sessionid, albumid, fileid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.deleteFile</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>fileid</name><value><string>"+fileid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoDeleteAlbum(sessionid, albumid, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.delete</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}

function joomeoUpdateAlbum(sessionid, albumid, label, resolve, reject)
{
    ajax("<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall>"+
         "<methodName>joomeo.user.album.update</methodName><params><param><value><struct>"+
         "<member><name>apikey</name><value><string>"+apiKey+"</string></value> </member>"+
         "<member><name>sessionid</name><value><string>"+sessionid+"</string></value></member>"+
         "<member><name>albumid</name><value><string>"+albumid+"</string></value></member>"+
         "<member><name>label</name><value><string>"+label+"</string></value></member>"+
         "</struct></value></param></params></methodCall>",
         resolve,
         reject
         )
}
