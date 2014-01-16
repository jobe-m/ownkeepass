/*****************************************************************
*  Copyright (C) 2012  Marco Bavagnoli - lil.deimos@gmail.com    *
******************************************************************/

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QDir>
#include <QList>
#include <QDateTime>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QString filePath, QObject *parent = 0);

    void setFilePath(const QString &);
    QString filePath() const;

    Q_INVOKABLE void setValue(const QString & key, const QVariant & value);
    Q_INVOKABLE QVariant getValue(const QString & key, const QVariant & defaultValue = QVariant()) const;

    Q_INVOKABLE void removeArray( const QString & key);
    Q_INVOKABLE void removeArrayEntry( const QString & key , int index);
    Q_INVOKABLE void appendToArray( const QString & key, QMap<QString, QVariant> values);
    Q_INVOKABLE QList< QVariantMap > getArray( const QString & key);
    Q_INVOKABLE QString getArrayJson( const QString & key);
    Q_INVOKABLE QString getArrayXml( const QString & key);
    Q_INVOKABLE bool checkValueArray( const QString & key, const QString & arrayKey , const QString & value);
    Q_INVOKABLE int getIndexOfValueInArray( const QString & key, const QString & arrayKey , const QString & value );

    // Time functions
    Q_INVOKABLE int getTimeZone();
    Q_INVOKABLE QDateTime stringToDate(QString s);


private:
    QString m_confFile;

signals:
    
public slots:
};

#endif
