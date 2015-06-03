/*
    kladi, Pastebin application
*/

#ifndef GISTS_H
#define GISTS_H
#include <QObject>
#include <QDebug>
#include <QSettings>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QUrlQuery>
#include <QtDBus/QtDBus>

#define SERVICE_NAME "com.kimmoli.gistpud"

#define GH_ZEN "/zen"
#define GH_USERS "/users"
#define GH_GISTS "/gists"

class Gists : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", SERVICE_NAME)

    Q_PROPERTY(QString zen READ zen NOTIFY zenChanged)
    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY loggedInChanged)
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)

public:
    explicit Gists(QObject *parent = 0);
    ~Gists();

    Q_INVOKABLE QVariant getSetting(QString name, QVariant defaultValue);
    Q_INVOKABLE void setSetting(QString name, QVariant value);

    Q_INVOKABLE void loginBasic(QString username, QString password);
    Q_INVOKABLE void loginToken(QString username, QString token);

    Q_INVOKABLE void fetchZen();
    Q_INVOKABLE void fetchGists();
    Q_INVOKABLE void postGist(QString json);
    Q_INVOKABLE void updateGist(QString id, QString json);

    Q_INVOKABLE bool fileExists(QString filename);
    Q_INVOKABLE bool save(QString filename, QString data);

    Q_INVOKABLE void registerToDBus();


    QString zen() { return _zen; }
    bool loggedIn() { return _username.length() > 0; }
    QString username() { return _username; }
    QString gistHtmlUrl() { return _gistHtmlUrl; }

    Q_INVOKABLE QString getGists() { return _gistsList; }
    Q_INVOKABLE QString getError() { return _error; }

    QString parseHtmlUrl(QString jsonReply);

signals:
    void zenChanged();
    void loggedInChanged();
    void usernameChanged();
    void gistsChanged();
    void error();
    void success();

private slots:
    void finished(QNetworkReply *reply);
    void errorReply(QNetworkReply::NetworkError networkError);

private:
    QNetworkAccessManager *_manager;

    QString _apiUrl;
    QString _username;
    QString _password;
    QString _token;
    bool _basicAuth;

    QString _zen;
    QString _gistsList;
    QString _gistHtmlUrl;

    QString _error;

};


#endif // GISTS_H

