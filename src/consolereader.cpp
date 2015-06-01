#include "consolereader.h"
#include <unistd.h>
#include <QtDBus/QtDBus>
#include <QtDBus/QDBusArgument>

consolereader::consolereader(QString title, QString expire, QObject *parent) :
    QObject(parent), running(true), _title(title), _expire(expire)
{
    char ch;
    while(read(STDIN_FILENO, &ch, 1) > 0)
    {
        _buffer.append(ch);
    }
    // loop exits on ctrl-D, EOF

    printf("Please wait...\n");
}

void consolereader::error()
{
    printf("Error\n");
    emit quit();
}

void consolereader::success()
{
    printf("Success\n");

    QDBusMessage m = QDBusMessage::createMethodCall("com.kimmoli.kladi",
                                                    "/",
                                                    "",
                                                    "fetchAll" );

    QDBusConnection::sessionBus().send(m);

    emit quit();
}

consolereader::~consolereader()
{
}
