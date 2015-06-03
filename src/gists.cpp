/*
    kladi, Pastebin application
*/

#include "gists.h"
#include <QtQml>
#include "simplecrypt.h"

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
    SimpleCrypt crypto((unsigned long long)(SECRET));
    QSettings s("/home/nemo/.config/harbour-gistpud/harbour-gistpud.conf", QSettings::NativeFormat);
    s.beginGroup("Settings");
    QVariant settingValue = QVariant(crypto.decryptToString(s.value(name, defaultValue).toString()));
    s.endGroup();

    return settingValue;
}

void Gists::setSetting(QString name, QVariant value)
{
    SimpleCrypt crypto((unsigned long long)(SECRET));
    QSettings s("harbour-gistpud", "harbour-gistpud");
    s.beginGroup("Settings");
    s.setValue(name, crypto.encryptToString(value.toString()));
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

void Gists::postGist(QString json)
{
    QUrl url(_apiUrl + GH_GISTS);

    QNetworkRequest req(url);

    QByteArray postData = json.toLocal8Bit();

    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(postData.size()));

    QString concatenated = _username + ":" + (_basicAuth ? _password : _token);
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    req.setRawHeader("Authorization", headerData.toLocal8Bit());

    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    QNetworkReply *reply = _manager->post(req, postData);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}

void Gists::updateGist(QString id, QString json)
{
    QUrl url(_apiUrl + GH_GISTS + "/" + id);

    QNetworkRequest req(url);

    QByteArray postData = json.toLocal8Bit();

    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    req.setHeader(QNetworkRequest::ContentLengthHeader, QString::number(postData.size()));

    QString concatenated = _username + ":" + (_basicAuth ? _password : _token);
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    req.setRawHeader("Authorization", headerData.toLocal8Bit());

    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    QNetworkReply *reply = _manager->post(req, postData);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(errorReply(QNetworkReply::NetworkError)));
}


/*****************/

void Gists::finished(QNetworkReply *reply)
{
    QString referringUrl(reply->request().url().toString());
    QString rAll(reply->readAll());
    reply->deleteLater();

    if (referringUrl.endsWith(GH_ZEN))
    {
        qDebug() << "zen:" << rAll;
        _zen = rAll;
        emit zenChanged();
    }
    else if (referringUrl.endsWith(_username + GH_GISTS))
    {
        qDebug() << "reply to fetchGists()";
        _gistsList = rAll;
        emit gistsChanged();
    }
    else if (referringUrl.endsWith(GH_GISTS))
    {
        qDebug() << "reply to postGist()";
        _gistHtmlUrl = parseHtmlUrl(rAll);
        if (_gistHtmlUrl.isEmpty())
        {
            emit error();
        }
        else
        {
            emit success();
        }
    }
    else if (referringUrl.contains(QString(GH_GISTS) + QString("/")))
    {
        qDebug() << "reply to updateGist()";
        emit success();
    }
    else
    {
        qDebug() << referringUrl << ">>" << rAll;
    }
}

void Gists::errorReply(QNetworkReply::NetworkError networkError)
{
    _error = ((QNetworkReply *)sender())->errorString();
    qCritical() << networkError << _error;

    emit error();
}

/******************************/

QString Gists::parseHtmlUrl(QString jsonReply)
{
    QJsonParseError jerror;

    QJsonDocument jdoc = QJsonDocument::fromJson(jsonReply.toUtf8(), &jerror);

    if(jerror.error != QJsonParseError::NoError)
    {
        _error = jerror.errorString();
        printf("Json parse error %s\n", qPrintable(_error));
        return QString();
    }

    QJsonObject jobj = jdoc.object();

    return jobj["html_url"].toString();
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
