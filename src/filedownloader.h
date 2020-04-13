#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class FileDownloader : public QObject
{
    Q_OBJECT

public:
    explicit FileDownloader(QObject *parent = 0);

signals:
    void fileDownloaded(int errorCode, const QString& errorMessage, const QString& filename);

public slots:
    void downloadFile(const QString& url, const QString& filename);
    void downloadFileFinished(QNetworkReply *);

protected:
    QString saveFileName(const QString &filename);
    bool saveToDisk(const QString &filename, QIODevice *data);

private:
    QNetworkAccessManager* m_networkAccessManager;
    QList<QNetworkReply *> m_currentDownloads;
    QMap<QNetworkReply *, QString> m_fileNames;
};

#endif // FILEDOWNLOADER_H
