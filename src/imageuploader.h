#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class ImageUploader : public QObject
{
    Q_OBJECT
public:
    explicit ImageUploader(QObject *parent = 0);

signals:
    void imageUploaded(int errorCode, const QString& errorMessage, const QString& uploadId, const QString& fileName);

public slots:
    void uploadImage(const QString& url,const QString& imageFilename);
    void uploadImageFinished();

private:
    QNetworkAccessManager* m_networkAccessManager;
    QNetworkReply* m_networkReply;
    QString m_fileName;

};

#endif // IMAGEUPLOADER_H



