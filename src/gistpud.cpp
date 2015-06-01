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

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        if (QString(argv[1]) == "-")
        {
            QCoreApplication* capp;
            capp = new QCoreApplication(argc, argv);
            QString title("Gist from Jolla");

            if (argc > 2)
                title = QString(argv[2]);

            consolereader *c = new consolereader(title);

            capp->connect(c, SIGNAL(quit()), capp, SLOT(quit()));

            if (c->running)
                return capp->exec();
        }
        return 0;
    }

    printf("GistPud version %s (C) kimmoli 2015\n\n", APPVERSION);
    printf("To use this from console, login through GUI, and start\n");
    printf("  harbour-gistpud - {title}\n");
    printf("to create a Gist from stdin.\n\n");

    qmlRegisterType<Gists>("harbour.gistpud.Gists", 1, 0, "Gists");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/gistpud.qml"));
    view->show();

    app->setApplicationVersion(APPVERSION);

    return app->exec();
}

