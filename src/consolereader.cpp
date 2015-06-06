#include "consolereader.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>
#include <QMimeDatabase>
#include <QMimeType>

consolereader::consolereader(QString readFileName, QString filename, QObject *parent) :
    QObject(parent), running(true), _filename(filename)
{
    QString mimeType = "text/plain";

    if (!readFileName.isEmpty())
    {
        QMimeDatabase db;
        QMimeType mt = db.mimeTypeForFile(readFileName);
        mimeType = mt.name();

        QFile f(readFileName);
        if (!f.open(QIODevice::ReadOnly))
        {
            printf("Error: Can not open %s\n", qPrintable(readFileName));
            running = false;
            return;
        }
        _buffer = f.readAll();
        f.close();
    }
    else
    {
        char ch;
        while(read(STDIN_FILENO, &ch, 1) > 0)
        {
            _buffer.append(ch);
        }
        // loop exits on ctrl-D, EOF
    }

    gists = new Gists();

    connect(gists, SIGNAL(error()), this, SLOT(error()));
    connect(gists, SIGNAL(success()), this, SLOT(success()));

    QJsonObject jsonvar;
    QJsonObject jsonvarfiles;
    QJsonObject jsonvarcontent;

    jsonvar["description"] = QString("Pasted from Jolla");
    jsonvar["public"] = bool(true);
    jsonvarcontent["content"] = QString(_buffer);
    jsonvarcontent["type"] = QString(mimeType);
    jsonvarfiles[_filename] = QJsonObject(jsonvarcontent);
    jsonvar["files"] = QJsonObject(jsonvarfiles);

    QJsonDocument json(jsonvar);

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
