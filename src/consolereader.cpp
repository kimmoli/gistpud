#include "consolereader.h"
#include <unistd.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>

consolereader::consolereader(QString filename, QObject *parent) :
    QObject(parent), running(true), _filename(filename)
{
    char ch;
    while(read(STDIN_FILENO, &ch, 1) > 0)
    {
        _buffer.append(ch);
    }
    // loop exits on ctrl-D, EOF

    printf("Please wait...\n");

    gists = new Gists();

    connect(gists, SIGNAL(error()), this, SLOT(error()));
    connect(gists, SIGNAL(success()), this, SLOT(success()));

    QJsonObject jsonvar;
    QJsonObject jsonvarfiles;
    QJsonObject jsonvarcontent;

    jsonvar["description"] = QString("Pasted from Jolla");
    jsonvar["public"] = bool(true);
    jsonvarcontent["content"] = QString(_buffer);
    jsonvarfiles[_filename] = QJsonObject(jsonvarcontent);
    jsonvar["files"] = QJsonObject(jsonvarfiles);

    QJsonDocument json(jsonvar);

    // printf("%s\n", qPrintable(QString(json.toJson())));
    gists->postGist(QString(json.toJson()));
}

void consolereader::error()
{
    printf("Error: %s\n", qPrintable(gists->getError()));
    emit quit();
}

void consolereader::success()
{
    printf("Success\n");

    QDBusMessage m = QDBusMessage::createMethodCall("com.kimmoli.gistpud",
                                                    "/",
                                                    "",
                                                    "fetchGists" );

    QDBusConnection::sessionBus().send(m);

    emit quit();
}

consolereader::~consolereader()
{
}
