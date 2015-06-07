/*
    kladi, Pastebin application
*/


#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include "gists.h"
#include "consolereader.h"
#include "filemodel.h"

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        QCoreApplication* capp;
        capp = new QCoreApplication(argc, argv);
        QString readFilename;
        QString filename;

        QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));

        if (QString(argv[1]) != "-")
        {
            readFilename = QString(argv[1]);
            filename =  QString(argv[1]);
        }

        if (argc > 2 && filename.isEmpty())
            filename = QString(argv[2]);

        if (filename.isEmpty())
            filename = "unnamed";

        consolereader *c = new consolereader(readFilename, filename);

        capp->connect(c, SIGNAL(quit()), capp, SLOT(quit()));

        if (c->running)
            return capp->exec();

        return 0;
    }

    printf("GistPud version %s (C) kimmoli 2015\n\n", APPVERSION);
    printf("To use this from console, login through GUI, and start\n");
    printf("  harbour-gistpud - {gist-filename}\n");
    printf("to create a Gist from stdin.\n");
    printf("  harbour-gistpud LOCALFILE\n");
    printf("to upload local text file as a Gist.\n\n");

    qmlRegisterType<Gists>("harbour.gistpud.Gists", 1, 0, "Gists");
    qmlRegisterType<FileModel>("harbour.gistpud.FileModel", 1, 0, "FileModel");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/gistpud.qml"));
    view->show();

    app->setApplicationVersion(APPVERSION);

    return app->exec();
}

