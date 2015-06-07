#include "filemodel.h"

FileModel::FileModel() :
    m_dir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation),
          QString(),
          QDir::Name |
          QDir::DirsFirst |
          QDir::IgnoreCase |
          QDir::LocaleAware,
          QDir::AllDirs |
          QDir::Files |
          QDir::NoDot)
{
    load();
}

FileModel::~FileModel()
{
}

void FileModel::load()
{
    m_files = m_dir.entryInfoList();
}

void FileModel::reset_start()
{
    beginResetModel();
}

void FileModel::reset_end()
{
    load();
    endResetModel();
}

QHash<int, QByteArray> FileModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[IsDirRole] = "isDir";
    roles[SizeRole] = "size";
    roles[TimeRole] = "time";
    return roles;
}

int FileModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return m_files.size();
}

QVariant FileModel::data(const QModelIndex& index, int role) const
{
    const QFileInfo& info = m_files[index.row()];
    switch (role)
    {
    case NameRole:
        return info.fileName();
    case PathRole:
        return info.filePath();
    case IsDirRole:
        return info.isDir();
    case SizeRole:
        return toHumanReadable(info.size());
    case TimeRole:
        return info.lastModified().toString(Qt::DefaultLocaleShortDate);
    default:
        return QVariant();
    }
}

QString FileModel::getPath()
{
    return m_dir.path();
}

void FileModel::setPath(const QString& path)
{
    reset_start();
    m_dir.setPath(path);
    reset_end();
    emit pathChanged();
}

void FileModel::cd(const QString& path)
{
    reset_start();
    m_dir.cd(path);
    reset_end();
    emit pathChanged();
}

QString FileModel::filePath(const QString& name) const
{
    return m_dir.filePath(name);
}

QString FileModel::toHumanReadable(qint64 size) const
{
    if (size < 1024)
    {
        return QString::number(size) + " bytes";
    }
    double sz = size / 1024.0;
    if (sz < 1024.0)
    {
        return QString::number(sz, 'f', 1) + " KiB";
    }
    sz /= 1024.0;
    if (sz < 1024.0)
    {
        return QString::number(sz, 'f', 1) + " MiB";
    }
    sz /= 1024.0;
    return QString::number(sz, 'g', 1) + " GiB";
}
