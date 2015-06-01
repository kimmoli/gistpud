#ifndef CONSOLEREADER_H
#define CONSOLEREADER_H

#include <QObject>
#include "gists.h"

class consolereader : public QObject
{
    Q_OBJECT
public:
    explicit consolereader(QString title = "Pasted from Jolla", QString expire = "1M", QObject *parent = 0);
    ~consolereader();

    bool running;

signals:
    void quit();

public slots:
    void success();
    void error();

public:
    QString _title;
    QString _expire;
    QString _buffer;

};

#endif // CONSOLEREADER_H
