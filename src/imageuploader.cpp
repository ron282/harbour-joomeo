#include "imageuploader.h"

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QNetworkRequest>
#include <QString>


ImageUploader::ImageUploader(QObject* parent)
    : QObject (parent)
    , m_networkAccessManager(NULL)
    , m_networkReply (NULL)
{
    m_networkAccessManager = new QNetworkAccessManager(this);
}

void ImageUploader::uploadImage(const QString& url, const QString& imageFilename)
{
    QString fileName = imageFilename;
    fileName = fileName.remove(QString("file://"));
    QFileInfo fileInfo(fileName);
    QFile* file = new QFile(fileName);
    if (!file->open(QIODevice::ReadOnly)) {
        emit imageUploaded(999, "Image not found", "", "");
        return;
    }

    emit imageUploaded(-1, "Try to upload image to server, please wait...", "", "");

    QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;

    m_fileName = fileInfo.fileName();

    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("form-data"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                        QVariant(QString("form-data; name=\"Filedata\"; filename=\"%1\"").arg(fileInfo.fileName()).toLatin1()));

    imagePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(imagePart);

    QNetworkRequest request(url);
    m_networkReply = m_networkAccessManager->post(request, multiPart);
    multiPart->setParent(m_networkReply);

    connect(m_networkReply, SIGNAL(finished()), this, SLOT(uploadImageFinished()));
}

void ImageUploader::uploadImageFinished()
{
    QString xmlReply = QString(m_networkReply->readAll());
    QString uploadId;

    delete m_networkReply;
    uploadId = xmlReply.remove("<uploadid>").remove("</uploadid>");

    // here, you can parse the reply from the server...
    emit imageUploaded(0, "Image successfully uploaded", uploadId, m_fileName);
}

