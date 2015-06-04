#ifndef CONSOLEREADER_H
#define CONSOLEREADER_H

#include <QObject>
#include "gists.h"

class consolereader : public QObject
{
    Q_OBJECT
public:
    explicit consolereader(QString readFileName, QString filename = "unnamed", QObject *parent = 0);
    ~consolereader();

    bool running;

signals:
    void quit();

public slots:
    void success();
    void error();

public:
    QString _filename;
    QByteArray _buffer;
    Gists *gists;

};

#endif // CONSOLEREADER_H
