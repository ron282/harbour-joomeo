#include <QtCore/QtGlobal>

#include <QGuiApplication>
#include <QQuickView>
#include <QTranslator>
#include <QQmlContext>

#include "imageuploader.h"
#include "filedownloader.h"

#include <sailfishapp.h>
#include "settings.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    Settings* settings = new Settings(app.data());
    ImageUploader imageUploader;
    FileDownloader fileDownloader;

    QString locale = QLocale::system().name();
    QTranslator translator;

    // Fall back to using English (burried strings), if the current
    // setting of the device is not available.
    translator.load("tr_"+locale, ":/");
    qDebug() << locale ;
    app->installTranslator(&translator);

    // Expose the application version to QML
    app->setApplicationVersion(APP_VERSION);
    view->rootContext()->setContextProperty("appVersion", app->applicationVersion());

    // Map Setting objects into QML
    view->rootContext()->setContextProperty("settings", settings);
    view->rootContext()->setContextProperty("imageUploader", &imageUploader);
    view->rootContext()->setContextProperty("fileDownloader", &fileDownloader);

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->show();
    
    return app->exec();
}

