#include "consolereader.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>

consolereader::consolereader(QString readFileName, QString filename, QObject *parent) :
    QObject(parent), running(true), _filename(filename)
{
    int f = STDIN_FILENO;
    if (!readFileName.isEmpty())
    {
        f = open(readFileName.toLocal8Bit().constData(),  O_RDONLY);
        if (f < 0)
        {
            printf("Error: Can not open %s\n", qPrintable(readFileName));
            running = false;
            return;
        }
    }

    char ch;
    while(read(f, &ch, 1) > 0)
    {
        _buffer.append(ch);
    }
    // loop exits on ctrl-D, EOF

    printf("Please wait...\n");

    if (f < 1)
        close(f);

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
    printf("Success, URL:\n%s\n", qPrintable(gists->gistHtmlUrl()));

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
