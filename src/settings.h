#ifndef SETTINGS_H
#define SETTINGS_H

#include <QString>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT

public:
    explicit Settings(QObject *parent = 0);
    ~Settings();

    Q_INVOKABLE void setValue(const QString &key, const QVariant &value) ;
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;

private:
    QSettings *mSettings; // Owned
};

//Q_DECLARE_METATYPE(Settings*)

#endif // SETTINGS_H
