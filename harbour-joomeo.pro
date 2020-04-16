NAME = joomeo

openrepos {
    PREFIX = openrepos
    DEFINES += OPENREPOS
} else {
    PREFIX = harbour
}

# The name of your app
TARGET = $${PREFIX}-$${NAME}

# Version
VERSION = 0.2.0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

CONFIG += sailfishapp
CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/$$TARGET-fr.ts

# C++ sources
SOURCES += \
    src/joomeo.cpp \
    src/settings.cpp \
    src/imageuploader.cpp \
    src/filedownloader.cpp \
    src/simplecrypt.cpp

# C++ headers
HEADERS += \
    src/settings.h \
    src/imageuploader.h \
    src/filedownloader.h \
    src/simplecrypt.h

# Please do not modify the following line.
#include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES += \
    qml/*.qml \
    qml/pages/*.qml \
    qml/cover/*.qml \
    translations/*.ts \
    rpm/harbour-joomeo.spec \
    rpm/harbour-joomeo.yaml


RESOURCES += \
    joomeo.qrc

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

DISTFILES += \
    harbour-joomeo.desktop \
    src/Constants.js \
    qml/pages/Constants.js \
    qml/pages/HttpRequests.js
