#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QtQuick>

class FileModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged)

public:
    enum ItemRole {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirRole,
        SizeRole,
        TimeRole
    };

    FileModel();
    ~FileModel();

    void load();
    void reset_start();
    void reset_end();

    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;

    QString getPath();
    void setPath(const QString& path);

    Q_INVOKABLE void cd(const QString& path);
    Q_INVOKABLE QString filePath(const QString& name) const;

signals:
    void pathChanged();

private:
    QString m_path;
    QDir m_dir;
    QFileInfoList m_files;

    QString toHumanReadable(qint64 size) const;
};

#endif // FILEMODEL_H
