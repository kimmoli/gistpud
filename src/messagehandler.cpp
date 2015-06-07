#include "messagehandler.h"

MessageHandler::MessageHandler() :
    _enable(false)

{
    printf("MessageHandler started\n");
    QFile f("/tmp/harbour-gistpud-log");
    if (f.exists())
        f.remove();
}

MessageHandler::~MessageHandler()
{
    setEnable(false);
}

void MessageHandler::setEnable(bool state)
{
    if (state == _enable)
        return;

    _enable = state;

    _messages.clear();

    if (_enable)
    {
        printf("enabling logging\n");
        QFile f("/tmp/harbour-gistpud-log");
        f.open(QIODevice::WriteOnly | QIODevice::Truncate);
        f.close();

        _logfileWatcher = new QFileSystemWatcher(QStringList() << QString("/tmp/harbour-gistpud-log"), this);
        connect(_logfileWatcher, SIGNAL(fileChanged(QString)), this, SLOT(logfileUpdated(QString)));
    }
    else
    {
        _logfileWatcher->disconnect();
        delete _logfileWatcher;
        _logfileWatcher = 0;

        QFile f("/tmp/harbour-gistpud-log");
        f.remove();
    }

    emit enableChanged();
}

void MessageHandler::logfileUpdated(QString filename)
{
    beginResetModel();

    QFile f(filename);
    f.open(QIODevice::ReadOnly);
    QTextStream ts(&f);

    _messages.clear();

    while (!ts.atEnd())
        _messages.append(ts.readLine());

    f.close();

    endResetModel();
}

QHash<int, QByteArray> MessageHandler::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MessageRole] = "message";
    return roles;
}

int MessageHandler::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return _messages.size();
}

QVariant MessageHandler::data(const QModelIndex& index, int role) const
{
    const QString& msg = _messages[index.row()];
    switch (role)
    {
    case MessageRole:
        return msg;
    default:
        return QVariant();
    }
}

