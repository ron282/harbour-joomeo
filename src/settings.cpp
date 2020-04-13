// This class is used to store application data in non volatile memory.
// This is a good example of a C++ object accessible from QML object

#include "settings.h"
#include "simplecrypt.h"

#include <QDebug>
#include <QLocale>
#include <QSettings>

SimpleCrypt crypto(Q_UINT64_C(0x15cafeaf7719f023));

Settings::Settings(QObject *parent)
{
     mSettings = new  QSettings( "harbour-joomeo",
                                 "harbour-joomeo",
                                 parent);

}

Settings::~Settings() {
    delete mSettings;
}


void Settings::setValue(const QString &key, const QVariant &value)
{
    if(key == QString("password")) {
        mSettings->setValue(key, crypto.encryptToString(value.toString()));
    } else {
        mSettings->setValue(key, value);
    }
}

QVariant Settings::value(const QString &key, const QVariant &defaultValue) const
{
    if(key == QString("password")) {
        QVariant encrypted;
        encrypted = mSettings->value(key, defaultValue);

        if (encrypted == defaultValue)
            return defaultValue;
        else
            return crypto.decryptToString(encrypted.toString());
    } if(key == QString("apiKey")) {
        return mSettings->value(key, "be2b209170e177f52d636a94b94e7fb5");
    }
    else {
        return mSettings->value(key, defaultValue);
    }
}
