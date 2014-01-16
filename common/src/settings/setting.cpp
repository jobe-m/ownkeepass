/*****************************************************************
*  Copyright (C) 2012  Marco Bavagnoli - lil.deimos@gmail.com    *
******************************************************************/

#include "setting.h"

#include <QDesktopServices>
#include <QCoreApplication>
//#include <QDebug>


Settings::Settings(QString filePath, QObject *parent) : QObject(parent)
{
    // Initialize the settings path
    m_confFile = filePath;
}

QString Settings::filePath() const
{
    return m_confFile;
}

void Settings::setFilePath(const QString &data)
{
    m_confFile.clear();
    m_confFile.append(data);
}

void Settings::setValue(const QString & key, const QVariant & value)
{
    QSettings settings(m_confFile, QSettings::IniFormat);

    settings.setValue(key, value);
}

QVariant Settings::getValue( const QString & key, const QVariant & defaultValue) const
{
    QSettings settings(m_confFile, QSettings::IniFormat);

    return settings.value(key, defaultValue);
}

// first index=0
void Settings::removeArrayEntry( const QString & key , int index)
{
    QList< QVariantMap > array;
    array = getArray(key);
    array.removeAt(index);

    removeArray(key);

    foreach (QVariantMap entry, array)
        appendToArray(key, entry);
    bool b;
    b=true;
}

void Settings::removeArray( const QString & key )
{
    QSettings settings(m_confFile, QSettings::IniFormat);

    settings.remove(key);
}

void Settings::appendToArray( const QString & key, QMap<QString, QVariant> values)
{
    QSettings settings(m_confFile, QSettings::IniFormat);
    QMapIterator<QString, QVariant> i(values);

    // get the current size of this array
    int size = settings.beginReadArray(key);
    settings.endArray();

    settings.beginWriteArray(key);
    settings.setArrayIndex(size);
    while (i.hasNext()) {
         i.next();
         settings.setValue(i.key(), i.value() );
     }
     settings.endArray();
}


QString Settings::getArrayJson( const QString & key)
{
    QSettings settings(m_confFile, QSettings::IniFormat);
    QString list;

    list = "[ { ";
    int size = settings.beginReadArray(key);

     for (int i = 0; i < size; ++i) {
         settings.setArrayIndex(i);
         QVariantMap entry;
         QStringList keys;
         keys = settings.allKeys();
         foreach (QString key, keys) {
             entry.insert( key, settings.value(key) );
             list += "\""+key+"\" : \""+settings.value(key).toString()+"\", ";
         }

         list.remove( list.length()-2, 2 );
         list += "},{";
     }
     list.remove( list.length()-2, 2 );
     list += " ]";
     list = list.replace("\n","<br>").replace("\r","").replace("\t"," ");
//     qDebug() << "LIST: " << list;

     settings.endArray();
     return list;
}

QString Settings::getArrayXml( const QString & key)
{
    QSettings settings(m_confFile, QSettings::IniFormat);
    QString list;

    int size = settings.beginReadArray(key);

    list = "<xml>";
     for (int i = 0; i < size; ++i) {
         list += "<item>";
         settings.setArrayIndex(i);
         QVariantMap entry;
         QStringList keys;
         keys = settings.allKeys();
         foreach (QString key, keys) {
             entry.insert( key, settings.value(key) );
             list += "<"+key+">"+settings.value(key).toString()+"</"+key+">";
         }
         list += "</item>";
     }
     list = list.replace("\n"," ").replace("\r"," ").replace("\t"," ").replace("<br>"," ");
     list += "</xml>";
//     qDebug() << "LIST: " << list;

     settings.endArray();
     return list;
}

bool Settings::checkValueArray( const QString & key, const QString & arrayKey , const QString & value )
{
    QSettings settings(m_confFile, QSettings::IniFormat);

    int size = settings.beginReadArray(key);

     for (int i = 0; i < size; ++i) {
         settings.setArrayIndex(i);
         if ( settings.value(arrayKey).toString().compare(value) == 0 ) return true;
     }

     return false;
}

int Settings::getIndexOfValueInArray( const QString & key, const QString & arrayKey , const QString & value )
{
    QSettings settings(m_confFile, QSettings::IniFormat);

    int size = settings.beginReadArray(key);

     for (int i = 0; i < size; ++i) {
         settings.setArrayIndex(i);
         if ( settings.value(arrayKey).toString().compare(value) == 0 ) return i;
     }
     return -1;
}

QList< QVariantMap > Settings::getArray( const QString & key)
{
    QSettings settings(m_confFile, QSettings::IniFormat);
    QList< QVariantMap > list;

    int size = settings.beginReadArray(key);

     for (int i = 0; i < size; ++i) {
         settings.setArrayIndex(i);
         QVariantMap entry;
         QStringList keys;
         keys = settings.allKeys();
         foreach (QString key, keys) {
             entry.insert( key, settings.value(key) );
         }

         list.append(entry);
     }

     settings.endArray();
     return list;
}



// https://bugreports.qt-project.org/browse/QTBUG-71
int Settings::getTimeZone()
{
    // determine how far off of UTC we are
    QDateTime now = QDateTime::currentDateTime();

    // check if we need to account for UTC being tomorrow relative to us
    int dayOffset = 0;
    if( now.date() < now.toUTC().date() )
    {
        dayOffset = 24;
    }

    int timezone = now.time().hour() - ( now.toUTC().time().hour() + dayOffset );
//    qDebug() << "TIMEZONE" << timezone;
    return timezone;
}


// convert a string with format "2012-02-06T06:00:00" ( the java Date() )to QDateTime
QDateTime Settings::stringToDate(QString s)
{
    QDateTime t;

    t = QDateTime::fromString(s, "yyyy-MM-ddThh:mm:ss");

    return t;
}
