#
# Project gistpud, github gist
#

TARGET = harbour-gistpud

QT += dbus

CONFIG += sailfishapp

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

SECRET = $$system(cat cryptokey)
DEFINES += "SECRET=0x$${SECRET}"

message($${DEFINES})

SOURCES += src/gistpud.cpp \
	src/gists.cpp \
    src/consolereader.cpp \
    src/simplecrypt.cpp
	
HEADERS += src/gists.h \
    src/consolereader.h \
    src/simplecrypt.h

OTHER_FILES += qml/gistpud.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FrontPage.qml \
    qml/pages/AboutPage.qml \
    rpm/gistpud.spec \
    harbour-gistpud.png \
    harbour-gistpud.desktop \
    qml/components/Messagebox.qml \
    qml/pages/GistInfo.qml \
    qml/pages/LoginPage.qml \
    qml/pages/AskFilename.qml \
    qml/pages/AskGistDetails.qml \
    qml/pages/GistEditor.qml \
    qml/components/GitHub-Mark-Light-120px-plus.png
