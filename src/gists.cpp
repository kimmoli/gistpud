/*
    kladi, Pastebin application
*/

#include "gists.h"
#include <QtQml>

Gists::Gists(QObject *parent) :
    QObject(parent)
{
    _username = getSetting("username", QString()).toString();
    if (getSetting("logintype", "basic").toString() == "basic")
    {
        _basicAuth = true;
        _password = getSetting("password", "").toString();
    }
    else
    {
        _basicAuth = false;
        _token = getSetting("token", "").toString();
    }

    _apiUrl = "https://api.github.com";
    _manager = new QNetworkAccessManager(this);

    connect(_manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));
}

Gists::~Gists()
{
}

QVariant Gists::getSetting(QString name, QVariant defaultValue)
{
    QSettings s("/home/nemo/.config/harbour-gistpud/harbour-gistpud.conf", QSettings::NativeFormat);
    s.beginGroup("Settings");
    QVariant settingValue = s.value(name, defaultValue);
    s.endGroup();

    return settingValue;
}

void Gists::setSetting(QString name, QVariant value)
{
    QSettings s("harbour-gistpud", "harbour-gistpud");
    s.beginGroup("Settings");
    s.setValue(name, value);
    s.endGroup();
}

/*****************/

void Gists::loginBasic(QString username, QString password)
{
    _basicAuth = true;
    _username = username;
    _password = password;

    setSetting("username", _username);
    setSetting("password", _password);
    setSetting("logintype", "basic");

    emit usernameChanged();
    emit loggedInChanged();
}

void Gists::loginToken(QString username, QString token)
{
    _basicAuth = false;
    _username = username;
    _token = token;

    setSetting("username", _username);
    setSetting("token", _token);
    setSetting("logintype", "token");

    emit usernameChanged();
    emit loggedInChanged();
}

void Gists::fetchZen()
{
    QUrl url(_apiUrl + GH_ZEN);

    QNetworkRequest req(url);

    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    QNetworkReply *reply = _manager->get(req);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Gists::fetchGists()
{
    QUrl url(_apiUrl + GH_USERS + "/" + _username + GH_GISTS);

    QNetworkRequest req(url);

    QString concatenated = _username + ":" + (_basicAuth ? _password : _token);
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    req.setRawHeader("Authorization", headerData.toLocal8Bit());

    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    QNetworkReply *reply = _manager->get(req);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

/*****************/

void Gists::finished(QNetworkReply *reply)
{
    QString referringUrl(reply->request().url().toString());
    QString rAll(reply->readAll());
    reply->deleteLater();

    qDebug() << referringUrl << ">>" << rAll;

    if (referringUrl.endsWith(GH_ZEN))
    {
        _zen = rAll;
        emit zenChanged();
    }
    if (referringUrl.endsWith(GH_GISTS))
    {
        qDebug() << "reply to fetchGists";
        _gistsList = rAll;
        emit gistsChanged();
    }
}

void Gists::errorReply(QNetworkReply::NetworkError networkError)
{
    _error = ((QNetworkReply *)sender())->errorString();
    qCritical() << networkError << _error;

    emit error();
}

/******************************/

bool Gists::fileExists(QString filename)
{
    QString filepath = QString("%1/%2")
            .arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
            .arg(filename);

    QFile test(filepath);

    return test.exists();
}

bool Gists::save(QString filename, QString data)
{
    QString filepath = QString("%1/%2")
            .arg(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
            .arg(filename);

    QFile f(filepath);

    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return false;

    f.write(data.toLocal8Bit());
    f.close();

    return true;
}

void Gists::registerToDBus()
{
     QDBusConnection::sessionBus().registerService(SERVICE_NAME);
     QDBusConnection::sessionBus().registerObject("/", this, QDBusConnection::ExportAllInvokables);
}
