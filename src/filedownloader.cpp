#include "filedownloader.h"

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QNetworkRequest>
#include <QString>
#include <QStandardPaths>


FileDownloader::FileDownloader(QObject *parent) : QObject(parent)
    , m_networkAccessManager(NULL)
{
    m_networkAccessManager = new QNetworkAccessManager(this);

    connect(m_networkAccessManager, SIGNAL(finished(QNetworkReply*)),
            this, SLOT(downloadFileFinished(QNetworkReply*)));
}

void FileDownloader::downloadFile(const QString& url, const QString& filename)
{
    QUrl fileUrl(url);

    if(! fileUrl.isValid()) {
        emit fileDownloaded(999, "Url invalid", url);
        return;
    }

    QNetworkRequest request(fileUrl);

    request.setRawHeader("Accept", "*/*");
    request.setRawHeader("User-Agent", "harbour-joomeo");

    QNetworkReply *networkReply = m_networkAccessManager->get(request);
    m_currentDownloads.append(networkReply);
    m_fileNames.insert(networkReply, filename);
}

QString FileDownloader::saveFileName(const QString &filename)
{
    QString returnedFileName = filename;
    QFileInfo fileInfo(filename);
    int i=1;

    while(QFileInfo(returnedFileName).exists()) {
        returnedFileName = fileInfo.filePath()+fileInfo.baseName()+i+fileInfo.suffix();
        i++;
    }

    return returnedFileName;
}

bool FileDownloader::saveToDisk(const QString &filename, QIODevice *data)
{
    QFile file(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)+"/"+filename);

    if (!file.open(QIODevice::WriteOnly)) {
        return false;
    }

    file.write(data->readAll());
    file.close();

    return true;
}

void FileDownloader::downloadFileFinished(QNetworkReply *reply)
{
    QUrl url = reply->url();

    if (reply->error()) {
        emit fileDownloaded(999, "Download failed:"+reply->errorString(),
                            url.toEncoded().constData());

        qDebug() << "Download failed:" << reply->errorString() << url.toEncoded().constData();

    } else {
        QString filename = saveFileName(m_fileNames.value(reply));

        if (saveToDisk(filename, reply))
            emit fileDownloaded(0, "Download suceeded", filename);
        else
            emit fileDownloaded(999, "Download file:impossible to open file for writing", filename);
    }

    m_fileNames.remove(reply);
    m_currentDownloads.removeAll(reply);
    reply->deleteLater();

    delete reply;
}

