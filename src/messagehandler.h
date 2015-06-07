#ifndef MESSAGEHANDLER_H
#define MESSAGEHANDLER_H

#include <QObject>
#include <QtQuick>
#include <QFileSystemWatcher>
#include <QFile>
#include <QTextStream>

class MessageHandler : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool enable READ enable WRITE setEnable NOTIFY enableChanged)

public:
    enum ItemRole
    {
        MessageRole = Qt::UserRole +1
    };

    MessageHandler();
    ~MessageHandler();

    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    bool enable() { return _enable; }
    void setEnable(bool state);

    void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);

signals:
    void enableChanged();

private slots:
    void logfileUpdated(QString filename);

private:
    bool _enable;
    QStringList _messages;
    QFileSystemWatcher *_logfileWatcher;
};

#endif // MESSAGEHANDLER_H
